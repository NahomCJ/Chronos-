import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/theme/text_theme.dart';

class LifeXSocialPage extends StatefulWidget {
  const LifeXSocialPage({super.key});

  @override
  State<LifeXSocialPage> createState() => _LifeXSocialPageState();
}

class _LifeXSocialPageState extends State<LifeXSocialPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  static const _bg = Color(0xFF080A0E);
  static const _card = Color(0xFF0E1018);
  static const _red = Color(0xFFEF4444);

  static const _posts = [
    _Post('Alex Rivera', 'Finance', 'Just paid off my car loan 6 months early using the LifeX budget tracker! 🎉 Consistency is everything.',
        'https://images.pexels.com/photos/3184338/pexels-photo-3184338.jpeg?auto=compress&cs=tinysrgb&w=200',
        'https://images.pexels.com/photos/730547/pexels-photo-730547.jpeg?auto=compress&cs=tinysrgb&w=600', 142),
    _Post('Maya Chen', 'Health', '21-day meditation streak complete! The morning calm sessions have transformed my focus and reduced my anxiety significantly.',
        'https://images.pexels.com/photos/3184292/pexels-photo-3184292.jpeg?auto=compress&cs=tinysrgb&w=200',
        'https://images.pexels.com/photos/3822622/pexels-photo-3822622.jpeg?auto=compress&cs=tinysrgb&w=600', 89),
    _Post('James O.', 'Education', 'Finished my Python course after 3 months of consistent 30-min daily sessions. The key? Small, consistent effort over time.',
        'https://images.pexels.com/photos/3184405/pexels-photo-3184405.jpeg?auto=compress&cs=tinysrgb&w=200',
        null, 67),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: Container(margin: const EdgeInsets.only(bottom: 30), child: const ChrisHomeFab()),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: _bg,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(margin: const EdgeInsets.all(10), decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.1)),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16)),
            ),
            flexibleSpace: FlexibleSpaceBar(background: _buildHero()),
            bottom: TabBar(controller: _tabs,
              tabs: const [Tab(text: 'Community Feed'), Tab(text: 'Following')],
              labelColor: _red, unselectedLabelColor: Colors.white54, indicatorColor: _red,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: [_buildFeedTab(), _buildFollowingTab()],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Stack(fit: StackFit.expand, children: [
      CachedNetworkImage(
        imageUrl: 'https://images.pexels.com/photos/1105666/pexels-photo-1105666.jpeg?auto=compress&cs=tinysrgb&w=900',
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: _red.withValues(alpha: 0.1)),
        errorWidget: (_, __, ___) => Container(color: _red.withValues(alpha: 0.1)),
      ),
      Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.3), _bg.withValues(alpha: 0.95)]))),
      Positioned(bottom: 52, left: 20, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: _red.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _red.withValues(alpha: 0.5), width: 1)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.public_rounded, color: _red, size: 12), const SizedBox(width: 6),
            const Text('COMMUNITY & SOCIAL', style: TextStyle(color: Color(0xFFEF4444), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
          ])),
        const SizedBox(height: 10),
        Text('Your Community', style: TextStyles.displaySmall.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 26, height: 1.1)),
      ])),
    ]);
  }

  Widget _buildFeedTab() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
      itemCount: _posts.length,
      itemBuilder: (_, i) => _PostCard(post: _posts[i]),
    );
  }

  Widget _buildFollowingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('People You Follow'),
        const SizedBox(height: 14),
        ...[
          ('Maya Chen', 'Health  ·  892 followers', 'https://images.pexels.com/photos/3184292/pexels-photo-3184292.jpeg?auto=compress&cs=tinysrgb&w=200'),
          ('Alex Rivera', 'Finance  ·  1.2k followers', 'https://images.pexels.com/photos/3184338/pexels-photo-3184338.jpeg?auto=compress&cs=tinysrgb&w=200'),
          ('James O.', 'Tech  ·  540 followers', 'https://images.pexels.com/photos/3184405/pexels-photo-3184405.jpeg?auto=compress&cs=tinysrgb&w=200'),
        ].map((p) => _FollowCard(name: p.$1, subtitle: p.$2, imageUrl: p.$3)),
        const SizedBox(height: 22),
        _sectionTitle('Suggested for You'),
        const SizedBox(height: 14),
        ...[
          ('Dr. Sarah Kim', 'Wellness  ·  3.4k followers', 'https://images.pexels.com/photos/3184430/pexels-photo-3184430.jpeg?auto=compress&cs=tinysrgb&w=200'),
          ('Marcus Wells', 'Finance  ·  2.1k followers', 'https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg?auto=compress&cs=tinysrgb&w=200'),
        ].map((p) => _FollowCard(name: p.$1, subtitle: p.$2, imageUrl: p.$3, isFollowing: false)),
      ]),
    );
  }

  Widget _sectionTitle(String t) => Text(t, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700));
}

