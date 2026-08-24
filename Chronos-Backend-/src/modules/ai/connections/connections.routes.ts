import { Router } from 'express';
import { requireAuth } from '../../auth/middlewares/auth.middleware';
import { analyzeConnection, getPlatforms } from './connections.controller';

const router = Router();

// GET /api/ai/connections/platforms — supported platforms & analysis types (no auth)
router.get('/platforms', getPlatforms);

// POST /api/ai/connections/analyze — fetch + analyze a URL (auth required)
// Body: { url: string, analysisType?: string, token?: string }
router.post('/analyze', requireAuth, analyzeConnection);

export default router;
