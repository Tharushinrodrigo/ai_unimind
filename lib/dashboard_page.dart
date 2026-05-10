// ============================================================
// WELLNESS PRODUCTIVITY APP - PREMIUM DASHBOARD PAGE
// dashboard_page.dart
// Requires: fl_chart, shared_preferences, provider packages
// ============================================================

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// DATA MODELS
// ============================================================

class DailyActivity {
  final DateTime date;
  final int sessionsCount;
  final int minutesSpent;
  final int productivityScore;

  DailyActivity({
    required this.date,
    required this.sessionsCount,
    required this.minutesSpent,
    required this.productivityScore,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'sessions': sessionsCount,
        'minutes': minutesSpent,
        'productivity': productivityScore,
      };

  factory DailyActivity.fromJson(Map<String, dynamic> json) => DailyActivity(
        date: DateTime.parse(json['date']),
        sessionsCount: json['sessions'] ?? 0,
        minutesSpent: json['minutes'] ?? 0,
        productivityScore: json['productivity'] ?? 0,
      );
}

class MoodStudyData {
  final DateTime date;
  final double moodLevel;   // 0.0 - 10.0
  final double studyHours;  // 0.0 - 24.0

  MoodStudyData({required this.date, required this.moodLevel, required this.studyHours});
}

class RecentActivity {
  final String title;
  final String subtitle;
  final String type; // 'task', 'focus', 'mood', 'water', 'habit'
  final DateTime time;

  RecentActivity({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.time,
  });
}

// ============================================================
// APP STATE PROVIDER
// ============================================================

class AppState extends ChangeNotifier {
  // User Profile
  String _userName = 'User';
  String get userName => _userName;

  // Analytics Data (loaded from local storage)
  int _completedTasks = 0;
  int _focusSessions = 0;
  int _habitsCompleted = 0;
  int _studyMinutes = 0;
  int _waterIntake = 0;       // glasses
  int _sleepHours = 0;
  int _streakDays = 0;
  int _goalsCompleted = 0;
  int _totalGoals = 5;
  double _productivityScore = 0.0;

  int get completedTasks => _completedTasks;
  int get focusSessions => _focusSessions;
  int get habitsCompleted => _habitsCompleted;
  int get studyMinutes => _studyMinutes;
  int get waterIntake => _waterIntake;
  int get sleepHours => _sleepHours;
  int get streakDays => _streakDays;
  int get goalsCompleted => _goalsCompleted;
  int get totalGoals => _totalGoals;
  double get productivityScore => _productivityScore;

  // Weekly Activity (past 7 days, real data)
  List<DailyActivity> _weeklyActivity = [];
  List<DailyActivity> get weeklyActivity => _weeklyActivity;

  // Mood vs Study (past 7 days)
  List<MoodStudyData> _moodStudyWeek = [];
  List<MoodStudyData> get moodStudyWeek => _moodStudyWeek;

  // Recent Activities
  List<RecentActivity> _recentActivities = [];
  List<RecentActivity> get recentActivities => _recentActivities;

  // Daily Quote
  final List<String> _quotes = [
    "The secret of getting ahead is getting started. — Mark Twain",
    "Focus on being productive instead of busy. — Tim Ferriss",
    "Small daily improvements lead to staggering long-term results.",
    "Your only limit is your mind.",
    "Do something today that your future self will thank you for.",
    "Success is the sum of small efforts repeated day in and day out.",
    "The difference between ordinary and extraordinary is practice.",
  ];

  String get dailyQuote {
    final dayIndex = DateTime.now().day % _quotes.length;
    return _quotes[dayIndex];
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    _userName = prefs.getString('user_name') ?? 'User';
    _completedTasks = prefs.getInt('completed_tasks') ?? 0;
    _focusSessions = prefs.getInt('focus_sessions') ?? 0;
    _habitsCompleted = prefs.getInt('habits_completed') ?? 0;
    _studyMinutes = prefs.getInt('study_minutes') ?? 0;
    _waterIntake = prefs.getInt('water_intake') ?? 0;
    _sleepHours = prefs.getInt('sleep_hours') ?? 0;
    _streakDays = prefs.getInt('streak_days') ?? 0;
    _goalsCompleted = prefs.getInt('goals_completed') ?? 0;
    _totalGoals = prefs.getInt('total_goals') ?? 5;

    _loadWeeklyActivity(prefs);
    _loadMoodStudyData(prefs);
    _loadRecentActivities(prefs);
    _calculateProductivity();

    notifyListeners();
  }

