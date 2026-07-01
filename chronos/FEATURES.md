# CHRONOS MOBILE — Feature & Route Registry

> **Rule**: Update this file in every commit that adds, modifies, or removes a feature, page, route, or service.
> Status tags: `[LIVE]` — built and wired | `[STUB]` — UI exists, no real data | `[PLANNED]` — not yet built

Last updated: 2026-07-01 (updated: Exchange flow collapsed to a single page — removed duplicate Enter Amount/Review Exchange steps, CTA renamed "Exchange Now"; Chris voice orb wave amplitude increased)

---

## App Structure

```
lib/
├── core/
│   ├── router/          GoRouter — ShellRoute (bottom nav) + full-screen routes
│   ├── services/        App-wide services (ChrisAction, Pexels)
│   ├── pages/           Shared pages (search)
│   └── widgets/         Shared widgets (bottom nav bar, ChrisFAB)
└── features/
    ├── auth/            Splash, onboarding, sign-in, sign-up, phone auth, forgot/reset password
    ├── transfer/        Send money flow (9 screens)
    ├── exchange/        Currency exchange flow (6 screens)
    ├── wallet/          Wallet, ATM finder, analytics
    ├── blockhub/        Crypto trading, NFTs, markets, onboarding (5-step)
    ├── panther_ai/      AI financial dashboard + 10 intelligence pages
    ├── tickpay/         BNPL shopping + credit platform (20+ screens)
    ├── lifex/           Life coaching dashboard (12 sub-pages)
    └── profile/         Settings, password, notifications
```

---

## Navigation Shell (Bottom Nav)

File: `lib/core/router/app_route.dart`

The shell has 5 tabs. Pages registered under the `ShellRoute` automatically show the bottom nav. Pages registered with `parentNavigatorKey: _rootNavigatorKey` are full-screen (no bottom nav).

| Tab | Icon | Route |
|-----|------|-------|
| Home | `home_rounded` | `/home` |
| BlockHub | `hub_rounded` | `/blockhub` |
| Panther AI | `/panther-ai` | `auto_awesome_rounded` |
| TickPay | `/tickpay-dashboard` | `shopping_bag_rounded` |
| LifeX | `/lifex` | `spa_rounded` |

Search (`/search`) and Profile (`/profile`) are accessible from the home top bar.

---

## Auth Feature

Path: `lib/features/auth/`

| Screen | Route | File | Status |
|--------|-------|------|--------|
| Splash | `/` | `splash_page.dart` | [LIVE] |
| Onboarding | `/onboarding` | `onboarding_page.dart` | [LIVE] |
| Sign Up | `/signup` | `sign_up_page.dart` | [LIVE] |
| Sign In | `/signin` | `sign_in_page.dart` | [LIVE] |
| Phone Auth | `/phone-auth` | `phone_auth_page.dart` | [LIVE] |
| Forgot Password | `/forgot-password` | `forgot_password_page.dart` | [LIVE] |
| Reset Password | `/reset-password` | `reset_password_page.dart` | [LIVE] |
| Pin Entry | `/pin-entry` | `pin_entry_page.dart` | [LIVE] |
| Home Dashboard | `/home` | `home_page.dart` | [LIVE] |

**Notes:**
- JWT stored via `token_storage_service.dart`
- Phone OTP via backend `/api/v1/auth/phone`
- Home tile grid: Wallet, Transfer, Exchange, BlockHub, Panther AI, TickPay, LifeX, Find ATM
- Hero background: Pexels photo 3943716 (sharp city/financial) via `CachedNetworkImageProvider` — replaced previous blurry purple `assets/background.png`
- Default fallback balance: **$24,332.34** (updated from $8,324.30); live data from `/api/home/summary`

---

## Transfer Feature

Path: `lib/features/transfer/`

