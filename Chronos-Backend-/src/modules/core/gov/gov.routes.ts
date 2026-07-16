// src/routes/gov.routes.ts

import { Router } from 'express';
import { payTax, payTransport, payEducation, payVisa } from '../../controllers/gov.controller';

const router = Router();

router.post('/pay/tax', payTax);
router.post('/pay/transport', payTransport);
router.post('/pay/education', payEducation);
router.post('/pay/visa', payVisa);

export default router;
