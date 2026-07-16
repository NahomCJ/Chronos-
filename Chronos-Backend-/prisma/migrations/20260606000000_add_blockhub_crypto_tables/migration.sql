-- BlockHub crypto trading tables already declared in prisma/schema.prisma.

CREATE TYPE "TradeSide" AS ENUM ('BUY', 'SELL');

CREATE TYPE "TradeStatus" AS ENUM ('PENDING', 'FILLED', 'FAILED');

CREATE TYPE "RevenueType" AS ENUM ('TRADE_FEE', 'SPREAD');

CREATE TABLE "CryptoWallet" (
  "id" TEXT NOT NULL,
  "userId" TEXT NOT NULL,
  "paxosCustomerId" TEXT NOT NULL,
  "paxosWalletId" TEXT NOT NULL,
  "nftWalletAddress" TEXT,
  "userIndex" INTEGER NOT NULL DEFAULT 0,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "CryptoWallet_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Trade" (
  "id" TEXT NOT NULL,
  "userId" TEXT NOT NULL,
  "asset" TEXT NOT NULL,
  "side" "TradeSide" NOT NULL,
  "amountUsd" DECIMAL(18,2) NOT NULL,
  "amountCrypto" DECIMAL(18,8) NOT NULL,
  "fee" DECIMAL(18,2) NOT NULL,
  "executionPrice" DECIMAL(18,2) NOT NULL,
  "paxosOrderId" TEXT NOT NULL,
  "status" "TradeStatus" NOT NULL DEFAULT 'PENDING',
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "filledAt" TIMESTAMP(3),

  CONSTRAINT "Trade_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "PortfolioHolding" (
  "id" TEXT NOT NULL,
  "userId" TEXT NOT NULL,
  "asset" TEXT NOT NULL,
  "amount" DECIMAL(18,8) NOT NULL,
  "avgPrice" DECIMAL(18,2) NOT NULL,
  "updatedAt" TIMESTAMP(3) NOT NULL,

  CONSTRAINT "PortfolioHolding_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Revenue" (
  "id" TEXT NOT NULL,
  "userId" TEXT NOT NULL,
  "tradeId" TEXT NOT NULL,
  "type" "RevenueType" NOT NULL,
  "amount" DECIMAL(18,2) NOT NULL,
  "asset" TEXT NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "Revenue_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "AuditLog" (
  "id" TEXT NOT NULL,
  "userId" TEXT,
  "action" TEXT NOT NULL,
  "amount" DECIMAL(18,2),
  "asset" TEXT,
  "metadata" JSONB,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "CryptoWallet_userId_key" ON "CryptoWallet"("userId");
CREATE UNIQUE INDEX "CryptoWallet_paxosWalletId_key" ON "CryptoWallet"("paxosWalletId");
CREATE UNIQUE INDEX "PortfolioHolding_userId_asset_key" ON "PortfolioHolding"("userId", "asset");

ALTER TABLE "CryptoWallet"
  ADD CONSTRAINT "CryptoWallet_userId_fkey"
  FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "Trade"
  ADD CONSTRAINT "Trade_userId_fkey"
  FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "PortfolioHolding"
  ADD CONSTRAINT "PortfolioHolding_userId_fkey"
  FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "Revenue"
  ADD CONSTRAINT "Revenue_userId_fkey"
  FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "Revenue"
  ADD CONSTRAINT "Revenue_tradeId_fkey"
  FOREIGN KEY ("tradeId") REFERENCES "Trade"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "AuditLog"
  ADD CONSTRAINT "AuditLog_userId_fkey"
  FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