| Screen | Route | File | Status |
|--------|-------|------|--------|
| Transfer | `/transfer` | `transfer_page.dart` | [LIVE] |
| Select Method | `/select-method` | `select_method_page.dart` | [LIVE] |
| Add Recipient | `/add-recipient` | `add_recipient_page.dart` | [LIVE] |
| Enter Amount | `/enter-amount` | `enter_amount_page.dart` | [LIVE] |
| Transfer Confirmation | `/transfer-confirmation` | `transfer_confirmation_page.dart` | [LIVE] |
| Transfer Success | `/transfer-success` | `transfer_success_page.dart` | [LIVE] |
| Add Money | `/add-money` | `add_money_page.dart` | [LIVE] |
| Bank Transfer | `/bank-transfer` | `bank_transfer_page.dart` | [LIVE] |
| Transfer (Chronos User) | — | `transfer_chronos_user_page.dart` | [LIVE] |
| Transfer (QR) | — | `transfer_qr_page.dart` | [LIVE] |
| Transfer (International) | — | `transfer_international_page.dart` | [LIVE] |
| Transfer (Contacts) | — | `transfer_contacts_page.dart` | [LIVE] |

---

## Exchange Feature

Path: `lib/features/exchange/`

| Screen | Route | File | Status |
|--------|-------|------|--------|
| Exchange | `/exchange` | `exchange_page.dart` | [LIVE] |
| Select Currency | `/select-currency` | `select_currency_page.dart` | [LIVE] |
| Processing | `/exchange-processing` | `exchange_processing_page.dart` | [LIVE] |
| Success | `/exchange-success` | `exchange_success_page.dart` | [LIVE] |

Exchange is now a single-page flow: amount entry, currency pick, and execute all happen on `exchange_page.dart` — the button dispatches quote+execute back-to-back on `ExchangeBloc`, then routes straight to Success. `enter_amount_page.dart` and `review_exchange_page.dart` (and their `/enter-exchange-amount`, `/review-exchange` routes) were removed as duplicate amount-entry/review steps. The CTA is now "Exchange Now" instead of "Review Exchange".

---

## Wallet Feature

Path: `lib/features/wallet/`

| Screen | Route | File | Status |
|--------|-------|------|--------|
| Wallet | `/wallet` | `wallet_page.dart` | [LIVE] |
| Wallet Onboarding | `/wallet-onboarding` | `wallet_onboarding_page.dart` | [LIVE] |
| Find ATM | `/find-atm` | `find_atm_page.dart` | [LIVE] |
| Analytics | — | `wallet_analytics_page.dart` | [LIVE] |

---

## Unit Banking Feature

Path: `lib/features/unit_banking/`

Integration with Unit (Banking-as-a-Service). Wired to `/api/unit/*` backend endpoints added by the Unit BaaS integration (Thom22).

| Screen | Route | File | Status |
|--------|-------|------|--------|
| Unit Banking | `/unit-banking` | `unit_banking_page.dart` | [LIVE] |

**API Endpoints:**
- `GET /api/unit/accounts` — list banking accounts
- `GET /api/unit/cards` — list debit cards
- `GET /api/unit/transfers` — list transfers
- `POST /api/unit/accounts` — open a new account
- `POST /api/unit/cards/:id/freeze` — freeze card
- `POST /api/unit/cards/:id/unfreeze` — unfreeze card

---

## BlockHub Feature

Path: `lib/features/blockhub/`

**Onboarding (5-step flow):**

| Screen | File | Status | Notes |
|--------|------|--------|-------|
| Welcome | `onboarding/blockhub_welcome_page.dart` | [LIVE] | Dark bg, Pexels crypto video at 30% opacity, animated feature tiles |
| Risk Disclosure | `onboarding/risk_disclosure_page.dart` | [LIVE] | 6 expandable risk cards, agree toggle required |
| Choose Experience | `onboarding/choose_experience_page.dart` | [LIVE] | Beginner/Intermediate/Expert; beginner guide shown for level 0; saves to SharedPreferences |
| Setup Wallet | `onboarding/setup_wallet_page.dart` | [LIVE] | 4 networks (ETH/Polygon/Arbitrum/Base), 3 wallet types; both required before CTA |
| Wallet Connected | `onboarding/wallet_connected_success_page.dart` | [LIVE] | Animated orb + confetti, no asset dependencies |

**Main screens:**

