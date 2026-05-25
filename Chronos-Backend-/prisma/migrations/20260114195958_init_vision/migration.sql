-- CreateEnum
CREATE TYPE "GoalCategory" AS ENUM ('CAREER', 'PERSONAL', 'FINANCE', 'HEALTH', 'SOCIAL', 'SPIRITUAL');

-- CreateEnum
CREATE TYPE "GoalStatus" AS ENUM ('ACTIVE', 'COMPLETED', 'PAUSED');

-- CreateEnum
CREATE TYPE "MilestoneStatus" AS ENUM ('PENDING', 'COMPLETED', 'MISSED');

-- CreateEnum
CREATE TYPE "HabitFrequency" AS ENUM ('DAILY', 'WEEKLY', 'MONTHLY');

-- CreateEnum
CREATE TYPE "HabitStatus" AS ENUM ('ACTIVE', 'COMPLETED', 'PAUSED');

-- CreateEnum
CREATE TYPE "MentorshipStatus" AS ENUM ('UPCOMING', 'COMPLETED', 'CANCELED');

-- CreateEnum
CREATE TYPE "CourseStatus" AS ENUM ('ACTIVE', 'ARCHIVED');

-- CreateEnum
CREATE TYPE "CommunityCategory" AS ENUM ('CAREER', 'PERSONAL', 'HEALTH', 'SOCIAL', 'SPIRITUAL');

-- CreateEnum
CREATE TYPE "NotificationStatus" AS ENUM ('PENDING', 'SENT', 'FAILED');

-- CreateTable
CREATE TABLE "vision_board" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "imageUrls" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "vision_board_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "long_term_goal" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "category" "GoalCategory" NOT NULL,
    "startDate" TIMESTAMP(3) NOT NULL,
    "endDate" TIMESTAMP(3) NOT NULL,
    "status" "GoalStatus" NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "long_term_goal_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "milestone" (
    "id" TEXT NOT NULL,
    "goalId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "dueDate" TIMESTAMP(3) NOT NULL,
    "status" "MilestoneStatus" NOT NULL DEFAULT 'PENDING',

    CONSTRAINT "milestone_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "habit_tracker" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "habitName" TEXT NOT NULL,
    "frequency" "HabitFrequency" NOT NULL,
    "progress" DECIMAL(5,2) NOT NULL,
    "status" "HabitStatus" NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "habit_tracker_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "mentorship_program" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "mentorId" TEXT NOT NULL,
    "schedule" TIMESTAMP(3) NOT NULL,
    "status" "MentorshipStatus" NOT NULL DEFAULT 'UPCOMING',

    CONSTRAINT "mentorship_program_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "community_group" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "category" "CommunityCategory" NOT NULL,
    "members" JSONB NOT NULL,

    CONSTRAINT "community_group_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "milestone" ADD CONSTRAINT "milestone_goalId_fkey" FOREIGN KEY ("goalId") REFERENCES "long_term_goal"("id") ON DELETE CASCADE ON UPDATE CASCADE;