  void _loadWeeklyActivity(SharedPreferences prefs) {
    _weeklyActivity = [];
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final key = _dateKey(date);
      _weeklyActivity.add(DailyActivity(
        date: date,
        sessionsCount: prefs.getInt('activity_sessions_$key') ?? 0,
        minutesSpent: prefs.getInt('activity_minutes_$key') ?? 0,
        productivityScore: prefs.getInt('activity_productivity_$key') ?? 0,
      ));
    }
  }

  void _loadMoodStudyData(SharedPreferences prefs) {
    _moodStudyWeek = [];
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final key = _dateKey(date);
      _moodStudyWeek.add(MoodStudyData(
        date: date,
        moodLevel: (prefs.getDouble('mood_$key') ?? 0.0),
        studyHours: (prefs.getInt('study_minutes_$key') ?? 0) / 60.0,
      ));
    }
  }

  void _loadRecentActivities(SharedPreferences prefs) {
    // Load last recorded activities from storage
    _recentActivities = [];
    final List<String>? activityList = prefs.getStringList('recent_activities');
    if (activityList != null && activityList.isNotEmpty) {
      for (var item in activityList.take(5)) {
        final parts = item.split('||');
        if (parts.length >= 4) {
          _recentActivities.add(RecentActivity(
            title: parts[0],
            subtitle: parts[1],
            type: parts[2],
            time: DateTime.tryParse(parts[3]) ?? DateTime.now(),
          ));
        }
      }
    }
  }

  void _calculateProductivity() {
    // Weighted productivity calculation
    double score = 0;
    if (_completedTasks > 0) score += (_completedTasks / 10).clamp(0, 30);
    if (_focusSessions > 0) score += (_focusSessions / 5).clamp(0, 25);
    if (_habitsCompleted > 0) score += (_habitsCompleted / 5).clamp(0, 20);
    if (_studyMinutes > 0) score += (_studyMinutes / 120).clamp(0, 25);
    _productivityScore = score.clamp(0, 100);
  }

  String _dateKey(DateTime date) =>
      '${date.year}_${date.month.toString().padLeft(2, '0')}_${date.day.toString().padLeft(2, '0')}';

  Future<void> recordSession(String type) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _dateKey(DateTime.now());
    final sessions = (prefs.getInt('activity_sessions_$key') ?? 0) + 1;
    await prefs.setInt('activity_sessions_$key', sessions);
    _focusSessions++;
    await prefs.setInt('focus_sessions', _focusSessions);
    _calculateProductivity();
    notifyListeners();
  }
}