| Screen | Route | File | Status |
|--------|-------|------|--------|
| BlockHub Home | `/blockhub` | `blockhub_page.dart` | [LIVE] | Pexels hero banner (photo 7567598) at top; crypto/NFT sub-tiles below |
| Bitcoin Detail | — | `bitcoin_detail_page.dart` | [LIVE] |
| Ethereum Detail | `/ethereum-detail` | `ethereum_detail_page.dart` | [LIVE] |
| Markets | — | `markets_page.dart` | [LIVE] |
| Crypto Markets | — | `crypto_markets_page.dart` | [LIVE] |
| Top Gainers | — | `top_gainers_page.dart` | [LIVE] |
| Top Losers | — | `top_losers_page.dart` | [LIVE] |
| Trending Assets | — | `trending_assets_page.dart` | [LIVE] |
| Trade | — | `trade_page.dart` | [LIVE] |
| Portfolio | — | `portfolio_page.dart` | [LIVE] |
| Risk Analysis | — | `risk_analysis_page.dart` | [LIVE] |
| Panther AI Insights (BH) | — | `panther_ai_insights_page.dart` | [LIVE] |

**Buy flow:** `buy/buy_btc_page.dart` → `buy_btc_order_type_page.dart` → `buy_btc_review_page.dart` → `buy_btc_success_page.dart`

**Sell flow:** `sell/sell_btc_page.dart` → `sell_btc_order_type_page.dart` → `sell_btc_review_page.dart` → `sell_btc_success_page.dart`

**Wallet ops:** `wallets/` — deposit, receive_crypto, send_crypto, transfer, wallets_funds, withdraw, deposit_fiat

**NFTs:** `nft/` — marketplace, collections, detail, price_history, buy_sheet, offer_sheet; `portfolio/` — nft_portfolio, nft_analytics, nft_pnl, blockhub_portfolio, blockhub_risk_analysis

**Ethereum flow (full-screen, root nav):**

| Screen | Route | File | Status |
|--------|-------|------|--------|
| ETH Detail | `/eth-flow/detail` | `ethereum/ethereum_detail_page.dart` | [LIVE] |
| Trading Assistant | `/eth-flow/trading-assistant` | `ethereum/trading_assistant_page.dart` | [LIVE] |
| Portfolio Intelligence | `/eth-flow/portfolio-intelligence` | `ethereum/portfolio_intelligence_page.dart` | [LIVE] |
| Simulate Rebalance | `/eth-flow/simulate-rebalance` | `ethereum/simulate_rebalance_page.dart` | [LIVE] |
| Rebalance Confirmation | `/eth-flow/rebalance-confirmation` | `ethereum/rebalance_confirmation_page.dart` | [LIVE] |
| Rebalance Success | `/eth-flow/rebalance-success` | `ethereum/rebalance_success_page.dart` | [LIVE] |

---

## Panther AI Feature

Path: `lib/features/panther_ai/`

**Main:**

| Screen | Route | File | Status |
|--------|-------|------|--------|
| Panther AI Dashboard | `/panther-ai` | `panther_ai_page.dart` | [LIVE] |
| Panther AI Chat | `/panther-ai-chat` | `panther_ai_chat_page.dart` | [LIVE] | Text + Voice mode toggle; voice mode shows full-screen purple orb |
| Panther AI Settings | `/panther-ai-settings` | `panther_ai_settings_page.dart` | [LIVE] |
| Market Intelligence | `/market-intelligence` | `market_intelligence_page.dart` | [LIVE] |
| Full Portfolio Analysis | `/full-portfolio-analysis` | `analysis/full_portfolio_analysis_page.dart` | [LIVE] |
| Affordability Check | `/affordability-check` | `affordability_check_page.dart` | [LIVE] |
| Payment Plan | `/payment-plan` | `payment_plan_page.dart` | [LIVE] |
| Product Discovery | `/product-discovery` | `product_discovery_page.dart` | [LIVE] |
| Portfolio Intelligence | `/portfolio-intelligence` | `portfolio_intelligence_page.dart` | [LIVE] |
| Trading Assistant | `/trading-assistant` | `trading_assistant_page.dart` | [LIVE] |

**Rebalance flow:**

