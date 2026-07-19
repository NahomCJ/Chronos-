// ============================================================
// Paxos Type Definitions (Module 2)
// ============================================================

export interface PaxosTokenResponse {
  access_token: string;
  token_type: string;
  expires_in: number;
  scope: string;
}

export interface PaxosCachedToken {
  token: string;
  expiresAt: number; // Unix timestamp ms
}

// ---- Identity / Customer ----
export interface PaxosCreateIdentityRequest {
  ref_id: string;               // Your internal user ID
  customer_type: 'INDIVIDUAL';
  first_name: string;
  last_name: string;
  email: string;
  date_of_birth?: string;       // YYYY-MM-DD
  tax_id_number?: string;
  country_of_citizenship?: string;
}

export interface PaxosIdentity {
  id: string;
  ref_id: string;
  status: 'ACTIVE' | 'PENDING' | 'REJECTED';
  customer_type: string;
}

// ---- Account / Profile ----
export interface PaxosCreateProfileRequest {
  identity_id: string;
  ref_id: string;
}

export interface PaxosProfile {
  id: string;         // This is used as "customer ID" in our system
  identity_id: string;
  status: 'ACTIVE' | 'PENDING';
}

// ---- Wallet / Account Balance ----
export interface PaxosBalance {
  asset: string;
  available: string;    // Paxos returns strings for precision
  trading: string;
}

export interface PaxosBalancesResponse {
  items: PaxosBalance[];
}

// ---- Orders ----
export type PaxosOrderSide = 'BUY' | 'SELL';
export type PaxosOrderStatus = 'PENDING' | 'OPEN' | 'FILLED' | 'PARTIALLY_FILLED' | 'CANCELLED' | 'FAILED';

export interface PaxosCreateOrderRequest {
  profile_id: string;           // Paxos profile/customer ID
  side: PaxosOrderSide;
  market: string;               // e.g. 'BTCUSD', 'ETHUSD', 'SOLUSD'
  type: 'MARKET';
  base_amount?: string;         // Crypto amount (for SELL)
  quote_amount?: string;        // USD amount (for BUY)
  client_order_id?: string;     // Idempotency key — use your trade UUID
}

export interface PaxosOrder {
  id: string;
  client_order_id?: string;
  profile_id: string;
  side: PaxosOrderSide;
  market: string;
  type: string;
  status: PaxosOrderStatus;
  filled_at?: string;
  fill_price?: string;
  base_amount?: string;
  quote_amount?: string;
  created_at: string;
  updated_at: string;
}

// ---- Market Data ----
export interface PaxosMarketTicker {
  market: string;   // e.g. 'BTCUSD'
  price: string;    // Latest trade price as string
  bid: string;
  ask: string;
  timestamp: string;
}

// ---- Transfers ----
export interface PaxosTransfer {
  id: string;
  type: string;
  status: string;
  amount: string;
  asset: string;
  profile_id: string;
  created_at: string;
}

export interface PaxosTransfersResponse {
  items: PaxosTransfer[];
  next_page_cursor?: string;
}

// ---- Internal Error ----
export class PaxosApiError extends Error {
  constructor(
    public readonly code: string,
    message: string,
    public readonly statusCode: number,
    public readonly raw?: any,
  ) {
    super(message);
    this.name = 'PaxosApiError';
  }
}
