// src/routes/accounts.routes.ts
import { Router } from 'express';
import * as AccountsController from './accounts.controller';
import { requireAuth, requireAdmin } from '../../auth/middlewares/auth.middleware';

const router = Router();

// user endpoints
router.post('/create', requireAuth, AccountsController.createAccount.bind(AccountsController));
router.get('/', requireAuth, AccountsController.getAllAccounts.bind(AccountsController));
router.get('/:id', requireAuth, AccountsController.getAccountById.bind(AccountsController));
router.post('/freeze', requireAuth, AccountsController.freezeAccount.bind(AccountsController));
router.post('/close', requireAuth, AccountsController.closeAccount.bind(AccountsController));
router.put('/update', requireAuth, AccountsController.updateAccount.bind(AccountsController));
router.get('/:id/statements', requireAuth, AccountsController.getAccountStatements.bind(AccountsController));
router.post('/upgrade-tier', requireAuth, AccountsController.upgradeAccountTier.bind(AccountsController));

// admin endpoints
router.post('/:id/freeze', requireAuth, requireAdmin, AccountsController.freezeAccount.bind(AccountsController));
router.post('/:id/close', requireAuth, requireAdmin, AccountsController.closeAccount.bind(AccountsController));
router.put('/:id/update', requireAuth, requireAdmin, AccountsController.updateAccount.bind(AccountsController));
router.post('/:id/upgrade-tier', requireAuth, requireAdmin, AccountsController.upgradeAccountTier.bind(AccountsController));

export default router;
