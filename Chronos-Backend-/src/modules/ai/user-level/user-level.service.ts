import prisma from "../../../config/prisma";
import { UserLevel } from "@prisma/client";

const QUIZ_WEIGHTS: Record<string, Record<string, UserLevel>> = {
  q1: { a: "BEGINNER", b: "INTERMEDIATE", c: "ADVANCED" },
  q2: { a: "BEGINNER", b: "INTERMEDIATE", c: "ADVANCED" },
  q3: { a: "BEGINNER", b: "INTERMEDIATE", c: "ADVANCED" },
  q4: { a: "BEGINNER", b: "INTERMEDIATE", c: "ADVANCED" },
  q5: { a: "BEGINNER", b: "INTERMEDIATE", c: "ADVANCED" },
};

export function scoreQuiz(
  answers: Record<string, string>
): UserLevel {
  const counts: Record<UserLevel, number> = {
    BEGINNER: 0,
    INTERMEDIATE: 0,
    ADVANCED: 0,
  };

  for (const [question, answer] of Object.entries(answers)) {
    const mapping = QUIZ_WEIGHTS[question];
    if (mapping) {
      const level = mapping[answer.toLowerCase()];
      if (level) counts[level]++;
    }
  }

  if (counts.ADVANCED >= 3) return "ADVANCED";
  if (counts.INTERMEDIATE >= 3) return "INTERMEDIATE";
  if (counts.ADVANCED === 2 && counts.INTERMEDIATE >= 1) return "INTERMEDIATE";
  return "BEGINNER";
}

export async function setUserLevel(
  userId: string,
  level: UserLevel
): Promise<void> {
  await prisma.user.update({
    where: { id: userId },
    data: { userLevel: level },
  });
}

export async function getUserLevel(userId: string): Promise<UserLevel> {
  const user = await prisma.user.findUniqueOrThrow({
    where: { id: userId },
    select: { userLevel: true },
  });
  return user.userLevel;
}
