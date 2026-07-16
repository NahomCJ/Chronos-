/*
  Warnings:

  - You are about to drop the column `fromAccountId` on the `FxOrder` table. All the data in the column will be lost.
  - You are about to drop the column `toAccountId` on the `FxOrder` table. All the data in the column will be lost.
  - Added the required column `fromWalletId` to the `FxOrder` table without a default value. This is not possible if the table is not empty.
  - Added the required column `toWalletId` to the `FxOrder` table without a default value. This is not possible if the table is not empty.

*/
-- DropForeignKey
ALTER TABLE "FxOrder" DROP CONSTRAINT "FxOrder_fromAccountId_fkey";

-- DropForeignKey
ALTER TABLE "FxOrder" DROP CONSTRAINT "FxOrder_toAccountId_fkey";

-- AlterTable
ALTER TABLE "FxOrder" DROP COLUMN "fromAccountId",
DROP COLUMN "toAccountId",
ADD COLUMN     "fromWalletId" TEXT NOT NULL,
ADD COLUMN     "toWalletId" TEXT NOT NULL;

-- AddForeignKey
ALTER TABLE "FxOrder" ADD CONSTRAINT "FxOrder_fromWalletId_fkey" FOREIGN KEY ("fromWalletId") REFERENCES "Wallet"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FxOrder" ADD CONSTRAINT "FxOrder_toWalletId_fkey" FOREIGN KEY ("toWalletId") REFERENCES "Wallet"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
