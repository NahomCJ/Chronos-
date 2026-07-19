// ============================================================
// PaxosMapper — Paxos DTO <-> Internal DTO transformation
// ============================================================

import { PaxosOrder, PaxosBalance } from './paxos.types';

export interface InternalOrderResult {
  paxosOrderId: string;
  status: 'PENDING' | 'FILLED' | 'FAILED';
  fillPrice: number | null;
  cryptoAmount: number | null;
  usdAmount: number | null;
  filledAt: Date | null;
}

export interface InternalBalance {
  asset: string;
  available: number;
  trading: number;
}

export class PaxosMapper {
  static toInternalOrder(order: PaxosOrder): InternalOrderResult {
    const statusMap: Record<string, 'PENDING' | 'FILLED' | 'FAILED'> = {
      PENDING: 'PENDING',
      OPEN: 'PENDING',
      PARTIALLY_FILLED: 'PENDING',
      FILLED: 'FILLED',
      FAILED: 'FAILED',
      CANCELLED: 'FAILED',
    };

    return {
      paxosOrderId: order.id,
      status: statusMap[order.status] ?? 'PENDING',
      fillPrice: order.fill_price ? parseFloat(order.fill_price) : null,
      cryptoAmount: order.base_amount ? parseFloat(order.base_amount) : null,
      usdAmount: order.quote_amount ? parseFloat(order.quote_amount) : null,
      filledAt: order.filled_at ? new Date(order.filled_at) : null,
    };
  }

  static toInternalBalance(balance: PaxosBalance): InternalBalance {
    return {
      asset: balance.asset,
      available: parseFloat(balance.available),
      trading: parseFloat(balance.trading),
    };
  }
}