// ============================================================
// MAIN DASHBOARD PAGE
// ============================================================

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimCtrl;
  late AnimationController _cardsAnimCtrl;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadData();
    });
  }

  void _setupAnimations() {
    _headerAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _cardsAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _headerFade = CurvedAnimation(parent: _headerAnimCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnimCtrl, curve: Curves.easeOutCubic));

    _headerAnimCtrl.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _cardsAnimCtrl.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimCtrl.dispose();
    _cardsAnimCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        // Background image
        Positioned.fill(
          child: Image.asset(
            'assets/images/dashboard_bg.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        // Dark overlay with blur
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.55),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
        // Main dashboard content
        Positioned.fill(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(isDark)),
                SliverToBoxAdapter(child: _buildDailyQuote(isDark)),
                SliverToBoxAdapter(child: _buildProductivityCard(isDark)),
                SliverToBoxAdapter(child: _buildQuickStats(isDark)),
                SliverToBoxAdapter(child: _buildSectionHeader('Quick Access', isDark)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: _buildQuickAccessRow(isDark),
                ),
                SliverToBoxAdapter(child: _buildSectionHeader('Activity Trends', isDark)),
                SliverToBoxAdapter(child: _buildActivityTrendChart(isDark)),
                SliverToBoxAdapter(child: _buildSectionHeader('Progress Analytics', isDark)),
                SliverToBoxAdapter(child: _buildProgressAnalytics(isDark)),
                SliverToBoxAdapter(child: _buildSectionHeader('Mood vs Study Hours', isDark)),
                SliverToBoxAdapter(child: _buildMoodStudyChart(isDark)),
                SliverToBoxAdapter(child: _buildMotivationalSection(isDark)),
                SliverToBoxAdapter(child: _buildSectionHeader('Today\'s Wellness', isDark)),
                SliverToBoxAdapter(child: _buildWellnessMiniCards(isDark)),
                SliverToBoxAdapter(child: _buildSectionHeader('Recent Activity', isDark)),
                SliverToBoxAdapter(child: _buildRecentActivity(isDark)),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ),
      ],
    );
  }
  // New: Horizontal Quick Access Row
  Widget _buildQuickAccessRow(bool isDark) {
    final pages = [
      {'icon': Icons.center_focus_strong, 'label': 'Focus', 'color': const Color(0xFF6C63FF), 'route': 'Focus'},
      {'icon': Icons.mood, 'label': 'Mood', 'color': const Color(0xFFFF9F0A), 'route': 'Mood'},
      {'icon': Icons.self_improvement, 'label': 'Wellness', 'color': const Color(0xFF8B5CF6), 'route': 'Wellness'},
      {'icon': Icons.account_balance_wallet, 'label': 'Finance', 'color': const Color(0xFF30D158), 'route': 'Finance'},
    ];
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: pages.map((page) {
            return _QuickAccessCard(
              icon: page['icon'] as IconData,
              label: page['label'] as String,
              color: page['color'] as Color,
              isDark: isDark,
              onTap: () => _navigateTo(context, page['route'] as String),
              animationDelay: Duration.zero,
              parentController: _cardsAnimCtrl,
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────────────
  Widget _buildHeader(bool isDark) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final greeting = _getGreeting();
        return SlideTransition(
          position: _headerSlide,
          child: FadeTransition(
            opacity: _headerFade,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20,
                right: 20,
                bottom: 32,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF1A0A3D), const Color(0xFF0D1B4A), const Color(0xFF0A2E2A)]
                      : [const Color(0xFF6C63FF), const Color(0xFF3B82F6), const Color(0xFF06B6D4)],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hello, ${state.userName} 👋',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Notification Bell
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(Icons.notifications_outlined,
                                    color: Colors.white, size: 22),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFF6B6B),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Avatar
                          GestureDetector(
                            onTap: () => _navigateTo(context, 'Settings'),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                                ),
                                border: Border.all(color: Colors.white, width: 2.5),
                              ),
                              child: Center(
                                child: Text(
                                  state.userName.isNotEmpty
                                      ? state.userName[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Streak + productivity quick chips
                  Row(
                    children: [
                      _headerChip(Icons.local_fire_department, '${state.streakDays}d streak', const Color(0xFFFF9500)),
                      const SizedBox(width: 10),
                      _headerChip(Icons.bolt, '${state.productivityScore.round()}% today', const Color(0xFF30D158)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _headerChip(IconData icon, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    ),
  );

  // ── DAILY QUOTE ─────────────────────────────────────────────
  Widget _buildDailyQuote(bool isDark) {
    return Consumer<AppState>(
      builder: (context, state, _) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)]
                  : [const Color(0xFFEDE9FE), const Color(0xFFDDD6FE)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Text('💡', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Inspiration',
                      style: TextStyle(
                        color: isDark ? const Color(0xFFA5B4FC) : const Color(0xFF6D28D9),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.dailyQuote,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF3730A3),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── PRODUCTIVITY SCORE CARD ──────────────────────────────────
  Widget _buildProductivityCard(bool isDark) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final score = state.productivityScore;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C2E) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.07),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Circular progress
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 8,
                        backgroundColor: isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF3F0FF),
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF6C63FF)),
                        strokeCap: StrokeCap.round,
                      ),
                      Center(
                        child: Text(
                          '${score.round()}%',
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Productivity',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _productivityLabel(score),
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Mini stats
                      Row(children: [
                        _miniStat('✅', '${state.completedTasks}', 'Tasks'),
                        const SizedBox(width: 16),
                        _miniStat('🎯', '${state.focusSessions}', 'Focus'),
                        const SizedBox(width: 16),
                        _miniStat('🔥', '${state.habitsCompleted}', 'Habits'),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _miniStat(String emoji, String value, String label) => Column(
    children: [
      Text(emoji, style: const TextStyle(fontSize: 14)),
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
    ],
  );

  String _productivityLabel(double score) {
    if (score >= 80) return 'Excellent! 🚀';
    if (score >= 60) return 'Good Progress';
    if (score >= 40) return 'Keep Going';
    if (score > 0) return 'Just Started';
    return 'Start Your Day';
  }

  // ── QUICK STATS ROW ──────────────────────────────────────────
  Widget _buildQuickStats(bool isDark) {
    return Consumer<AppState>(
      builder: (context, state, _) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(
          children: [
            _quickStatCard('💧', '${state.waterIntake}', 'Glasses', const Color(0xFF06B6D4), isDark),
            const SizedBox(width: 12),
            _quickStatCard('😴', '${state.sleepHours}h', 'Sleep', const Color(0xFF8B5CF6), isDark),
            const SizedBox(width: 12),
            _quickStatCard('📚', '${(state.studyMinutes / 60).toStringAsFixed(1)}h', 'Study', const Color(0xFFFF9500), isDark),
            const SizedBox(width: 12),
            _quickStatCard('🏆', '${state.goalsCompleted}/${state.totalGoals}', 'Goals', const Color(0xFF30D158), isDark),
          ],
        ),
      ),
    );
  }

  Widget _quickStatCard(String emoji, String value, String label, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C2E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black45,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SECTION HEADER ───────────────────────────────────────────
  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            'See all',
            style: TextStyle(
              color: const Color(0xFF6C63FF),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── QUICK ACCESS GRID ────────────────────────────────────────
  SliverGrid _buildQuickAccessGrid(bool isDark) {
    final pages = [
      {'icon': Icons.center_focus_strong, 'label': 'Focus', 'color': const Color(0xFF6C63FF), 'route': 'Focus'},
      {'icon': Icons.self_improvement, 'label': 'Meditation', 'color': const Color(0xFF8B5CF6), 'route': 'Meditation'},
      {'icon': Icons.checklist_rounded, 'label': 'Tasks', 'color': const Color(0xFF30D158), 'route': 'Tasks'},
      {'icon': Icons.water_drop, 'label': 'Water', 'color': const Color(0xFF06B6D4), 'route': 'Water'},
      {'icon': Icons.bedtime, 'label': 'Sleep', 'color': const Color(0xFF5856D6), 'route': 'Sleep'},
      {'icon': Icons.mood, 'label': 'Mood', 'color': const Color(0xFFFF9F0A), 'route': 'Mood'},
      {'icon': Icons.note_alt, 'label': 'Notes', 'color': const Color(0xFFFF6B6B), 'route': 'Notes'},
      {'icon': Icons.flag_rounded, 'label': 'Goals', 'color': const Color(0xFF34D399), 'route': 'Goals'},
      {'icon': Icons.bar_chart, 'label': 'Reports', 'color': const Color(0xFF818CF8), 'route': 'Reports'},
      {'icon': Icons.settings, 'label': 'Settings', 'color': Colors.grey, 'route': 'Settings'},
      {'icon': Icons.timer, 'label': 'Study Timer', 'color': const Color(0xFFFF9500), 'route': 'StudyTimer'},
      {'icon': Icons.repeat_rounded, 'label': 'Habits', 'color': const Color(0xFFEF4444), 'route': 'Habits'},
    ];

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.85,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final page = pages[index];
          return _QuickAccessCard(
            icon: page['icon'] as IconData,
            label: page['label'] as String,
            color: page['color'] as Color,
            isDark: isDark,
            onTap: () => _navigateTo(context, page['route'] as String),
            animationDelay: Duration(milliseconds: 60 * index),
            parentController: _cardsAnimCtrl,
          );
        },
        childCount: pages.length,
      ),
    );
  }

  // ── ACTIVITY TREND CHART ─────────────────────────────────────
  Widget _buildActivityTrendChart(bool isDark) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final data = state.weeklyActivity;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: _cardDecoration(isDark, const Color(0xFF6C63FF)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Weekly Sessions',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '7 days',
                        style: TextStyle(color: Color(0xFF6C63FF), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 160,
                  child: BarChart(
                    BarChartData(
                      barGroups: data.asMap().entries.map((e) {
                        final val = e.value.sessionsCount.toDouble();
                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: val == 0 ? 0.001 : val,
                              width: 18,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  const Color(0xFF6C63FF).withOpacity(0.5),
                                  const Color(0xFF6C63FF),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (v) => FlLine(
                          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, meta) {
                              const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                              return Text(
                                days[v.toInt() % 7],
                                style: TextStyle(
                                  color: isDark ? Colors.white54 : Colors.black45,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      maxY: (data.map((e) => e.sessionsCount).reduce(max).toDouble() + 2).clamp(5, 20),
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 600),
                    swapAnimationCurve: Curves.easeOutCubic,
                  ),
                ),
                const SizedBox(height: 12),
                // Summary row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _chartSummaryItem(
                      'Total Sessions',
                      '${data.fold(0, (s, e) => s + e.sessionsCount)}',
                      isDark,
                    ),
                    _chartSummaryItem(
                      'Active Days',
                      '${data.where((e) => e.sessionsCount > 0).length}/7',
                      isDark,
                    ),
                    _chartSummaryItem(
                      'Time Spent',
                      '${(data.fold(0, (s, e) => s + e.minutesSpent) / 60).toStringAsFixed(1)}h',
                      isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _chartSummaryItem(String label, String value, bool isDark) => Column(
    children: [
      Text(
        value,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.white54 : Colors.black45,
          fontSize: 11,
        ),
      ),
    ],
  );

  // ── PROGRESS ANALYTICS ───────────────────────────────────────
  Widget _buildProgressAnalytics(bool isDark) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Pie Chart card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _cardDecoration(isDark, const Color(0xFF30D158)),
                child: Column(
                  children: [
                    Text(
                      'Completion Overview',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 160,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              value: state.completedTasks.toDouble().clamp(1, 100),
                              color: const Color(0xFF6C63FF),
                              radius: 50,
                              title: 'Tasks',
                              titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                            PieChartSectionData(
                              value: state.focusSessions.toDouble().clamp(1, 100),
                              color: const Color(0xFF30D158),
                              radius: 50,
                              title: 'Focus',
                              titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                            PieChartSectionData(
                              value: state.habitsCompleted.toDouble().clamp(1, 100),
                              color: const Color(0xFFFF9500),
                              radius: 50,
                              title: 'Habits',
                              titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                            PieChartSectionData(
                              value: (state.studyMinutes / 60).clamp(1, 100),
                              color: const Color(0xFF06B6D4),
                              radius: 50,
                              title: 'Study',
                              titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        swapAnimationDuration: const Duration(milliseconds: 800),
                        swapAnimationCurve: Curves.easeOutCubic,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Legend
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _legendItem('Tasks', const Color(0xFF6C63FF), isDark),
                        _legendItem('Focus', const Color(0xFF30D158), isDark),
                        _legendItem('Habits', const Color(0xFFFF9500), isDark),
                        _legendItem('Study', const Color(0xFF06B6D4), isDark),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Progress bars card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _cardDecoration(isDark, const Color(0xFF8B5CF6)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Goal Progress',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _progressBar('Tasks Completed', state.completedTasks / 10.0, const Color(0xFF6C63FF), isDark),
                    _progressBar('Focus Sessions', state.focusSessions / 8.0, const Color(0xFF30D158), isDark),
                    _progressBar('Habits Done', state.habitsCompleted / 5.0, const Color(0xFFFF9500), isDark),
                    _progressBar('Goals Reached', state.goalsCompleted / state.totalGoals.toDouble(), const Color(0xFF8B5CF6), isDark),
                    _progressBar('Wellness Score', state.productivityScore / 100.0, const Color(0xFF06B6D4), isDark),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _legendItem(String label, Color color, bool isDark) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54)),
    ],
  );

  Widget _progressBar(String label, double value, Color color, bool isDark) {
    final clamped = value.clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13)),
              Text('${(clamped * 100).round()}%', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: clamped,
              backgroundColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  // ── MOOD VS STUDY CHART ──────────────────────────────────────
  Widget _buildMoodStudyChart(bool isDark) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final data = state.moodStudyWeek;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: _cardDecoration(isDark, const Color(0xFFFF9500)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _legendItem('Mood (/10)', const Color(0xFF6C63FF), isDark),
                    const SizedBox(width: 20),
                    _legendItem('Study (h)', const Color(0xFFFF9500), isDark),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 180,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (v) => FlLine(
                          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, meta) {
                              const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                              final idx = v.toInt();
                              if (idx < 0 || idx >= days.length) return const SizedBox();
                              return Text(
                                days[idx],
                                style: TextStyle(
                                  color: isDark ? Colors.white38 : Colors.black38,
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        // Mood line
                        LineChartBarData(
                          spots: data.asMap().entries
                              .map((e) => FlSpot(e.key.toDouble(), e.value.moodLevel))
                              .toList(),
                          isCurved: true,
                          color: const Color(0xFF6C63FF),
                          barWidth: 2.5,
                          dotData: FlDotData(
                            getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                              radius: 4,
                              color: const Color(0xFF6C63FF),
                              strokeWidth: 2,
                              strokeColor: isDark ? const Color(0xFF1C1C2E) : Colors.white,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                const Color(0xFF6C63FF).withOpacity(0.3),
                                const Color(0xFF6C63FF).withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                        // Study hours line
                        LineChartBarData(
                          spots: data.asMap().entries
                              .map((e) => FlSpot(e.key.toDouble(), e.value.studyHours))
                              .toList(),
                          isCurved: true,
                          color: const Color(0xFFFF9500),
                          barWidth: 2.5,
                          dotData: FlDotData(
                            getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                              radius: 4,
                              color: const Color(0xFFFF9500),
                              strokeWidth: 2,
                              strokeColor: isDark ? const Color(0xFF1C1C2E) : Colors.white,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                const Color(0xFFFF9500).withOpacity(0.2),
                                const Color(0xFFFF9500).withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ],
                      minY: 0,
                      maxY: 12,
                    ),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── MOTIVATIONAL SECTION ─────────────────────────────────────
  Widget _buildMotivationalSection(bool isDark) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final isHigh = state.productivityScore >= 60;
        final messages = isHigh
            ? [
                '🚀 Amazing work today! Keep the momentum going!',
                '⭐ You\'re crushing it! Excellent consistency!',
                '👏 Brilliant progress! You should be proud!',
              ]
            : [
                '💪 You can do better today — one step at a time!',
                '🌱 Small progress is still progress. Keep going!',
                '🔥 Stay focused — your future self will thank you!',
              ];

        final msg = messages[DateTime.now().hour % messages.length];
        final gradient = isHigh
            ? [const Color(0xFF30D158), const Color(0xFF06B6D4)]
            : [const Color(0xFFFF9500), const Color(0xFFFF6B6B)];

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: gradient[0].withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  isHigh ? '🏆' : '🌟',
                  style: const TextStyle(fontSize: 36),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHigh ? 'Outstanding!' : 'You\'ve Got This!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        msg,
                        style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── WELLNESS MINI CARDS ───────────────────────────────────────
  Widget _buildWellnessMiniCards(bool isDark) {
    return Consumer<AppState>(
      builder: (context, state, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: _wellnessMiniCard(
                '💧 Water',
                '${state.waterIntake} / 8 glasses',
                state.waterIntake / 8.0,
                const Color(0xFF06B6D4),
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _wellnessMiniCard(
                '😴 Sleep',
                '${state.sleepHours}h / 8h goal',
                state.sleepHours / 8.0,
                const Color(0xFF8B5CF6),
                isDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wellnessMiniCard(String title, String subtitle, double progress, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(isDark, color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black45,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // ── RECENT ACTIVITY ──────────────────────────────────────────
  Widget _buildRecentActivity(bool isDark) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final activities = state.recentActivities;
        if (activities.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: _cardDecoration(isDark, Colors.grey),
              child: Center(
                child: Column(
                  children: [
                    const Text('📱', style: TextStyle(fontSize: 36)),
                    const SizedBox(height: 8),
                    Text(
                      'No recent activity yet',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black45,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Start using the app to see your activity here',
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black26,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: _cardDecoration(isDark, const Color(0xFF6C63FF)),
            child: Column(
              children: activities.asMap().entries.map((entry) {
                final a = entry.value;
                final isLast = entry.key == activities.length - 1;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _activityColor(a.type).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(child: Text(_activityEmoji(a.type), style: const TextStyle(fontSize: 18))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(a.title, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A1A2E), fontSize: 14, fontWeight: FontWeight.w600)),
                                Text(a.subtitle, style: TextStyle(color: isDark ? Colors.white54 : Colors.black45, fontSize: 12)),
                              ],
                            ),
                          ),
                          Text(
                            _timeAgo(a.time),
                            style: TextStyle(color: isDark ? Colors.white38 : Colors.black26, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                        indent: 68,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  // ── HELPERS ──────────────────────────────────────────────────
  BoxDecoration _cardDecoration(bool isDark, Color accentColor) => BoxDecoration(
    color: isDark ? const Color(0xFF1C1C2E) : Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: accentColor.withOpacity(isDark ? 0.15 : 0.08),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ],
  );

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤';
    return 'Good Evening 🌙';
  }

  Color _activityColor(String type) {
    switch (type) {
      case 'task': return const Color(0xFF30D158);
      case 'focus': return const Color(0xFF6C63FF);
      case 'mood': return const Color(0xFFFF9500);
      case 'water': return const Color(0xFF06B6D4);
      default: return Colors.grey;
    }
  }

  String _activityEmoji(String type) {
    switch (type) {
      case 'task': return '✅';
      case 'focus': return '🎯';
      case 'mood': return '😊';
      case 'water': return '💧';
      default: return '📌';
    }
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _navigateTo(BuildContext context, String route) {
    // Replace these with your actual page routes
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to $route...'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    // Example: Navigator.push(context, MaterialPageRoute(builder: (_) => FocusPage()));
  }
}

// ============================================================
// QUICK ACCESS CARD WIDGET (Animated)
// ============================================================

class _QuickAccessCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;
  final Duration animationDelay;
  final AnimationController parentController;

  const _QuickAccessCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
    required this.animationDelay,
    required this.parentController,
  });

  @override
  State<_QuickAccessCard> createState() => _QuickAccessCardState();
}

class _QuickAccessCardState extends State<_QuickAccessCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) {
          _pressCtrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _pressCtrl.reverse(),
        child: Container(
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF1C1C2E) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.icon, color: widget.color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.isDark ? Colors.white : const Color(0xFF1A1A2E),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// APP ENTRY POINT EXAMPLE
// ============================================================
//
// void main() {
//   runApp(
//     ChangeNotifierProvider(
//       create: (_) => AppState(),
//       child: MaterialApp(
//         title: 'Wellness App',
//         themeMode: ThemeMode.system,
//         theme: ThemeData(
//           useMaterial3: true,
//           colorSchemeSeed: const Color(0xFF6C63FF),
//           brightness: Brightness.light,
//         ),
//         darkTheme: ThemeData(
//           useMaterial3: true,
//           colorSchemeSeed: const Color(0xFF6C63FF),
//           brightness: Brightness.dark,
//         ),
//         home: const DashboardPage(),
//       ),
//     ),
//   );
// }
//
// ============================================================
// PUBSPEC.YAML DEPENDENCIES
// ============================================================
//
// dependencies:
//   flutter:
//     sdk: flutter
//   fl_chart: ^0.68.0
//   provider: ^6.1.2
//   shared_preferences: ^2.3.2
//
// ============================================================