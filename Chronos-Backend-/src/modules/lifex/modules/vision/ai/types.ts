export interface AIRecommendation {
  type: "HABIT" | "COURSE" | "MENTOR" | "GOAL";
  title: string;
  reason: string;
}
