// src/modules/core/kyc/kyc.service.ts
import jwt from "jsonwebtoken";
import { CountryCode, Products, Strategy } from "plaid";
import { AccountStatus } from "@prisma/client";
import prisma from "../../../config/prisma";
import { plaidClient } from "../../../config/plaid";
import { NotificationService } from "../../notification/notificatoin.service";
import * as T from "../../notification/email.templates";
import {
  RiskLevel,
  PlaidIdvStatus,
  CreateKycSessionInput,
  CreateAuthLinkTokenInput,
  ExchangePublicTokenInput,
  PlaidAuthDTO,
  KycProfileDTO,
  KycSessionDTO,
  PlaidWebhookBody,
} from "./kyc.types";

// Maps Plaid IDV status → our internal AccountStatus
function mapPlaidStatus(plaidStatus: PlaidIdvStatus): {
  status: AccountStatus;
  kycVerified: boolean;
  approvedAt?: Date;
  rejectedAt?: Date;
  submittedAt?: Date;
} {
  switch (plaidStatus) {
    case "success":
      return { status: "APPROVED", kycVerified: true, approvedAt: new Date() };
    case "failed":
      return { status: "REJECTED", kycVerified: false, rejectedAt: new Date() };
    case "pending_review":
    case "pending_docv":
    case "active":
      return { status: "PENDING", kycVerified: false, submittedAt: new Date() };
    case "expired":
      return { status: "DRAFT", kycVerified: false };
    default:
      return { status: "PENDING", kycVerified: false };
  }
}

export class KycService {
  // ─── Profile ────────────────────────────────────────────────────────────────

  async getProfile(userId: string): Promise<KycProfileDTO | null> {
    const profile = await prisma.bankingProfile.findUnique({ where: { userId } });
    if (!profile) return null;

    return {
      userId: profile.userId,
      status: profile.status,
      kycVerified: profile.kycVerified,
      riskLevel: profile.riskLevel as RiskLevel | undefined,
      frozen: profile.frozen,
      plaidIdvId: profile.plaidIdvId,
      plaidStatus: profile.plaidStatus,
      bankLinked: !!profile.plaidAccessToken,
      createdAt: profile.createdAt.toISOString(),
      updatedAt: profile.updatedAt.toISOString(),
    };
  }

  async createProfile(userId: string) {
    return prisma.bankingProfile.create({ data: { userId } });
  }

  // ─── Plaid IDV (KYC) ────────────────────────────────────────────────────────

  /**
   * Step 1 – Create a Plaid Link token configured for Identity Verification.
   * The frontend uses this token to open Plaid Link so the user can complete IDV.
   *
   * Sandbox testing:
   *  - Create an IDV template in the Plaid Dashboard and set PLAID_IDV_TEMPLATE_ID.
   *  - Use Plaid's sandbox test credentials to trigger pass/fail outcomes.
   *  - Fire test webhooks via Plaid Dashboard → "Send Webhook".
   */
  async createKycSession(
    userId: string,
    input: CreateKycSessionInput
  ): Promise<KycSessionDTO> {
    const profile = await prisma.bankingProfile.findUnique({ where: { userId } });
    if (!profile) throw new Error("Banking profile not found. Create a profile first.");
    if (profile.status === "APPROVED") throw new Error("KYC already approved.");

    const templateId = process.env.PLAID_IDV_TEMPLATE_ID;
    if (!templateId) throw new Error("PLAID_IDV_TEMPLATE_ID is not configured.");

    const response = await plaidClient.linkTokenCreate({
      user: {
        client_user_id: userId,
        email_address: input.email,
        ...(input.dateOfBirth && { date_of_birth: input.dateOfBirth }),
        ...(input.phoneNumber && { phone_number: input.phoneNumber }),
        legal_name: `${input.firstName} ${input.lastName}`,
      },
      client_name: "Chronos",
      products: [Products.IdentityVerification],
      identity_verification: { template_id: templateId },
      language: "en",
      country_codes: [CountryCode.Us],
    });

    const { link_token, expiration, request_id } = response.data;

    await prisma.bankingProfile.update({
      where: { userId },
      data: { status: "PENDING", submittedAt: new Date() },
    });

    return { linkToken: link_token, expiration, requestId: request_id };
  }

