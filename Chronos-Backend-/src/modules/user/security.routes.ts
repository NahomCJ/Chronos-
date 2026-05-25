import { Router } from 'express';
import { enable2FA, verify2FA, sendNotification, getHistory } from '../../controllers/security.controller';

const router = Router();

router.post('/2fa/enable', enable2FA);
router.post('/2fa/verify', verify2FA);
router.post('/notifications/send', sendNotification);
router.get('/notifications/history', getHistory);

export default router;
