// src/core/cards/cards.types.ts

export interface IssueCardDTO {
  accountId: string;
  brand: string;
  last4: string;
  type: 'VIRTUAL' | 'PHYSICAL' | 'TICKPAY' | 'CRYPTO'; // string from request
}

export interface ReplaceCardDTO {
  brand: string;
  last4: string;
  type: 'VIRTUAL' | 'PHYSICAL' | 'TICKPAY' | 'CRYPTO';
}

export interface SetCardStatusDTO {
  status: 'ACTIVE' | 'FROZEN';
}