  /**
   * Step 2 – Called after Plaid Link's onSuccess callback.
   * Saves the identity_verification_id and syncs the initial status from Plaid.
   */
  async completeKycSession(userId: string, identityVerificationId: string) {
    const profile = await prisma.bankingProfile.findUnique({ where: { userId } });
    if (!profile) throw new Error("Banking profile not found.");

    const idvResponse = await plaidClient.identityVerificationGet({
      identity_verification_id: identityVerificationId,
    });

    const plaidStatus = idvResponse.data.status as PlaidIdvStatus;
    const mapped = mapPlaidStatus(plaidStatus);

    await prisma.bankingProfile.update({
      where: { userId },
      data: {
        plaidIdvId: identityVerificationId,
        plaidStatus,
        status: mapped.status,
        kycVerified: mapped.kycVerified,
        ...(mapped.approvedAt && { approvedAt: mapped.approvedAt }),
        ...(mapped.rejectedAt && { rejectedAt: mapped.rejectedAt }),
      },
    });

    return { plaidStatus, internalStatus: mapped.status };
  }

  /** Returns the live Plaid IDV session object directly from Plaid. */
  async getKycSessionStatus(sessionId: string) {
    const response = await plaidClient.identityVerificationGet({
      identity_verification_id: sessionId,
    });
    return response.data;
  }

  /**
   * Retry a failed/expired IDV session.
   * Returns a fresh link token for the frontend to open Plaid Link again.
   */
  async retryKycSession(userId: string, email: string): Promise<KycSessionDTO> {
    const profile = await prisma.bankingProfile.findUnique({ where: { userId } });
    if (!profile) throw new Error("Banking profile not found.");
    if (profile.status === "APPROVED") throw new Error("KYC already approved.");

    const templateId = process.env.PLAID_IDV_TEMPLATE_ID;
    if (!templateId) throw new Error("PLAID_IDV_TEMPLATE_ID is not configured.");

    if (profile.plaidIdvId) {
      await plaidClient.identityVerificationRetry({
        client_user_id: userId,
        template_id: templateId,
        strategy: Strategy.Reset,
      });
    }

    const response = await plaidClient.linkTokenCreate({
      user: { client_user_id: userId, email_address: email },
      client_name: "Chronos",
      products: [Products.IdentityVerification],
      identity_verification: { template_id: templateId },
      language: "en",
      country_codes: [CountryCode.Us],
    });

    const { link_token, expiration, request_id } = response.data;

    await prisma.bankingProfile.update({
      where: { userId },
      data: { status: "PENDING", plaidStatus: "active" },
    });

    return { linkToken: link_token, expiration, requestId: request_id };
  }

  // ─── Plaid Auth (Bank Account Linking) ──────────────────────────────────────

  /**
   * Creates a Plaid Link token for the Auth product (bank account linking).
   * The frontend opens Plaid Link and the user selects their external bank.
   *
   * Compliance gate: KYC must be approved before a bank account can be linked.
   *
   * Sandbox testing:
   *  - Use credentials: username "user_good", password "pass_good" in Plaid Link.
   *  - institution_id "ins_109508" (Chase) works reliably in sandbox.
   */
  async createAuthLinkToken(
    userId: string,
    input: CreateAuthLinkTokenInput
  ): Promise<KycSessionDTO> {
    const profile = await prisma.bankingProfile.findUnique({ where: { userId } });
    if (!profile) throw new Error("Banking profile not found.");
    if (!profile.kycVerified)
      throw new Error("KYC must be approved before linking a bank account.");

    const response = await plaidClient.linkTokenCreate({
      user: { client_user_id: userId, email_address: input.email },
      client_name: "Chronos",
      products: [Products.Auth],
      language: "en",
      country_codes: [CountryCode.Us],
    });

    const { link_token, expiration, request_id } = response.data;
    return { linkToken: link_token, expiration, requestId: request_id };
  }

