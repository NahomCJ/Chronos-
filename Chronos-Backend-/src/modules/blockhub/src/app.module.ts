import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { ScheduleModule } from '@nestjs/schedule';
import { ThrottlerModule } from '@nestjs/throttler';
import { BullModule } from '@nestjs/bull';

// Core infrastructure
import { PrismaModule } from './prisma/prisma.module';
import { PaxosModule } from './providers/paxos/paxos.module';
import { AuthModule } from './auth/auth.module';

// Feature modules
import { CryptoModule } from './crypto/crypto.module';
import { NftModule } from './nft/nft.module';
import { GatewayModule } from './gateway/gateway.module';
import { HealthModule } from './health/health.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true, envFilePath: '.env' }),
    ScheduleModule.forRoot(),
    ThrottlerModule.forRoot([{ ttl: 60_000, limit: 100 }]),

    BullModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        redis: config.get<string>('REDIS_URL') ?? 'redis://localhost:6379',
      }),
    }),

    // Global infrastructure
    AuthModule,
    PrismaModule,
    PaxosModule,

    // Feature modules
    CryptoModule,
    NftModule,
    GatewayModule,
    HealthModule,
  ],
})
export class AppModule { }
