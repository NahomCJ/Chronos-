import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/chris_home_fab.dart';
import '../../../../core/theme/text_theme.dart';

class LifeXEducationPage extends StatefulWidget {
  const LifeXEducationPage({super.key});

  @override
  State<LifeXEducationPage> createState() => _LifeXEducationPageState();
}

class _LifeXEducationPageState extends State<LifeXEducationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  int _selectedCategory = 0;

  static const _bg = Color(0xFF08080F);
  static const _card = Color(0xFF0F0F1C);
  static const _indigo = Color(0xFF6366F1);
  static const _indigoLight = Color(0xFF818CF8);

  static const _categories = [
    'All', 'Tech', 'Finance', 'Health', 'Business', 'Arts'
  ];

  static const _courses = [
    _Course(
      'Python for Data Science',
      'Dr. Sarah Chen',
      'Tech',
      '4.8',
      '12 modules',
      'https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg?auto=compress&cs=tinysrgb&w=600',
      Color(0xFF6366F1),
      0.35,
    ),
    _Course(
      'Personal Finance Mastery',
      'James Rivera',
      'Finance',
      '4.9',
      '8 modules',
      'https://images.pexels.com/photos/730547/pexels-photo-730547.jpeg?auto=compress&cs=tinysrgb&w=600',
      Color(0xFF10B981),
      0.68,
    ),
    _Course(
      'Leadership & Communication',
      'Dr. Maya Patel',
      'Business',
      '4.7',
      '10 modules',
      'https://images.pexels.com/photos/3184430/pexels-photo-3184430.jpeg?auto=compress&cs=tinysrgb&w=600',
      Color(0xFFF59E0B),
      0.15,
    ),
    _Course(
      'Mindful Productivity',
      'Alex Thompson',
      'Health',
      '4.6',
      '6 modules',
      'https://images.pexels.com/photos/3822622/pexels-photo-3822622.jpeg?auto=compress&cs=tinysrgb&w=600',
      Color(0xFF14B8A6),
      0.0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
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
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 30),
        child: const ChrisHomeFab(),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: _bg,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 16),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(background: _buildHero()),
            bottom: TabBar(
              controller: _tabs,
              tabs: const [
                Tab(text: 'Courses'),
                Tab(text: 'Scholarships'),
                Tab(text: 'Tutors'),
              ],
              labelColor: _indigo,
              unselectedLabelColor: Colors.white54,
              indicatorColor: _indigo,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: [
            _buildCoursesTab(),
            _buildScholarshipsTab(),
            _buildTutorsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl:
              'https://images.pexels.com/photos/256541/pexels-photo-256541.jpeg?auto=compress&cs=tinysrgb&w=900',
          fit: BoxFit.cover,
          placeholder: (_, __) =>
              Container(color: _indigo.withValues(alpha: 0.2)),
          errorWidget: (_, __, ___) =>
              Container(color: _indigo.withValues(alpha: 0.2)),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.25),
                _bg.withValues(alpha: 0.95),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 54,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _indigo.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: _indigo.withValues(alpha: 0.5), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.school_rounded, color: _indigo, size: 12),
                    const SizedBox(width: 6),
                    Text('EDUCATION & GROWTH',
                        style: TextStyle(
                            color: _indigo,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text('Learn Every\nDay',
                  style: TextStyles.displaySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 30,
                      height: 1.1)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCoursesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLearningStreak(),
          const SizedBox(height: 22),
          _sectionTitle('Browse Categories'),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final active = _selectedCategory == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: active
                          ? _indigo
                          : Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: active
                              ? _indigo
                              : Colors.white.withValues(alpha: 0.12),
                          width: 1),
                    ),
                    child: Text(_categories[i],
                        style: TextStyle(
                            color: active
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.6),
                            fontSize: 13,
                            fontWeight: active
                                ? FontWeight.w600
                                : FontWeight.w400)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          _sectionTitle('Continue Learning'),
          const SizedBox(height: 14),
          ...[_courses[0], _courses[1]].map((c) => _CourseCard(course: c)),
          const SizedBox(height: 22),
          _sectionTitle('Recommended for You'),
          const SizedBox(height: 14),
          _buildChrisRec(),
          const SizedBox(height: 14),
          ...[_courses[2], _courses[3]].map((c) => _CourseCard(course: c)),
          const SizedBox(height: 22),
          _sectionTitle('Featured Lecture'),
          const SizedBox(height: 14),
          _VideoCard(
            title: 'The Science of Learning',
            duration: '48 min',
            instructor: 'Dr. Barbara Oakley',
            imageUrl:
                'https://images.pexels.com/photos/3184430/pexels-photo-3184430.jpeg?auto=compress&cs=tinysrgb&w=600',
          ),
          const SizedBox(height: 14),
          _VideoCard(
            title: 'Building a Reading Habit',
            duration: '22 min',
            instructor: 'James Clear',
            imageUrl:
                'https://images.pexels.com/photos/1181244/pexels-photo-1181244.jpeg?auto=compress&cs=tinysrgb&w=600',
          ),
        ],
      ),
    );
  }

  Widget _buildScholarshipsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Active Scholarships'),
          const SizedBox(height: 14),
          ...[
            _ScholarshipCard(
                'STEM Excellence Award', '\$5,000', 'Mar 30, 2025', 'Open',
                const Color(0xFF6366F1)),
            _ScholarshipCard(
                'Community Leaders Fund', '\$2,500', 'Apr 15, 2025', 'Open',
                const Color(0xFF10B981)),
            _ScholarshipCard(
                'Entrepreneurship Grant', '\$10,000', 'Feb 28, 2025',
                'Closed', Colors.grey),
          ].toList(),
          const SizedBox(height: 22),
          _buildChrisRec(
              text:
                  'Based on your profile, you match 3 scholarships. I\'ve ranked them by your likelihood of success.'),
        ],
      ),
    );
  }

  Widget _buildTutorsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Top-Rated Tutors'),
          const SizedBox(height: 14),
          ...[
            _TutorCard('Dr. Lisa Park', 'Data Science & AI', '4.9', '\$85/hr',
                'https://images.pexels.com/photos/3184292/pexels-photo-3184292.jpeg?auto=compress&cs=tinysrgb&w=200'),
            _TutorCard('Marcus Wells', 'Finance & Investing', '4.8', '\$65/hr',
                'https://images.pexels.com/photos/3184338/pexels-photo-3184338.jpeg?auto=compress&cs=tinysrgb&w=200'),
            _TutorCard('Elena Sousa', 'Business Strategy', '4.7', '\$70/hr',
                'https://images.pexels.com/photos/3184405/pexels-photo-3184405.jpeg?auto=compress&cs=tinysrgb&w=200'),
          ].toList(),
        ],
      ),
    );
  }

  Widget _buildLearningStreak() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _indigo.withValues(alpha: 0.22),
            const Color(0xFF4F46E5).withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _indigo.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text('🔥',
                  style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 2),
              Text('14',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800)),
              Text('day streak',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11)),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Keep it up!',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('You\'re in the top 12% of learners this month.',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12,
                        height: 1.4)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _statChip('3h 20m', 'this week', _indigo),
                    const SizedBox(width: 8),
                    _statChip('4 courses', 'active', const Color(0xFF10B981)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String val, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(val,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w700)),
          Text(label,
              style: TextStyle(
                  color: color.withValues(alpha: 0.7),
                  fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildChrisRec({String? text}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _indigo.withValues(alpha: 0.15),
              border:
                  Border.all(color: _indigo.withValues(alpha: 0.4), width: 1),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: _indigo, size: 15),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chris recommends',
                    style: const TextStyle(
                        color: _indigo,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                    text ??
                        'You spend 2.3hrs per week on learning. Adding just 30 more minutes could help you finish Python for Data Science in 3 weeks.',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12.5,
                        height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700));
  }
}

