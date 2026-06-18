# Menu page fixtures

HTML snapshots for validating Take Away menu import.

## Fetching live pages

```bash
curl -L -A "Mozilla/5.0" \
  "https://www.singhwebordring.com/ordering/restaurant/menu?company_uid=a6134fcb-3569-4faf-8b1c-36ce0bb9e21f&restaurant_uid=eb8da294-ef2a-4b31-b75f-3e5d7cbe4eac&facebook=true" \
  -o test/fixtures/menu_pages/singhwebordring.html

curl -L -A "Mozilla/5.0" \
  "https://www.kvartersmenyn.se/mobile_site/rest/16372/9" \
  -o test/fixtures/menu_pages/kvartersmenyn.html
```

Run `dart run tool/fetch_menu_fixtures.dart` to anonymize fetched HTML (optional).

Unit tests mock AI responses; live import validation requires configured AI in the app settings.
