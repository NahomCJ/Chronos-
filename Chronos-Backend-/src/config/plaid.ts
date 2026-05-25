// src/config/plaid.ts
//
// Plaid credentials are read from environment variables:
//   PLAID_CLIENT_ID  — from Plaid Dashboard → Team Settings → Keys
//   PLAID_SECRET     — sandbox secret from the same page
//   PLAID_ENV        — "sandbox" | "development" | "production" (default: sandbox)
//
// These are intentionally left unset until API keys are issued.
// The server will start but Plaid-dependent routes will return 500 until
// the variables are populated in .env.
import { Configuration, PlaidApi, PlaidEnvironments } from "plaid";

if (
  process.env.NODE_ENV !== "test" &&
  (!process.env.PLAID_CLIENT_ID || !process.env.PLAID_SECRET)
) {
  console.warn(
    "[Plaid] PLAID_CLIENT_ID or PLAID_SECRET is not set. " +
      "All Plaid-dependent routes will fail until .env is configured. " +
      "See .env.example for instructions."
  );
}

const env = (process.env.PLAID_ENV ?? "sandbox") as keyof typeof PlaidEnvironments;

const configuration = new Configuration({
  basePath: PlaidEnvironments[env],
  baseOptions: {
    headers: {
      "PLAID-CLIENT-ID": process.env.PLAID_CLIENT_ID ?? "",
      "PLAID-SECRET": process.env.PLAID_SECRET ?? "",
    },
  },
});

export const plaidClient = new PlaidApi(configuration);
