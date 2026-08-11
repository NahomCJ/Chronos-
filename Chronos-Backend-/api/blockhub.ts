// Vercel serverless entrypoint for BlockHub (NestJS). Reachable at
// /blockhub/* — see vercel.json. Real-time (Socket.io) and NFT minting
// (Bull/Redis queue) are known gaps here; see
// src/modules/blockhub/src/serverless.ts and Chronos-Backend-/CLAUDE.md.
//
// Imports the COMPILED output (dist-blockhub/, built by vercel.json's
// buildCommand via tsc), not the TS source. NestJS's DI relies on
// reflected decorator metadata that tsc emits correctly but esbuild (what
// Vercel's zero-config TS bundler uses) does not — bundling the raw
// decorated source here throws a false "undefined dependency" error at
// boot. The plain JS in dist-blockhub/ already has that metadata baked in
// as ordinary Reflect.metadata() calls, so esbuild has nothing to get wrong.
import type { IncomingMessage, ServerResponse } from "http";
import { getBlockhubServer } from "../dist-blockhub/serverless";

export default async function handler(req: IncomingMessage, res: ServerResponse) {
  const server = await getBlockhubServer();
  server(req, res);
}
