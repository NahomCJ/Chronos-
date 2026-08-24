import { detectPlatform, inferAnalysisType } from './platform-detector';
import { fetchGitHub } from './fetchers/github.fetcher';
import { fetchReddit } from './fetchers/reddit.fetcher';
import { fetchNotion } from './fetchers/notion.fetcher';
import { fetchSpotify } from './fetchers/spotify.fetcher';
import { fetchCanva } from './fetchers/canva.fetcher';
import { fetchGeneric } from './fetchers/generic.fetcher';
import { analyzeContent } from './analyzer';
import { AnalysisResult, AnalysisType, FetchedContent, Platform } from './types';

export interface AnalyzeRequest {
  url: string;
  analysisType?: AnalysisType;
  token?: string;
}

async function fetchContent(url: string, platform: Platform, token?: string): Promise<FetchedContent> {
  switch (platform) {
    case 'github':  return fetchGitHub(url, token);
    case 'reddit':  return fetchReddit(url);
    case 'notion':  return fetchNotion(url, token);
    case 'spotify': return fetchSpotify(url);
    case 'canva':   return fetchCanva(url);
    default:        return fetchGeneric(url);
  }
}

export async function analyzeUrl(req: AnalyzeRequest): Promise<AnalysisResult> {
  const platform = detectPlatform(req.url);
  const analysisType = req.analysisType ?? inferAnalysisType(req.url, platform);
  const content = await fetchContent(req.url, platform, req.token);
  return analyzeContent(content, analysisType);
}

export const SUPPORTED_PLATFORMS = [
  {
    id: 'github',
    name: 'GitHub',
    description: 'Repositories, user profiles, and code files',
    examples: ['github.com/user', 'github.com/owner/repo', 'github.com/owner/repo/blob/main/file.ts'],
    writeBack: 'Issue creation — provide a GitHub token',
    icon: '🐙',
  },
  {
    id: 'reddit',
    name: 'Reddit',
    description: 'Posts, subreddits, and comment threads',
    examples: ['reddit.com/r/startups', 'reddit.com/r/sub/comments/id/title'],
    writeBack: null,
    icon: '🟠',
  },
  {
    id: 'notion',
    name: 'Notion',
    description: 'Public pages and private pages (with integration token)',
    examples: ['notion.so/Page-Title-abc123', 'your-workspace.notion.site/page'],
    writeBack: 'Comment creation — provide a Notion integration token',
    icon: '⬛',
  },
  {
    id: 'spotify',
    name: 'Spotify',
    description: 'Tracks, albums, playlists, artists, and podcasts',
    examples: ['open.spotify.com/track/id', 'open.spotify.com/playlist/id'],
    writeBack: null,
    icon: '🟢',
  },
  {
    id: 'canva',
    name: 'Canva',
    description: 'Designs, presentations, and pitch decks — ideal for pitch deck review',
    examples: ['canva.com/design/xxx/view', 'canva.com/design/xxx/present'],
    writeBack: 'Planned — requires Canva OAuth',
    icon: '🎨',
  },
  {
    id: 'generic',
    name: 'Any public URL',
    description: 'Any publicly accessible web page',
    examples: ['yoursite.com/page'],
    writeBack: null,
    icon: '🌐',
  },
];
