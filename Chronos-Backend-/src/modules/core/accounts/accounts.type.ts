// src/core/accounts/accounts.types.ts

export type AccountType = 'CHECKING' | 'SAVINGS' | 'CREDIT' | 'INVESTMENT';

export type AccountStatus = 'DRAFT' | 'ACTIVE' | 'SUSPENDED' | 'CLOSED';

export interface CreateAccountDTO {
  type: AccountType;     // Enforced enum
  currency?: string;     // Default handled in service (USD)
  tier?: string;         // e.g., 'basic', 'premium'
}

export interface UpdateAccountDTO {
   id: string; 
  type?: AccountType;
  currency?: string;
  tier?: string;
  status?: AccountStatus;
}
