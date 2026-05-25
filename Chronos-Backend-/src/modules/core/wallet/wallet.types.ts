// src/modules/core/wallet/wallet.types.ts

export type WalletType =
  | "FIAT"
  | "CRYPTO"
  | "STABLECOIN"
  | "SYSTEM"
  | "ESCROW"
  | "SETTLEMENT"
  | "FEE_POOL";

export type WalletStatus = "ACTIVE" | "INACTIVE" | "FROZEN";

export interface CreateWalletInput {
  accountId: string;
  currency: string;
  type: WalletType;
}

export interface WalletDTO {
  id: string;
  accountId: string;
  currency: string;
  type: WalletType;
  status: WalletStatus;
  createdAt: string;
  updatedAt: string;
}