import { Router } from 'express';
import { z } from 'zod';
import { validate } from '../../../middlewares/validate.middleware';
 import{requireAuth } from '../../auth/middlewares/auth.middleware';
import * as CardsController from './cards.controller';
import { CardType, CardStatus } from '@prisma/client';

const router = Router();

// Zod Schemas
const issueSchema = z.object({
  accountId: z.string().uuid(),
  brand: z.string().min(2),
  last4: z.string().regex(/^\d{4}$/),
  type: z.enum(['VIRTUAL', 'PHYSICAL', 'TICKPAY', 'CRYPTO']),
});

const replaceSchema = z.object({
  brand: z.string().min(2),
  last4: z.string().regex(/^\d{4}$/),
  type: z.enum(['VIRTUAL', 'PHYSICAL', 'TICKPAY', 'CRYPTO']),
});

const statusSchema = z.object({
  status: z.enum(['ACTIVE', 'FROZEN']),
});

// Routes
router.post('/issue', requireAuth, validate(issueSchema), CardsController.issueCard);
router.get('/', requireAuth, CardsController.listCards);
router.get('/:id', requireAuth, CardsController.getCardById);
router.patch('/:id/status', requireAuth, validate(statusSchema), CardsController.setCardStatus);
router.post('/:id/replace', requireAuth, validate(replaceSchema), CardsController.replaceCard);
router.put('/:id/pin', requireAuth, CardsController.changePin);
router.put('/:id/spending-limits', requireAuth, CardsController.setSpendingLimits);

export default router;
