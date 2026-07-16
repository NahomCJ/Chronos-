-- CreateEnum
CREATE TYPE "FxOrderStatus" AS ENUM ('QUOTED', 'EXECUTING', 'FILLED', 'CANCELED', 'FAILED');

-- CreateEnum
CREATE TYPE "CardType" AS ENUM ('VIRTUAL', 'PHYSICAL', 'CRYPTO', 'DISPOSABLE');

-- CreateEnum
CREATE TYPE "CardStatus" AS ENUM ('ACTIVE', 'BLOCKED', 'INACTIVE', 'EXPIRED');

-- CreateEnum
CREATE TYPE "TickPayAccountStatus" AS ENUM ('ACTIVE', 'SUSPENDED', 'CLOSED');

-- CreateEnum
CREATE TYPE "TickPayTransactionType" AS ENUM ('PURCHASE', 'REPAYMENT', 'REFUND', 'FEE', 'ADJUSTMENT');

-- CreateEnum
CREATE TYPE "TickPayTransactionStatus" AS ENUM ('PENDING', 'COMPLETED', 'FAILED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "TickPayFeeStatus" AS ENUM ('SCHEDULED', 'DUE', 'PAID', 'MISSED', 'CANCELLED');

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "firstName" TEXT NOT NULL,
    "middleName" TEXT,
    "lastName" TEXT NOT NULL,
    "phone" TEXT,
    "isEmailVerified" BOOLEAN NOT NULL DEFAULT false,
    "otpCode" TEXT,
    "otpExpiresAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Account" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "accountNumber" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "balance" DECIMAL(30,8) NOT NULL DEFAULT 0,
    "currency" TEXT NOT NULL DEFAULT 'USD',
    "status" TEXT NOT NULL DEFAULT 'active',
    "tier" TEXT NOT NULL DEFAULT 'basic',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Account_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Transfer" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "fromAccountId" TEXT NOT NULL,
    "toAccountId" TEXT,
    "toExternal" JSONB,
    "amount" DECIMAL(30,8) NOT NULL,
    "currency" TEXT NOT NULL,
    "fee" DECIMAL(30,8) NOT NULL DEFAULT 0,
    "status" TEXT NOT NULL,
    "reference" TEXT,
    "note" TEXT,
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Transfer_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TransferTransaction" (
    "id" TEXT NOT NULL,
    "transferId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "accountId" TEXT,
    "amount" DECIMAL(30,8) NOT NULL,
    "currency" TEXT NOT NULL,
    "reference" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TransferTransaction_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TransferAudit" (
    "id" TEXT NOT NULL,
    "transferId" TEXT NOT NULL,
    "actorId" TEXT,
    "action" TEXT NOT NULL,
    "payload" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TransferAudit_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FxOrder" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "fromAccountId" TEXT NOT NULL,
    "toAccountId" TEXT NOT NULL,
    "side" TEXT NOT NULL,
    "buyCurrency" TEXT NOT NULL,
    "sellCurrency" TEXT NOT NULL,
    "buyAmount" DECIMAL(18,6),
    "sellAmount" DECIMAL(18,6),
    "rate" DECIMAL(18,10),
    "provider" TEXT NOT NULL,
    "providerRef" TEXT,
    "status" "FxOrderStatus" NOT NULL DEFAULT 'QUOTED',
    "expiresAt" TIMESTAMP(3),
    "meta" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "FxOrder_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Card" (
    "id" TEXT NOT NULL,
    "accountId" TEXT NOT NULL,
    "brand" TEXT NOT NULL,
    "last4" TEXT NOT NULL,
    "type" "CardType" NOT NULL,
    "status" "CardStatus" NOT NULL DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Card_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TickPayOnboarding" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "employmentStatus" TEXT NOT NULL,
    "employerName" TEXT,
    "monthlySalary" DECIMAL(30,8),
    "incomeFrequency" TEXT,
    "primaryIncomeSrc" TEXT,
    "secondaryIncome" DECIMAL(30,8),
    "bankName" TEXT,
    "accountType" TEXT,
    "monthlyRent" DECIMAL(30,8),
    "monthlyUtilities" DECIMAL(30,8),
    "otherObligations" DECIMAL(30,8),
    "outstandingLoans" DECIMAL(30,8),
    "avgMonthlySpending" DECIMAL(30,8),
    "purpose" TEXT,
    "spendingPrefs" TEXT,
    "agreedTerms" BOOLEAN NOT NULL DEFAULT false,
    "agreedDataSharing" BOOLEAN NOT NULL DEFAULT false,
    "noRecentBankruptcy" BOOLEAN,
    "score" INTEGER,
    "recommendedLimit" DECIMAL(30,8),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "TickPayOnboarding_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TickPayAccount" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "creditLimit" DECIMAL(30,8) NOT NULL DEFAULT 500,
    "balance" DECIMAL(30,8) NOT NULL DEFAULT 0,
    "available" DECIMAL(30,8),
    "status" "TickPayAccountStatus" NOT NULL DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "TickPayAccount_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TickPayTransaction" (
    "id" TEXT NOT NULL,
    "tickPayAccountId" TEXT NOT NULL,
    "type" "TickPayTransactionType" NOT NULL,
    "status" "TickPayTransactionStatus" NOT NULL DEFAULT 'PENDING',
    "amount" DECIMAL(30,8) NOT NULL,
    "currency" TEXT NOT NULL DEFAULT 'USD',
    "merchant" TEXT,
    "meta" JSONB,
    "reference" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "TickPayTransaction_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TickPayFeeInstallment" (
    "id" TEXT NOT NULL,
    "tickPayAccountId" TEXT NOT NULL,
    "purchaseTxId" TEXT,
    "amount" DECIMAL(30,8) NOT NULL,
    "status" "TickPayFeeStatus" NOT NULL DEFAULT 'SCHEDULED',
    "dueDate" TIMESTAMP(3) NOT NULL,
    "paidAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "TickPayFeeInstallment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TickPayCard" (
    "id" TEXT NOT NULL,
    "cardId" TEXT NOT NULL,
    "tickPayAccountId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "TickPayCard_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TickPayAudit" (
    "id" TEXT NOT NULL,
    "accountId" TEXT NOT NULL,
    "actorId" TEXT,
    "action" TEXT NOT NULL,
    "payload" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TickPayAudit_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE UNIQUE INDEX "User_phone_key" ON "User"("phone");

-- CreateIndex
CREATE UNIQUE INDEX "Account_accountNumber_key" ON "Account"("accountNumber");

-- CreateIndex
CREATE UNIQUE INDEX "Transfer_reference_key" ON "Transfer"("reference");

-- CreateIndex
CREATE INDEX "Transfer_userId_idx" ON "Transfer"("userId");

-- CreateIndex
CREATE INDEX "Transfer_reference_idx" ON "Transfer"("reference");

-- CreateIndex
CREATE INDEX "TransferTransaction_transferId_idx" ON "TransferTransaction"("transferId");

-- CreateIndex
CREATE INDEX "TransferAudit_transferId_idx" ON "TransferAudit"("transferId");

-- CreateIndex
CREATE UNIQUE INDEX "TickPayOnboarding_userId_key" ON "TickPayOnboarding"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "TickPayAccount_userId_key" ON "TickPayAccount"("userId");

-- CreateIndex
CREATE INDEX "TickPayFeeInstallment_tickPayAccountId_dueDate_idx" ON "TickPayFeeInstallment"("tickPayAccountId", "dueDate");

-- CreateIndex
CREATE UNIQUE INDEX "TickPayCard_cardId_key" ON "TickPayCard"("cardId");

-- CreateIndex
CREATE UNIQUE INDEX "TickPayCard_tickPayAccountId_key" ON "TickPayCard"("tickPayAccountId");

-- AddForeignKey
ALTER TABLE "Account" ADD CONSTRAINT "Account_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Transfer" ADD CONSTRAINT "Transfer_fromAccountId_fkey" FOREIGN KEY ("fromAccountId") REFERENCES "Account"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Transfer" ADD CONSTRAINT "Transfer_toAccountId_fkey" FOREIGN KEY ("toAccountId") REFERENCES "Account"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TransferTransaction" ADD CONSTRAINT "TransferTransaction_transferId_fkey" FOREIGN KEY ("transferId") REFERENCES "Transfer"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TransferAudit" ADD CONSTRAINT "TransferAudit_transferId_fkey" FOREIGN KEY ("transferId") REFERENCES "Transfer"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FxOrder" ADD CONSTRAINT "FxOrder_fromAccountId_fkey" FOREIGN KEY ("fromAccountId") REFERENCES "Account"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FxOrder" ADD CONSTRAINT "FxOrder_toAccountId_fkey" FOREIGN KEY ("toAccountId") REFERENCES "Account"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FxOrder" ADD CONSTRAINT "FxOrder_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Card" ADD CONSTRAINT "Card_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES "Account"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TickPayOnboarding" ADD CONSTRAINT "TickPayOnboarding_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TickPayAccount" ADD CONSTRAINT "TickPayAccount_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TickPayTransaction" ADD CONSTRAINT "TickPayTransaction_tickPayAccountId_fkey" FOREIGN KEY ("tickPayAccountId") REFERENCES "TickPayAccount"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TickPayFeeInstallment" ADD CONSTRAINT "TickPayFeeInstallment_tickPayAccountId_fkey" FOREIGN KEY ("tickPayAccountId") REFERENCES "TickPayAccount"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TickPayFeeInstallment" ADD CONSTRAINT "TickPayFeeInstallment_purchaseTxId_fkey" FOREIGN KEY ("purchaseTxId") REFERENCES "TickPayTransaction"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TickPayCard" ADD CONSTRAINT "TickPayCard_cardId_fkey" FOREIGN KEY ("cardId") REFERENCES "Card"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TickPayCard" ADD CONSTRAINT "TickPayCard_tickPayAccountId_fkey" FOREIGN KEY ("tickPayAccountId") REFERENCES "TickPayAccount"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
