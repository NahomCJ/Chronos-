import { AutonomousInvestorModel } from './autonomousInvestor.model';
import { AutonomousInvestorSettings } from './autonomousInvestor.interface';

export class AutonomousInvestorService {
    async createSettings(settings: AutonomousInvestorSettings) {
        const newSettings = new AutonomousInvestorModel(settings);
        return newSettings.save();
    }

    async getSettings(userId: string) {
        return AutonomousInvestorModel.findOne({ userId });
    }

    async updateSettings(userId: string, settings: Partial<AutonomousInvestorSettings>) {
        return AutonomousInvestorModel.findOneAndUpdate({ userId }, settings, { new: true });
    }

    // Placeholder for AI integration
    async generateInvestmentPlan(userId: string) {
        // Here we’ll integrate the AI token and logic later
        return { message: "Investment plan will be generated here after AI integration." };
    }
}