| Screen | Route | File | Status |
|--------|-------|------|--------|
| Insight Details | `/insight-details` | `rebalance/insight_details_page.dart` | [LIVE] |
| Rebalance Confirmation | `/rebalance-confirmation` | `rebalance/rebalance_confirmation_page.dart` | [LIVE] |
| Rebalance Success | `/rebalance-success` | `rebalance/rebalance_success_page.dart` | [LIVE] |
| Simulate Rebalance | `/simulate-rebalance` | `simulate/simulate_rebalance_page.dart` | [LIVE] |

**Financial Intelligence dashboards (Mahesh pipeline — stub data, Plaid integration pending):**

All 7 intelligence pages use the Panther light theme: `Color(0xFFF5F6FA)` bg, white cards, `Color(0xFFE8EAF0)` borders.

| Screen | Route | File | Status | Key UI |
|--------|-------|------|--------|--------|
| Portfolio Intelligence | `/panther/portfolio` | `portfolio_intelligence_page.dart` | [STUB] | Hero card ($45,890 total), allocation bars, performance chart, holdings list, Chris insight |
| Trading Assistant | `/panther/trading` | `trading_assistant_page.dart` | [STUB] | Market strip (BTC/ETH/SPX), 4 active signals with confidence bars, market conditions, Chris recommendation |
| Tax Intelligence | `/panther/tax` | `tax_intelligence_page.dart` | [STUB] | Pie chart (Federal/State/FICA/Medicare), deductions list, quarterly timeline |
| Bills Management | `/panther/bills` | `bills_management_page.dart` | [STUB] | 7 bills, auto-pay status, linear progress bars per category |
| Liabilities | `/panther/liabilities` | `liabilities_intelligence_page.dart` | [STUB] | Donut chart, 4 debts, Avalanche/Snowball strategy cards |
| Budget | `/panther/budget` | `budget_intelligence_page.dart` | [STUB] | Period toggle, ring progress per category, over-budget alerts |
| Net Worth | `/panther/net-worth` | `net_worth_intelligence_page.dart` | [STUB] | Line chart (6-month trend), assets vs liabilities bars |
| Market Intelligence | `/market-intelligence` | `market_intelligence_page.dart` | [STUB] | Market mood card, movers list, alerts, portfolio impact |
| TickPay AI | `/tickpay-ai` | `tickpay_ai_page.dart` | [LIVE] | 3-tab (Shop/Plans/Rewards), BLoC-driven, credit card hero, Chris insight |

> To connect real data: replace stub constants with Plaid API calls via Panther AI backend (`/api/lifex/finance`).

**TickPay AI (shared):**

| Screen | Route | File | Status |
|--------|-------|------|--------|
| TickPay AI | `/tickpay-ai` | `tickpay_ai_page.dart` | [LIVE] |

---

## TickPay Feature

Path: `lib/features/tickpay/`

TickPay is a BNPL (Buy Now Pay Later) + credit platform with AI-powered product discovery.

**Onboarding flow:**

| Screen | Route | File | Status |
|--------|-------|------|--------|
| TickPay Welcome | `/tickpay-welcome` | `tickpay_welcome_page.dart` | [LIVE] |
| Verification | `/tickpay-verification` | `tickpay_verification_page.dart` | [LIVE] |
| Link Wallets | `/tickpay-link-wallets` | `tickpay_link_wallets_page.dart` | [LIVE] |
| Completion | `/tickpay-completion` | `tickpay_completion_page.dart` | [LIVE] |
| Setup Complete | `/tickpay/setup-complete` | `tickpay_setup_complete_page.dart` | [LIVE] |

**Dashboard & management:**

