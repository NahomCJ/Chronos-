import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnectionsPage extends StatefulWidget {
  const ConnectionsPage({super.key});

  @override
  State<ConnectionsPage> createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage> {
  static const _purple = Color(0xFF7C6EF0);
  static const _green = Color(0xFF22C55E);
  static const _bg = Color(0xFF08080F);
  static const _card = Color(0xFF0F0F1A);
  static const _border = Color(0xFF1E1E30);

  final Map<String, String?> _tokens = {};
  bool _loaded = false;

  static const _prefKeys = {
    'github': 'conn_github_token',
    'notion': 'conn_notion_token',
    'figma': 'conn_figma_token',
  };

  final List<_PlatformDef> _platforms = const [
    _PlatformDef(
      id: 'github',
      name: 'GitHub',
      letter: 'GH',
      brandColor: Color(0xFF24292E),
      accentColor: Color(0xFF6E40C9),
      authType: _AuthType.token,
      tokenLabel: 'Personal Access Token',
      tokenHint: 'ghp_xxxxxxxxxxxx',
      description: 'Repositories, profiles, and code files',
      capabilities: [
        'Analyze code quality, security & architecture',
        'Review pull requests and suggest improvements',
        'Audit README and documentation',
        'Detect dependency vulnerabilities',
        'Profile strength & contribution analysis',
        'Create issues with AI-generated context',
      ],
    ),
    _PlatformDef(
      id: 'notion',
      name: 'Notion',
      letter: 'N',
      brandColor: Color(0xFF191919),
      accentColor: Color(0xFFFFFFFF),
      authType: _AuthType.token,
      tokenLabel: 'Integration Token',
      tokenHint: 'secret_xxxxxxxxxxxx',
      description: 'Pages, databases, and workspaces',
      capabilities: [
        'Analyze page content and structure',
        'Summarize long documents instantly',
        'Suggest improvements to writing & clarity',
        'Extract action items and key insights',
        'Add AI-generated comments to pages',
        'Audit databases for consistency',
      ],
    ),
    _PlatformDef(
      id: 'figma',
      name: 'Figma',
      letter: 'Fig',
      brandColor: Color(0xFF1E1E1E),
      accentColor: Color(0xFFF24E1E),
      authType: _AuthType.token,
      tokenLabel: 'Personal Access Token',
      tokenHint: 'figd_xxxxxxxxxxxx',
      description: 'Designs, components, and prototypes',
      capabilities: [
        'Analyze design system consistency',
        'Review accessibility & contrast ratios',
        'Suggest UX improvements',
        'Audit component naming and organization',
        'Generate design-to-code summaries',
        'Identify unused or duplicate components',
      ],
    ),
    _PlatformDef(
      id: 'canva',
      name: 'Canva',
      letter: 'Ca',
      brandColor: Color(0xFF00C4CC),
      accentColor: Color(0xFF00C4CC),
      authType: _AuthType.urlOnly,
      description: 'Designs, presentations, and pitch decks',
      capabilities: [
        'Review pitch deck narrative & flow',
        'Score investor-readiness (0–10)',
        'Identify missing deck sections',
        'Suggest design improvements',
        'Analyze market sizing & business model',
        'Generate actionable feedback',
      ],
    ),
    _PlatformDef(
      id: 'reddit',
      name: 'Reddit',
      letter: 'R',
      brandColor: Color(0xFFFF4500),
      accentColor: Color(0xFFFF4500),
      authType: _AuthType.urlOnly,
      description: 'Posts, subreddits, and comment threads',
      capabilities: [
        'Analyze post sentiment & engagement',
        'Summarize top comments',
        'Identify trending topics in a subreddit',
        'Extract community pain points',
        'Gauge public opinion on any topic',
        'Content strategy insights from discussions',
      ],
    ),
    _PlatformDef(
      id: 'spotify',
      name: 'Spotify',
      letter: 'S',
      brandColor: Color(0xFF1DB954),
      accentColor: Color(0xFF1DB954),
      authType: _AuthType.urlOnly,
      description: 'Tracks, albums, playlists, and podcasts',
      capabilities: [
        'Analyze podcast content & themes',
        'Summarize playlist mood & vibe',
        'Extract key insights from episodes',
        'Identify music genre trends',
        'Content quality assessment',
        'Artist profile analysis',
      ],
    ),
    _PlatformDef(
      id: 'google_drive',
      name: 'Google Drive',
      letter: 'GD',
      brandColor: Color(0xFF0F9D58),
      accentColor: Color(0xFF4285F4),
      authType: _AuthType.oauth,
      description: 'Documents, spreadsheets, and files',
      capabilities: [
        'Analyze document quality & structure',
        'Summarize long reports',
        'Extract data insights from spreadsheets',
        'Suggest edits and improvements',
        'Audit folder organization',
        'Generate document summaries',
      ],
    ),
    _PlatformDef(
      id: 'gmail',
      name: 'Gmail',
      letter: 'Gm',
      brandColor: Color(0xFFEA4335),
      accentColor: Color(0xFFEA4335),
      authType: _AuthType.oauth,
      description: 'Emails, threads, and attachments',
      capabilities: [
        'Summarize long email threads',
        'Draft AI-powered replies',
        'Identify action items from emails',
        'Organize inbox by priority',
        'Flag important follow-ups',
        'Sentiment analysis on client emails',
      ],
    ),
    _PlatformDef(
      id: 'slack',
      name: 'Slack',
      letter: 'Sl',
      brandColor: Color(0xFF4A154B),
      accentColor: Color(0xFF36C5F0),
      authType: _AuthType.oauth,
      description: 'Channels, messages, and workspaces',
      capabilities: [
        'Summarize channel discussions',
        'Extract decisions and action items',
        'Draft professional replies',
        'Analyze team communication patterns',
        'Identify blockers & risks in threads',
        'Generate meeting summaries from threads',
      ],
    ),
    _PlatformDef(
      id: 'linkedin',
      name: 'LinkedIn',
      letter: 'Li',
      brandColor: Color(0xFF0A66C2),
      accentColor: Color(0xFF0A66C2),
      authType: _AuthType.oauth,
      description: 'Profiles, posts, and company pages',
      capabilities: [
        'Analyze profile strength & completeness',
        'Suggest headline and bio improvements',
        'Review content engagement strategy',
        'Identify skill gaps vs job market',
        'Optimize for recruiter visibility',
        'Analyze company presence & branding',
      ],
    ),
    _PlatformDef(
      id: 'youtube',
      name: 'YouTube',
      letter: 'YT',
      brandColor: Color(0xFFFF0000),
      accentColor: Color(0xFFFF0000),
      authType: _AuthType.urlOnly,
      description: 'Videos, channels, and playlists',
      capabilities: [
        'Analyze video content & quality',
        'Summarize long videos via transcripts',
        'Channel growth strategy analysis',
        'Thumbnail & title effectiveness review',
        'Audience engagement insights',
        'Content gap identification',
      ],
    ),
    _PlatformDef(
      id: 'twitter',
      name: 'X / Twitter',
      letter: 'X',
      brandColor: Color(0xFF000000),
      accentColor: Color(0xFF1D9BF0),
      authType: _AuthType.oauth,
      description: 'Posts, threads, and profiles',
      capabilities: [
        'Analyze tweet engagement & reach',
        'Identify trending topics in your niche',
        'Profile branding & voice analysis',
        'Thread strategy optimization',
        'Sentiment analysis on mentions',
        'Competitor comparison insights',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadTokens();
  }

  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final loaded = <String, String?>{};
    for (final entry in _prefKeys.entries) {
      loaded[entry.key] = prefs.getString(entry.value);
    }
    if (mounted) setState(() { _tokens.addAll(loaded); _loaded = true; });
  }

  Future<void> _saveToken(String platformId, String token) async {
    final key = _prefKeys[platformId];
    if (key == null) return;
    final prefs = await SharedPreferences.getInstance();
    if (token.isEmpty) {
      await prefs.remove(key);
      if (mounted) setState(() => _tokens[platformId] = null);
    } else {
      await prefs.setString(key, token);
      if (mounted) setState(() => _tokens[platformId] = token);
    }
  }

  bool _isConnected(String id) {
    final p = _platforms.firstWhere((p) => p.id == id);
    if (p.authType == _AuthType.urlOnly) return true;
    return (_tokens[id] ?? '').isNotEmpty;
  }

  void _onConnect(_PlatformDef platform) {
    switch (platform.authType) {
      case _AuthType.token:
        _showTokenSheet(platform);
      case _AuthType.urlOnly:
        _showUrlOnlyInfo(platform);
      case _AuthType.oauth:
        _showOAuthInfo(platform);
    }
  }

  void _showTokenSheet(_PlatformDef platform) {
    final controller = TextEditingController(text: _tokens[platform.id] ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TokenSheet(
        platform: platform,
        controller: controller,
        isConnected: (_tokens[platform.id] ?? '').isNotEmpty,
        onSave: (token) async {
          await _saveToken(platform.id, token);
          if (mounted) Navigator.of(context).pop();
        },
        onDisconnect: () async {
          await _saveToken(platform.id, '');
          if (mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showUrlOnlyInfo(_PlatformDef platform) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _InfoSheet(
        platform: platform,
        message:
            '${platform.name} content is publicly accessible — no login required.\n\n'
            'To analyze ${platform.name} content, paste any ${platform.name} URL into the Chris AI chat and ask for an analysis.',
        icon: Icons.link_rounded,
        iconColor: platform.accentColor,
      ),
    );
  }

  void _showOAuthInfo(_PlatformDef platform) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _InfoSheet(
        platform: platform,
        message:
            '${platform.name} OAuth integration is coming soon.\n\n'
            'Once live, you\'ll authenticate securely with one tap and AI agents will be able to act across your ${platform.name} account.',
        icon: Icons.schedule_rounded,
        iconColor: const Color(0xFFF59E0B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Connected Apps',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border),
        ),
      ),
      body: _loaded
          ? ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              itemCount: _platforms.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) return _buildHeader();
                return _buildCard(_platforms[i - 1]);
              },
            )
          : const Center(child: CircularProgressIndicator(color: _purple)),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _purple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _purple.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _purple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.hub_rounded, color: _purple, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Agent Connections',
                      style: TextStyle(
                          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                  SizedBox(height: 3),
                  Text(
                    'Connect your platforms so AI agents can analyze and act on your behalf.',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(_PlatformDef platform) {
    final connected = _isConnected(platform.id);
    final isUrlOnly = platform.authType == _AuthType.urlOnly;
    final isOAuth = platform.authType == _AuthType.oauth;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: connected && !isUrlOnly
              ? _green.withValues(alpha: 0.35)
              : _border,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _PlatformLogo(platform: platform),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(platform.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                          if (isUrlOnly) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _green.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('No Auth',
                                  style: TextStyle(
                                      color: _green, fontSize: 9, fontWeight: FontWeight.w600)),
                            ),
                          ],
                          if (isOAuth) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('Soon',
                                  style: TextStyle(
                                      color: Color(0xFFF59E0B),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(platform.description,
                          style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _ConnectButton(
                  platform: platform,
                  connected: connected,
                  isUrlOnly: isUrlOnly,
                  isOAuth: isOAuth,
                  onTap: () => _onConnect(platform),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: _border,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Agent capabilities',
                    style: TextStyle(
                        color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w600,
                        letterSpacing: 0.5)),
                const SizedBox(height: 10),
                ...platform.capabilities.map((cap) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.only(top: 5, right: 8),
                            decoration: BoxDecoration(
                              color: platform.accentColor.withValues(alpha: 0.7),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(cap,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12.5, height: 1.4)),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectButton extends StatelessWidget {
  final _PlatformDef platform;
  final bool connected;
  final bool isUrlOnly;
  final bool isOAuth;
  final VoidCallback onTap;

  const _ConnectButton({
    required this.platform,
    required this.connected,
    required this.isUrlOnly,
    required this.isOAuth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7C6EF0);
    const green = Color(0xFF22C55E);

    if (isUrlOnly) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: green.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: green.withValues(alpha: 0.4)),
          ),
          child: const Text('Ready',
              style: TextStyle(color: green, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      );
    }

    if (isOAuth) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: const Text('Soon',
              style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      );
    }

    if (connected) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: green.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: green.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.check_circle_rounded, color: green, size: 13),
              SizedBox(width: 5),
              Text('Connected',
                  style: TextStyle(color: green, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: purple,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text('Connect',
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _PlatformLogo extends StatelessWidget {
  final _PlatformDef platform;

  const _PlatformLogo({required this.platform});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: platform.brandColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: platform.accentColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          platform.letter,
          style: TextStyle(
            color: platform.id == 'notion' ? Colors.black : Colors.white,
            fontSize: platform.letter.length > 2 ? 11 : 14,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }
}

class _TokenSheet extends StatefulWidget {
  final _PlatformDef platform;
  final TextEditingController controller;
  final bool isConnected;
  final Future<void> Function(String) onSave;
  final Future<void> Function() onDisconnect;

  const _TokenSheet({
    required this.platform,
    required this.controller,
    required this.isConnected,
    required this.onSave,
    required this.onDisconnect,
  });

  @override
  State<_TokenSheet> createState() => _TokenSheetState();
}

class _TokenSheetState extends State<_TokenSheet> {
  bool _obscure = true;
  bool _saving = false;

  static const _purple = Color(0xFF7C6EF0);
  static const _red = Color(0xFFEF4444);
  static const _bg = Color(0xFF0F0F1A);
  static const _border = Color(0xFF1E1E30);

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(bottom: insets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        decoration: const BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                _PlatformLogo(platform: widget.platform),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Connect ${widget.platform.name}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                    Text(widget.platform.tokenLabel!,
                        style: const TextStyle(color: Colors.white54, fontSize: 13)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: TextField(
                controller: widget.controller,
                obscureText: _obscure,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  hintText: widget.platform.tokenHint,
                  hintStyle: const TextStyle(color: Colors.white24, fontFamily: 'monospace'),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white38, size: 18),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your token is stored locally on this device and never shared.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 11),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: _saving
                    ? null
                    : () async {
                        setState(() => _saving = true);
                        await widget.onSave(widget.controller.text.trim());
                      },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: _purple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Save & Connect',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
            if (widget.isConnected) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: _saving ? null : widget.onDisconnect,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: _red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _red.withValues(alpha: 0.4)),
                    ),
                    child: const Center(
                      child: Text('Disconnect',
                          style: TextStyle(
                              color: _red, fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoSheet extends StatelessWidget {
  final _PlatformDef platform;
  final String message;
  final IconData icon;
  final Color iconColor;

  const _InfoSheet({
    required this.platform,
    required this.message,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(
            width: 56,
            height: 56,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          Text(
            platform.name,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white60, fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: const Center(
                child: Text('Got it',
                    style: TextStyle(
                        color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _AuthType { token, urlOnly, oauth }

class _PlatformDef {
  final String id;
  final String name;
  final String letter;
  final Color brandColor;
  final Color accentColor;
  final _AuthType authType;
  final String? tokenLabel;
  final String? tokenHint;
  final String description;
  final List<String> capabilities;

  const _PlatformDef({
    required this.id,
    required this.name,
    required this.letter,
    required this.brandColor,
    required this.accentColor,
    required this.authType,
    this.tokenLabel,
    this.tokenHint,
    required this.description,
    required this.capabilities,
  });
}
