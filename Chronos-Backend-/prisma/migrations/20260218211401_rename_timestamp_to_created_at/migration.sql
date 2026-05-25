/*
  Warnings:

  - You are about to drop the column `timestamp` on the `ExchangeRate` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "ExchangeRate" DROP COLUMN "timestamp",
ADD COLUMN     "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP;
