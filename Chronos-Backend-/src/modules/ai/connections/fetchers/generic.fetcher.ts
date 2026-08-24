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

export async function fetchGeneric(rawUrl: string): Promise<FetchedContent> {
  const res = await fetch(rawUrl, {
    headers: {
      'User-Agent': 'Mozilla/5.0 (compatible; Chronos-App/1.0)',
      Accept: 'text/html,application/xhtml+xml,*/*',
    },
  });
  if (!res.ok) throw new Error(`Cannot fetch URL: ${res.status} ${res.statusText}`);
  const html = await res.text();

  const ogTitle = extractMeta(html, 'og:title');
  const ogDesc = extractMeta(html, 'og:description');
  const pageTitle = html.match(/<title[^>]*>([^<]+)<\/title>/i)?.[1] ?? new URL(rawUrl).hostname;
  const title = ogTitle || pageTitle;

  const mainMatch = html.match(/<(?:main|article)[^>]*>([\s\S]*?)<\/(?:main|article)>/i);
  const bodyText = stripHtml(mainMatch ? mainMatch[1] : html).substring(0, 5000);

  const text = [
    `URL: ${rawUrl}`,
    `Title: ${title}`,
    ogDesc ? `Description: ${ogDesc}` : '',
    '',
    bodyText,
  ]
    .filter(Boolean)
    .join('\n');

  return {
    platform: 'generic',
    url: rawUrl,
    title,
    text,
    metadata: { hostname: new URL(rawUrl).hostname, description: ogDesc },
    canWrite: false,
  };
}
