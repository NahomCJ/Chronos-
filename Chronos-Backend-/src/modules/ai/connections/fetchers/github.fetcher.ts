import { FetchedContent } from '../types';

const GITHUB_API = 'https://api.github.com';

function apiHeaders(token?: string): Record<string, string> {
  const h: Record<string, string> = {
    Accept: 'application/vnd.github+json',
    'User-Agent': 'Chronos-App/1.0',
  };
  if (token) h.Authorization = `token ${token}`;
  return h;
}

async function ghFetch(url: string, token?: string): Promise<any> {
  const res = await fetch(url, { headers: apiHeaders(token) });
  if (!res.ok) throw new Error(`GitHub API ${res.status}: ${res.statusText}`);
  return res.json();
}

function b64decode(b64: string): string {
  return Buffer.from(b64.replace(/\n/g, ''), 'base64').toString('utf-8');
}

export async function fetchGitHub(rawUrl: string, token?: string): Promise<FetchedContent> {
  const { pathname } = new URL(rawUrl);
  const parts = pathname.split('/').filter(Boolean);

  // github.com/username — user profile
  if (parts.length === 1) {
    const [login] = parts;
    const [user, repos] = await Promise.all([
      ghFetch(`${GITHUB_API}/users/${login}`, token),
      ghFetch(`${GITHUB_API}/users/${login}/repos?sort=stars&per_page=6`, token),
    ]);

    const text = [
      `GitHub User: ${user.name || login}`,
      user.bio ? `Bio: ${user.bio}` : '',
      `Location: ${user.location || 'Not specified'}`,
      `Public repos: ${user.public_repos} | Followers: ${user.followers} | Following: ${user.following}`,
      '',
      'Top repositories:',
      ...(repos as any[]).map(
        (r: any) => `- ${r.name}: ${r.description || 'No description'} (⭐ ${r.stargazers_count}, ${r.language || 'various'})`
      ),
    ]
      .filter(Boolean)
      .join('\n');

    return {
      platform: 'github',
      url: rawUrl,
      title: `GitHub: ${user.name || login}`,
      text,
      metadata: { type: 'user', login, repos: user.public_repos, followers: user.followers },
      canWrite: false,
    };
  }

  // github.com/owner/repo — repository
  if (parts.length === 2) {
    const [owner, repo] = parts;
    const [repoRes, readmeRes, langsRes] = await Promise.allSettled([
      ghFetch(`${GITHUB_API}/repos/${owner}/${repo}`, token),
      ghFetch(`${GITHUB_API}/repos/${owner}/${repo}/readme`, token),
      ghFetch(`${GITHUB_API}/repos/${owner}/${repo}/languages`, token),
    ]);

    const rd = repoRes.status === 'fulfilled' ? repoRes.value : {};
    const readme =
      readmeRes.status === 'fulfilled'
        ? b64decode(readmeRes.value.content).substring(0, 3000)
        : 'No README available';
    const langs =
      langsRes.status === 'fulfilled' ? Object.keys(langsRes.value).join(', ') : 'Unknown';

    const text = [
      `Repository: ${owner}/${repo}`,
      rd.description ? `Description: ${rd.description}` : '',
      `Languages: ${langs}`,
      `Stars: ${rd.stargazers_count ?? 0} | Forks: ${rd.forks_count ?? 0} | Open issues: ${rd.open_issues_count ?? 0}`,
      rd.topics?.length ? `Topics: ${(rd.topics as string[]).join(', ')}` : '',
      '',
      '--- README (first 3000 chars) ---',
      readme,
    ]
      .filter(Boolean)
      .join('\n');

    return {
      platform: 'github',
      url: rawUrl,
      title: `${owner}/${repo}`,
      text,
      metadata: { type: 'repo', owner, repo, stars: rd.stargazers_count, forks: rd.forks_count, language: rd.language, topics: rd.topics },
      canWrite: !!token,
    };
  }

  // github.com/owner/repo/blob/branch/path/to/file
  if (parts.length >= 5 && parts[2] === 'blob') {
    const [owner, repo, , branch, ...fileParts] = parts;
    const filePath = fileParts.join('/');
    const fileData = await ghFetch(
      `${GITHUB_API}/repos/${owner}/${repo}/contents/${filePath}?ref=${branch}`,
      token
    );
    const content =
      fileData.encoding === 'base64'
        ? b64decode(fileData.content).substring(0, 5000)
        : '(Binary or unsupported encoding)';

    return {
      platform: 'github',
      url: rawUrl,
      title: `${owner}/${repo}: ${filePath}`,
      text: `File: ${filePath}\nSize: ${fileData.size} bytes\n\n--- Content ---\n${content}`,
      metadata: { type: 'file', owner, repo, path: filePath, branch },
      canWrite: !!token,
    };
  }

  throw new Error('Unrecognized GitHub URL — supported formats: /user, /owner/repo, /owner/repo/blob/branch/file');
}
