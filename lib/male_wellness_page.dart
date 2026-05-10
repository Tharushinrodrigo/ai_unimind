import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────
//  IMPORTANT: Store your API key securely.
// ─────────────────────────────────────────────
const String _geminiApiKey =
    String.fromEnvironment('GEMINI_KEY', defaultValue: 'AIzaSyB4IIQE4tXHM8rtilEil6yMr1cXNPt7Hzk');

// ─────────────────────────────────────────────
//  Mood Data Model
// ─────────────────────────────────────────────
class MoodData {
  final String emoji;
  final String mainMessage;
  final String exerciseTip;
  final int exerciseSeconds; 
  final String gymReminder;
  final List<ActivityItem> activities;

  const MoodData({
    required this.emoji,
    required this.mainMessage,
    required this.exerciseTip,
    required this.exerciseSeconds,
    required this.gymReminder,
    required this.activities,
  });
}

class ActivityItem {
  final String name;
  final IconData icon;
  final String howTo;
  final String duration;

  const ActivityItem({
    required this.name,
    required this.icon,
    required this.howTo,
    required this.duration,
  });
}

MoodData getMoodData(String mood) {
  switch (mood.toLowerCase()) {
    case 'sad':
      return const MoodData(
        emoji: '😔',
        mainMessage: 'Feeling a bit low? A quick walk can boost your serotonin levels.',
        exerciseTip: 'Do light stretching or deep breathing.',
        exerciseSeconds: 600, 
        gymReminder: 'Evening (Around 5 PM) is best for a light workout.',
        activities: [
          ActivityItem(name: 'Walking', icon: Icons.directions_walk, howTo: 'Walk at a comfortable pace outdoors for 10–15 minutes.', duration: '10 min'),
          ActivityItem(name: 'Music', icon: Icons.music_note, howTo: 'Listen to uplifting music and focus on the rhythm.', duration: '15 min'),
          ActivityItem(name: 'Yoga', icon: Icons.self_improvement, howTo: 'Follow a beginner yoga flow — child\'s pose, downward dog, cat-cow.', duration: '20 min'),
          ActivityItem(name: 'Reading', icon: Icons.book, howTo: 'Pick a book you enjoy. Read in a calm, quiet space.', duration: '30 min'),
          ActivityItem(name: 'Stretching', icon: Icons.accessibility, howTo: 'Hold each stretch for 20–30 seconds. Focus on shoulders and neck.', duration: '10 min'),
          ActivityItem(name: 'Journaling', icon: Icons.edit, howTo: 'Write freely about your thoughts. No rules — just express.', duration: '15 min'),
        ],
      );
    case 'stress':
      return const MoodData(
        emoji: '🤯',
        mainMessage: 'Stress rising. Consider short physical activity to clear your mind.',
        exerciseTip: 'Do push-ups or high-intensity interval training.',
        exerciseSeconds: 1200, 
        gymReminder: 'Hit the gym now to release that tension!',
        activities: [
          ActivityItem(name: 'Running', icon: Icons.directions_run, howTo: 'Run at a moderate pace. Focus on breathing.', duration: '20 min'),
          ActivityItem(name: 'Push-Ups', icon: Icons.fitness_center, howTo: 'Do 3 sets of 15 push-ups. Keep your core tight.', duration: '10 min'),
          ActivityItem(name: 'Boxing', icon: Icons.sports_mma, howTo: 'Shadow box for 3 rounds. Jab, cross, hook combinations.', duration: '15 min'),
          ActivityItem(name: 'Cycling', icon: Icons.pedal_bike, howTo: 'Cycle at a high cadence for 20 minutes.', duration: '20 min'),
          ActivityItem(name: 'Swimming', icon: Icons.pool, howTo: 'Swim freestyle laps. Rest 30 seconds between each lap.', duration: '30 min'),
          ActivityItem(name: 'Stretching', icon: Icons.accessibility, howTo: 'Deep stretches for hips and back.', duration: '10 min'),
        ],
      );
    case 'happy':
      return const MoodData(
        emoji: '😊',
        mainMessage: 'You are doing great! Keep up the positive energy.',
        exerciseTip: 'Complete your full gym routine today.',
        exerciseSeconds: 2700, 
        gymReminder: 'Your usual gym time is perfect today!',
        activities: [
          ActivityItem(name: 'Gym', icon: Icons.fitness_center, howTo: 'Full body workout — squats, bench press, deadlift.', duration: '45 min'),
          ActivityItem(name: 'Running', icon: Icons.directions_run, howTo: 'Go for a longer run at a comfortable pace.', duration: '30 min'),
          ActivityItem(name: 'Squats', icon: Icons.accessibility_new, howTo: '4 sets of 12 squats. Keep knees behind toes.', duration: '15 min'),
          ActivityItem(name: 'Plank', icon: Icons.timer, howTo: 'Hold a plank for 60 seconds. Repeat 3 times.', duration: '10 min'),
          ActivityItem(name: 'Cardio', icon: Icons.favorite, howTo: '20 minutes of your favourite cardio exercise.', duration: '20 min'),
          ActivityItem(name: 'Weights', icon: Icons.line_weight, howTo: 'Dumbbell curls, shoulder press, rows.', duration: '25 min'),
        ],
      );
    case 'nature':
    default:
      return const MoodData(
        emoji: '🌿',
        mainMessage: 'Connect with nature today. Fresh air does wonders for your mind.',
        exerciseTip: 'Try an outdoor walk or light jog in a park.',
        exerciseSeconds: 1800, 
        gymReminder: 'Have you worked out this week? Maybe plan a session today?',
        activities: [
          ActivityItem(name: 'Hiking', icon: Icons.terrain, howTo: 'Choose a local trail. Walk at a steady pace.', duration: '60 min'),
          ActivityItem(name: 'Cycling', icon: Icons.pedal_bike, howTo: 'Ride outdoors through a park or scenic route.', duration: '30 min'),
          ActivityItem(name: 'Yoga', icon: Icons.self_improvement, howTo: 'Outdoor yoga session on the grass.', duration: '20 min'),
          ActivityItem(name: 'Walking', icon: Icons.directions_walk, howTo: 'Mindful walk — notice sounds and sights around you.', duration: '20 min'),
          ActivityItem(name: 'Stretching', icon: Icons.accessibility, howTo: 'Stretch outdoors. Full body, 30 sec each pose.', duration: '15 min'),
          ActivityItem(name: 'Breathing', icon: Icons.air, howTo: 'Box breathing: inhale 4s, hold 4s, exhale 4s, hold 4s.', duration: '10 min'),
        ],
      );
  }
}

