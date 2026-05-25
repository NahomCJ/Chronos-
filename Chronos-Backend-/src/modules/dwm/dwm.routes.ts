import { Router } from 'express';
import {
    getDWMSummary,
    postDWMAdvice,
    trackGoal,
    setupAutoSave
} from '../../controllers/dwm.controller';

const router = Router();

router.get('/summary', getDWMSummary);
router.post('/advice', postDWMAdvice);
router.post('/track-goal', trackGoal);
router.post('/auto-save/setup', setupAutoSave);

export default router;
