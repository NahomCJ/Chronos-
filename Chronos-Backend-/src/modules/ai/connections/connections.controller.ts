import { Request, Response } from 'express';
import { analyzeUrl, SUPPORTED_PLATFORMS } from './connections.service';
import { AnalysisType } from './types';

const VALID_TYPES = new Set<AnalysisType>(['pitch_deck', 'code_review', 'profile', 'content', 'general']);

export async function analyzeConnection(req: Request, res: Response): Promise<void> {
  const { url, analysisType, token } = req.body as {
    url?: string;
    analysisType?: string;
    token?: string;
  };

  if (!url || typeof url !== 'string') {
    res.status(400).json({ error: 'url is required' });
    return;
  }

  try {
    new URL(url);
  } catch {
    res.status(400).json({ error: 'url must be a valid URL including protocol (https://...)' });
    return;
  }

  const type = analysisType as AnalysisType | undefined;
  if (type && !VALID_TYPES.has(type)) {
    res.status(400).json({
      error: `analysisType must be one of: ${[...VALID_TYPES].join(', ')}`,
    });
    return;
  }

  try {
    const result = await analyzeUrl({ url, analysisType: type, token });
    res.status(200).json(result);
  } catch (err) {
    const msg = err instanceof Error ? err.message : 'Analysis failed';
    console.error('[connections] analyze error:', msg);
    res.status(500).json({ error: msg });
  }
}

export function getPlatforms(_req: Request, res: Response): void {
  res.status(200).json({
    platforms: SUPPORTED_PLATFORMS,
    analysisTypes: [
      { id: 'pitch_deck', label: 'Pitch Deck Review', description: 'Investor-ready feedback on presentations' },
      { id: 'code_review', label: 'Code Review', description: 'Architecture, security, and quality feedback' },
      { id: 'profile', label: 'Profile Analysis', description: 'Personal brand and profile strength' },
      { id: 'content', label: 'Content Analysis', description: 'Page, post, and document insights' },
      { id: 'general', label: 'General Analysis', description: 'Catch-all analysis for any URL' },
    ],
  });
}
