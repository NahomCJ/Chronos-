// src/services/gov.service.ts

import { v4 as uuidv4 } from 'uuid';
import { mockGovPayments } from '../models/gov.model';

export const payGovernmentFee = async (userId: string, type: string, amount: number) => {
    const payment = {
        id: uuidv4(),
        userId,
        type,
        amount,
        refNumber: 'GOV-' + Math.floor(Math.random() * 999999),
        submittedAt: new Date(),
    };

    mockGovPayments.push(payment);
    return payment;
};
