# TwoThumbs

Korean restaurant review app for foreign tourists. Differentiator: demographic-weighted ratings (country × occupation × gender) on top of Google Places data, with 4-tier thumbs system and halal badges.

## Stack
- Flutter 3.41.7 (Android + iOS)
- Supabase (Postgres + Auth + Edge Functions + Storage) — Seoul region
- Google Places API (restaurant data, cached)
- AdMob (monetization)
- `com.talkverselab.twothumbs` bundle ID

## Running
```bash
# First-time setup
cp env.example.json env.json
# Then fill env.json with real Supabase URL/anon key, Google Maps key, AdMob IDs

flutter pub get
flutter run --dart-define-from-file=env.json
```
VS Code: F5 uses `.vscode/launch.json` (already wired for `--dart-define-from-file=env.json`).

## Rating system (4-tier thumbs)
Enum stored as `smallint` in `reviews.rating`:
| Value | Label        | Meaning              |
|-------|--------------|----------------------|
|  `2`  | 쌍따봉       | Must visit           |
|  `1`  | 따봉         | Worth visiting       |
| `-1`  | 아래따봉     | Only if hungry       |
| `-2`  | 쌍아래따봉   | Don't go             |

## Key architectural rules

1. **Demographics snapshotted at review time** — `reviews.snap_country/occupation/gender` frozen so historic stats stay stable even if user updates profile.
2. **Min sample size for demographic stats**: n ≥ 5. Below threshold, UI falls back to global rating.
3. **Google review text is NEVER persisted** — ToS violation. Fetch live in Edge Function, display in-session only. Google `rating` and `review_count` are cacheable (72h TTL).
4. **service_role key**: Edge Functions only, never in app bundle or `env.json`. Use `supabase secrets set`.
5. **1 review per user per restaurant**: enforced by `unique(restaurant_id, user_id)`.

## Halal signal tiers
`restaurants.halal_cert_type`: `certified` / `self-reported` / `muslim-friendly` / `null`. Crowdsourced via `halal_reports` table, admin-verified before elevating from self to certified.

## Secrets & env
- `env.json` — gitignored, baked in at build via `--dart-define-from-file`
- Template: `env.example.json`
- Accessor: `lib/config/env.dart` via `String.fromEnvironment`

## Folder structure
```
lib/
  config/        env, theme, constants
  services/      supabase, places, location, ads
  models/        profile, restaurant, review (JSON-serializable)
  screens/       onboarding, home, detail, review, profile
  widgets/       thumbs_rating, halal_badge, restaurant_card
  routing/       app_router (go_router)
supabase/
  migrations/    SQL schema versioned
  functions/     Edge Functions (Deno) for Places proxy
```

## MVP scope
- Seoul entire city, ~500 seeded restaurants
- English UI only
- Anyone can review (no location/receipt verification yet)
- AdMob banners (list every 5 items, detail bottom)
