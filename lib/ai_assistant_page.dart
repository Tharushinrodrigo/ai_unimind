import 'dart:math';
import 'package:flutter/material.dart';

void main() {
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
      initialRoute: '/voice',
      routes: {
        '/voice': (_) => const VoiceAssistantScreen(),
        '/focus': (_) => const FocusPage(),
      },
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
  late AnimationController _waveController;
  late AnimationController _orbController;
  late Animation<double> _pulseAnim;
  late Animation<double> _ring1Anim;
  late Animation<double> _ring2Anim;
  late Animation<double> _ring3Anim;

  bool _isListening = false;
  String _displayText = 'How can I help?';

  final List<double> _barHeights = [12, 20, 32, 26, 38, 30, 40, 28, 22, 36, 18, 28, 14, 24, 10];
  final List<double> _barDelays = [0, 0.1, 0.2, 0.05, 0.15, 0.25, 0.1, 0.3, 0.05, 0.2, 0.15, 0.35, 0.1, 0.25, 0];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _ring1Anim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ringController, curve: Curves.easeOut));
    _ring2Anim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ringController, curve: const Interval(0.2, 1.0, curve: Curves.easeOut)));
    _ring3Anim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ringController, curve: const Interval(0.4, 1.0, curve: Curves.easeOut)));

    _waveController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    _orbController = AnimationController(vsync: this, duration: const Duration(milliseconds: 4000))..repeat(reverse: true);
  }

  // මෙතනින් තමයි AI reply එක handle කරන්නේ
  void _handleVoiceInput(String input) async {
    setState(() {
      _isListening = true;
      _displayText = "Listening: $input...";
    });

    // මෙතන ChatGPT API එකට input එක යවන්න පුළුවන්. දැනට මම Mock reply එකක් දානවා.
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isListening = false;
      _displayText = "Reply: I'm processing '$input' for you!";
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ringController.dispose();
    _waveController.dispose();
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a0833), Color(0xFF0e0520), Color(0xFF180730), Color(0xFF0a0318)],
          ),
        ),
        child: SafeArea(
          // status bar eka ain kara (child eken check karanna)
          child: Stack(
            children: [
              _buildOrbs(),
              Column(
                children: [
                  const SizedBox(height: 20), // Top spacing
                  _buildTopBar(context),
                  _buildCenterSection(),
                  Expanded(child: _buildBottomCards()),
                ],
              ),
            ],
          ),
        ),
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
            Positioned(top: -40 + t * 10, left: -40, child: _orb(220, const Color(0xFF7c3aed), const Color(0xFFa855f7), 0.35 + t * 0.1)),
            Positioned(bottom: 120 - t * 10, right: -30, child: _orb(180, const Color(0xFFec4899), const Color(0xFFa855f7), 0.3 + t * 0.1)),
          ],
        );
      },
    );
  }

  Widget _orb(double size, Color c1, Color c2, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [c1.withOpacity(opacity), c2.withOpacity(0)])),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/focus'),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08), border: Border.all(color: Colors.white.withOpacity(0.15))),
              child: Center(child: Transform.rotate(angle: pi, child: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFd8b4fe), size: 14))),
            ),
          ),
          const Expanded(child: Center(child: Text('Voice Assistant', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)))),
          const SizedBox(width: 36), // Balance
        ],
      ),
    );
  }

  Widget _buildCenterSection() {
    return Column(
      children: [
        const SizedBox(height: 30),
        GestureDetector(
          onTap: () => _handleVoiceInput("Voice button clicked"), // Mic click action
          child: SizedBox(
            width: 200, height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _ringController,
                  builder: (_, __) => Stack(alignment: Alignment.center, children: [
                    _ring(200, _ring1Anim.value, 0.15),
                    _ring(165, _ring2Anim.value, 0.25),
                    _ring(130, _ring3Anim.value, 0.35),
                  ]),
                ),
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, child) => Transform.scale(scale: _pulseAnim.value, child: child),
                  child: Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [Color(0xFF7c3aed), Color(0xFFa855f7), Color(0xFFec4899)]),
                      boxShadow: [BoxShadow(color: const Color(0xFFa855f7).withOpacity(0.6), blurRadius: 30)],
                    ),
                    child: const Icon(Icons.mic_rounded, color: Colors.white, size: 44),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_barHeights.length, (i) => _WaveBar(maxHeight: _isListening ? _barHeights[i] : 5, delayFraction: _barDelays[i])),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isListening) _BlinkingDot(),
            const SizedBox(width: 6),
            Text(_displayText, style: const TextStyle(color: Color(0xFFd8b4fe), fontSize: 13)),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _ring(double size, double progress, double opacity) {
    return Opacity(
      opacity: (1 - progress) * opacity,
      child: Transform.scale(scale: 0.9 + progress * 0.2, child: Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFa855f7).withOpacity(opacity))))),
    );
  }

  Widget _buildBottomCards() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Quick Actions'),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8,
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.55,
            children: [
              GestureDetector(onTap: () => _handleVoiceInput("Add assignment"), child: const _ActionCard(emoji: '📝', title: 'Add assignment', color: Color(0xFF8b5cf6))),
              GestureDetector(onTap: () => _handleVoiceInput("Track expenses"), child: const _ActionCard(emoji: '💸', title: 'Track expenses', color: Color(0xFFec4899))),
              GestureDetector(onTap: () => _handleVoiceInput("Feeling anxious"), child: const _ActionCard(emoji: '🫂', title: 'I feel anxious', color: Color(0xFF6366f1))),
              GestureDetector(onTap: () => _handleVoiceInput("Emergency contact"), child: const _ActionCard(emoji: '🚨', title: 'Emergency', color: Color(0xFF14b8a6))),
            ],
          ),
          const SizedBox(height: 14),
          _sectionLabel('Quick Prompts'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7, runSpacing: 7,
            children: [
              GestureDetector(onTap: () => _handleVoiceInput("Set Reminder"), child: const _QuickPill(label: 'Assignment Reminder')),
              GestureDetector(onTap: () => _handleVoiceInput("Motivate me"), child: const _QuickPill(label: 'Motivate Me')),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(text.toUpperCase(), style: const TextStyle(color: Color(0xFFd8b4fe), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5));
}

// ─────────────────────────────────────────────
// WAVE BAR WIDGET
// ─────────────────────────────────────────────
class _WaveBar extends StatefulWidget {
  final double maxHeight;
  final double delayFraction;
  const _WaveBar({required this.maxHeight, required this.delayFraction});

  @override
  State<_WaveBar> createState() => _WaveBarState();
}

class _WaveBarState extends State<_WaveBar> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    Future.delayed(Duration(milliseconds: (widget.delayFraction * 800).toInt()), () { if (mounted) _ctrl.repeat(reverse: true); });
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 3, height: widget.maxHeight * _anim.value,
        margin: const EdgeInsets.symmetric(horizontal: 1.5),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), gradient: const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xFF7c3aed), Color(0xFFec4899)])),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// (Other widgets remain same as your code: _BlinkingDot, _ActionCard, _QuickPill, FocusPage, etc.)
// ─────────────────────────────────────────────

class _BlinkingDot extends StatefulWidget {
  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    _anim = Tween<double>(begin: 1.0, end: 0.15).animate(_ctrl);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _anim, builder: (_, __) => Opacity(opacity: _anim.value, child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFa855f7), shape: BoxShape.circle))));
  }
}

class _ActionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final Color color;
  const _ActionCard({required this.emoji, required this.title, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white.withOpacity(0.05), border: Border.all(color: const Color(0xFFd8b4fe).withOpacity(0.15))),
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500), maxLines: 2),
      ]),
    );
  }
}

class _QuickPill extends StatelessWidget {
  final String label;
  const _QuickPill({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white.withOpacity(0.06), border: Border.all(color: const Color(0xFFd8b4fe).withOpacity(0.2))),
      child: Text(label, style: const TextStyle(color: Color(0xFFd8b4fe), fontSize: 11)),
    );
  }
}

class FocusPage extends StatelessWidget {
  const FocusPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color(0xFF0e0520), body: Center(child: Text("Focus Page", style: TextStyle(color: Colors.white))));
  }
}