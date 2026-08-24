export type Platform = 'github' | 'reddit' | 'notion' | 'spotify' | 'canva' | 'generic';
export type AnalysisType = 'pitch_deck' | 'code_review' | 'profile' | 'content' | 'general';

export interface FetchedContent {
  platform: Platform;
  url: string;
  title: string;
  text: string;
  metadata: Record<string, unknown>;
  canWrite: boolean;
}

export interface Suggestion {
  category: string;
  priority: 'high' | 'medium' | 'low';
  title: string;
  description: string;
  action?: string;
}

export interface AnalysisResult {
  platform: Platform;
  url: string;
  title: string;
  analysisType: AnalysisType;
  summary: string;
  suggestions: Suggestion[];
  scores?: Record<string, number>;
  metadata: Record<string, unknown>;
  canWrite: boolean;
  timestamp: string;
}
