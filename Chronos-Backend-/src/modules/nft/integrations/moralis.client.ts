// src/modules/nft/integrations/moralis.client.ts
import Moralis from "moralis";

const MORALIS_API_KEY = process.env.MORALIS_API_KEY || "";

if (!MORALIS_API_KEY) {
  throw new Error("MORALIS_API_KEY not set in .env");
}

export async function initMoralis() {
  await Moralis.start({
    apiKey: MORALIS_API_KEY,
  });
}

export default Moralis;
