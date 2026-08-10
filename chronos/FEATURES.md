# CHRONOS MOBILE — Feature & Route Registry

> **Rule**: Update this file in every commit that adds, modifies, or removes a feature, page, route, or service.
> Status tags: `[LIVE]` — built and wired | `[STUB]` — UI exists, no real data | `[PLANNED]` — not yet built

Last updated: 2026-08-10 (updated: redesigned `feature_walkthrough_page.dart` from a light-theme rounded-video-card layout to a full-bleed, edge-to-edge video walkthrough matching a full-screen-photo/small-corner-icon-button reference — video fills the whole screen, controls are small translucent icon buttons anchored to the four corners (logo+skip top, mute toggle+CTA pill bottom), stories-style segmented progress bar, title/subtitle/new optional tag chips overlaid on the video via a bottom gradient scrim. Converted `blockhub_welcome_page.dart` from its old scrolling single-hero layout onto the same shared component (now 4 slides: Crypto Trading/NFT Gallery/Panther AI/Multi-Chain Wallet). Re-audited and redistributed every already-verified Pexels video ID already in production use across the app so onboarding (5 slides), TickPay (3), LifeX (3) and BlockHub (4) each get a distinct, topically-matched clip instead of the same handful reused everywhere; `PexelsService`'s runtime background-refresh now scores candidates by portrait resolution and loop-friendly duration (4-25s) instead of taking the first search hit. Earlier history in this line trimmed for file health — see git log for prior entries.)

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
- Onboarding: full-bleed video walkthrough built on the shared `FeatureWalkthroughPage` (see Core / Shared) — video fills the entire screen (not a rounded card), controls are small translucent icon buttons anchored to the four corners (logo + skip up top, mute toggle + CTA pill down low), title/subtitle/tag chips sit directly on the video over a bottom scrim. Each of the 5 slides carries its own accent color (blue/red/purple/orange/teal) that tints its progress bar, tags and CTA pill.

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
| Welcome | `onboarding/blockhub_welcome_page.dart` | [LIVE] | 4-slide full-bleed video walkthrough built on the shared `FeatureWalkthroughPage` (see Core / Shared) — Crypto Trading / NFT Gallery / Panther AI / Multi-Chain Wallet, replaces the old rounded-card-video + white feature-tile-list layout |
| Risk Disclosure | `onboarding/risk_disclosure_page.dart` | [LIVE] | 6 expandable risk cards, agree toggle required |
| Choose Experience | `onboarding/choose_experience_page.dart` | [LIVE] | Beginner/Intermediate/Expert; beginner guide shown for level 0; saves to SharedPreferences |
| Setup Wallet | `onboarding/setup_wallet_page.dart` | [LIVE] | 4 networks (ETH/Polygon/Arbitrum/Base), 3 wallet types; both required before CTA |
| Wallet Connected | `onboarding/wallet_connected_success_page.dart` | [LIVE] | Animated orb + confetti, no asset dependencies |

**Main screens:**

| Screen | Route | File | Status |
|--------|-------|------|--------|
| BlockHub Home | `/blockhub` | `blockhub_page.dart` | [LIVE] | Pexels hero banner (photo 7567598) at top; crypto/NFT sub-tiles below. Top Movers carousel: 3D-rendered coins (BTC/ETH/BNB/SOL) float free with no clip (fixed a visible square edge from `ClipRect` cutting through the tilted coin's rim); coins without a 3D render (ADA/DOT/MATIC/LINK/AVAX) show their real brand logo inside a colored coin badge instead of a raw clipped image. Carousel `viewportFraction` tightened to 0.62 so neighboring coins peek in on both sides. |
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

`buy_btc_page.dart` and `sell_btc_page.dart` (only these two — their `order_type`/`review`/`success` sub-pages were already correct) had a second `Positioned.fill(Colors.black.withValues(alpha: 0.58))` stacked on top of the standard `0.20` overlay, making them noticeably darker/muddier than every other page in the buy/sell flow and the rest of the app. Removed — both now use the same single `0.20` overlay as their sub-pages.

**Wallet ops:** `wallets/` — deposit, receive_crypto, send_crypto, transfer, wallets_funds, withdraw, deposit_fiat

**NFTs:** `nft/` — collections, detail, price_history, buy_sheet, offer_sheet, and **marketplace** (`nft/nft_marketplace_page.dart` is the real Marketplace screen — `blockhub_page.dart`'s "NFT" tile imports and pushes it); `portfolio/` — nft_portfolio, nft_analytics, nft_pnl, blockhub_portfolio, blockhub_risk_analysis. A second, separate `presentation/pages/nft_marketplace_page.dart` also exists (only reachable from `more_options_modal.dart`'s "More" sheet) and is wired to the same bloc/data for consistency, but `nft/nft_marketplace_page.dart` is the one users actually see from BlockHub Home. [LIVE] — Featured/Trending Collections/Top Volume/New Drops on both marketplace pages come from `NftMarketplaceBloc`, backed by 4 BlockHub endpoints (`GET /nft/collections/featured|trending|top-volume`, `GET /nft/drops/new`) computing real floor price, volume, 24h/7d volume-change%, and owner count from `NftListing`/`NftTransaction`/`Nft` data (`nft.service.ts`'s `computeCollectionStats`); falls back to non-trademarked placeholder content only while a collection category has zero real listings or transactions yet. Every card everywhere in the NFT flow (`nft/nft_detail_page.dart`, both marketplace pages, `nft_collections_page.dart`, `nft_price_history_page.dart`) shares the same TickPay/BlockHub hero-photo background + 0.20 dark overlay and a `LinearGradient` glass-card treatment for legibility.

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
| Panther AI Dashboard | `/panther-ai` | `panther_ai_page.dart` | [LIVE] | Flat `PantherColors.bg` background (photo backdrop removed — see "Last updated"). Personalized "Hey {name}" greeting. "Safe to spend / Next bill / Total debt" band under the Chris orb ("Safe to spend" routes to `budgetIntelligence`). Intelligence grid leads with a 2-up "On your schedule" row (Bills, Debts) above 2 labeled reference groups (Money Health: Budget/Net Worth/Taxes, Grow: Portfolio/Trading). The former "Payments" section (TickPay tile) was removed — it duplicated the home page's own TickPay entry points; see "Last updated". Live "heads up" banner wired to `AlertsBloc`/`AlertsGenerateRequested`. |
| Panther AI Chat | `/panther-ai-chat` | `panther_ai_chat_page.dart` | [LIVE] | `sendMessage()` calls Vercel's `POST /api/chat` (the only publicly-reachable piece of this system — EB/local Panther AI are not) with real multi-turn history threaded through (`ChatMessageSent.history` built from the page's own message list) — see "Last updated". Text and voice merged into one ChatGPT/Claude-style view — no more separate full-screen voice mode; the mic button in the input bar transcribes into the chat, and Chris speaks the reply back only when that turn came from voice (speaker icon in the header mutes/unmutes). Replies can now carry a `ChatVisual` (`presentation/bloc/chat_visual.dart`) rendered under the text bubble: a `PantherRingChart` for net worth / portfolio / debt / spending questions (via the already-live `GetNetWorthDashboard`/`GetSpendingSummary` usecases), or a horizontal row of product cards (photo via `PexelsService` + name/price/vendor/BNPL badge) for "should I buy X"/"show me a X" questions (via the already-live `SearchProducts` usecase). Detection is keyword-based on the user's message in `ChatBloc._resolveVisual`; a failed lookup just means no visual attaches, chat itself never breaks. |
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

All 7 intelligence pages use the Panther light theme: `Color(0xFFF5F6FA)` bg, white cards, `Color(0xFFE8EAF0)` borders — as of the Panther visual redesign (see "Last updated" note above) this is now a real flat background with no photo behind it, matching this table's claim for the first time.

| Screen | Route | File | Status | Key UI |
|--------|-------|------|--------|--------|
| Portfolio Intelligence | `/panther/portfolio` | `portfolio_intelligence_page.dart` | [STUB] | Hero card ($45,890 total), allocation bars, performance chart, holdings list, Chris insight |
| Trading Assistant | `/panther/trading` | `trading_assistant_page.dart` | [STUB] | Market strip (BTC/ETH/SPX), 4 active signals with confidence bars, market conditions, Chris recommendation |
| Tax Intelligence | `/panther/tax` | `tax_intelligence_page.dart` | [STUB] | Ring chart via shared `PantherRingChart` (Federal/State/FICA/Medicare), deductions list, quarterly timeline |
| Bills Management | `/panther/bills` | `bills_management_page.dart` | [STUB] | 7 bills, auto-pay status, linear progress bars per category |
| Liabilities | `/panther/liabilities` | `liabilities_intelligence_page.dart` | [STUB] | Ring chart via shared `PantherRingChart` (was an unlabeled donut, fixed), 4 debts, Avalanche/Snowball strategy cards, Chris's paydown suggestion surfaced above the numbers |
| Budget | `/panther/budget` | `budget_intelligence_page.dart` | [STUB] | Period toggle, ring progress per category, over-budget alerts |
| Net Worth | `/panther/net-worth` | `net_worth_intelligence_page.dart` | [LIVE] | Wired to `GET /api/net-worth/dashboard` + `/projection` via `NetWorthBloc`; 90-day trend chart, itemized real investment holdings + liability items, a "what-if" monthly-contribution projection card |
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
| Walkthrough (first-time, skippable) | — (pushed via root navigator) | `tickpay_walkthrough_page.dart` | [LIVE] |
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

**Content notes:**
- Walkthrough: 3-slide full-bleed video walkthrough built on the shared `FeatureWalkthroughPage` (see Core / Shared), gated by `tickpay_walkthrough_seen` and checked in `TickPayDashboardPage.initState`; pushed via root navigator so it covers the bottom nav, same pattern as BlockHub's onboarding gate.
- Chris Shopping's budget/product Q&A now hits the real `POST /api/marketplace/search` (Panther AI, Claude tool-calling) instead of a local hardcoded state machine — see "Last updated" note above.
- Dashboard quick actions: the separate "AI Search" tile was removed — it routed to the same `tickpayDiscover` page as "Shop", so they're now one entry.
- Discover page: search and category taps no longer show results in a strip inside the dark header — they replace the "Featured Deals" section content in the white body instead (title becomes `Results for "<query>"`, with a Clear action). Tapping a search result opens the installment-picker checkout sheet directly (`_selectProduct`) instead of navigating to Product Detail.
- Discover's checkout sheet (`_CheckoutSheet`): installment buttons and the confirm button are smaller, and purple (`#8B5CF6`) was replaced with dark (`#1A1A2E`)/white throughout.
- Order History: "View Receipt"/"Buy Again" buttons had `minimumSize: Size.zero` + `tapTargetSize: MaterialTapTargetSize.shrinkWrap` added — Material buttons enforce a 48dp minimum tap target regardless of padding, which was why they looked oversized despite already-small padding/font.
- Upcoming Payments: calendar card now uses `FluidGlass.light` instead of a plain white `Container`. "Due Today" card rebuilt as a 2-column `FluidGlass.dark` grid (amount · payment count) in red (`#EF4444`) instead of the purple gradient block.
- Product Detail page had a full-page dark photo background (the same hardcoded Pexels-image pattern used elsewhere in the app) sitting underneath content designed for a solid white page with dark text — removed it; the page was always meant to be plain white.
- Dashboard (`tickpay_dashboard_page.dart`) had two full-page background layers stacked (a `0.20`-alpha one, then a redundant `0.52`-alpha one painted on top) — removed the redundant second layer, which was the "too dark behind the card" difference vs. the main Home page.

---

## LifeX Feature

Path: `lib/features/lifex/`

LifeX is a life coaching dashboard with 11 life-area sub-pages. All sub-pages use the shell navigator so the bottom nav remains visible.

**Theme:** Dark bg `Color(0xFF0D0D22)` with per-category accent colors. No yoga imagery in Spiritual.

**Main:**

| Screen | Route | File | Status |
|--------|-------|------|--------|
| LifeX Dashboard | `/lifex` | `lifex_page.dart` | [LIVE] | Domain orbs: consistent grey/white styling (icons white, rings grey) — replaces rainbow per-module colors |
| LifeX Walkthrough (first-time, skippable) | — (pushed via root navigator) | `lifex_walkthrough_page.dart` | [LIVE] | 3-slide full-bleed video walkthrough on `FeatureWalkthroughPage`; gated by `lifex_walkthrough_seen`, checked in `LifeXPage.initState`; independent of the chat-based onboarding below |
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
- Onboarding now asks faith: `personal_info_page.dart` has a 4th step ("Chris wants to know you better") with a faith chip picker, feeding the same `faith` field via `LifeXService.setFaith()` (best-effort — this page doesn't submit the rest of its fields to the backend yet either).

---

## Profile Feature

Path: `lib/features/profile/`

| Screen | Route | File | Status |
|--------|-------|------|--------|
| Profile | `/profile` | `profile_page.dart` | [LIVE] |
| Change Password | `/profile/change-password` | `change_password_page.dart` | [LIVE] |
| Notification Settings | `/profile/notifications` | `notification_settings_page.dart` | [LIVE] |
| Theme Settings | — | `theme_settings_page.dart` | [LIVE] | Added a "Custom Background" section — search Pexels for a photo or video and apply it as the app-wide background via `BackgroundCubit`. Persisted locally and synced to the user's profile (`backgroundUrl`/`backgroundMediaType` on `User`, `PATCH /api/v1/users/me`). |

**App-wide background system** [PARTIAL — infrastructure done, most pages not yet migrated]:
- `lib/core/theme/background_cubit.dart` — `BackgroundCubit` (registered in `app_di.dart`, provided at the app root in `main.dart` alongside `ThemeCubit`) holds the selected background and keeps local (`SharedPreferences`) + backend in sync.
- `lib/core/widgets/app_background.dart` — `AppBackground({child, overlayOpacity})` replaces the old per-page pattern of a hardcoded Pexels photo + dark overlay `Container`, rendering the user's chosen photo or video (looping, muted) instead, with the same overlay treatment. Falls back to the same default photo every page used to hardcode when nothing's been chosen yet.
- Migrated: `panther_ai_page.dart`, `exchange_page.dart`.
- **Not yet migrated**: ~121 other pages still hardcode `Image.network('...pexels-photo-30004067...')` + a dark overlay `Container` directly (grep `pexels-photo-30004067` across `lib/` to find them). Swapping each to `AppBackground(child: SafeArea(...))` is mechanical but was too large a surface to safely hand-edit in one pass without a compiler in this environment — planned as a follow-up.

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
| ChrisFAB | `lib/core/widgets/chris_home_fab.dart` | [LIVE] | `_StrandsPainter` renders 4 animated wave strands (blue/purple/near-black `#3B82F6`/`#7C3AED`/`#100820`, thinner/calmer amplitude per updated visual tuning) inside the FAB circle, with a teal pulse ring while the wake-word mic is listening. Motion now matches a supplied JS reference component exactly: binary idle/responding painter speed (`0.07`/`0.45`, any non-idle state in the underlying `idle/listening/thinking/speaking` machine counts as "responding"), a linear (no easing) 1200ms glow-pulse triangle wave, and drag-vs-tap resolved via a 5px total-movement threshold (`onPanDown`/`onPanUpdate`/`onPanEnd`) instead of a separate `onTap` recognizer. The reference component's own TTS/command-capture/action-execution logic was intentionally NOT ported — the existing voice-conversation flow (greeting, listen, `ChrisActionService`, chat fallback) is unchanged underneath, per explicit direction to match motion/visuals only. Both "Hey Chris" and a direct tap trigger `_engage()` — no sheet ever pops up: Chris speaks "Hey `<firstName>`, what would you like to do?" (via `TtsService`, waits for it to finish), then `_listenForCommand()` captures the follow-up via STT. Tapping the FAB again while Chris is talking/thinking interrupts him immediately (`TtsService` is generation-guarded/interruptible) and starts listening for the new command. `ChrisActionService` resolves and executes the intent directly (navigate + spoken confirmation, or `VoiceConfirmationSheet`); unresolved intents get a real spoken reply from Chris chat (`SendMessage`, with the last few turns threaded through as conversation history) and — up to 4 follow-ups — keep listening without repeating "Hey Chris". Background wake-word polling is disabled on web (`kIsWeb`) since browsers block unattended mic restarts; tap-to-talk still works there. Denied/unavailable mic shows a one-time SnackBar instead of failing silently. Wave amplitude/spread increased for a bigger, wider look; triple-open wake word bug fixed via `_wakeWordTriggered` guard. |
| Chris Action Service | `lib/core/services/chris_action_service.dart` | [LIVE] | 8 transactional actions (exchange/transfer/balance/BNPL/deposit/buy-sell-send crypto) + 21 navigation intents covering every app page |
| Pexels Service | `lib/core/services/pexels_service.dart` | [LIVE] | Fetches Pexels video/photo search results via the Vercel deployment's `api/pexels.js` serverless proxy (holds `PEXELS_API_KEY` as a Vercel env var, same pattern as `_kChrisChatBase`/`_kVoiceBase`) instead of calling `api.pexels.com` directly with a client-embedded key. `photoUrl()`'s direct CDN link (`images.pexels.com/photos/<id>/...`) is unauthenticated and untouched. |
| Token Storage Service | `lib/features/auth/data/services/token_storage_service.dart` | [LIVE] | JWT persistence |
| Crypto Coin Icon | `lib/core/widgets/crypto_coin_icon.dart` | [LIVE] | `CryptoCoinIcon(symbol, size)` — reuses BlockHub's real 3D coin PNGs (`assets/crypto/`) + `coin_icon_scale.dart`'s per-symbol scale correction, falling back to a colored-initial badge for symbols with no local asset. Used by Panther's `portfolio_intelligence_page.dart` (asset rows, previously a plain `₿`/`Ξ`/`S` glyph-in-circle) and `trading_assistant_page.dart` (Quick Analysis chips, previously text-only). |
| Feature Walkthrough Page | `lib/core/widgets/feature_walkthrough_page.dart` | [LIVE] | `FeatureWalkthroughPage`/`WalkthroughSlide` — reusable, skippable, swipeable, **full-bleed** video walkthrough (redesigned from the old rounded-card layout to match a full-screen-photo/small-corner-icon-button reference). Video fills the entire screen edge-to-edge (Pexels background-fetch + fallback-URL loading pattern, now scored by portrait resolution + loop-friendly 4-25s duration instead of taking the first search hit); top/bottom black gradient scrims keep controls legible. Controls are small translucent circular icon buttons anchored to the four corners: app-logo badge + skip (top), mute toggle + accent-colored "Next"/finish pill (bottom); a stories-style segmented progress bar sits above them. Title/subtitle/optional tag chips (`WalkthroughSlide.tags`) render directly on the video over the bottom scrim. `kIsWeb` skips video entirely and shows the accent-gradient + icon placeholder (video_player is unsupported in Chrome). Used by the main auth onboarding (5 slides), `tickpay_walkthrough_page.dart` (3), `lifex_walkthrough_page.dart` (3), and `blockhub_welcome_page.dart` (4, converted from its old scrolling single-hero layout to this same component). |

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
| `_RingPainter` (inside shared `PantherRingChart` widget) | `presentation/widgets/panther_ring_chart.dart` | Stroke-style ring with center total + %-labeled legend — shared by Tax Breakdown and Debt Composition (replaces the old per-page `_PieChartPainter`/`_DonutPainter`, which had no center label and no legend percentages) |
| `_LineChartPainter` | `net_worth_intelligence_page.dart` | Gradient-filled line chart for net worth trend |
| `_ConfettiPainter` | `wallet_connected_success_page.dart` | 20-particle confetti on wallet connect |

---

## State & Persistence

| Mechanism | Used for |
|-----------|---------|
| `SharedPreferences` | BlockHub onboarding state (`blockhub_experience_level`), TickPay setup completion, `tickpay_walkthrough_seen`, `lifex_walkthrough_seen`, `onboarding_completed` |
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
| Panther dashboard intelligence grid | Done | Replaced horizontal scroll ListView with 2-column GridView — all 8 tiles visible at once |
| Voice mode in Panther chat | Done | ChatGPT-style full-screen orb voice mode added to `panther_ai_chat_page.dart` |
| Panther pages illegible over photo background | **Done** | Fixed: removed the Pexels photo + dark-overlay `Stack` from all ~26 Panther pages in favor of a flat `PantherColors.bg`; see "Last updated" note above |
| Chris chat/voice always fails ("something went wrong" to every query) | **Done** | Root cause: every real LLM call used the invalid model id `claude-sonnet-4-6`; fixed to `claude-sonnet-5` across `orchestrator.ts`, `claude.client.ts`, and all 5 domain agents. Per direction, the app's chat/voice calls (`PantherAiRemoteDataSource.sendMessage`, `TtsService._fetchAudio`) were repointed from the EB Express backend (needs a manual redeploy this environment can't perform) to the Vercel deployment (`chronosapp-rosy.vercel.app`'s `api/chat.js`/`api/synthesize.js`, already fixed to `claude-sonnet-5` above), which is where the user's Anthropic/ElevenLabs keys actually live and where they can redeploy just by pushing. Loses the EB backend's personalized financial-context routing (`orchestrator.ts`'s domain agents) — Vercel's functions are a stateless Claude call with no user data — a tradeoff accepted for now to get chat/voice working from an environment that's actually deployable. `_kPantherBase` (net worth/spending/marketplace/warnings/transactions) is untouched — still EB, no Vercel equivalent exists for it, and it wasn't what was reported broken. |
| Debt Composition chart unreadable | **Done** | Fixed: `liabilities_intelligence_page.dart`'s donut had no track/center label; now uses the shared `PantherRingChart` widget (also used by Tax Breakdown) |
| CLAUDE.md Panther card token | Low | `chronos/CLAUDE.md` still documents `#0F0F1C` as Panther card color — update if CLAUDE.md is edited |
| Health page white text on white bg | **Done** | Fixed: changed `_bg` from `#F5F6FA` to `#0D0D22`, `_card` from `Colors.white` to `#0F0F1C` |
| LifeX domain orbs rainbow colors | **Done** | Fixed: all orb icons now white, rings use consistent grey instead of per-module color |
| Social Invite button no-op | **Done** | Fixed: shows bottom sheet with searchable friend list and invite-toggle per friend |
| Home blurry purple background | **Done** | Fixed: replaced `assets/background.png` with sharp Pexels photo via `CachedNetworkImageProvider` |
| BlockHub no hero photo | **Done** | Fixed: added Pexels hero banner at top with gradient overlay and title |
| LifeX AI coach has no chat UI | Medium | Backend `GET /api/lifex/ai/insights`, `POST /api/lifex/ai/chat`, `GET /api/lifex/ai/weekly-plan`, and its ElevenLabs voice chat (`/api/lifex/ai/voice/*`) all exist and work, but no Flutter page calls them — `lifex_ai_insights_page.dart` is still fully static/hardcoded |
| Chris voice not wired everywhere | **Done** | Fixed: `panther_ai_chat_page.dart` (voice mode) and `chris_shopping_page.dart` now call `TtsService().speak(...)`; previously only the home-screen Chris FAB spoke replies |
| LifeX color/Overview redesign incomplete | **Done** | All 13 of 13 LifeX pages recolored to the neutral white/light-gray system. Overview tabs added on the 9 pages with genuinely separate sub-domains (hub is decorative, not tabbed); Feed/AI Insights/Export kept as single-scroll since their existing content already reads as a summary |
| Panther AI / TickPay theme unification — complete | — | Both the frontend theme unification (all ~51 pages) and the Net Worth backend pipeline (Plaid Investments/Liabilities, projection endpoint, Flutter wiring) described below are done. Kept as a historical marker; no outstanding work here. |
| Chris Shopping was fully local/hardcoded, never called Claude | **Done** | Fixed: see "Last updated" (previous entry) — added `search_products` tool + `POST /api/marketplace/search` to Panther AI, rewired `chris_shopping_page.dart` to call it |
| Panther AI Chat page — every message replied "Sorry, something went wrong: Chat failed" | **Done** | Root cause: `sendMessage()` called the Vercel `api/chat.js` function, which constructs its Anthropic client eagerly at module scope and 500s if the key isn't live at load time. Repointed at the local/EB Panther AI service's `/api/chris/chat` instead (real tool-calling, richer than Vercel's stateless call) and deleted the Vercel indirection; also wired real multi-turn history through for the first time on this page. See "Last updated" |
| Net Worth pipeline: crypto still mocked | Low | Investments and Liabilities now sync from real Plaid (with mock fallback) via `services/investments/ingestion.py`/`services/liabilities/ingestion.py`, and `GET /api/net-worth/projection` gives a real what-if projection. Crypto and "other savings" still use the Week-1 mock fixtures — crypto lives in BlockHub, not Plaid, so wiring it up is a separate cross-service integration (BlockHub wallet balances aren't exposed to the Python service yet) |