  /**
   * Exchanges the public_token returned by Plaid Link for a permanent access_token.
   * Stores the access_token, item_id, and selected account_id on the profile.
   *
   * IMPORTANT: In production, encrypt plaidAccessToken at rest (AES-256 or KMS).
   */
  async exchangePublicToken(
    userId: string,
    input: ExchangePublicTokenInput
  ): Promise<void> {
    const profile = await prisma.bankingProfile.findUnique({ where: { userId } });
    if (!profile) throw new Error("Banking profile not found.");
    if (!profile.kycVerified)
      throw new Error("KYC must be approved before linking a bank account.");

    const exchangeResponse = await plaidClient.itemPublicTokenExchange({
      public_token: input.publicToken,
    });

    const { access_token, item_id } = exchangeResponse.data;

    await prisma.bankingProfile.update({
      where: { userId },
      data: {
        plaidAccessToken: access_token,
        plaidItemId: item_id,
        plaidAccountId: input.accountId,
      },
    });
  }

  /**
   * Returns linked bank account details (name, mask, routing/account numbers).
   * Account number is included here — guard this endpoint with auth + logging.
   */
  async getLinkedAccount(userId: string): Promise<PlaidAuthDTO | null> {
    const profile = await prisma.bankingProfile.findUnique({ where: { userId } });
    if (!profile?.plaidAccessToken) return null;

    const authResponse = await plaidClient.authGet({
      access_token: profile.plaidAccessToken,
    });

    const accounts = authResponse.data.accounts;
    const achNumbers = authResponse.data.numbers.ach;

    const selected = profile.plaidAccountId
      ? accounts.find((a) => a.account_id === profile.plaidAccountId)
      : accounts[0];

    if (!selected) return null;

    const ach = achNumbers.find((n) => n.account_id === selected.account_id);

    return {
      accountId: selected.account_id,
      name: selected.name,
      mask: selected.mask ?? "",
      itemId: profile.plaidItemId ?? "",
      routingNumber: ach?.routing,
      accountNumber: ach?.account,
    };
  }

  // ─── Plaid Webhook ──────────────────────────────────────────────────────────

  /**
   * Verifies the Plaid-Verification JWT sent with every webhook.
   *
   * Full JWK verification requires the `jose` package:
   *   npm install jose
   * Until then, we fetch the key from Plaid (confirming the key_id is valid)
   * and check it has not expired. Set PLAID_VERIFY_WEBHOOKS=true to enforce.
   *
   * Plaid sandbox webhook codes for IDENTITY_VERIFICATION:
   *   STATUS_UPDATED — fired on any status change
   *   STEP_UPDATED   — fired per step advance
   *
   * Fire test webhooks via:
   *   Plaid Dashboard → Send Webhook, or
   *   POST /sandbox/identity_verification/fire_webhook
   */
  async verifyWebhookToken(token: string, rawBody?: Buffer): Promise<boolean> {
    try {
      const decoded = jwt.decode(token, { complete: true }) as any;
      if (!decoded?.header?.kid) return false;

      const keyResponse = await plaidClient.webhookVerificationKeyGet({
        key_id: decoded.header.kid,
      });

      const key = keyResponse.data.key;
      if (key.expired_at) return false;

      // Full JWT signature verification using jose
      const { importJWK, jwtVerify } = await import("jose");
      const publicKey = await importJWK(key as any);
      const { payload } = await jwtVerify(token, publicKey);

      // Verify token is fresh (within 5 minutes)
      const iat = payload.iat as number;
      if (!iat || Date.now() / 1000 - iat > 300) return false;

      // Verify body hash if raw body is available
      if (rawBody && payload.request_body_sha256) {
        const { createHash } = await import("crypto");
        const bodyHash = createHash("sha256").update(rawBody).digest("hex");
        if (payload.request_body_sha256 !== bodyHash) return false;
      }

      return true;
    } catch {
      return false;
    }
  }

