/*
  Warnings:

  - The values [ACTIVE,CLOSED] on the enum `AccountStatus` will be removed. If these variants are still used in the database, this will fail.
  - The `riskLevel` column on the `BankingProfile` table would be dropped and recreated. This will lead to data loss if there is data in the column.

*/
-- CreateEnum
CREATE TYPE "RiskLevel" AS ENUM ('LOW', 'MEDIUM', 'HIGH');

-- AlterEnum
BEGIN;
CREATE TYPE "AccountStatus_new" AS ENUM ('DRAFT', 'PENDING', 'APPROVED', 'REJECTED', 'SUSPENDED');
ALTER TABLE "public"."Account" ALTER COLUMN "status" DROP DEFAULT;
ALTER TABLE "public"."BankingProfile" ALTER COLUMN "status" DROP DEFAULT;
ALTER TABLE "Account" ALTER COLUMN "status" TYPE "AccountStatus_new" USING ("status"::text::"AccountStatus_new");
ALTER TABLE "BankingProfile" ALTER COLUMN "status" TYPE "AccountStatus_new" USING ("status"::text::"AccountStatus_new");
ALTER TYPE "AccountStatus" RENAME TO "AccountStatus_old";
ALTER TYPE "AccountStatus_new" RENAME TO "AccountStatus";
DROP TYPE "public"."AccountStatus_old";
ALTER TABLE "Account" ALTER COLUMN "status" SET DEFAULT 'DRAFT';
ALTER TABLE "BankingProfile" ALTER COLUMN "status" SET DEFAULT 'DRAFT';
COMMIT;

-- AlterTable
ALTER TABLE "BankingProfile" ADD COLUMN     "approvedAt" TIMESTAMP(3),
ADD COLUMN     "rejectedAt" TIMESTAMP(3),
ADD COLUMN     "rejectionReason" TEXT,
ADD COLUMN     "submittedAt" TIMESTAMP(3),
DROP COLUMN "riskLevel",
ADD COLUMN     "riskLevel" "RiskLevel";
