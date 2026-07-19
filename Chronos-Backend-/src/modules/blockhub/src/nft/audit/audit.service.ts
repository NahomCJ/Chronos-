import { Injectable } from '@nestjs/common';
import { NftAuditEvent } from '../../common/types';
import { PrismaService } from '../../prisma/prisma.service';

export interface AuditLogPayload {
  userId: string;
  event: NftAuditEvent;
  nftId?: string;
  payload?: Record<string, any>;
  ipAddress?: string;
}

@Injectable()
export class AuditService {
  constructor(private readonly prisma: PrismaService) {}

  async log(data: AuditLogPayload): Promise<void> {
    await this.prisma.nftAuditLog.create({
      data: {
        userId: data.userId,
        event: data.event,
        nftId: data.nftId,
        payload: data.payload || {},
        ipAddress: data.ipAddress,
      },
    });
  }

  async findByUser(userId: string, limit = 50) {
    return this.prisma.nftAuditLog.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: limit,
    });
  }

  async findByNft(nftId: string) {
    return this.prisma.nftAuditLog.findMany({
      where: { nftId },
      orderBy: { createdAt: 'asc' },
    });
  }
}
