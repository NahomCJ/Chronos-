export const unitConfig = {
  token: process.env.UNIT_API_TOKEN ?? "",
  env: (process.env.UNIT_ENV ?? "sandbox") as "sandbox" | "production",
  webhookSecret: process.env.UNIT_WEBHOOK_SECRET ?? "",
  baseUrl:
    process.env.UNIT_ENV === "production"
      ? "https://api.unit.co"
      : "https://api.s.unit.sh",
};
