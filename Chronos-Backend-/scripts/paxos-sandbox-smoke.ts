import paxos, { SUPPORTED_CRYPTO_ASSETS } from "../src/modules/crypto/services/crypto.paxos.service";
import { isCryptoApiError } from "../src/modules/crypto/services/crypto.errors";

function hasBaseSandboxConfig() {
  return Boolean(
    process.env.PAXOS_CLIENT_ID &&
      process.env.PAXOS_CLIENT_SECRET &&
      process.env.PAXOS_PROFILE_ID,
  );
}

function refId(prefix: string) {
  return `chronos-${prefix}-${Date.now()}`;
}

function filledBaseAmount(order: {
  filled_base_amount?: string;
  amount_filled?: string;
  base_amount?: string;
}) {
  return order.filled_base_amount || order.amount_filled || order.base_amount;
}

async function runTradeLoop(profileId: string) {
  const tradeUsd = process.env.PAXOS_SANDBOX_TRADE_AMOUNT_USD || "5.00";
  const buy = await paxos.placeOrder({
    profileId,
    side: "BUY",
    asset: "BTC",
    quoteAmount: tradeUsd,
    clientOrderId: refId("buy"),
  });
  const filledBuy = await paxos.pollOrderUntilTerminal(profileId, buy.id);
  const btcAmount = filledBaseAmount(filledBuy);

  console.log(`Buy order ${filledBuy.id} ended ${filledBuy.status}`);

  if (!btcAmount || Number(btcAmount) <= 0) {
    throw new Error("Sandbox buy did not return a filled BTC amount.");
  }

  const sell = await paxos.placeOrder({
    profileId,
    side: "SELL",
    asset: "BTC",
    baseAmount: btcAmount,
    clientOrderId: refId("sell"),
  });
  const filledSell = await paxos.pollOrderUntilTerminal(profileId, sell.id);
  console.log(`Sell order ${filledSell.id} ended ${filledSell.status}`);

  try {
    const impossible = await paxos.placeOrder({
      profileId,
      side: "BUY",
      asset: "BTC",
      quoteAmount: "999999999.00",
      clientOrderId: refId("insufficient"),
    });
    await paxos.pollOrderUntilTerminal(profileId, impossible.id);
    throw new Error("Expected insufficient-balance sandbox order to fail.");
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    console.log(`Insufficient-balance check returned expected failure: ${message}`);
  }
}

async function runTransferLoop(profileId: string) {
  await paxos.creditFromSettlement({
    profileId,
    amount: "5.00",
    asset: "USD",
    refId: refId("credit"),
  });
  await paxos.debitToSettlement({
    profileId,
    amount: "5.00",
    asset: "USD",
    refId: refId("debit"),
  });
  console.log("Settlement credit/debit checks submitted.");
}

async function main() {
  if (!hasBaseSandboxConfig()) {
    console.log(
      "Skipping Paxos sandbox smoke test. Set PAXOS_CLIENT_ID, PAXOS_CLIENT_SECRET, and PAXOS_PROFILE_ID to run it.",
    );
    return;
  }

  const profileId = process.env.PAXOS_PROFILE_ID!;
  const config = paxos.getConfig();
  console.log(`Running Paxos sandbox smoke test against ${config.apiBaseUrl}`);

  const balances = await paxos.getBalances(profileId);
  console.log(`Fetched ${balances.length} profile balances.`);

  const prices = await Promise.all(
    SUPPORTED_CRYPTO_ASSETS.map((asset) => paxos.getMarketPrice(asset)),
  );
  console.log(
    `Fetched prices: ${prices
      .map((price) => `${price.asset}=${price.price} (${price.source})`)
      .join(", ")}`,
  );

  await paxos.listTransfers(profileId, 10);
  console.log("Fetched transfer list.");

  if (process.env.PAXOS_SANDBOX_RUN_TRANSFERS === "true") {
    await runTransferLoop(profileId);
  } else {
    console.log("Skipping transfer mutation checks. Set PAXOS_SANDBOX_RUN_TRANSFERS=true to enable.");
  }

  if (process.env.PAXOS_SANDBOX_RUN_TRADES === "true") {
    await runTradeLoop(profileId);
  } else {
    console.log("Skipping buy/sell mutation checks. Set PAXOS_SANDBOX_RUN_TRADES=true to enable.");
  }
}

main().catch((err) => {
  if (isCryptoApiError(err)) {
    console.error(`${err.code}: ${err.message}`);
    if (err.details) console.error(JSON.stringify(err.details, null, 2));
  } else {
    console.error(err);
  }
  process.exitCode = 1;
});