  /**
   * Handles incoming Plaid webhooks.
   * Supports IDENTITY_VERIFICATION and ITEM webhook types.
   */
  async handlePlaidWebhook(body: PlaidWebhookBody) {
    if (body.webhook_type === "IDENTITY_VERIFICATION") {
      if (body.webhook_code !== "STATUS_UPDATED") return;
      if (!body.identity_verification_id) return;

      const idvResponse = await plaidClient.identityVerificationGet({
        identity_verification_id: body.identity_verification_id,
      });

      const plaidStatus = idvResponse.data.status as PlaidIdvStatus;
      const mapped = mapPlaidStatus(plaidStatus);

      await prisma.bankingProfile.updateMany({
        where: { plaidIdvId: body.identity_verification_id },
        data: {
          plaidStatus,
          status: mapped.status,
          kycVerified: mapped.kycVerified,
          ...(mapped.approvedAt && { approvedAt: mapped.approvedAt }),
          ...(mapped.rejectedAt && { rejectedAt: mapped.rejectedAt }),
        },
      });

      // Notify user of KYC status change
      const profiles = await prisma.bankingProfile.findMany({
        where: { plaidIdvId: body.identity_verification_id },
        select: { userId: true },
      });

      for (const { userId } of profiles) {
        const user = await prisma.user.findUnique({ where: { id: userId }, select: { firstName: true } });
        if (mapped.status === "APPROVED") {
          NotificationService.notifyUser(userId, {
            subject: "Your identity has been verified",
            title: "KYC Approved",
            message: T.kycApproved(user?.firstName || "there"),
          }).catch(() => {});
        } else if (mapped.status === "REJECTED") {
          NotificationService.notifyUser(userId, {
            subject: "Identity verification update",
            title: "Verification Update",
            message: T.kycRejected(user?.firstName),
          }).catch(() => {});
        }
      }
    }

    if (body.webhook_type === "ITEM") {
      if (body.webhook_code === "ERROR" && body.item_id) {
        const profiles = await prisma.bankingProfile.findMany({
          where: { plaidItemId: body.item_id },
          select: { userId: true },
        });

        await prisma.bankingProfile.updateMany({
          where: { plaidItemId: body.item_id },
          data: {
            plaidAccessToken: null,
            plaidItemId: null,
            plaidAccountId: null,
          },
        });

        for (const { userId } of profiles) {
          NotificationService.notifyUser(userId, {
            subject: "Action required: reconnect your bank",
            title: "Bank Re-auth Needed",
            message: T.kycBankReauthRequired(),
          }).catch(() => {});
        }
      }
    }
  }

  // ─── Admin overrides ────────────────────────────────────────────────────────

  async approveKyc(userId: string, riskLevel: RiskLevel) {
    return prisma.bankingProfile.update({
      where: { userId },
      data: {
        status: "APPROVED",
        kycVerified: true,
        riskLevel,
        approvedAt: new Date(),
      },
    });
  }

  async rejectKyc(userId: string, reason: string) {
    return prisma.bankingProfile.update({
      where: { userId },
      data: {
        status: "REJECTED",
        kycVerified: false,
        rejectionReason: reason,
        rejectedAt: new Date(),
      },
    });
  }

  async freezeAccount(userId: string) {
    return prisma.bankingProfile.update({
      where: { userId },
      data: { frozen: true, status: "SUSPENDED" },
    });
  }

  async unfreezeAccount(userId: string) {
    return prisma.bankingProfile.update({
      where: { userId },
      data: { frozen: false, status: "APPROVED" },
    });
  }
}

export const kycService = new KycService();
