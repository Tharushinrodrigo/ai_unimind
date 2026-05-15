import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

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
  late Animation<double> _pulseAnim;

  bool _isListening = false;
  String _displayText = 'Tap mic and speak';

  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  final String apiKey = "YOUR_API_KEY_HERE";
  final String model = "openai/gpt-oss-20b:free";

  String lastWords = "";

  List<dynamic> _voices = [];
  String _voiceMode = "female";

  @override
  void initState() {
    super.initState();

    _pulseController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);

    _pulseAnim =
        Tween<double>(begin: 0.85, end: 1.0).animate(_pulseController);

    _initSpeech();
    _initTTS(); // ✅ FIX
    _loadVoices();
  }

  // ✅ TTS INIT (IMPORTANT FIX)
  Future<void> _initTTS() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
  }

  void _initSpeech() async {
    await _speech.initialize();
  }

  // LOAD VOICES
  Future<void> _loadVoices() async {
    var v = await _tts.getVoices;
    _voices = v ?? [];
  }

  // SET VOICE (SAFE VERSION)
  Future<void> _setVoice(String type) async {
    _voiceMode = type;

    for (var v in _voices) {
      String name = v["name"].toString().toLowerCase();

      if (type == "male") {
        if (name.contains("male") ||
            name.contains("david") ||
            name.contains("mark") ||
            name.contains("en-us")) {
          await _tts.setVoice(Map<String, String>.from(v));
          break;
        }
      } else {
        if (name.contains("female") ||
            name.contains("zira") ||
            name.contains("samantha")) {
          await _tts.setVoice(Map<String, String>.from(v));
          break;
        }
      }
    }

    setState(() {});
  }

  // MIC TOGGLE
  void _toggleMic() async {
    if (!_isListening) {
      bool available = await _speech.initialize();

      if (available) {
        setState(() {
          _isListening = true;
          _displayText = "Listening...";
        });

        _speech.listen(onResult: (result) {
          setState(() {
            lastWords = result.recognizedWords;
            _displayText = lastWords;
          });
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();

      if (lastWords.isNotEmpty) {
        _sendToAI(lastWords);
      }
    }
  }

  // AI CALL
  Future<void> _sendToAI(String message) async {
    setState(() => _displayText = "Thinking...");

    try {
      final response = await http.post(
        Uri.parse("https://openrouter.ai/api/v1/chat/completions"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode({
          "model": model,
          "messages": [
            {
              "role": "system",
              "content": "You are UniMind AI assistant. Keep answers short."
            },
            {"role": "user", "content": message}
          ],
          "temperature": 0.7,
          "max_tokens": 300,
        }),
      );

      final data = jsonDecode(response.body);

      String reply =
          data["choices"][0]["message"]["content"].toString().trim();

      setState(() {
        _displayText = reply;
      });

      // 🔊 FIXED SPEAK (NO SILENT ISSUE)
      await _tts.stop();
      await Future.delayed(const Duration(milliseconds: 200));
      await _tts.speak(reply);
    } catch (e) {
      setState(() {
        _displayText = "Error: $e";
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1a0833),
              Color(0xFF0e0520),
              Color(0xFF180730),
              Color(0xFF0a0318),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),

              // BACK
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        color: Colors.white),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/focus');
                    },
                  ),
                  const Text("UniMind Voice AI",
                      style: TextStyle(color: Colors.white))
                ],
              ),

              // VOICE SELECT
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text("Female"),
                    selected: _voiceMode == "female",
                    onSelected: (_) => _setVoice("female"),
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text("Male"),
                    selected: _voiceMode == "male",
                    onSelected: (_) => _setVoice("male"),
                  ),
                ],
              ),

              const Spacer(),

              // MIC
              GestureDetector(
                onTap: _toggleMic,
                child: AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, child) =>
                      Transform.scale(scale: _pulseAnim.value, child: child),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF7c3aed),
                          Color(0xFFec4899),
                        ],
                      ),
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // TEXT
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  _displayText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FOCUS PAGE
// ─────────────────────────────────────────────
class FocusPage extends StatelessWidget {
  const FocusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0e0520),
      body: const Center(
        child: Text(
          "Focus Page",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}