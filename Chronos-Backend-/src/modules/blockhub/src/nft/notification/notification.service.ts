import { Injectable, Logger, Optional } from '@nestjs/common';
import { NftEventGateway } from '../websocket/nft-event.gateway';

@Injectable()
export class NotificationService {
  private readonly logger = new Logger(NotificationService.name);

  constructor(
    @Optional() private readonly eventGateway: NftEventGateway,
  ) {}

  async send(userId: string, event: string, data: Record<string, any>): Promise<void> {
    this.logger.debug(`[Notification] user=${userId} event=${event}`);

    if (this.eventGateway) {
      this.eventGateway.sendToUser(userId, event, data);
    }
  }

  async broadcast(collectionId: string, event: string, data: Record<string, any>): Promise<void> {
    this.logger.debug(`[Notification] collection=${collectionId} event=${event}`);

    if (this.eventGateway) {
      this.eventGateway.broadcastToCollection(collectionId, event, data);
    }
  }

  async broadcastMarketplace(event: string, data: Record<string, any>): Promise<void> {
    this.logger.debug(`[Notification] marketplace event=${event}`);

    if (this.eventGateway) {
      this.eventGateway.broadcastToMarketplace(event, data);
    }
  }
}
