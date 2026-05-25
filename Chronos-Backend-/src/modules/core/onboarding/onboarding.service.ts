// src/modules/core/onboarding/onboarding.service.ts
//
// Full new-user onboarding flow:
//   Step 1  POST /onboarding/start
//           → register user (email + password)
//           → create BankingProfile (DRAFT)
//           → create Plaid IDV Link token
//           → return { user, accessToken, refreshToken, plaidLinkToken }
//
//   Step 2  (Frontend) User completes Plaid Identity Verification in-app
//           Plaid calls our webhook → KYC status updated automatically
//           OR user calls POST /kyc/session/complete with identityVerificationId
//
//   Step 3  POST /onboarding/link-bank
//           → create Plaid Auth Link token (requires KYC APPROVED)
//           → return { plaidLinkToken }
//
//   Step 4  (Frontend) User selects their bank + account in Plaid Link
//           → calls POST /kyc/bank/connect with { publicToken, accountId }
//
//   Step 5  POST /onboarding/status
//           → returns current onboarding state so the frontend knows what step to show
//
// NOTE: API keys are placeholder — set PLAID_CLIENT_ID, PLAID_SECRET, PLAID_IDV_TEMPLATE_ID
//       in .env when keys are issued. Server starts fine without them (routes warn, not crash).

import * as bcrypt from "bcrypt";
import { PrismaClient } from "@prisma/client";
import { generateToken, generateRefreshToken } from "../../../modules/auth/utils/utils";
import { NotificationService } from "../../notification/notificatoin.service";
import * as T from "../../notification/email.templates";
import { plaidClient } from "../../../config/plaid";
import { CountryCode, Products } from "plaid";

const prisma = new PrismaClient();

export interface OnboardingStartInput {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  dateOfBirth?: string;   // "YYYY-MM-DD" — passed to Plaid IDV
  phoneNumber?: string;   // E.164 format — passed to Plaid IDV
}

export interface OnboardingStartResult {
  user: {
    id: string;
    email: string;
    firstName: string | null;
    lastName: string | null;
    role: string;
  };
  accessToken: string;
  refreshToken: string;
  onboarding: {
    step: "KYC_PENDING";
    /** Pass this token to Plaid Link on the frontend to start Identity Verification */
    plaidLinkToken: string | null;
    plaidLinkTokenExpiration: string | null;
    message: string;
  };
}

export class OnboardingService {

  // ─── Step 1: register + create profile + start KYC ──────────────────────────