| Screen | Route | File | Status |
|--------|-------|------|--------|
| Dashboard | `/tickpay-dashboard` | `tickpay_dashboard_page.dart` | [LIVE] |
| Credit Overview | `/tickpay-credit-overview` | `tickpay_credit_overview_page.dart` | [LIVE] |
| Active Plans | `/tickpay-active-plans` | `tickpay_active_plans_page.dart` | [LIVE] |
| Notifications | `/tickpay-notifications` | `tickpay_notifications_page.dart` | [LIVE] |
| Rewards | `/tickpay-rewards` | `tickpay_rewards_page.dart` | [LIVE] |
| Shortcuts | `/tickpay-shortcuts` | `tickpay_shortcuts_page.dart` | [LIVE] |
| Upcoming Payments | `/tickpay/upcoming-payments` | `tickpay_upcoming_payments_page.dart` | [LIVE] |
| Repay Now | `/tickpay/repay-now` | `tickpay_repay_now_page.dart` | [LIVE] |
| Payment History | `/tickpay/payment-history` | `tickpay_payment_history_page.dart` | [LIVE] |
| Alerts | `/tickpay/alerts` | `tickpay_alerts_page.dart` | [LIVE] |
| Auto Pay | `/tickpay/auto-pay` | `tickpay_auto_pay_page.dart` | [LIVE] |
| Order History | `/tickpay/order-history` | `tickpay_order_history_page.dart` | [LIVE] |

**Shopping flow:**

| Screen | Route | File | Status |
|--------|-------|------|--------|
| Discover | `/tickpay/discover` | `tickpay_discover_page.dart` | [LIVE] |
| Search | `/tickpay/search` | `tickpay_search_page.dart` | [LIVE] |
| AI Picks | `/tickpay/ai-picks` | `tickpay_ai_picks_page.dart` | [LIVE] |
| AI Shop | `/tickpay/ai-shop` | `tickpay_ai_shop_page.dart` | [LIVE] |
| Product Detail | `/tickpay/product-detail` | `tickpay_product_detail_page.dart` | [LIVE] |
| Shop Detail | `/tickpay/shop-detail` | `tickpay_shop_detail_page.dart` | [LIVE] |
| BNPL Checkout | `/tickpay/bnpl-checkout` | `tickpay_bnpl_checkout_page.dart` | [LIVE] |
| Order Confirmed | `/tickpay/order-confirmed` | `tickpay_order_confirmed_page.dart` | [LIVE] |
| Chris Shopping | — | `chris_shopping_page.dart` | [LIVE] |

---

## LifeX Feature

Path: `lib/features/lifex/`

LifeX is a life coaching dashboard with 11 life-area sub-pages. All sub-pages use the shell navigator so the bottom nav remains visible.

**Theme:** Dark bg `Color(0xFF0D0D22)` with per-category accent colors. No yoga imagery in Spiritual.

**Main:**

| Screen | Route | File | Status |
|--------|-------|------|--------|
| LifeX Dashboard | `/lifex` | `lifex_page.dart` | [LIVE] | Domain orbs: consistent grey/white styling (icons white, rings grey) — replaces rainbow per-module colors |
| LifeX Onboarding | `/lifex/onboarding` | `lifex_onboarding_page.dart` | [LIVE] |
| Feed | `/lifex/feed` | `lifex_feed_page.dart` | [LIVE] |
| AI Insights | `/lifex/ai-insights` | `lifex_ai_insights_page.dart` | [LIVE] |
| Export | `/lifex/export` | `lifex_export_page.dart` | [LIVE] |

**Life area sub-pages (all keep bottom nav):**

| Area | Route | File | Status | Icon |
|------|-------|------|--------|------|
| Health | `/lifex/health` | `lifex_health_page.dart` | [LIVE] | `monitor_heart_rounded` — dark bg `#0D0D22`, dark cards `#0F0F1C` (fixed white-on-white text bug). Rebuilt around HSA management, an insurance marketplace, NY/SF gym partnerships, and wearable/nutrition-partner connections — calorie/step tracking is now a small "Today's Vitals" strip on Overview instead of the headline. HSA deposit/withdraw, insurance enrollment, wearable connect+sync, and nutrition-partner connect all call real `/api/lifex/health/*` endpoints; insurance/gym/nutrition catalogs are mock/curated content on the client. |
| Education | `/lifex/education` | `lifex_education_page.dart` | [LIVE] | `menu_book_rounded` |
| Spiritual | `/lifex/spiritual` | `lifex_spiritual_page.dart` | [LIVE] | `spa_rounded` — nature imagery only |
| Finance | `/lifex/finance` | `lifex_finance_page.dart` | [LIVE] | `account_balance_wallet_rounded` |
| Activity | `/lifex/activity` | `lifex_activity_page.dart` | [LIVE] | (activity icon) |
| Vision | `/lifex/vision` | `lifex_vision_page.dart` | [LIVE] | `rocket_launch_rounded` |
| Family | `/lifex/family` | `lifex_family_page.dart` | [LIVE] | (family icon) |
| Relationship | `/lifex/relationship` | `lifex_relationship_page.dart` | [LIVE] | `handshake_rounded` |
| Social | `/lifex/social` | `lifex_social_page.dart` | [LIVE] | `people_rounded` — Invite button opens friend-search bottom sheet with avatar list + invite toggle |

