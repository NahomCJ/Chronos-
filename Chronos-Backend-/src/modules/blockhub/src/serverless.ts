// Bootstraps the BlockHub Nest app for Vercel's serverless runtime — same
// setup as main.ts, minus app.listen(). Instead it calls app.init() and
// hands back the underlying Express instance for a Vercel function to call
// directly as (req, res). Cached at module scope so a warm container reuses
// the same app instance across invocations instead of rebuilding it.
//
// NOTE: the Socket.io gateways (src/gateway, src/nft/websocket) and the
// Bull minting queue (src/nft/minting) do not work correctly here — a
// serverless invocation can't hold a persistent WebSocket connection or run
// a queue worker. See Chronos-Backend-/CLAUDE.md "Vercel Deployment —
// BlockHub" for the known gap.
import { NestFactory } from "@nestjs/core";
import { NestExpressApplication } from "@nestjs/platform-express";
import { ValidationPipe } from "@nestjs/common";
import type { Express } from "express";
import { AppModule } from "./app.module";
import { GlobalExceptionFilter } from "./common/filters/http-exception.filter";

let cachedServer: Express | undefined;

export async function getBlockhubServer(): Promise<Express> {
  if (cachedServer) return cachedServer;

  const app = await NestFactory.create<NestExpressApplication>(AppModule, {
    logger: ["log", "warn", "error"],
  });

  app.useGlobalFilters(new GlobalExceptionFilter());
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: { enableImplicitConversion: true },
    }),
  );
  app.enableCors({
    origin: process.env.ALLOWED_ORIGIN ?? "*",
    methods: ["GET", "POST", "PUT", "DELETE", "PATCH"],
    allowedHeaders: ["Content-Type", "Authorization"],
    credentials: true,
  });

  // On Vercel, BlockHub is reachable under /blockhub (see Chronos-Backend-/vercel.json) —
  // route path/exclusions have to match that, unlike main.ts's plain "api/v1".
  app.setGlobalPrefix("blockhub/api/v1", {
    exclude: ["blockhub/health", "blockhub/webhooks/plaid", "blockhub/market/prices"],
  });

  await app.init();
  cachedServer = app.getHttpAdapter().getInstance();
  return cachedServer;
}