class _Course {
  final String title;
  final String instructor;
  final String category;
  final String rating;
  final String modules;
  final String imageUrl;
  final Color color;
  final double progress;

  const _Course(this.title, this.instructor, this.category, this.rating,
      this.modules, this.imageUrl, this.color, this.progress);
}

class _CourseCard extends StatelessWidget {
  final _Course course;
  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: course.color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomLeft: Radius.circular(18)),
            child: CachedNetworkImage(
              imageUrl: course.imageUrl,
              width: 90,
              height: 110,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(color: course.color.withValues(alpha: 0.2)),
              errorWidget: (_, __, ___) =>
                  Container(color: course.color.withValues(alpha: 0.2)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: course.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(course.category,
                        style: TextStyle(
                            color: course.color,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 6),
                  Text(course.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          height: 1.3)),
                  Text(course.instructor,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 11)),
                  const SizedBox(height: 8),
                  if (course.progress > 0) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: course.progress,
                        backgroundColor:
                            course.color.withValues(alpha: 0.12),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(course.color),
                        minHeight: 3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                        '${(course.progress * 100).round()}% complete',
                        style: TextStyle(
                            color: course.color, fontSize: 10)),
                  ] else
                    Text(course.modules,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 10)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Row(
              children: [
                const Icon(Icons.star_rounded,
                    color: Color(0xFFF59E0B), size: 13),
                const SizedBox(width: 2),
                Text(course.rating,
                    style: const TextStyle(
                        color: Color(0xFFF59E0B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScholarshipCard extends StatelessWidget {
  final String name;
  final String amount;
  final String deadline;
  final String status;
  final Color color;

  const _ScholarshipCard(
      this.name, this.amount, this.deadline, this.status, this.color);

  @override
  Widget build(BuildContext context) {
    final isOpen = status == 'Open';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
            ),
            child: Icon(Icons.emoji_events_rounded, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text('Deadline: $deadline',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount,
                  style: TextStyle(
                      color: color,
                      fontSize: 15,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isOpen
                      ? color.withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(status,
                    style: TextStyle(
                        color: isOpen ? color : Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TutorCard extends StatelessWidget {
  final String name;
  final String subject;
  final String rating;
  final String rate;
  final String imageUrl;

  const _TutorCard(
      this.name, this.subject, this.rating, this.rate, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1C),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.07), width: 1),
      ),
      child: Row(
        children: [
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.2)),
              errorWidget: (_, __, ___) => Container(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                  child: const Icon(Icons.person_rounded,
                      color: Colors.white54, size: 24)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                Text(subject,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: Color(0xFFF59E0B), size: 13),
                  const SizedBox(width: 2),
                  Text(rating,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 4),
              Text(rate,
                  style: const TextStyle(
                      color: Color(0xFF6366F1),
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final String title;
  final String duration;
  final String instructor;
  final String imageUrl;

  const _VideoCard({
    required this.title,
    required this.duration,
    required this.instructor,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 170,
        margin: const EdgeInsets.only(bottom: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: const Color(0xFF111130)),
                errorWidget: (_, __, ___) =>
                    Container(color: const Color(0xFF111130)),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 1.5),
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 26),
                ),
              ),
              Positioned(
                bottom: 14,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    Text('$instructor  ·  $duration',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
