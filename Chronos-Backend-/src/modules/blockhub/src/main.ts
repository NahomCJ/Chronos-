import { NestFactory } from '@nestjs/core';
import { ValidationPipe, Logger } from '@nestjs/common';
import { AppModule } from './app.module';
import { GlobalExceptionFilter } from './common/filters/http-exception.filter';

async function bootstrap() {
  const logger = new Logger('Bootstrap');

  const app = await NestFactory.create(AppModule, {
    logger: ['log', 'warn', 'error', 'debug'],
  });

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

bootstrap();
