import { FetchedContent } from '../types';

export async function fetchReddit(rawUrl: string): Promise<FetchedContent> {
  const cleanUrl = rawUrl.split('?')[0].replace(/\/$/, '');
  const jsonUrl = `${cleanUrl}.json`;

  const res = await fetch(jsonUrl, {
    headers: { 'User-Agent': 'Chronos-App/1.0' },
  });
  if (!res.ok) throw new Error(`Reddit ${res.status}: ${res.statusText}`);
  const data = await res.json();

  // Post page: API returns [post_listing, comments_listing]
  if (Array.isArray(data) && data.length === 2) {
    const post = data[0].data.children[0]?.data;
    if (!post) throw new Error('No post data found');

    const topComments = (data[1].data.children as any[])
      .filter((c) => c.kind === 't1')
      .slice(0, 8)
      .map((c) => `  [${c.data.author}, ↑${c.data.score}]: ${(c.data.body as string).substring(0, 300)}`)
      .join('\n');

    const text = [
      `Title: ${post.title}`,
      `Subreddit: r/${post.subreddit}`,
      `Author: u/${post.author}`,
      `Score: ↑${post.score} | Comments: ${post.num_comments} | Awards: ${post.total_awards_received ?? 0}`,
      post.selftext ? `\nPost:\n${(post.selftext as string).substring(0, 3000)}` : (post.url ? `\nLink: ${post.url}` : ''),
      topComments ? `\n--- Top Comments ---\n${topComments}` : '',
    ]
      .filter(Boolean)
      .join('\n');

    return {
      platform: 'reddit',
      url: rawUrl,
      title: post.title,
      text,
      metadata: { type: 'post', subreddit: post.subreddit, author: post.author, score: post.score, numComments: post.num_comments },
      canWrite: false,
    };
  }

  // Subreddit or user listing
  if (data?.data?.children) {
    const children = data.data.children as any[];
    const posts = children
      .filter((c) => c.kind === 't3')
      .slice(0, 10)
      .map((c) => `- [↑${c.data.score}] ${c.data.title} (${c.data.num_comments} comments)`);

    const subreddit = children[0]?.data?.subreddit || rawUrl.split('/').filter(Boolean).pop() || 'Unknown';

    return {
      platform: 'reddit',
      url: rawUrl,
      title: `r/${subreddit}`,
      text: `Subreddit: r/${subreddit}\n\nTop posts:\n${posts.join('\n')}`,
      metadata: { type: 'subreddit', subreddit },
      canWrite: false,
    };
  }

  throw new Error('Unrecognized Reddit URL — use a post URL (reddit.com/r/sub/comments/…) or subreddit (reddit.com/r/sub)');
}