class _Post {
  final String author;
  final String category;
  final String content;
  final String avatarUrl;
  final String? imageUrl;
  final int likes;
  const _Post(this.author, this.category, this.content, this.avatarUrl, this.imageUrl, this.likes);
}

class _PostCard extends StatefulWidget {
  final _Post post;
  const _PostCard({required this.post});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: const Color(0xFF0E1018), borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07), width: 1)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.all(14), child: Row(children: [
          ClipOval(child: CachedNetworkImage(imageUrl: widget.post.avatarUrl, width: 40, height: 40, fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: const Color(0xFF1A1A2E), width: 40, height: 40),
              errorWidget: (_, __, ___) => Container(color: const Color(0xFF1A1A2E), width: 40, height: 40,
                  child: const Icon(Icons.person_rounded, color: Colors.white38)))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.post.author, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            Text(widget.post.category, style: TextStyle(color: const Color(0xFFEF4444).withValues(alpha: 0.9), fontSize: 11)),
          ])),
        ])),
        Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Text(widget.post.content, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13.5, height: 1.5))),
        if (widget.post.imageUrl != null) ClipRRect(borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18)),
          child: CachedNetworkImage(imageUrl: widget.post.imageUrl!, height: 180, width: double.infinity, fit: BoxFit.cover,
              placeholder: (_, __) => Container(height: 180, color: const Color(0xFF1A1A2E)),
              errorWidget: (_, __, ___) => Container(height: 180, color: const Color(0xFF1A1A2E)))),
        Padding(padding: const EdgeInsets.fromLTRB(14, 10, 14, 14), child: Row(children: [
          GestureDetector(
            onTap: () => setState(() => _liked = !_liked),
            child: Row(children: [
              Icon(_liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: _liked ? const Color(0xFFEF4444) : Colors.white38, size: 18),
              const SizedBox(width: 5),
              Text('${widget.post.likes + (_liked ? 1 : 0)}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 12)),
            ]),
          ),
          const SizedBox(width: 18),
          Row(children: [
            Icon(Icons.chat_bubble_outline_rounded, color: Colors.white38, size: 16),
            const SizedBox(width: 5),
            Text('Reply', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
          ]),
          const Spacer(),
          Icon(Icons.share_outlined, color: Colors.white38, size: 16),
        ])),
      ]),
    );
  }
}

class _FollowCard extends StatefulWidget {
  final String name;
  final String subtitle;
  final String imageUrl;
  final bool isFollowing;

  const _FollowCard({required this.name, required this.subtitle, required this.imageUrl, this.isFollowing = true});

  @override
  State<_FollowCard> createState() => _FollowCardState();
}

class _FollowCardState extends State<_FollowCard> {
  late bool _following;

  @override
  void initState() {
    super.initState();
    _following = widget.isFollowing;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF0E1018), borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 1)),
      child: Row(children: [
        ClipOval(child: CachedNetworkImage(imageUrl: widget.imageUrl, width: 44, height: 44, fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: const Color(0xFF1A1A2E), width: 44, height: 44),
            errorWidget: (_, __, ___) => Container(color: const Color(0xFF1A1A2E), width: 44, height: 44,
                child: const Icon(Icons.person_rounded, color: Colors.white38)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          Text(widget.subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
        ])),
        GestureDetector(
          onTap: () => setState(() => _following = !_following),
          child: AnimatedContainer(duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: _following ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _following ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFEF4444), width: 1),
            ),
            child: Text(_following ? 'Following' : 'Follow',
                style: TextStyle(color: _following ? Colors.white.withValues(alpha: 0.6) : Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }
}
