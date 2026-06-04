import { Router } from "express";
import authRoutes from "../modules/auth/routes/auth.routes";

// import express from 'express';
// import authRoutes from './auth.routes';
import accountRoutes from '../modules/core/accounts/accounts.routes';
import transferRoutes from '../modules/core/transfer/routes/transfer.routes';
import  tickpayRoutes from '../modules/bnpl/routes/tickpay.routes';
 import cardRoutes from '../modules/core/card/cards.routes';
// import transactionRoutes from './transactions.routes';
// import dwmRoutes from './dwm.routes';
// import aiRoutes from './ai.routes';
// import tickpayRoutes from './tickpay.routes';
// import cryptoRoutes from './crypto.routes';
// import nftRoutes from './nft.routes';
 import lifexRoutes from '../modules/lifex/routes/lifex.routes';
 import billsRoutes from '../modules/core/bill/bills.routes';
import currrencyRoutes from '../modules/core/currency/currency.routes';
//import r from "../modules/crypto/routes/crypto.routes";
// import govRoutes from './gov.routes';
// import kycRoutes from './kyc.routes';
// import securityRoutes from './security.routes';
// import adminRoutes from './admin.routes';
 import coreTransferRoutes from "../modules/core/transfer/transfer.routes";
import fxRoutes from "../modules/core/fx/fx.routes";
import walletRoutes from "../modules/core/wallet/wallet.routes";
import kycRoutes from "../modules/core/kyc/kyc.routes";
import transactionRoutes from "../modules/core/transactions/transaction.route";
import r from "../modules/crypto/routes/crypto.routes";
import depositRoutes from "../modules/core/deposit/deposit.routes";
// import cryptoRoutes from "../modules/crypto/routes/crypto.routes";
import aiRoutes from "../modules/ai/ai.routes";
import homeRoutes from "../modules/core/home/home.routes";
import notificationRoutes from "../modules/core/notifications/notifications.routes";
import onboardingRoutes from "../modules/core/onboarding/onboarding.routes";
import userProfileRoutes from "../modules/user/user-profile.routes";

const router = Router();

// Mount API v1
router.use("/v1/auth", authRoutes);
router.use("/v1/transfer", transferRoutes);
router.use('/core/accounts', accountRoutes);

// router.use("/v1/cards", cardRoutes);












// router.use('/auth', authRoutes);

// router.use('/transfer', transferRoutes);
 router.use('/cards', cardRoutes);
router.use('/transactions', transactionRoutes);
// router.use('/dwm', dwmRoutes);
router.use('/wallet', walletRoutes);
router.use('/tickpay', tickpayRoutes);
// router.use('/crypto', cryptoRoutes);
// router.use('/nft', nftRoutes);
 router.use('/lifex', lifexRoutes);
 router.use('/bills', billsRoutes);
 router.use('/currency', currrencyRoutes);
 router.use('/fx', fxRoutes);
// router.use('/gov', govRoutes);
 router.use('/kyc', kycRoutes);
// router.use('/', securityRoutes); // root-level for now
// router.use('/', adminRoutes);
// router.use("/core/transfer", coreTransferRoutes);
 router.use("/core/transfer", coreTransferRoutes);
 router.use("/core/deposit", depositRoutes);
router.use("/ai", aiRoutes);
router.use("/home", homeRoutes);
router.use("/notifications", notificationRoutes);
router.use("/onboarding", onboardingRoutes);
router.use("/v1/users", userProfileRoutes);
export default router;