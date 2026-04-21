# TwoThumbs — 작업 메모

> Claude와의 대화 요약, 결정 이력, 진행 중인 아이디어를 누적하는 파일.
> 새 대화에서 맥락을 이어가려면 이 파일을 참고하면 된다.
>
> **업데이트 규칙**: 사용자가 "메모 업데이트해줘"라고 요청할 때만 갱신. 자동 갱신 금지.

## 인덱스

- 2026-04-20 — 앱 컨셉 확정 (쌍따봉 평점 + 인구통계 + 할랄)
- 2026-04-20 — 앱 이름 선정 (TwoThumbs)
- 2026-04-20 — 기술 스택 결정 (Flutter + Supabase)
- 2026-04-20 — DB 스키마 핵심 설계
- 2026-04-20 — MVP 범위 확정
- 2026-04-20 — Google 로그인 방식 (Supabase OAuth)
- 2026-04-20 — 앱 아이콘 컨셉 (👍👅👍)
- 2026-04-21 — AdMob manifest 크래시 대응 (테스트 ID)
- 2026-04-21 — 실기기 첫 실행 성공

---

## 2026-04-20 — 앱 컨셉 확정 (쌍따봉 평점 + 인구통계 + 할랄)

**맥락**: 한국 관광객 대상 맛집 앱. Google 평점만으로는 국가·문화·종교별 맛집 선호도가 반영 안 됨.

**결정/결론**:
- 4단계 따봉 평점 (`2/1/-1/-2` smallint): 쌍따봉 / 따봉 / 아래따봉 / 쌍아래따봉
- 가입 시 국가·직업·성별·나이 수집 → 리뷰 시점에 DB 트리거로 **스냅샷** 저장
- "같은 국가/성별/나이대의 따봉 비율"을 상세 페이지에 노출
- 할랄 뱃지 3단계 (certified / self-reported / muslim-friendly)

**근거**:
- 아고다의 국적별 평점 시스템이 관광객 의사결정에 실제로 효과적
- 스냅샷 저장 안 하면 유저가 프로필 수정했을 때 과거 통계가 망가짐
- 할랄은 중동/동남아 관광객 핵심 니즈

**다음 행동**: n≥5 미만 샘플은 노출 안 하고 전체 평점으로 fallback하는 UI 규칙 적용 (완료).

---

## 2026-04-20 — 앱 이름 선정 (TwoThumbs)

**맥락**: 앱스토어에서 눈에 띄면서 쌍따봉 컨셉을 전달할 이름 필요.

**결정/결론**: **TwoThumbs** (9자). 서브타이틀 "Korean Food Guide"로 SEO 담당.

**근거**:
- 9자라 아이콘 라벨 안 잘림 (iOS ~12자, Android ~13자 한계)
- 쌍따봉 정체성 직접 전달
- 탈락 후보:
  - `Mukbang` — generic, 경쟁앱 "먹방 로드" 이미 존재
  - `Tabli` — Lavazza의 "Tablì" 앱과 Food 카테고리 충돌
  - `Hansik` — 외국인 발음 어려움
  - `ThumbsUp Korea` — 11자 길고 generic, "Korea" 접미사가 공공기관 톤
  - `TwoThumbs Gourmet` — 17자 라벨 잘림, Gourmet이 파인다이닝 톤 (미스매치)
- MAP 접미사 안 씀 → Naver/Kakao Maps와 카테고리 혼동, 아이콘 제약

**다음 행동**: KIPRIS·USPTO 상표 직접 확인 필요 (사용자 수행).

---

## 2026-04-20 — 기술 스택 결정 (Flutter + Supabase)

**맥락**: Talkverse와 운영 노하우 공유하면서 독립 앱으로 빌드.

**결정/결론**:
- Flutter 3.41.7 (Talkverse와 동일)
- Supabase 별도 프로젝트 (`fboqvtreaarsfhwlkrgs`, Seoul 리전)
- Google Places API (Edge Function 경유, 72h 캐시, Field Masking)
- AdMob (MVP 수익 모델)
- Riverpod + go_router
- Env 주입: `--dart-define-from-file=env.json` (compile-time const)

**근거**:
- Supabase 무료티어 2개 한도 내에서 Chinese + TwoThumbs
- Places Details $17 → Field Masking으로 $5로 절감
- dart-define-from-file은 Talkverse의 `--dart-define=APP_FLAVOR` 패턴 연장선
- Google 리뷰 텍스트는 **ToS상 영구저장 금지** → 실시간 호출·세션 내 표시만

**다음 행동**: `service_role` key는 Edge Function secrets에만 (앱 번들·env.json 금지).

---

## 2026-04-20 — DB 스키마 핵심 설계

**맥락**: 인구통계 평점 + 할랄 + 1인 1리뷰를 RLS 위에서 구현.

**결정/결론**:
- 5 테이블: `profiles` (auth.users 확장) / `restaurants` (Google 캐시) / `reviews` (unique restaurant+user) / `bookmarks` / `halal_reports`
- 2 뷰: `restaurant_stats`, `restaurant_stats_demo`
- 2 트리거: `fill_review_snapshot` (리뷰 인구 스냅샷 자동), `set_updated_at`
- RLS: profiles·bookmarks는 본인만, restaurants·reviews는 public read + 본인만 write
- 리뷰 rating CHECK: `rating in (2, 1, -1, -2)`