class MaleWellnessPage extends StatefulWidget {
  const MaleWellnessPage({super.key});

  @override
  State<MaleWellnessPage> createState() => _MaleWellnessPageState();
}

class _MaleWellnessPageState extends State<MaleWellnessPage> {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _timerRunning = false;
  String _currentMood = '';
  String _aiInsight = 'Loading AI insight...';
  bool _aiLoading = true;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_timerRunning) return;
    setState(() => _timerRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds <= 0) {
        t.cancel();
        setState(() => _timerRunning = false);
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _timerRunning = false);
  }

  void _resetTimer(int seconds) {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = seconds;
      _timerRunning = false;
    });
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _fetchGeminiInsight(String mood, String name) async {
    setState(() { _aiLoading = true; _aiInsight = 'Loading AI insight...'; });
    try {
      final prompt = 'Give a short (2 sentences max) motivational wellness tip for a male named $name who is feeling $mood today. Focus on strength and consistency.';
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'contents': [{'parts': [{'text': prompt}]}]}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? 'Stay strong and keep moving!';
        setState(() { _aiInsight = text.trim(); _aiLoading = false; });
      } else {
        setState(() { _aiInsight = 'Focus on your goals. Every small step counts today.'; _aiLoading = false; });
      }
    } catch (e) {
      setState(() { _aiInsight = 'Push your limits. You are stronger than you think.'; _aiLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text('Please log in.')));

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final userData = snapshot.data?.data() as Map<String, dynamic>?;
          if (userData == null) return const Center(child: Text('Profile error.'));

          final String name = (userData['name'] ?? 'User').toString();
          final String mood = (userData['mood'] ?? 'Nature').toString();
          final moodData = getMoodData(mood);

          if (_currentMood != mood) {
            _currentMood = mood;
            _remainingSeconds = moodData.exerciseSeconds;
            _timerRunning = false;
            _timer?.cancel();
            WidgetsBinding.instance.addPostFrameCallback((_) => _fetchGeminiInsight(mood, name));
          }

          return Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=2070'), // Gym Background
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        const SizedBox(height: 10),
                        _buildUserGreeting(name, moodData.emoji),
                        const SizedBox(height: 15),
                        _buildMoodMessageCard(moodData.mainMessage),
                        const SizedBox(height: 20),
                        _buildAIInsightsSection(),
                        const SizedBox(height: 20),
                        _buildExerciseCard(moodData),
                        const SizedBox(height: 20),
                        _buildActivitiesSection(moodData.activities),
                        const SizedBox(height: 20),
                        _buildGymReminder(moodData.gymReminder),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  // _buildBottomNav(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // මෙහි onPressed කොටස '/wellness' වෙත යන ලෙස සකසා ඇත.
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 48
          ),
          IconButton(
  icon: const Icon(Icons.arrow_back), 
  onPressed: () => Navigator.pop(context) // මේ කේතය මගින් කලින් පිටුවට යයි
),
          const Text('MALE WELLNESS', 
            style: TextStyle(
              color: Colors.white, 
              fontSize: 18, 
              fontWeight: FontWeight.bold, 
              letterSpacing: 1.5
            )
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white, size: 28),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserGreeting(String name, String emoji) {
    return Row(
      children: [
        const CircleAvatar(radius: 25, backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white)),
        const SizedBox(width: 12),
        Text('Hello $name', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(width: 8),
        Text(emoji, style: const TextStyle(fontSize: 28)),
      ],
    );
  }

  Widget _buildMoodMessageCard(String message) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24)),
      child: Text(message, style: const TextStyle(fontSize: 15, color: Colors.white, height: 1.4)),
    );
  }

  Widget _buildAIInsightsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('AI Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.blue.withOpacity(0.2), Colors.purple.withOpacity(0.2)]), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blueAccent.withOpacity(0.3))),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.cyanAccent, size: 30),
              const SizedBox(width: 15),
              Expanded(child: _aiLoading ? const LinearProgressIndicator() : Text(_aiInsight, style: const TextStyle(color: Colors.white, fontSize: 13))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(MoodData moodData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Exercise Now!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('Tap time to start', style: TextStyle(fontSize: 11, color: Colors.white70)),
                ],
              ),
              GestureDetector(
                onTap: _timerRunning ? _pauseTimer : _startTimer,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(color: _timerRunning ? Colors.redAccent : Colors.greenAccent, borderRadius: BorderRadius.circular(15)),
                  child: Text(_formatTime(_remainingSeconds), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(Icons.restart_alt, color: Colors.white), onPressed: () => _resetTimer(moodData.exerciseSeconds)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActivitiesSection(List<ActivityItem> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recommended Activities', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.9),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return GestureDetector(
              onTap: () => _showActivityDetail(activity),
              child: Column(
                children: [
                  CircleAvatar(radius: 25, backgroundColor: Colors.white12, child: Icon(activity.icon, color: Colors.white)),
                  const SizedBox(height: 5),
                  Text(activity.name, style: const TextStyle(fontSize: 12, color: Colors.white), textAlign: TextAlign.center),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showActivityDetail(ActivityItem activity) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(activity.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text('Duration: ${activity.duration}', style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
            const Divider(),
            const Text('How to do it:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(activity.howTo),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGymReminder(String reminder) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.orangeAccent.withOpacity(0.3))),
      child: Row(
        children: [
          const Icon(Icons.notification_important, color: Colors.orangeAccent),
          const SizedBox(width: 10),
          Expanded(child: Text(reminder, style: const TextStyle(color: Colors.white, fontSize: 13))),
        ],
      ),
    );
  }
  Widget _navIcon(BuildContext context, String label, String route, {bool active = false}) {
    return GestureDetector(
      onTap: () {
        if (!active) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      child: Text(label, style: TextStyle(color: active ? Colors.purpleAccent : Colors.white60, fontWeight: active ? FontWeight.bold : FontWeight.normal)),
    );
  }
}