**Content notes for Spiritual page:**
- Meditation images use Pexels nature photos only (no yoga)
- IDs in use: forest `1761279`, ocean `355465`, starry night `1252890`, mountain `2775196`, sunrise `994605`
- Rebuilt from a meditation-app-first layout into 5 tabs: Practice (meditation/gratitude/goals, unchanged), Giving (charity donations + crowdfunding campaigns), Trips (spiritual pilgrimages/retreats), Shop (ecommerce for devotional goods), Events (faith-based event calendar, informational). Removed the third-party Mindfulness Apps (Calm/Headspace) tile and the old Anchor tab.
- Charity/campaign/trip/product/event catalogs are mock/curated data in the page (Pexels images) — the actual money movement (donate, contribute, book, checkout) calls real backend endpoints under `/api/lifex/spiritual/*` (`donations`, `campaigns/contribute`, `trips/book`, `shop/checkout`) which debit the user's real wallet via the same ledger mechanism `TransferService` uses.
- `LifeXService` (`lib/features/lifex/data/lifex_service.dart`) is now registered in DI (`auth_di.dart`) — it previously existed but was never wired to GetIt.

---

## Profile Feature

Path: `lib/features/profile/`

| Screen | Route | File | Status |
|--------|-------|------|--------|
| Profile | `/profile` | `profile_page.dart` | [LIVE] |
| Change Password | `/profile/change-password` | `change_password_page.dart` | [LIVE] |
| Notification Settings | `/profile/notifications` | `notification_settings_page.dart` | [LIVE] |
| Theme Settings | — | `theme_settings_page.dart` | [LIVE] |

---

## History Feature

Path: `lib/features/history/`

| Screen | Route | File | Status |
|--------|-------|------|--------|
| History | `/history` | `history_page.dart` | [STUB] — sample data only; real data from `/api/transactions` not yet wired |

Accessible via the history icon (top-right of home hero section, replaces bell icon).

---

## Core / Shared

| Component | File | Status | Notes |
|-----------|------|--------|-------|
| Search Page | `lib/core/pages/search_page.dart` | [LIVE] | Neutral dark theme `#08080F`, white/subtle borders — no purple |
| Bottom Nav Bar | `lib/core/widgets/` | [LIVE] | 5 tabs, persistent across shell routes |
| ChrisFAB | `lib/core/widgets/chris_home_fab.dart` | [LIVE] | Dark amber orb FAB; tap → gradient-border text sheet with suggestion chips; "Hey Chris" → Siri-like voice overlay with pulsing orb (amber=listening, teal=thinking, indigo=speaking); triple-open wake word bug fixed via `_wakeWordTriggered` guard |
| Chris Action Service | `lib/core/services/chris_action_service.dart` | [LIVE] | 8 transactional actions (exchange/transfer/balance/BNPL/deposit/buy-sell-send crypto) + 21 navigation intents covering every app page |
| Pexels Service | `lib/core/services/pexels_service.dart` | [LIVE] | Fetches Pexels video/photo URLs |
| Token Storage Service | `lib/features/auth/data/services/token_storage_service.dart` | [LIVE] | JWT persistence |

---

## Design System

