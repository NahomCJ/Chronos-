export type AdviceInput = {
  userId: string;
  goals?: string[];
  riskTolerance?: "low" | "medium" | "high";
  context?: Record<string, any>;
};

export type AdviceDTO = {
  summary: string;
  actions: string[];
  allocations?: Record<string, number>;
  caveats?: string[];
};

export type TickPayAnalysisInput = {
  userId: string;
  amount: number;
  category?: string;
};

export type TickPayAnalysisDTO = {
  approved: boolean;
  reason?: string;
  recommendedBudget?: number;
  suggestedAlternatives?: { name: string; price: number; url?: string }[];
};
