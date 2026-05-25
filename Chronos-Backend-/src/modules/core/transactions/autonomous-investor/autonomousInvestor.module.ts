import { Router } from 'express';
import autonomousInvestorRoutes from './autonomousInvestor.routes';

export const AutonomousInvestorModule = (router: Router) => {
    router.use('/autonomous-investor', autonomousInvestorRoutes);
};
