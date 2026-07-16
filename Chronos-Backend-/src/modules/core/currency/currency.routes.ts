import { Router } from 'express';
 import{requireAuth } from '../../auth/middlewares/auth.middleware';

import {
  getLatestRate,
  convertCurrency,
  getCurrencyHistory,
} from './currency.controller';

const router = Router();

router.get('/latest', requireAuth, getLatestRate); // ?from=USD&to=EUR
router.get('/convert', requireAuth, convertCurrency); // ?from=USD&to=EUR&amount=100
router.get('/history', requireAuth, getCurrencyHistory); // ?from=USD&to=EUR&start=2026-01-01&end=2026-01-31

export default router;