**근거**:
- Materialized view 대신 plain view로 시작 (트래픽 늘면 pg_cron으로 승격)
- 스냅샷 저장이 인구통계 평점의 정확성 핵심
- Supabase SQL Editor가 `$$` 달러 quoting 세미콜론 파싱 이슈로 트리거 함수 반복 실패 → 최종적으로 **표준 문자열 리터럴(`as '...'`)**로 해결

**다음 행동**: 시드 500곳 production 데이터는 Google Places Nearby Search 크롤링 후 upsert (미완).

---

## 2026-04-20 — MVP 범위 확정

**맥락**: 최소 실행 가능 제품 범위 합의.

**결정/결론**:
- **지역**: 서울 전역 (초기 시드 500곳)
- **언어**: 영어만
- **리뷰 자격**: 누구나 (위치/영수증 검증은 v2)
- **수익**: AdMob 배너 (리스트 5개마다 1개 + 상세 하단)
- **소셜 기능**: 팔로우/피드는 v2

**근거**:
- 서울 전역이면 Places 크롤링 비용 ~$50-150 (무료 크레딧 $200/월로 커버)
- 관광객 영어 무리 없음, i18n은 출시 후 반응 보고 결정
- 초기엔 리뷰량이 생명 — 진입장벽 최소화
- 출시 후 DAU 3000 미달까진 수익화 논의 무의미

---

## 2026-04-20 — Google 로그인 방식 (Supabase OAuth)

**맥락**: google_sign_in 패키지 vs Supabase의 signInWithOAuth 택일.

**결정/결론**: Supabase `signInWithOAuth(OAuthProvider.google)` 사용.

**근거**:
- 네이티브 google_sign_in은 Android SHA-1 + iOS URL scheme + Cloud OAuth Client 3개(Web/Android/iOS) 필요 — 설정 무거움
- Supabase OAuth는 Web Client 1개면 충분, 브라우저/커스텀 탭 기반
- 커스텀 scheme: `com.talkverselab.twothumbs://login-callback`
- AndroidManifest intent-filter + iOS CFBundleURLTypes로 딥링크 등록

**다음 행동**: Google Cloud OAuth Client 발급 + Supabase Providers 등록은 사용자 수행 필요 (대기 중).

---

## 2026-04-20 — 앱 아이콘 컨셉 (👍👅👍)

**맥락**: 다른 앱과 헷갈리지 않을 간단한 아이콘 필요.

**결정/결론**: 노란 배경(`#FFC107`) + `👍👅👍` 이모지 가로 배치.

**근거**:
- 쌍따봉 정체성 + 혀(맛) 의미 조합
- 단순하고 기억 쉬움
- `tools/generate_icon.html`로 Canvas에서 조정·다운로드 → `flutter_launcher_icons`로 플랫폼 사이즈 자동 생성

**다음 행동**: `assets/icon/app_icon.png` 배치 후 `dart run flutter_launcher_icons` 필요 (사용자가 현재 경로 오입력으로 미완).

---

## 2026-04-21 — AdMob manifest 크래시 대응 (테스트 ID)

**맥락**: 첫 실행 시 `MobileAdsInitProvider` 관련 FATAL EXCEPTION. 앱이 뜨기도 전에 죽음.

**결정/결론**:
- AndroidManifest에 `com.google.android.gms.ads.APPLICATION_ID` meta-data 추가
- iOS Info.plist에 `GADApplicationIdentifier` 추가
- **Google 공식 테스트 App ID** 사용:
  - Android: `ca-app-pub-3940256099942544~3347511713`
  - iOS: `ca-app-pub-3940256099942544~1458002511`

**근거**:
- `google_mobile_ads` 패키지의 ContentProvider가 앱 시작 시 자동 기동하면서 APPLICATION_ID 요구 — 코드에서 init 호출하지 않아도 반드시 manifest 필요
- AdMob 실계정 승인 대기 중 (2~7일) 테스트 ID로 개발 진행

**다음 행동**: AdMob 계정 승인되면 실 App ID로 교체.

---

## 2026-04-21 — 실기기 첫 실행 성공

**맥락**: `--dart-define-from-file=env.json` flag가 원활히 적용되지 않아 "Supabase not configured" 루프.

**결정/결론**: 원인은 `env.json`이 placeholder 값을 담고 있었던 것. 실제 anon key로 교체 후 `flutter clean` + 재빌드로 해결. 삼성 Galaxy S24 Ultra에서 LoginScreen 렌더 및 Supabase init OK 확인.

**근거**:
- `String.fromEnvironment`는 compile-time const → env.json 내용이 바뀌어도 hot reload로 반영 안 됨. 완전 재빌드 필요.
- `main()` 시작부에 `debugPrint('[twothumbs] supabaseUrl set=...')` 진단 로그 추가해 문제 지점 특정 가능해짐.
- startup 실패 시 빨간 에러 화면 (`_StartupErrorApp`)으로 표시 — splash 무한 대기 방지.

**다음 행동**: Supabase `service_role` key 재발급 (채팅 노출분 폐기) + 이메일/비번 가입 플로우 실기기 테스트.
