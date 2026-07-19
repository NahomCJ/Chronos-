export const FLAGS = {
  TICKPAY_USE_AKOYA: process.env.TICKPAY_USE_AKOYA === "true",
  TICKPAY_USE_FINGPT: process.env.TICKPAY_USE_FINGPT === "true",
  INTEGRATIONS_CACHE: process.env.INTEGRATIONS_CACHE !== "false", // default on
  CACHE_TTL_SEC: Number(process.env.CACHE_TTL_SEC || 90),
};
