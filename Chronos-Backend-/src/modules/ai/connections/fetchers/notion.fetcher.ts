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

function extractNotionPageId(rawUrl: string): string | null {
  // Notion page IDs: 32 hex chars, sometimes hyphenated as UUID
  const match = rawUrl.match(/([a-f0-9]{32})|([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})/i);
  return match ? match[0].replace(/-/g, '') : null;
}

export async function fetchNotion(rawUrl: string, token?: string): Promise<FetchedContent> {
  // Private page via Notion Integration token
  if (token) {
    const pageId = extractNotionPageId(rawUrl);
    if (pageId) {
      const headers = { Authorization: `Bearer ${token}`, 'Notion-Version': '2022-06-28' };

      const pageRes = await fetch(`https://api.notion.com/v1/pages/${pageId}`, { headers });
      if (pageRes.ok) {
        const page = await pageRes.json();
        const titleProp =
          page.properties?.title?.title?.[0]?.plain_text ||
          page.properties?.Name?.title?.[0]?.plain_text ||
          'Notion Page';

        // Fetch page content blocks
        const blocksRes = await fetch(
          `https://api.notion.com/v1/blocks/${pageId}/children?page_size=100`,
          { headers }
        );
        let contentText = '';
        if (blocksRes.ok) {
          const blocks = await blocksRes.json();
          contentText = (blocks.results as any[])
            .map((b: any) => {
              const rt = b[b.type]?.rich_text as any[] | undefined;
              return rt ? rt.map((t: any) => t.plain_text).join('') : '';
            })
            .filter(Boolean)
            .join('\n');
        }

        return {
          platform: 'notion',
          url: rawUrl,
          title: titleProp,
          text: `${titleProp}\n\n${contentText.substring(0, 5000)}`,
          metadata: { type: 'page', pageId, source: 'notion-api' },
          canWrite: true,
        };
      }
    }
  }

  // Public page — scrape HTML
  const res = await fetch(rawUrl, {
    headers: { 'User-Agent': 'Mozilla/5.0 (compatible; Chronos-App/1.0)' },
  });
  if (!res.ok) throw new Error(`Cannot reach Notion page: ${res.status}`);
  const html = await res.text();

  const titleMatch = html.match(/<title[^>]*>([^<]+)<\/title>/i);
  const title = (titleMatch?.[1] ?? 'Notion Page').replace(/\s*[–—-]\s*Notion\s*$/i, '').trim();

  const mainMatch = html.match(/<div[^>]*class="[^"]*notion-page-content[^"]*"[^>]*>([\s\S]*?)<\/div>/i);
  const rawText = stripHtml(mainMatch ? mainMatch[1] : html).substring(0, 5000);

  return {
    platform: 'notion',
    url: rawUrl,
    title,
    text: rawText || `(Public Notion page: ${title})`,
    metadata: { type: 'page', source: 'scrape' },
    canWrite: false,
  };
}
