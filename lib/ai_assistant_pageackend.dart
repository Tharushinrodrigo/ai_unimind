import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Backend එක සඳහා
import 'package:firebase_core/firebase_core.dart';

void main() async {
  // Firebase initialize කිරීම (Backend වැඩ කිරීමට මෙය අවශ්‍යයි)
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(); // ඔයා Firebase setup කරාම මේක uncomment කරන්න
  runApp(const VoiceAssistantApp());
}

class VoiceAssistantApp extends StatelessWidget {
  const VoiceAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'SF Pro Display'),
      home: const VoiceAssistantScreen(),
    );
  }
}

// ─────────────────────────────────────────────
// VOICE ASSISTANT SCREEN
// ─────────────────────────────────────────────
class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _ringController;
  late AnimationController _orbController;
  late Animation<double> _pulseAnim;

  // App States
  bool _isListening = false;
  String _assistantStatus = 'How can I help?';
  String _lastResponse = "";

  final List<double> _barHeights = [12, 20, 32, 26, 38, 30, 40, 28, 22, 36, 18, 28, 14, 24, 10];
  final List<double> _barDelays = [0, 0.1, 0.2, 0.05, 0.15, 0.25, 0.1, 0.3, 0.05, 0.2, 0.15, 0.35, 0.1, 0.25, 0];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _ringController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat();
    _orbController = AnimationController(vsync: this, duration: const Duration(milliseconds: 4000))..repeat(reverse: true);
  }

  // ── BACKEND: Data Save to Firestore ──
  Future<void> _saveToBackend(String query, String response) async {
    try {
      // 'chats' කියන collection එකට data save වෙනවා
      await FirebaseFirestore.instance.collection('assistant_history').add({
        'user_query': query,
        'ai_response': response,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("History Saved to Backend");
    } catch (e) {
      print("Backend Error: $e");
    }
  }

  // ── VOICE LOGIC (ChatGPT Style) ──
  void _handleInteraction(String input) async {
    setState(() {
      _isListening = true;
      _assistantStatus = "Thinking...";
    });

    // AI එකෙන් reply එක එන බව පෙන්වීමට delay එකක්
    await Future.delayed(const Duration(seconds: 2));

    String aiReply = "";
    // සරල AI logic එකක් (පස්සේ මේකට ChatGPT API එක සම්බන්ධ කරන්න පුළුවන්)
    if (input.contains("assignment")) {
      aiReply = "Sure, I've added a reminder for your assignment.";
    } else if (input.contains("anxious")) {
      aiReply = "Take a deep breath. I'm here to help you relax.";
    } else {
      aiReply = "I understand. I will help you with '$input'.";
    }

    setState(() {
      _isListening = false;
      _lastResponse = aiReply;
      _assistantStatus = "I'm listening...";
    });

    // දත්ත Backend එකට යැවීම
    _saveToBackend(input, aiReply);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ringController.dispose();
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a0833), Color(0xFF0e0520), Color(0xFF180730), Color(0xFF0a0318)],
          ),
        ),
        child: SafeArea(
          // උඩින්ම තියෙන battery/time (status bar) එක මෙතනින් අයින් කර ඇත
          child: Stack(
            children: [
              _buildOrbs(),
              Column(
                children: [
                  const SizedBox(height: 25), 
                  _buildTopBar(),
                  _buildCenterMicSection(),
                  if (_lastResponse.isNotEmpty) _buildResponseBubble(),
                  Expanded(child: _buildBottomActions()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── UI COMPONENTS ──

  Widget _buildTopBar() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('VOICE ASSISTANT', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _buildCenterMicSection() {
    return Column(
      children: [
        const SizedBox(height: 30),
        GestureDetector(
          onTap: () => _handleInteraction("Voice Command"), // Mic එක click කරාම
          child: Stack(
            alignment: Alignment.center,
            children: [
              _buildRings(),
              ScaleTransition(
                scale: _pulseAnim,
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [Color(0xFF7c3aed), Color(0xFFec4899)]),
                    boxShadow: [BoxShadow(color: const Color(0xFFa855f7).withOpacity(0.5), blurRadius: 40)],
                  ),
                  child: const Icon(Icons.mic_rounded, color: Colors.white, size: 40),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        // Waveform
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_barHeights.length, (i) => _WaveBar(maxHeight: _isListening ? _barHeights[i] : 5, delayFraction: _barDelays[i])),
        ),
        const SizedBox(height: 15),
        Text(_assistantStatus, style: const TextStyle(color: Color(0xFFd8b4fe), fontSize: 14)),
      ],
    );
  }

  Widget _buildResponseBubble() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)),
        child: Text(_lastResponse, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 13, fontStyle: FontStyle.italic)),
      ),
    );
  }

  Widget _buildBottomActions() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const Text("QUICK ACTIONS", style: TextStyle(color: Color(0xFFd8b4fe), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true, crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.6,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _actionCard("📝", "Add assignment", const Color(0xFF8b5cf6)),
            _actionCard("🫂", "I feel anxious", const Color(0xFF6366f1)),
          ],
        ),
        const SizedBox(height: 20),
        const Text("QUICK PROMPTS", style: TextStyle(color: Color(0xFFd8b4fe), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: [
            _promptChip("Motivate Me"),
            _promptChip("Play Focus Music"),
          ],
        )
      ],
    );
  }

  Widget _actionCard(String emoji, String title, Color color) {
    return GestureDetector(
      onTap: () => _handleInteraction(title), // Click කරාම backend එකට යනවා
      child: Container(
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: color.withOpacity(0.3))),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _promptChip(String label) {
    return ActionChip(
      backgroundColor: Colors.white.withOpacity(0.05),
      label: Text(label, style: const TextStyle(color: Color(0xFFd8b4fe), fontSize: 11)),
      onPressed: () => _handleInteraction(label),
    );
  }

  Widget _buildRings() {
    return AnimatedBuilder(
      animation: _ringController,
      builder: (_, __) => Stack(
        alignment: Alignment.center,
        children: [130.0, 170.0, 210.0].map((size) => Container(
          width: size, height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFa855f7).withOpacity(0.1))),
        )).toList(),
      ),
    );
  }

  Widget _buildOrbs() {
    return AnimatedBuilder(
      animation: _orbController,
      builder: (_, __) {
        final t = _orbController.value;
        return Stack(
          children: [
            Positioned(top: -40 + t * 10, left: -40, child: _orb(220, const Color(0xFF7c3aed), 0.2)),
            Positioned(bottom: 120 - t * 10, right: -30, child: _orb(180, const Color(0xFFec4899), 0.2)),
          ],
        );
      },
    );
  }

  Widget _orb(double size, Color c1, double opacity) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [c1.withOpacity(opacity), Colors.transparent])),
    );
  }
}

// Wave Bar Widget
class _WaveBar extends StatefulWidget {
  final double maxHeight;
  final double delayFraction;
  const _WaveBar({required this.maxHeight, required this.delayFraction});
  @override
  State<_WaveBar> createState() => _WaveBarState();
}

class _WaveBarState extends State<_WaveBar> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat(reverse: true);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: 3, height: widget.maxHeight * (0.4 + _ctrl.value * 0.6),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(color: const Color(0xFFec4899), borderRadius: BorderRadius.circular(5)),
      ),
    );
  }
}