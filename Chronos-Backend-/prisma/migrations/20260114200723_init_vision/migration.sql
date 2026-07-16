/*
  Warnings:

  - You are about to alter the column `progress` on the `habit_tracker` table. The data in that column could be lost. The data in that column will be cast from `Decimal(5,2)` to `DoublePrecision`.

*/
-- AlterTable
ALTER TABLE "habit_tracker" ALTER COLUMN "progress" DROP NOT NULL,
ALTER COLUMN "progress" SET DEFAULT 0,
ALTER COLUMN "progress" SET DATA TYPE DOUBLE PRECISION;
