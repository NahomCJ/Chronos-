/*
  Warnings:

  - You are about to drop the column `goal` on the `Habit` table. All the data in the column will be lost.
  - You are about to drop the column `name` on the `Habit` table. All the data in the column will be lost.
  - You are about to drop the column `reminderAt` on the `Habit` table. All the data in the column will be lost.
  - You are about to drop the column `status` on the `Habit` table. All the data in the column will be lost.
  - You are about to alter the column `progress` on the `Habit` table. The data in that column could be lost. The data in that column will be cast from `DoublePrecision` to `Integer`.
  - Added the required column `title` to the `Habit` table without a default value. This is not possible if the table is not empty.
  - Added the required column `type` to the `Habit` table without a default value. This is not possible if the table is not empty.
  - Changed the type of `frequency` on the `Habit` table. No cast exists, the column would be dropped and recreated, which cannot be done if there is data, since the column is required.

*/
-- AlterTable
ALTER TABLE "Habit" DROP COLUMN "goal",
DROP COLUMN "name",
DROP COLUMN "reminderAt",
DROP COLUMN "status",
ADD COLUMN     "completedAt" TIMESTAMP(3),
ADD COLUMN     "reminders" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "title" TEXT NOT NULL,
ADD COLUMN     "type" TEXT NOT NULL,
DROP COLUMN "frequency",
ADD COLUMN     "frequency" INTEGER NOT NULL,
ALTER COLUMN "progress" SET DEFAULT 0,
ALTER COLUMN "progress" SET DATA TYPE INTEGER;
