import fs from "fs";
import path from "path";

const root = path.resolve(__dirname, "../../../../");

function read(relativePath: string) {
  return fs.readFileSync(path.join(root, relativePath), "utf8");
}

describe("BlockHub crypto backend contract files", () => {
  it("keeps the crypto migration aligned to the Prisma BlockHub models", () => {
    const migration = read(
      "prisma/migrations/20260606000000_add_blockhub_crypto_tables/migration.sql",
    );

    for (const ddl of [
      'CREATE TYPE "TradeSide"',
      'CREATE TYPE "TradeStatus"',
      'CREATE TYPE "RevenueType"',
      'CREATE TABLE "CryptoWallet"',
      'CREATE TABLE "Trade"',
      'CREATE TABLE "PortfolioHolding"',
      'CREATE TABLE "Revenue"',
      'CREATE TABLE "AuditLog"',
      'CREATE UNIQUE INDEX "CryptoWallet_userId_key"',
      'CREATE UNIQUE INDEX "CryptoWallet_paxosWalletId_key"',
      'CREATE UNIQUE INDEX "PortfolioHolding_userId_asset_key"',
      'REFERENCES "User"("id") ON DELETE CASCADE',
      'REFERENCES "User"("id") ON DELETE SET NULL',
      'REFERENCES "Trade"("id") ON DELETE RESTRICT',
    ]) {
      expect(migration).toContain(ddl);
    }
  });

  it("documents all required Paxos and trading environment variables", () => {
    const envExample = read(".env.example");
    const envDocs = read("docs/env.md");

    for (const variable of [
      "PAXOS_ENV",
      "PAXOS_CLIENT_ID",
      "PAXOS_CLIENT_SECRET",
      "PAXOS_PROFILE_ID",
      "PAXOS_SETTLEMENT_PROFILE_ID",
      "PAXOS_SCOPES",
      "FEE_RATE_DEFAULT",
      "SPREAD_RATE",
      "DAILY_TRADE_LIMIT_STANDARD",
      "DAILY_TRADE_LIMIT_VERIFIED_PLUS",
      "PAXOS_ORDER_POLL_INTERVAL_MS",
      "PAXOS_ORDER_POLL_ATTEMPTS",
      "PAXOS_SANDBOX_RUN_TRADES",
      "PAXOS_SANDBOX_RUN_TRANSFERS",
      "PAXOS_SANDBOX_TRADE_AMOUNT_USD",
    ]) {
      expect(envExample).toContain(variable);
      expect(envDocs).toContain(variable);
    }
  });

  it("keeps the Postman crypto collection on the Express backend contract", () => {
    const collection = read("Chronos-API.postman_collection.json");
    const generator = read("scripts/add_blockhub_postman.py");

    for (const contract of [
      "/api/v1/crypto/price/BTC",
      "/api/v1/crypto/price/ETH",
      "/api/v1/crypto/price/SOL",
      "/api/v1/crypto/price/UNI",
      "/api/v1/crypto/price/AAVE",
      "/api/v1/crypto/price/LINK",
      "/api/v1/crypto/history?page=1&limit=25",
      "/api/v1/crypto/buy",
      "/api/v1/crypto/sell",
    ]) {
      expect(collection).toContain(contract);
      expect(generator).toContain(contract);
    }

    expect(collection).toContain('\\"amount_usd\\": 5');
    expect(collection).toContain('\\"amount_crypto\\": 0.0001');
    expect(generator).toContain('"amount_usd": 5');
    expect(generator).toContain('"amount_crypto": 0.0001');

    for (const stale of [
      "/market/prices",
      "/api/v1/trade/buy",
      "/api/v1/trade/sell",
      '"amountUsd"',
      '"quantity"',
    ]) {
      expect(generator).not.toContain(stale);
    }
  });

  it("exposes deterministic crypto test commands", () => {
    const packageJson = JSON.parse(read("package.json"));

    expect(packageJson.scripts).toMatchObject({
      "test:crypto": expect.stringContaining("SKIP_DB_TEST_SETUP=true"),
      "test:crypto:coverage": expect.stringContaining("--coverage"),
      "test:paxos:sandbox": "tsx scripts/paxos-sandbox-smoke.ts",
    });
  });
});
