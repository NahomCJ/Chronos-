// ============================================================
// WebhooksController
// Receives Plaid identity verification webhooks.
// On success: updates user status to VERIFIED and auto-triggers
// Paxos wallet provisioning.
//
// NOTE: KYC/AML is handled at the app login layer by Plaid.
//       This controller only RECEIVES the status update.
//       Do not add KYC logic here.
// ============================================================

import {
  Controller,
  Post,
  Body,
  Headers,
  HttpCode,
  HttpStatus,
  Logger,
  BadRequestException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../../prisma/prisma.service';
import { WalletService } from '../wallet/wallet.service';
import { AuditService } from '../audit/audit.service';
import * as crypto from 'crypto';

interface PlaidWebhookPayload {
  webhook_type: string;
  webhook_code: string;
  identity_verification_id?: string;
  status?: string;
  link_session_id?: string;
  environment?: string;
}

@Controller('webhooks')
export class WebhooksController {
  private readonly logger = new Logger(WebhooksController.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly wallet: WalletService,
    private readonly audit: AuditService,
    private readonly config: ConfigService,
  ) {}

  /**
   * POST /webhooks/plaid
   * Receives Plaid identity verification status updates.
   * Validates the Plaid-Verification header before processing.
   */
  @Post('plaid')
  @HttpCode(HttpStatus.OK)
  async handlePlaid(
    @Body() payload: PlaidWebhookPayload,
    @Headers('plaid-verification') plaidSignature: string,
    @Body('_raw') _rawBody?: string,
  ) {
    // Verify webhook signature (HMAC SHA-256)
    const webhookSecret = this.config.get<string>('PLAID_WEBHOOK_SECRET');
    if (webhookSecret && plaidSignature) {
      const expectedSig = crypto
        .createHmac('sha256', webhookSecret)
        .update(JSON.stringify(payload))
        .digest('hex');

      if (expectedSig !== plaidSignature) {
        this.logger.warn('Plaid webhook: invalid signature — rejected');
        throw new BadRequestException('Invalid webhook signature');
      }
    }

    this.logger.log(
      `Plaid webhook received: type=${payload.webhook_type} code=${payload.webhook_code}`,
    );

    // Only handle IDENTITY_VERIFICATION events
    if (payload.webhook_type !== 'IDENTITY_VERIFICATION') {
      return { received: true };
    }

    if (payload.webhook_code === 'STATUS_UPDATED' && payload.status === 'success') {
      await this.handleKycApproved(payload);
    } else if (
      payload.webhook_code === 'STATUS_UPDATED' &&
      ['failed', 'expired'].includes(payload.status ?? '')
    ) {
      await this.handleKycRejected(payload);
    }

    return { received: true };
  }

  private async handleKycApproved(payload: PlaidWebhookPayload): Promise<void> {
    const identityId = payload.identity_verification_id;
    if (!identityId) return;

    // Find user profile by Plaid identity ID
    const profile = await this.prisma.bankingProfile.findFirst({
      where: { plaidIdvId: identityId },
    });

    if (!profile) {
      this.logger.warn(`Plaid KYC approved for unknown identity: ${identityId}`);
      return;
    }

    // Mark profile as KYC-approved so ComplianceService allows trading
    await this.prisma.bankingProfile.update({
      where: { id: profile.id },
      data: { status: 'APPROVED', kycVerified: true },
    });

    await this.audit.log('KYC_APPROVED', profile.userId, {
      plaid_identity_id: identityId,
    });

    // Auto-trigger wallet provisioning (non-blocking)
    this.wallet.createForUser(profile.userId).catch((err) => {
      this.logger.error(`Wallet provisioning failed for ${profile.userId}`, err);
    });
  }

  private async handleKycRejected(payload: PlaidWebhookPayload): Promise<void> {
    const identityId = payload.identity_verification_id;
    if (!identityId) return;

    const profile = await this.prisma.bankingProfile.findFirst({
      where: { plaidIdvId: identityId },
    });

    if (!profile) return;

    this.logger.warn(`User ${profile.userId} KYC rejected`);
    await this.audit.log('KYC_REJECTED', profile.userId, {
      plaid_identity_id: identityId,
      status: payload.status,
    });
  }
}

