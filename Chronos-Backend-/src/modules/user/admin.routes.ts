import { Router } from 'express';
import { getUsers, lockAccount, getAuditLogs, impersonate } from './admin.service';

const router = Router();

router.get('/admin/users', getUsers);
router.post('/admin/lock-account', lockAccount);
router.get('/admin/audit/logs', getAuditLogs);
router.post('/admin/impersonate', impersonate);

export default router;