| Token | Value | Usage |
|-------|-------|-------|
| App background | `#08080F` | Search, global dark base |
| LifeX background | `#0D0D22` | Slight navy for LifeX pages |
| Panther page bg | `#F5F6FA` | All Panther AI pages and intelligence dashboards |
| Panther card bg | `#FFFFFF` | Cards on all Panther intelligence pages |
| Panther card border | `#E8EAF0` | Card borders on Panther light theme pages |
| Panther text primary | `#1A1A2E` | Headings and primary text on Panther pages |
| Panther text secondary | `#6B7080` | Secondary text, labels on Panther pages |
| Icon container bg | `#F3F4F6` | Icon chip backgrounds on Panther pages (replaces dark cards) |
| Card dark | `#111118` / `#141420` | General dark-theme cards (non-Panther) |
| Accent green | `#22C55E` | Positive values, LifeX |
| Accent amber | `#F59E0B` | Taxes, warnings |
| Accent blue | `#3B82F6` | Bills, info |
| Accent red | `#EF4444` | Liabilities, negative |
| Accent purple | `#7C6EF0` | Panther AI orb, voice mode, portfolio accent |

**Bottom nav / global nav:** white icons on dark bg. No purple on search page.
**Panther AI chat:** light bg, purple user message bubbles, white AI bubbles, voice mode shows full-screen orb.

### Glass System

| Component | File | Usage | Status |
|-----------|------|-------|--------|
| FluidGlass widget | `lib/core/widgets/fluid_glass.dart` | Glass-morphism container applied to nav bar, headers, cards | [LIVE] |
| `FluidGlass.dark` | — | Subtle white tint (9% opacity) for dark bg pages (Transfer, Exchange, Profile, BlockHub) | [LIVE] |
| `FluidGlass.light` | — | Strong white frosted tint (72% opacity) for light bg pages (History) | [LIVE] |

---

## Custom Painters

| Painter | File | Usage |
|---------|------|-------|
| `_PieChartPainter` | `tax_intelligence_page.dart` | Filled arc segments for tax breakdown |
| `_DonutPainter` | `liabilities_intelligence_page.dart` | Stroke-style donut for debt composition |
| `_LineChartPainter` | `net_worth_intelligence_page.dart` | Gradient-filled line chart for net worth trend |
| `_ConfettiPainter` | `wallet_connected_success_page.dart` | 20-particle confetti on wallet connect |

---

## State & Persistence

| Mechanism | Used for |
|-----------|---------|
| `SharedPreferences` | BlockHub onboarding state (`blockhub_experience_level`), TickPay setup completion |
| `AnimationController` | Slide-in, pulse, confetti, chart draw-on animations |
| `GoRouter` + `ShellRoute` | Navigation; shell keeps bottom nav visible |
| JWT in SecureStorage | Auth token from `token_storage_service.dart` |

---

## Known Issues / TODOs

| Item | Priority | Notes |
|------|----------|-------|
| Pexels video on web | Medium | `MEDIA_ERR_SRC_NOT_SUPPORTED` in Chrome — video_player package doesn't support web without additional setup |
| Financial intelligence real data | High | All Panther financial intelligence pages use stub data; wire to Plaid via backend |
| LifeX family page | Low | `lifex_family_page.dart` exists but may not be linked from dashboard tile |
| `dart:math` in liabilities | Done | Needed for `min()` in `_DonutPainter` — keep the import |
| Panther dashboard intelligence grid | Done | Replaced horizontal scroll ListView with 2-column GridView — all 8 tiles visible at once |
| Voice mode in Panther chat | Done | ChatGPT-style full-screen orb voice mode added to `panther_ai_chat_page.dart` |
| CLAUDE.md Panther card token | Low | `chronos/CLAUDE.md` still documents `#0F0F1C` as Panther card color — update if CLAUDE.md is edited |
| Health page white text on white bg | **Done** | Fixed: changed `_bg` from `#F5F6FA` to `#0D0D22`, `_card` from `Colors.white` to `#0F0F1C` |
| LifeX domain orbs rainbow colors | **Done** | Fixed: all orb icons now white, rings use consistent grey instead of per-module color |
| Social Invite button no-op | **Done** | Fixed: shows bottom sheet with searchable friend list and invite-toggle per friend |
| Home blurry purple background | **Done** | Fixed: replaced `assets/background.png` with sharp Pexels photo via `CachedNetworkImageProvider` |
| BlockHub no hero photo | **Done** | Fixed: added Pexels hero banner at top with gradient overlay and title |
