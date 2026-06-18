# Recipe page test fixtures

Anonymized HTML snapshots from real recipe websites, used to validate code-based recipe extraction without network access in CI.

## Sources

| Fixture | Origin | Format |
|---------|--------|--------|
| `jsonld_howto` | BBC Good Food (easy chicken curry) | JSON-LD Recipe |
| `microdata_blog` | Budget Bytes (chicken noodle soup) | JSON-LD + microdata |
| `wprm_plugin` | Pinch of Yum (wild rice soup) | WP Recipe Maker + JSON-LD |
| `tasty_plugin` | Delish (honey garlic chicken) | Tasty Recipes + JSON-LD |
| `jsonld_simple` | Synthetic (AllRecipes-style) | JSON-LD Recipe |
| `jsonld_graph` | Synthetic (Serious Eats-style) | JSON-LD `@graph` + HowToSection |
| `microdata_only` | Synthetic | Microdata only |
| `hrecipe_blog` | Synthetic (101 Cookbooks-style) | h-recipe microformat |
| `mediavine_plugin` | Synthetic | Mediavine Create markup |
| `relative_image` | Synthetic | JSON-LD with relative image URL |
| `no_recipe` | Synthetic | Negative case (no recipe data) |

## Anonymization

Real-site fixtures are fetched with `tool/fetch_recipe_fixtures.dart` (or curl) and processed to:

- Replace site domains with `example-recipes.test`
- Remove email addresses
- Preserve JSON-LD structure, microdata attributes, and plugin class names

## Regenerating expected output

After changing fixtures or the extractor:

```bash
flutter test test/recipe_fixture_generator_test.dart
```

This rewrites `*.expected.json` files from the current extractor implementation.
