// src/types/gov.types.ts

export interface GovernmentPayment {
    id: string;
    userId: string;
    type: 'tax' | 'transport' | 'education' | 'visa';
    amount: number;
    refNumber: string;
    submittedAt: Date;
}
