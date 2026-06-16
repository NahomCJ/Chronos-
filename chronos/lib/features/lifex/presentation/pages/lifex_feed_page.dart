import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/theme/text_theme.dart';

class LifeXFeedPage extends StatefulWidget {
  const LifeXFeedPage({super.key});

  @override
  State<LifeXFeedPage> createState() => _LifeXFeedPageState();
}

class _LifeXFeedPageState extends State<LifeXFeedPage> {
  int _selectedFilter = 0;

  static const _bg = Color(0xFFF5F6FA);
  static const _border = Color(0xFFE8EAF0);
  static const _textPrimary = Color(0xFF1A1A2E);
  static const _textSecondary = Color(0xFF6B7080);
  static const _orange = Color(0xFFF97316);
  static const _filters = ['All', 'Health', 'Finance', 'Mindset', 'Lifestyle'];

  static const _feedItems = [
    _FeedItem('The Morning Routine That Changed My Life', 'Lifestyle', '7 min read',
        'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=600',
        Color(0xFFF97316), false),
    _FeedItem('5 Habits of Financially Free People', 'Finance', '5 min read',
        'https://images.pexels.com/photos/730547/pexels-photo-730547.jpeg?auto=compress&cs=tinysrgb&w=600',
        Color(0xFF10B981), false),
    _FeedItem('Why Sleep is Your Superpower', 'Health', '6 min read',
        'https://images.pexels.com/photos/1552252/pexels-photo-1552252.jpeg?auto=compress&cs=tinysrgb&w=600',
        Color(0xFF14B8A6), true),
    _FeedItem('Stoicism: The Ancient Art of Mental Resilience', 'Mindset', '9 min read',
        'https://images.pexels.com/photos/3759089/pexels-photo-3759089.jpeg?auto=compress&cs=tinysrgb&w=600',
        Color(0xFF8B5CF6), false),
    _FeedItem('Compound Learning: Read 25 Books This Year', 'Education', '4 min read',
        'https://images.pexels.com/photos/256541/pexels-photo-256541.jpeg?auto=compress&cs=tinysrgb&w=600',
        Color(0xFF6366F1), false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: Container(margin: const EdgeInsets.only(bottom: 30), child: const ChrisHomeFab()),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHero(context)),
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildFeatured(),
              const SizedBox(height: 22),
              Row(children: [
                Text('For You', style: TextStyle(color: _textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                const Spacer(),
              ]),
              const SizedBox(height: 12),
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  itemBuilder: (_, i) {
                    final active = _selectedFilter == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilter = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? _orange : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: active ? _orange : _border, width: 1),
                        ),
                        child: Text(_filters[i], style: TextStyle(
                          color: active ? Colors.white : _textSecondary,
                          fontSize: 13, fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                        )),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ]),
          )),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                child: _FeedCard(item: _feedItems[i]),
              ),
              childCount: _feedItems.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return SizedBox(height: 220, child: Stack(fit: StackFit.expand, children: [
      CachedNetworkImage(
        imageUrl: 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=900',
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: _orange.withValues(alpha: 0.1)),
        errorWidget: (_, __, ___) => Container(color: _orange.withValues(alpha: 0.1)),
      ),
      Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.2), _bg.withValues(alpha: 0.97)]))),
      SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(width: 36, height: 36,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFF3F4F6),
                  border: Border.all(color: _border, width: 1)),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF374151), size: 16)),
        ),
      )),
      Positioned(bottom: 20, left: 20, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: _orange.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _orange.withValues(alpha: 0.5), width: 1)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.feed_rounded, color: _orange, size: 12), const SizedBox(width: 6),
            Text('LIFESTYLE FEED', style: TextStyle(color: _orange, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
          ])),
        const SizedBox(height: 10),
        Text('Your Daily\nInspiration', style: TextStyles.displaySmall.copyWith(color: _textPrimary, fontWeight: FontWeight.w800, fontSize: 28, height: 1.1)),
      ])),
    ]));
  }

  Widget _buildFeatured() {
    return Container(
      height: 200,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(fit: StackFit.expand, children: [
          CachedNetworkImage(
            imageUrl: 'https://images.pexels.com/photos/3225517/pexels-photo-3225517.jpeg?auto=compress&cs=tinysrgb&w=700',
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: _orange.withValues(alpha: 0.15)),
            errorWidget: (_, __, ___) => Container(color: _orange.withValues(alpha: 0.15)),
          ),
          Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)]))),
          Positioned(top: 12, left: 14, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: _orange, borderRadius: BorderRadius.circular(10)),
            child: const Text('FEATURED', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.2)))),
          Positioned(bottom: 16, left: 16, right: 16, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('The Art of Living Well', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, height: 1.2)),
            const SizedBox(height: 4),
            Text('A curated guide to building a life of purpose and abundance', style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 12)),
            const SizedBox(height: 10),
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7), decoration: BoxDecoration(color: _orange, borderRadius: BorderRadius.circular(20)),
                  child: const Text('Read Now', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
              const SizedBox(width: 10),
              Text('12 min read', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
            ]),
          ])),
        ]),
      ),
    );
  }
}

class _FeedItem {
  final String title;
  final String category;
  final String readTime;
  final String imageUrl;
  final Color color;
  final bool isVideo;
  const _FeedItem(this.title, this.category, this.readTime, this.imageUrl, this.color, this.isVideo);
}

class _FeedCard extends StatelessWidget {
  final _FeedItem item;
  const _FeedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: item.color.withValues(alpha: 0.15), width: 1),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Row(children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), bottomLeft: Radius.circular(18)),
            child: Stack(children: [
              CachedNetworkImage(imageUrl: item.imageUrl, width: 100, height: 110, fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: item.color.withValues(alpha: 0.15), width: 100, height: 110),
                  errorWidget: (_, __, ___) => Container(color: item.color.withValues(alpha: 0.15), width: 100, height: 110)),
              if (item.isVideo) Positioned(bottom: 8, left: 8, child: Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withValues(alpha: 0.6)),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 14))),
            ]),
          ),
          const SizedBox(width: 14),
          Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: item.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: Text(item.category, style: TextStyle(color: item.color, fontSize: 10, fontWeight: FontWeight.w600))),
              const SizedBox(height: 6),
              Text(item.title, style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.35)),
              const SizedBox(height: 8),
              Row(children: [
                Icon(item.isVideo ? Icons.play_circle_rounded : Icons.menu_book_rounded,
                    color: const Color(0xFF9CA3AF), size: 13),
                const SizedBox(width: 4),
                Text(item.readTime, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11)),
              ]),
            ]),
          )),
          const Padding(padding: EdgeInsets.only(right: 14),
              child: Icon(Icons.bookmark_border_rounded, color: Color(0xFFD1D5DB), size: 18)),
        ]),
      ),
    );
  }
}
