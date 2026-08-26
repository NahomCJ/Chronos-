import { webcrypto } from 'node:crypto';

// @nestjs/schedule calls the global `crypto.randomUUID()` at bootstrap, which
// is only auto-registered as a global on newer Node versions. Polyfill it
// here so the app doesn't crash on whatever Node version the host picks.
if (!globalThis.crypto) {
  globalThis.crypto = webcrypto as Crypto;
}

import { NestFactory } from '@nestjs/core';
import { ValidationPipe, Logger } from '@nestjs/common';
import compression from 'compression';
import { AppModule } from './app.module';
import { GlobalExceptionFilter } from './common/filters/http-exception.filter';

const REQUIRED_ENV_VARS = ['JWT_SECRET', 'DATABASE_URL'];

async function bootstrap() {
  const logger = new Logger('Bootstrap');

  const missing = REQUIRED_ENV_VARS.filter((key) => !process.env[key]);
  if (missing.length > 0) {
    logger.error(
      `Missing required environment variable(s): ${missing.join(', ')}. ` +
        'Set them on the BlockHub service (Railway → Project → Variables) before deploying.',
    );
    process.exit(1);
  }

  const app = await NestFactory.create(AppModule, {
    logger: ['log', 'warn', 'error', 'debug'],
  });

  // Gzip/brotli-negotiated compression for JSON responses above 1kb.
  // `compression` reads the client's Accept-Encoding and skips responses
  // that already carry a Content-Encoding header, so it never double-compresses.
  app.use(compression());

  // ── Global exception filter ───────────────────────────────
  app.useGlobalFilters(new GlobalExceptionFilter());

  // ── Global validation pipe ────────────────────────────────
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: { enableImplicitConversion: true },
    }),
  );

  // ── CORS ─────────────────────────────────────────────────
  app.enableCors({
    origin: process.env.ALLOWED_ORIGIN ?? '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true,
  });

  // ── Global prefix ─────────────────────────────────────────
  app.setGlobalPrefix('api/v1', {
    exclude: ['health', 'webhooks/plaid', 'market/prices'],
  });

  const port = process.env.PORT ?? 3000;
  await app.listen(port);

  logger.log(`BlockHub backend running on port ${port}`);
  logger.log(`Environment: ${process.env.NODE_ENV ?? 'development'}`);
  logger.log(
    `Paxos mode: ${process.env.NODE_ENV === 'production' ? 'PRODUCTION' : 'SANDBOX'}`,
  );
}

bootstrap().catch((err) => {
  new Logger('Bootstrap').error('Fatal error during startup', err instanceof Error ? err.stack : err);
  process.exit(1);
});
