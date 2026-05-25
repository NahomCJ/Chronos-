import { PlanFrequency } from '@prisma/client';

export interface CreateSavingsDto {
  goalName: string;
  targetAmount: number;
  frequency: PlanFrequency;
}
