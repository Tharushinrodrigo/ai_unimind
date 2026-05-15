import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'focus_page.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, String>> messages = [];
  bool isLoading = false;

  final String apiKey =
      " API key";

  final String model = "openai/gpt-oss-20b:free";

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": message});
      isLoading = true;
    });

    _controller.clear();
    scrollToBottom();

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
              "content": "You are UniMind AI, a helpful student assistant."
            },
            {"role": "user", "content": message}
          ],
          "temperature": 0.7,
          "max_tokens": 500,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        String botReply =
            data["choices"][0]["message"]["content"].toString().trim();

        setState(() {
          messages.add({"role": "bot", "text": botReply});
        });
      } else {
        setState(() {
          messages.add({
            "role": "bot",
            "text":
                "API Error (${response.statusCode}): ${data['error']?['message'] ?? 'Unknown error'}"
          });
        });
      }
    } catch (e) {
      setState(() {
        messages.add({"role": "bot", "text": "Error: $e"});
      });
    }

    setState(() => isLoading = false);
    scrollToBottom();
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget buildMessage(Map<String, String> message) {
    bool isUser = message["role"] == "user";

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [Color(0xff7F5AF0), Color(0xff5B3DF5)],
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.12),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          message["text"] ?? "",
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      // 🌌 AI Gradient Background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff0F1117),
              Color(0xff1A1C2C),
              Color(0xff0B0D14),
            ],
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [
              // 🔙 App Bar with Back Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios,
                          color: Colors.white),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const FocusPage()),
                        );
                      },
                    ),
                    const Text(
                      "UniMind AI",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return buildMessage(messages[index]);
                  },
                ),
              ),

              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(color: Colors.white),
                ),

              // 💬 Input Box (glass style)
              Padding(
                padding: const EdgeInsets.all(12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              style:
                                  const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: "Ask UniMind AI...",
                                hintStyle:
                                    TextStyle(color: Colors.white54),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              sendMessage(_controller.text);
                            },
                            icon: const Icon(Icons.send,
                                color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}