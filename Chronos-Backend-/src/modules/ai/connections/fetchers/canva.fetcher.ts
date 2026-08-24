import { FetchedContent } from '../types';

function stripHtml(html: string): string {
  return html
    .replace(/<script[^>]*>[\s\S]*?<\/script>/gi, '')
    .replace(/<style[^>]*>[\s\S]*?<\/style>/gi, '')
    .replace(/<[^>]+>/g, ' ')
    .replace(/&nbsp;/g, ' ')
    .replace(/&amp;/g, '&')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&quot;/g, '"')
    .replace(/\s{2,}/g, ' ')
    .trim();
}

function extractMeta(html: string, property: string): string {
  const match =
    html.match(new RegExp(`<meta[^>]*property="${property}"[^>]*content="([^"]+)"`, 'i')) ||
    html.match(new RegExp(`<meta[^>]*name="${property}"[^>]*content="([^"]+)"`, 'i'));
  return match?.[1] ?? '';
}

export async function fetchCanva(rawUrl: string): Promise<FetchedContent> {
  const res = await fetch(rawUrl, {
    headers: {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/124.0.0.0 Safari/537.36',
      Accept: 'text/html,application/xhtml+xml,*/*',
    },
  });
  if (!res.ok) throw new Error(`Cannot fetch Canva page: ${res.status}`);
  const html = await res.text();

  const ogTitle = extractMeta(html, 'og:title');
  const ogDesc = extractMeta(html, 'og:description');
  const twitterTitle = extractMeta(html, 'twitter:title');

  const titleRaw =
    ogTitle || twitterTitle || html.match(/<title[^>]*>([^<]+)<\/title>/i)?.[1] || 'Canva Design';
  const title = titleRaw.replace(/\s*[|–—-]\s*Canva\s*$/i, '').trim();

  // Extract any JSON-LD structured data Canva embeds
  const jsonLdBlocks = [...html.matchAll(/<script[^>]*type="application\/ld\+json"[^>]*>([\s\S]*?)<\/script>/gi)];
  const structuredItems: unknown[] = [];
  for (const [, raw] of jsonLdBlocks) {
    try { structuredItems.push(JSON.parse(raw.trim())); } catch { /* skip */ }
  }

  // Heuristic: is this a pitch deck / presentation?
  const looksLikeDeck =
    /presentation|pitch|deck|slide/i.test(rawUrl + ' ' + title + ' ' + ogDesc);

  const bodyText = stripHtml(html).substring(0, 4000);

  const text = [
    `Design Title: ${title}`,
    ogDesc ? `Description: ${ogDesc}` : '',
    looksLikeDeck ? 'Type: Presentation / Pitch Deck' : 'Type: Design',
    structuredItems.length
      ? `Structured data: ${JSON.stringify(structuredItems[0]).substring(0, 600)}`
      : '',
    '',
    'Extracted page text:',
    bodyText,
  ]
    .filter(Boolean)
    .join('\n');

  return {
    platform: 'canva',
    url: rawUrl,
    title,
    text,
    metadata: {
      type: looksLikeDeck ? 'presentation' : 'design',
      description: ogDesc,
      hasStructuredData: structuredItems.length > 0,
    },
    // Canva write-back requires user OAuth — designed for future implementation
    canWrite: false,
  };
}