  async start(input: OnboardingStartInput): Promise<OnboardingStartResult> {
    const { email, password, firstName, lastName, dateOfBirth, phoneNumber } = input;

    // 1a. Guard: email uniqueness
    const existing = await prisma.user.findUnique({ where: { email } });
    if (existing) throw new Error("An account with this email already exists.");

    // 1b. Create user
    const hashedPassword = await bcrypt.hash(password, 10);
    const user = await prisma.user.create({
      data: { email, password: hashedPassword, firstName, lastName, role: "USER" },
    });

    // 1c. Issue JWTs
    const tokenPayload = { userId: user.id, email: user.email, role: user.role };
    const accessToken = generateToken(tokenPayload);
    const refreshToken = generateRefreshToken(tokenPayload);

    // 1d. Create BankingProfile (DRAFT — pre-KYC)
    await prisma.bankingProfile.create({ data: { userId: user.id } });

    // 1e. Send welcome email (non-blocking)
    NotificationService.sendDirectEmail(
      user.email,
      "Welcome to Chronos!",
      T.welcome(user.firstName || "there")
    ).catch(() => {});

    // 1f. Create Plaid IDV link token (gracefully fails if keys not yet configured)
    let plaidLinkToken: string | null = null;
    let plaidLinkTokenExpiration: string | null = null;

    const templateId = process.env.PLAID_IDV_TEMPLATE_ID;
    const plaidConfigured =
      !!process.env.PLAID_CLIENT_ID &&
      !!process.env.PLAID_SECRET &&
      !!templateId;

    if (plaidConfigured) {
      try {
        const response = await plaidClient.linkTokenCreate({
          user: {
            client_user_id: user.id,
            email_address: email,
            legal_name: `${firstName} ${lastName}`,
            ...(dateOfBirth && { date_of_birth: dateOfBirth }),
            ...(phoneNumber && { phone_number: phoneNumber }),
          },
          client_name: "Chronos",
          products: [Products.IdentityVerification],
          identity_verification: { template_id: templateId! },
          language: "en",
          country_codes: [CountryCode.Us],
        });

        plaidLinkToken = response.data.link_token;
        plaidLinkTokenExpiration = response.data.expiration;

        // Mark profile as PENDING now that IDV has been initiated
        await prisma.bankingProfile.update({
          where: { userId: user.id },
          data: { status: "PENDING", submittedAt: new Date() },
        });
      } catch (err: any) {
        // Non-fatal: log and continue. Frontend will retry via /kyc/session/create.
        console.warn("[Onboarding] Plaid IDV link token creation failed:", err?.message);
      }
    } else {
      console.warn(
        "[Onboarding] Plaid not configured (PLAID_CLIENT_ID / PLAID_SECRET / PLAID_IDV_TEMPLATE_ID missing). " +
          "User registered successfully — KYC step will be available once keys are set."
      );
    }

    const { password: _pw, ...safeUser } = user;

    return {
      user: safeUser as any,
      accessToken,
      refreshToken,
      onboarding: {
        step: "KYC_PENDING",
        plaidLinkToken,
        plaidLinkTokenExpiration,
        message: plaidLinkToken
          ? "Account created. Pass the plaidLinkToken to Plaid Link to complete identity verification."
          : "Account created. Plaid KYC is not yet configured — call POST /kyc/session/create once API keys are set.",
      },
    };
  }

  // ─── Step 3: link bank (after KYC approved) ──────────────────────────────────

  async linkBank(userId: string): Promise<{ plaidLinkToken: string; expiration: string }> {
    const profile = await prisma.bankingProfile.findUnique({ where: { userId } });
    if (!profile) throw new Error("Banking profile not found.");
    if (!profile.kycVerified) {
      throw new Error(
        "Identity verification must be approved before linking a bank account. " +
          "Complete KYC via POST /kyc/session/create and then POST /kyc/session/complete."
      );
    }
    if (profile.plaidAccessToken) {
      throw new Error("A bank account is already linked. Unlink the existing account first.");
    }

    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new Error("User not found.");

    const response = await plaidClient.linkTokenCreate({
      user: { client_user_id: userId, email_address: user.email },
      client_name: "Chronos",
      products: [Products.Auth],
      language: "en",
      country_codes: [CountryCode.Us],
    });

    return {
      plaidLinkToken: response.data.link_token,
      expiration: response.data.expiration,
    };
  }

  // ─── Onboarding status (what step is the user on?) ───────────────────────────

  async getStatus(userId: string) {
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new Error("User not found.");

    const profile = await prisma.bankingProfile.findUnique({ where: { userId } });

    if (!profile) {
      return {
        step: "PROFILE_MISSING",
        kycVerified: false,
        bankLinked: false,
        message: "Banking profile not created. Call POST /onboarding/start.",
      };
    }

    const kycVerified = profile.kycVerified;
    const bankLinked = !!profile.plaidAccessToken;

    if (!kycVerified) {
      return {
        step: "KYC_PENDING",
        kycStatus: profile.status,
        plaidIdvId: profile.plaidIdvId,
        kycVerified: false,
        bankLinked: false,
        message: "Identity verification is pending or not yet started.",
      };
    }

    if (!bankLinked) {
      return {
        step: "BANK_LINK_PENDING",
        kycVerified: true,
        bankLinked: false,
        message: "KYC approved. Call POST /onboarding/link-bank to connect your bank account.",
      };
    }

    return {
      step: "COMPLETE",
      kycVerified: true,
      bankLinked: true,
      message: "Onboarding complete. You can now deposit funds and start trading.",
    };
  }
}

export const onboardingService = new OnboardingService();
