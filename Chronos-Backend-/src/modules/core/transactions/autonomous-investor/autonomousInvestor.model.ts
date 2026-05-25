import { Schema, model } from 'mongoose';
import { AutonomousInvestorSettings } from './autonomousInvestor.interface';

const autonomousInvestorSchema = new Schema<AutonomousInvestorSettings>({
    riskLevel: { type: String, enum: ['low', 'medium', 'high'], required: true },
    investmentGoals: { type: [String], required: true },
    budget: { type: Number, required: true },
    currency: { type: String, required: true },
    portfolioPreferences: { type: [String], required: true }
}, { timestamps: true });

export const AutonomousInvestorModel = model<AutonomousInvestorSettings>('AutonomousInvestor', autonomousInvestorSchema);
