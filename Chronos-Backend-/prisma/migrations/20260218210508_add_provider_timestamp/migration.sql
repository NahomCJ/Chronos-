/*
  Warnings:

  - Added the required column `provider` to the `ExchangeRate` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "ExchangeRate" ADD COLUMN     "provider" TEXT NOT NULL;
