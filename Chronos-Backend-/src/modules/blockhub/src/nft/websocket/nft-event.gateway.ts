import {
  WebSocketGateway, WebSocketServer, OnGatewayConnection,
  OnGatewayDisconnect, SubscribeMessage, MessageBody, ConnectedSocket,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';

/**
 * NftEventGateway
 *
 * Real-time WebSocket gateway for NFT marketplace events.
 *
 * Channels:
 *   user:{userId}         — personal events (purchase confirmation, sale, royalty)
 *   collection:{id}       — collection-level events (new listing, floor price change)
 *   marketplace           — global feed (recent sales, trending)
 *
 * Events emitted to clients:
 *   nft:purchase_confirmed
 *   nft:listing_sold
 *   nft:mint_complete
 *   nft:new_listing
 *   nft:listing_cancelled
 *   royalty:received
 */
@WebSocketGateway({
  cors: { origin: process.env.ALLOWED_ORIGIN ?? '*', credentials: true },
  namespace: '/nft',
})
export class NftEventGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server!: Server;

  private readonly logger = new Logger(NftEventGateway.name);
  private connectedUsers = new Map<string, string>(); // socketId → userId

  constructor(private readonly jwtService: JwtService) {}

  async handleConnection(client: Socket) {
    try {
      const token = client.handshake.auth?.token
        || client.handshake.headers?.authorization?.replace('Bearer ', '');

      if (!token) {
        client.disconnect();
        return;
      }

      const payload = this.jwtService.verify(token);
      const userId = payload.sub;

      this.connectedUsers.set(client.id, userId);
      client.join(`user:${userId}`);
      this.logger.debug(`Client connected: ${client.id} (user: ${userId})`);
    } catch {
      client.disconnect();
    }
  }

  handleDisconnect(client: Socket) {
    this.connectedUsers.delete(client.id);
    this.logger.debug(`Client disconnected: ${client.id}`);
  }

  @SubscribeMessage('subscribe:collection')
  handleCollectionSubscribe(
    @MessageBody() data: { collectionId: string },
    @ConnectedSocket() client: Socket,
  ) {
    client.join(`collection:${data.collectionId}`);
    this.logger.debug(`Socket ${client.id} subscribed to collection ${data.collectionId}`);
  }

  // ─── Emit helpers (called by services) ────────────────────────────────────

  sendToUser(userId: string, event: string, data: Record<string, any>) {
    this.server.to(`user:${userId}`).emit(`nft:${event.toLowerCase()}`, data);
  }

  broadcastToCollection(collectionId: string, event: string, data: Record<string, any>) {
    this.server.to(`collection:${collectionId}`).emit(`nft:${event}`, data);
  }

  broadcastToMarketplace(event: string, data: Record<string, any>) {
    this.server.emit(`nft:${event}`, data);
  }
}
