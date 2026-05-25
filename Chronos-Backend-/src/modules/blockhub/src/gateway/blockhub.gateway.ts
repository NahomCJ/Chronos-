// ============================================================
// BlockhubGateway — Module 6
// Real-time WebSocket gateway (NestJS + Socket.io).
// All connections require valid JWT in handshake.
//
// Channels:
//   price.{ASSET}        — pushed every 5s (market cache refresh)
//   order.{userId}       — pushed on order state change
//   portfolio.{userId}   — pushed after every trade completion
// ============================================================

import {
  WebSocketGateway,
  WebSocketServer,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { Logger } from '@nestjs/common';

@WebSocketGateway({
  cors: {
    origin: process.env.ALLOWED_ORIGIN ?? '*',
    credentials: true,
  },
  namespace: '/ws',
})
export class BlockhubGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  private server!: Server;

  private readonly logger = new Logger(BlockhubGateway.name);

  constructor(
    private readonly jwtService: JwtService,
    private readonly config: ConfigService,
  ) {}

  // ============================================================
  // Connection Lifecycle
  // ============================================================

  async handleConnection(client: Socket) {
    const token =
      client.handshake.auth?.token ??
      client.handshake.headers?.authorization?.replace('Bearer ', '');

    if (!token) {
      this.logger.warn(`WS rejected: no token — socket ${client.id}`);
      client.emit('error', { code: 4001, message: 'Unauthorized — token required' });
      client.disconnect(true);
      return;
    }

    try {
      const payload = this.jwtService.verify(token, {
        secret: this.config.getOrThrow<string>('JWT_SECRET'),
        algorithms: ['HS256'],
      });

      const userId = payload.sub as string;

      // Subscribe to user-scoped rooms
      await client.join(`portfolio.${userId}`);
      await client.join(`order.${userId}`);

      // Store userId on socket for later use
      client.data.userId = userId;

      this.logger.log(`WS connected: userId=${userId} socket=${client.id}`);
    } catch (err) {
      this.logger.warn(`WS rejected: invalid token — socket ${client.id}`);
      client.emit('error', { code: 4001, message: 'Unauthorized — invalid or expired token' });
      client.disconnect(true);
    }
  }

  handleDisconnect(client: Socket) {
    this.logger.log(`WS disconnected: userId=${client.data?.userId ?? 'unknown'} socket=${client.id}`);
  }

  // ============================================================
  // Push Methods (called by other services)
  // ============================================================

  /**
   * Pushes portfolio update to a specific user.
   * Called by TradingService after every successful trade.
   */
  pushPortfolioUpdate(userId: string, data: any) {
    this.server.to(`portfolio.${userId}`).emit('portfolio_update', {
      channel: `portfolio.${userId}`,
      data,
    });
  }

  /**
   * Pushes order status update to a specific user.
   * Called during order polling lifecycle.
   */
  pushOrderUpdate(userId: string, data: {
    orderId: string;
    status: string;
    filledAt?: Date;
  }) {
    this.server.to(`order.${userId}`).emit('order_update', {
      channel: `order.${userId}`,
      data,
    });
  }

  /**
   * Broadcasts a price update to all connected clients.
   * Called by the price broadcaster cron job every 5s.
   */
  pushPriceUpdate(asset: string, price: number) {
    this.server.emit(`price_${asset.toUpperCase()}`, {
      channel: `price.${asset.toUpperCase()}`,
      data: {
        asset: asset.toUpperCase(),
        price,
        timestamp: new Date().toISOString(),
      },
    });
  }

  /**
   * Broadcasts all asset prices at once.
   * Convenience method for the 5s market data interval.
   */
  pushAllPrices(prices: Record<string, number>) {
    for (const [asset, price] of Object.entries(prices)) {
      this.pushPriceUpdate(asset, price);
    }
  }
}
