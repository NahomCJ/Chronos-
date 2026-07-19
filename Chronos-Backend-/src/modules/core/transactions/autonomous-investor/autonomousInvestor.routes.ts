import { Router } from 'express';
import { AutonomousInvestorController } from './autonomousInvestor.controller';

const router = Router();
const controller = new AutonomousInvestorController();

router.post('/settings', controller.createSettings.bind(controller));
router.get('/settings/:userId', controller.getSettings.bind(controller));
router.put('/settings/:userId', controller.updateSettings.bind(controller));
router.get('/plan/:userId', controller.generateInvestmentPlan.bind(controller));

export default router;
