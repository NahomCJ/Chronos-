// src/core/bill/bill.routes.ts

import { Router } from 'express';
import * as billController from './bills.controller';
 import{requireAuth } from '../../auth/middlewares/auth.middleware';
const router = Router();

// All bill routes require authentication
router.get('/providers', requireAuth, billController.getProviders);
router.post('/pay', requireAuth, billController.payBill);
router.get('/history', requireAuth, billController.getHistory);

export default router;
