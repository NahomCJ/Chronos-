# CHRONOS MOBILE — Claude Instructions

## Project

Flutter 3.29 / Dart 3.7 fintech super-app. Entry: `lib/main.dart`. Routes: `lib/core/router/app_route.dart`.

Full platform context (backend, Panther AI, BlockHub): `../CLAUDE.md`

---

## MANDATORY: Update FEATURES.md on Every Task

**Whenever you add, modify, or remove a feature, page, route, or service — update `FEATURES.md` in the same operation.**

What triggers an update:
- New page or screen added
- Route added or changed in `route_constants.dart` or `app_route.dart`
- Feature status changes (stub → live, planned → live)
- New service or widget added to `lib/core/`
- Any design system token change (colors, typography)
- Known issue resolved or newly discovered

What to update:
- Add new rows to the correct table in `FEATURES.md`
- Change `[STUB]` → `[LIVE]` when real data is wired
- Update the "Last updated" date at the top
- Add to "Known Issues" for bugs found during the task

Do not update `FEATURES.md` for: pure refactors with no user-visible change, test files, build config.

---

## Architecture

```
lib/
├── core/router/      GoRouter — ShellRoute (bottom nav) + root-nav full-screen routes
├── core/services/    ChrisActionService, PexelsService
├── core/pages/       search_page.dart
├── core/widgets/     bottom nav bar, ChrisFAB
└── features/
    ├── auth/         splash → onboarding → sign-up/in → home
    ├── transfer/     send money (9 screens)
    ├── exchange/     currency exchange (6 screens)
    ├── wallet/       wallet + ATM
    ├── blockhub/     crypto + NFT + 5-step onboarding
    ├── panther_ai/   AI financial intelligence (10+ pages)
    ├── tickpay/      BNPL shopping platform (20+ screens)
    ├── lifex/        life coaching dashboard (12 sub-pages)
    └── profile/      settings, password, notifications
```

---

## Key Rules

### Navigation
- ShellRoute pages: **no** `parentNavigatorKey: _rootNavigatorKey` → keeps bottom nav visible
- Full-screen pages (Panther financial intelligence, Ethereum flow): **add** `parentNavigatorKey: _rootNavigatorKey`
- LifeX detail pages must NOT have `parentNavigatorKey` — they live inside the shell

### Files with box-drawing characters
`app_route.dart` has `──` characters in comments. **Use Bash `sed` to edit it, not PowerShell or the Edit tool.** Both fail due to encoding issues.

### Adding a new route
1. Add enum value to `RouteConstants` in `route_constants.dart`
2. Add case to both `toPath` and `toName` switch statements (exhaustiveness enforced at compile time)
3. Add `import` + `GoRoute` entry in `app_route.dart`
4. Update `FEATURES.md`

### Adding a new Panther financial intelligence page
- Use `parentNavigatorKey: _rootNavigatorKey` (full-screen)
- Route under `/panther/<name>`
- Mark `[STUB]` until Plaid data is wired
- Follow the pattern in `tax_intelligence_page.dart`: dark bg `0xFF06060E`, card `0xFF0F0F1C`, animated with `CurvedAnimation`

### Adding a new LifeX sub-page
- **No** `parentNavigatorKey` in GoRoute
- Use bg `Color(0xFF0D0D22)`, consistent with other LifeX pages
- Import: `lib/features/lifex/presentation/pages/lifex_<name>_page.dart`

### Spiritual content
No yoga imagery. Use Pexels nature photos only (forests, oceans, mountains, starry skies, sunrises).

### Design system
- App dark base: `#08080F` (search, global)
- LifeX bg: `#0D0D22`
- Panther cards: `#0F0F1C`
- Positive: `#22C55E` | Warning: `#F59E0B` | Info: `#3B82F6` | Negative: `#EF4444`
- No purple on the search page — use white/subtle for all UI elements there

### Video on web
`video_player` throws `MEDIA_ERR_SRC_NOT_SUPPORTED` in Chrome. Fall back to a static image or opacity overlay when `kIsWeb == true`.

---

## Running the App

```bash
# Mobile
flutter run

# Web (Chrome)
flutter run -d chrome --no-web-resources-cdn

# Analyze
dart analyze

# Format
dart format lib/
```

---

## Dart Conventions
- Variables and methods: `lowerCamelCase` (not `snake_case`)
- Private classes/painters: prefix with `_` (e.g. `_PieChartPainter`, `_Debt`)
- Remove unused imports before committing — `dart analyze` will catch them
- `dart:math` needed only when `min()`/`max()` are used in `CustomPainter`
