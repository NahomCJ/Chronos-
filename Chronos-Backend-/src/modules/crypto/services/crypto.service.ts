import prisma from "../../../models/prisma";
import pricing from "./crypto.pricing.service";
import risk from "./crypto.risk.service";
import custody from "./crypto.custody.service";
import audit from "./crypto.audit.service";
import { DexRouter } from "../integrations/routers/dex.router";
import { CexRouter } from "../integrations/routers/cex.router";

const dex = new DexRouter();
const cex = new CexRouter();

export class CryptoService {
  // 1) Create quote with best execution selection
  async quote(params: {
    userId: string;
    side: "BUY" | "SELL";
    base: string;
    quote: string;
    amount: number;
    maxSlippageBps: number;
  }) {
    // Pre-checks
    await risk.assertKycCleared(params.userId);
    await risk.assertAmlOk(params.userId, params.base, params.quote);

    // If you maintain USD oracle conversion, compute approx trade size for limits
    const notionalUsd = await this.estimateUsd(params.base, params.quote, params.amount);
    await risk.checkVelocity(params.userId, notionalUsd);

    const q = await pricing.getBestQuote(params);
    await audit.emit("CRYPTO_QUOTE_CREATED", { ...q, notionalUsd });

    return q;
  }

  // 2) Execute quote (idempotent)
  async execute(params: {
    userId: string;
    quoteId: string;
    idempotencyKey: string;
    walletId?: string;
    paymentSource: "CUSTODIAL_WALLET" | "NONCUSTODIAL_WALLET" | "CARD" | "TICKPAY";
  }) {
    // Idempotency: has this key executed?
    const prior = await prisma.idempotencyKey.findFirst({
      where: { key: params.idempotencyKey, scope: "CRYPTO_EXECUTE" },
    });
    if (prior) {
      const tx = await prisma.cryptoTransaction.findUnique({ where: { id: prior.resourceId } });
      if (tx) return tx;
    }

    const quote = await pricing.assertQuoteActive(params.quoteId);

    // Ensure wallet
    const wallet =
      params.walletId
        ? await prisma.cryptoWallet.findUnique({ where: { id: params.walletId } })
        : await custody.ensureWallet(params.userId, { type: "CUSTODIAL" });

    if (!wallet) throw new Error("Wallet not found");

    // Execute on chosen venue
    let txHash: string | undefined;
    let externalOrderId: string | undefined;

    const amount = quote.baseAmount;
    const side = quote.side;

    if (quote.provider === "DEX") {
      const result = await dex.execute({
        routeId: quote.providerRef!,
        side,
        base: quote.base,
        quote: quote.quote,
        amount,
        maxSlippageBps: quote.maxSlippageBps,
        walletAddress: wallet.address,
      });
      txHash = result.txHash;
    } else {
      const result = await cex.execute({
        side,
        base: quote.base,
        quote: quote.quote,
        amount,
        maxSlippageBps: quote.maxSlippageBps,
        accountRef: `USER-${params.userId}`,
      });
      externalOrderId = result.externalOrderId;
    }

    // Mark quote as used
    await pricing.markQuoteUsed(quote.id);

    // Persist transaction
    const tx = await prisma.cryptoTransaction.create({
      data: {
        userId: params.userId,
        walletId: wallet.id,
        type: side === "BUY" ? "BUY" : "SELL",
        amount: amount,
        currency: quote.base, // amount is in base
        priceExecuted: quote.netPrice,
        provider: quote.provider,
        providerRef: externalOrderId || quote.providerRef || null,
        txHash: txHash || null,
        status: "COMPLETED",
        amountUsd: await this.estimateUsd(quote.base, quote.quote, amount),
        meta: {
          quoteId: quote.id,
          paymentSource: params.paymentSource,
        },
      } as any,
    });

    // Save idempotency key
    await prisma.idempotencyKey.create({
      data: { key: params.idempotencyKey, scope: "CRYPTO_EXECUTE", resourceId: tx.id },
    });

    await audit.emit("CRYPTO_TRADE_EXECUTED", {
      txId: tx.id,
      provider: quote.provider,
      txHash,
      externalOrderId,
    });

    return tx;
  }

  private async estimateUsd(base: string, quote: string, amount: number): Promise<number> {
    // Simplified: if quote is already USD/USDC/USDT, use price ~1
    const stable = ["USD", "USDC", "USDT"];
    if (stable.includes(quote.toUpperCase())) return amount * (1 * 1.0); // assuming price ~1 for simplicity
    // Else call a price oracle (could reuse pricing routers)
    // For brevity, mock a 100 USD price
    return amount * 100;
  }
}

export default new CryptoService();
