# BlockHub Crypto Testing

This backend sprint has three test tiers.

## Deterministic Crypto Suite

Run:

```bash
npm run test:crypto
```

This command disables global database cleanup with `SKIP_DB_TEST_SETUP=true` and runs the crypto-focused Jest suite with mocked Prisma, Paxos, auth, and Plaid dependencies.

Coverage:

- Paxos config, OAuth caching, endpoint paths, retry/error mapping, balances, transfers, order polling, and CoinGecko fallback.
- Trading/compliance gates, no-order-on-rejection behavior, insufficient balance handling, buy/sell accounting, revenue writes, holding math, history, lazy wallet provisioning, and audit failures.
- Express route contract for all `/api/v1/crypto` endpoints, including validation and public error mapping.
- KYC wallet provisioning hooks for admin approval, Plaid session completion, and Plaid webhooks.
- Static contract checks for migration SQL, env vars, package scripts, and Postman route drift.

For coverage output:

```bash
npm run test:crypto:coverage
```

## Schema Checks

Run schema validation without requiring a real database connection:

```bash
DATABASE_URL=postgresql://user:pass@localhost:5432/chronos npx prisma validate
```

Migration drift against the migrations directory requires a real PostgreSQL shadow database:

```bash
npx prisma migrate diff \
  --from-migrations prisma/migrations \
  --to-schema-datamodel prisma/schema.prisma \
  --shadow-database-url "$SHADOW_DATABASE_URL" \
  --script
```

## Live Paxos Sandbox Smoke Test

Run:

```bash
npm run test:paxos:sandbox
```

Without `PAXOS_CLIENT_ID`, `PAXOS_CLIENT_SECRET`, and `PAXOS_PROFILE_ID`, the command exits successfully with a skip message.

With credentials present, it validates OAuth, balances, transfer listing, and prices for BTC, ETH, SOL, UNI, AAVE, and LINK.

Mutation checks are gated:

```bash
PAXOS_SANDBOX_RUN_TRADES=true npm run test:paxos:sandbox
PAXOS_SANDBOX_RUN_TRANSFERS=true npm run test:paxos:sandbox
```

Transfers also require `PAXOS_SETTLEMENT_PROFILE_ID`.

## Known Repo-Wide Blockers

`npm test -- --runInBand` and `npm run build` currently include unrelated legacy modules. As of this sprint, failures remain in standalone BlockHub legacy specs, core account/controller type errors, and missing or stale modules outside `src/modules/crypto`.
