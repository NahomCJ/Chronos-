import { AnalysisType, Platform } from './types';

export function detectPlatform(rawUrl: string): Platform {
  try {
    const host = new URL(rawUrl).hostname.replace(/^www\./, '');
    if (host === 'github.com') return 'github';
    if (host === 'reddit.com' || host === 'old.reddit.com') return 'reddit';
    if (host === 'notion.so' || host.endsWith('.notion.so') || host === 'notion.site') return 'notion';
    if (host === 'open.spotify.com' || host === 'spotify.com') return 'spotify';
    if (host === 'canva.com' || host.endsWith('.canva.com')) return 'canva';
    return 'generic';
  } catch {
    return 'generic';
  }
}

export function inferAnalysisType(rawUrl: string, platform: Platform): AnalysisType {
  if (platform === 'canva') return 'pitch_deck';
  if (platform === 'spotify') return 'profile';
  if (platform === 'reddit') return 'content';
  if (platform === 'notion') return 'content';
  if (platform === 'github') {
    try {
      const parts = new URL(rawUrl).pathname.split('/').filter(Boolean);
      return parts.length === 1 ? 'profile' : 'code_review';
    } catch {
      return 'code_review';
    }
  }
  return 'general';
}
