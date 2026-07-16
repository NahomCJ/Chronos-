import axios from 'axios';

export const getSummary = async (userId: string) => {
    // mock or connect to PyCharm AI summary API
    return {
        userId,
        netWorth: 10250,
        riskLevel: 'moderate',
        topCategories: ['Investments', 'Savings'],
        recommendedAllocation: {
            crypto: 10,
            etfs: 40,
            cash: 30,
            bonds: 20,
        },
    };
};

export const getAdvice = async (userId: string) => {
    // Call real AI engine later
    return {
        message: 'AI-generated advice',
        advice: `User ${userId} should invest 25% in low-risk assets, 15% in crypto.`,
    };
};

export const trackGoal = async ({ userId, goal, target, deadline }: any) => {
    return {
        message: `Goal '${goal}' tracked successfully.`,
        progress: '0%',
        target,
        deadline,
    };
};

export const setupAutoSave = async ({ userId, amount, frequency }: any) => {
    return {
        message: `Auto-saving $${amount} every ${frequency} set up for user ${userId}.`,
    };
};
