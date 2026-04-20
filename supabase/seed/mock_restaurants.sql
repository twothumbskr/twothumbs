-- =========================================================================
-- Mock restaurant data for UI development / smoke testing
-- =========================================================================
-- Run in Supabase SQL Editor AFTER 0001_initial.sql is applied.
-- Replace google_place_id with real Place IDs once Places API is wired up.
-- =========================================================================

insert into public.restaurants
  (google_place_id, name, address, lat, lng, phone, category,
   is_halal, halal_cert_type, google_rating, google_review_count)
values
  -- Myeongdong / classic Korean
  ('MOCK_MYEONGDONG_KYOJA',
   'Myeongdong Kyoja',
   '29 Myeongdong 10-gil, Jung-gu, Seoul',
   37.5636, 126.9850, '+82 2-776-5348',
   'korean',
   false, null,
   4.3, 8420),

  -- Gwangjang Market street food
  ('MOCK_GWANGJANG_BINDAETTEOK',
   'Gwangjang Market Bindaetteok',
   '88 Changgyeonggung-ro, Jongno-gu, Seoul',
   37.5704, 127.0031, null,
   'street-food',
   false, null,
   4.2, 3150),

  -- Itaewon Halal certified Korean BBQ
  ('MOCK_EID_HALAL_KBBQ',
   'EID Korean Halal Restaurant',
   '6 Usadan-ro 10-gil, Yongsan-gu, Seoul',
   37.5348, 126.9949, '+82 2-793-8900',
   'korean-bbq',
   true, 'certified',
   4.5, 1240),

  -- Itaewon Lebanese halal
  ('MOCK_MANAKISH_OVEN',
   'Manakish Lebanese Oven',
   '14 Usadan-ro, Yongsan-gu, Seoul',
   37.5348, 126.9953, '+82 2-790-8828',
   'middle-eastern',
   true, 'certified',
   4.4, 890),

  -- Seongsu trendy cafe/dessert
  ('MOCK_NUDAKE_SEONGSU',
   'Nudake Seongsu',
   '7 Yeonmujang 5ga-gil, Seongdong-gu, Seoul',
   37.5447, 127.0557, null,
   'cafe',
   false, null,
   4.4, 2760),

  -- Gangnam Japanese udon
  ('MOCK_MARUGAME_GANGNAM',
   'Marugame Seimen Gangnam',
   '123 Teheran-ro, Gangnam-gu, Seoul',
   37.5012, 127.0366, '+82 2-555-1111',
   'japanese',
   false, null,
   4.1, 1520),

  -- Gangnam Korean BBQ muslim-friendly
  ('MOCK_BONGA_HANWOO',
   'Bonga Hanwoo House',
   '456 Gangnam-daero, Gangnam-gu, Seoul',
   37.5020, 127.0270, '+82 2-555-2222',
   'korean-bbq',
   true, 'muslim-friendly',
   4.6, 3100),

  -- Itaewon Mexican
  ('MOCK_VATOS_ITAEWON',
   'Vatos Urban Tacos',
   '1 Itaewon-ro 15-gil, Yongsan-gu, Seoul',
   37.5342, 126.9961, '+82 2-797-8226',
   'mexican',
   false, null,
   4.3, 4320),

  -- Hongdae casual Korean
  ('MOCK_CHEONGNYEON_HONGDAE',
   'Cheongnyeon Dabang Hongdae',
   '31 Wausan-ro 21-gil, Mapo-gu, Seoul',
   37.5554, 126.9226, '+82 2-325-3333',
   'korean',
   false, null,
   4.0, 980),

  -- Gangnam high-end halal self-reported
  ('MOCK_SAMWON_GARDEN',
   'Samwon Garden',
   '835 Eonju-ro, Gangnam-gu, Seoul',
   37.5263, 127.0395, '+82 2-548-3030',
   'korean-bbq',
   true, 'self-reported',
   4.5, 5670)
on conflict (google_place_id) do nothing;

-- Verify
select name, category, is_halal, halal_cert_type, google_rating
  from public.restaurants
 order by name;
