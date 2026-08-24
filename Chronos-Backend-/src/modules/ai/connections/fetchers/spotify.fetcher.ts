import { FetchedContent } from '../types';

export async function fetchSpotify(rawUrl: string): Promise<FetchedContent> {
  // Spotify oEmbed — no auth required for public content
  const oembedRes = await fetch(
    `https://open.spotify.com/oembed?url=${encodeURIComponent(rawUrl)}`,
    { headers: { 'User-Agent': 'Chronos-App/1.0' } }
  );
  if (!oembedRes.ok) throw new Error(`Spotify oEmbed ${oembedRes.status}: ${oembedRes.statusText}`);
  const data = await oembedRes.json();

  const parts = new URL(rawUrl).pathname.split('/').filter(Boolean);
  const contentType = parts[0] || 'content'; // track, album, artist, playlist, show, episode

  const text = [
    `Title: ${data.title}`,
    `Type: Spotify ${contentType}`,
    `Provider: ${data.provider_name}`,
  ]
    .filter(Boolean)
    .join('\n');

  return {
    platform: 'spotify',
    url: rawUrl,
    title: data.title,
    text,
    metadata: {
      type: contentType,
      thumbnailUrl: data.thumbnail_url,
      thumbnailWidth: data.thumbnail_width,
      thumbnailHeight: data.thumbnail_height,
    },
    canWrite: false,
  };
}
