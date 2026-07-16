/*
  Warnings:

  - The values [EXECUTING,FILLED,CANCELED] on the enum `FxOrderStatus` will be removed. If these variants are still used in the database, this will fail.
  - You are about to drop the column `type` on the `LedgerEntry` table. All the data in the column will be lost.
  - Added the required column `category` to the `LedgerEntry` table without a default value. This is not possible if the table is not empty.
  - Added the required column `direction` to the `LedgerEntry` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "LedgerDirection" AS ENUM ('DEBIT', 'CREDIT');

-- CreateEnum
CREATE TYPE "LedgerCategory" AS ENUM ('TRANSFER', 'FEE', 'FX', 'ADJUSTMENT');

-- AlterEnum
BEGIN;
CREATE TYPE "FxOrderStatus_new" AS ENUM ('QUOTED', 'LOCKED', 'EXECUTED', 'FAILED', 'EXPIRED', 'CANCELLED');
ALTER TABLE "public"."FxOrder" ALTER COLUMN "status" DROP DEFAULT;
ALTER TABLE "FxOrder" ALTER COLUMN "status" TYPE "FxOrderStatus_new" USING ("status"::text::"FxOrderStatus_new");
ALTER TYPE "FxOrderStatus" RENAME TO "FxOrderStatus_old";
ALTER TYPE "FxOrderStatus_new" RENAME TO "FxOrderStatus";
DROP TYPE "public"."FxOrderStatus_old";
ALTER TABLE "FxOrder" ALTER COLUMN "status" SET DEFAULT 'QUOTED';
COMMIT;

-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "WalletType" ADD VALUE 'SYSTEM';
ALTER TYPE "WalletType" ADD VALUE 'ESCROW';
ALTER TYPE "WalletType" ADD VALUE 'SETTLEMENT';
ALTER TYPE "WalletType" ADD VALUE 'FEE_POOL';

-- AlterTable
ALTER TABLE "LedgerEntry" DROP COLUMN "type",
ADD COLUMN     "category" "LedgerCategory" NOT NULL,
ADD COLUMN     "direction" "LedgerDirection" NOT NULL;

-- DropEnum
DROP TYPE "LedgerEntryType";

-- CreateTable
CREATE TABLE "IdempotencyKey" (
    "id" TEXT NOT NULL,
    "key" TEXT NOT NULL,
    "userId" TEXT,
    "requestHash" TEXT NOT NULL,
    "response" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "IdempotencyKey_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "IdempotencyKey_key_key" ON "IdempotencyKey"("key");
