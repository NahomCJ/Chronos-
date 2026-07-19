export interface AutonomousInvestorSettings {
    riskLevel: 'low' | 'medium' | 'high';
    investmentGoals: string[];
    budget: number;
    currency: string;
    portfolioPreferences: string[];
}
