import 'package:ai_unimind/chatbot_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dashboard_page.dart';
import 'focus_page.dart' as focus;
import 'finance_page.dart';
import 'ai_assistant_page.dart';
import 'community_forum_page.dart';
import 'my_profile_page.dart';
import 'wellness_backend.dart';


import 'male_wellness_page.dart' as male;
import 'female_wellness_page.dart';

class WellnessPage extends StatefulWidget {
  const WellnessPage({super.key});

  @override
  State<WellnessPage> createState() => _WellnessPageState();
}

class _WellnessPageState extends State<WellnessPage> {
  final int _currentIndex = 3;
  final TextEditingController _moodController = TextEditingController();
  
  final WellnessBackend backend = WellnessBackend();

  String _selectedMood = "None";
  String _aiSuggestion = "Select your mood to get AI suggestions.";

  Map<String, double> weeklyMoodData = {
    "Mon": 2, "Tue": 4, "Wed": 3, "Thu": 1, "Fri": 4, "Sat": 2, "Sun": 3,
  };

  void loadWeeklyData() async {
    final data = await backend.getWeeklyMoodData();
    setState(() {
      weeklyMoodData = data;
    });
    AppState.notifyDashboardUpdate(context);
  }

  @override
  void dispose() {
    _moodController.dispose();
    super.dispose();
  }

  void _showSupportDialog(String title, List<Map<String, String>> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, i) => Card(
                  elevation: 0,
                  color: Colors.deepPurple[50],
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: const CircleAvatar(backgroundColor: Colors.deepPurple, child: Icon(Icons.phone, color: Colors.white, size: 20)),
                    title: Text(data[i]['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(data[i]['contact']!),
                    trailing: const Icon(Icons.call, color: Colors.green),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleActivity(String activityType) {
    List<Map<String, String>> steps = [];
    String title = "";

    if (activityType == "Breathing") {
      title = "Breathing Exercise";
      if (_selectedMood == "Stressed" || _selectedMood == "Sad") {
        steps = [
          {"step": "Deep Belly Breath", "desc": "Breathe in for 5 seconds to calm your nervous system.", "img": "assets/images/breathe_deep.png"},
          {"step": "Hold & Release", "desc": "Hold for 2 seconds and exhale through mouth slowly.", "img": "assets/images/exhale.png"},
        ];
      } else {
        steps = [
          {"step": "Energizing Breath", "desc": "Quick inhales to maintain your positive energy.", "img": "assets/images/energy.png"},
          {"step": "Focus Breath", "desc": "Maintain a steady rhythm to stay productive.", "img": "assets/images/focus1.png"},
        ];
      }
    } else if (activityType == "Music") {
      title = "Calm Music";
      steps = _selectedMood == "Happy" 
        ? [{"step": "Upbeat Lo-Fi", "desc": "Listen to light rhythmic beats.", "img": "assets/images/happy_music.png"}]
        : [{"step": "Nature Sounds", "desc": "Listen to rainfall or forest sounds to relax.", "img": "assets/images/rain.png"}];
    } else {
      title = "Self-Care Tips";
      steps = _selectedMood == "Stressed"
        ? [{"step": "Unplug", "desc": "Turn off all screens for 10 minutes.", "img": "assets/images/unplug.png"}]
        : [{"step": "Hydrate", "desc": "Drink a glass of water to stay fresh.", "img": "assets/images/water.png"}];
    }
    _showActivityDetails(title, steps);
  }

  void _showActivityDetails(String title, List<Map<String, String>> steps) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: steps.length,
                itemBuilder: (context, i) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                  color: Colors.grey[50],
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        child: Image.asset(
                          steps[i]['img']!, 
                          height: 150, 
                          width: double.infinity, 
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(height: 150, color: Colors.deepPurple[50], child: const Icon(Icons.image_outlined)),
                        ),
                      ),
                      ListTile(
                        title: Text(steps[i]['step']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(steps[i]['desc']!),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateMoodSelection(String mood, double value) {
    setState(() {
      _selectedMood = mood;
      String today = DateFormat('EEE').format(DateTime.now()); 
      if (weeklyMoodData.containsKey(today)) weeklyMoodData[today] = value;

      if (mood == "Happy") {
        _aiSuggestion = "Great energy! Time to crush your goals.";
      } else if (mood == "Neutral") _aiSuggestion = "Steady flow. Keep moving forward.";
      else if (mood == "Stressed") _aiSuggestion = "Take it easy. Let's try to de-stress.";
      else if (mood == "Sad") _aiSuggestion = "It's okay to rest. Be kind to yourself.";
    });
  }

  void _sendToAIChatbot(String text) {
    if (text.trim().isNotEmpty) {
      Navigator.push(context, MaterialPageRoute(builder: (c) => const ChatBotPage(), settings: RouteSettings(arguments: text)));
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: const Color(0xFFB5B2FF),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(child: Text("UniMind", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
              _drawerItem(Icons.grid_view_rounded, "Dashboard", () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) =>  DashboardPage()))),
              _drawerItem(Icons.book, "Study Focus", () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => focus.FocusPage()))),
              _drawerItem(Icons.self_improvement, "Wellness", () => Navigator.pop(context)),
              _drawerItem(Icons.chat_bubble_outline, "AI Chatbot", () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ChatBotPage()))),
              _drawerItem(Icons.smart_toy_outlined, "AI Assistant", () => Navigator.push(context, MaterialPageRoute(builder: (c) => const VoiceAssistantScreen()))),
              _drawerItem(Icons.people_outline, "Community Forum", () => Navigator.push(context, MaterialPageRoute(builder: (c) => CommunityForumPage()))),
              _drawerItem(Icons.person_outline, "My Profile", () => Navigator.push(context, MaterialPageRoute(builder: (c) => const MyProfilePage()))),
            ],
          ),
        ),
      ),
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.4), BlendMode.lighten),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Builder(builder: (context) => IconButton(icon: const Icon(Icons.menu, size: 30), onPressed: () => Scaffold.of(context).openDrawer())),
                    Text("Set Date: $formattedDate", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 10),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 85,
                      width: 85,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.auto_awesome, size: 35, color: Colors.deepPurple)
                    ),
                    
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "WELLNESS & MOOD", 
                          textAlign: TextAlign.center, 
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5)
                        ),
                      ),
                    ),

                   
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (context) => male.MaleWellnessPage()
                              )
                            );
                          },
                          child: const CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.male, size: 22, color: Colors.blue),
                          ),
                        ),
                        const SizedBox(height: 5),
                        GestureDetector(
                          onTap: () {
                            
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (context) => FemaleWellnessPage(
                                  userName: "Tharushi", 
                                  currentMood: _selectedMood
                                )
                              )
                            );
                          },
                          child: const CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.female, size: 22, color: Colors.pink),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 25),
                const Text("Today's Mood Input", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _moodActionIcon("😊", "Happy", 5.0),
                    _moodActionIcon("😐", "Neutral", 3.0),
                    _moodActionIcon("😫", "Stressed", 2.0),
                    _moodActionIcon("😔", "Sad", 1.0),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _moodController,
                  onSubmitted: (value) => _sendToAIChatbot(value),
                  decoration: InputDecoration(
                    hintText: "How are you feeling?",
                    filled: true, fillColor: Colors.white.withOpacity(0.7),
                    suffixIcon: IconButton(icon: const Icon(Icons.send), onPressed: () => _sendToAIChatbot(_moodController.text)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 30),
                const Text("Weekly Mood Analysis", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildWeeklyMoodChart(),
                const SizedBox(height: 25),
                _buildInfoCard(
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 25, backgroundColor: Colors.white, child: Icon(Icons.auto_awesome, color: Colors.deepPurple)),
                      const SizedBox(width: 15),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("AI Insight: $_selectedMood", style: const TextStyle(fontWeight: FontWeight.bold)), Text(_aiSuggestion, style: const TextStyle(fontSize: 12))])),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 10,
                  children: [
                    _smallBtn("Breathing Exercise", () => _handleActivity("Breathing")),
                    _smallBtn("Calm Music", () => _handleActivity("Music")),
                    _smallBtn("Self-Care Tips", () => _handleActivity("Self-Care")),
                  ],
                ),
                const SizedBox(height: 20),
                const Text("Emergency / Support", style: TextStyle(fontWeight: FontWeight.bold)),
                _buildInfoCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                    children: [
                      _smallBtn("Contact Counselor", () => _showSupportDialog("Available Counselors", [
                        {"name": "Sri Lanka Sumithrayo", "contact": "011 269 6666"},
                        {"name": "Shanthi Maargam", "contact": "071 763 9898"},
                        {"name": "CCC Line (24/7 Support)", "contact": "1333"},
                      ])), 
                      _smallBtn("Hotlines", () => _showSupportDialog("Emergency Hotlines", [
                        {"name": "National Mental Health Helpline", "contact": "1926"},
                        {"name": "Police Emergency", "contact": "119 / 118"},
                        {"name": "Suwaseriya Ambulance", "contact": "1990"},
                        {"name": "Women Help Line", "contact": "1938"},
                      ])),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromARGB(255, 127, 125, 131).withOpacity(0.9),
        selectedItemColor: Colors.white,
        onTap: (index) {
          if (index == _currentIndex) return;
          if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => DashboardPage()));
          if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => focus.FocusPage()));
          if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const FinancePage()));
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Study'),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Finance'),
          BottomNavigationBarItem(icon: Icon(Icons.spa), label: 'Wellness'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }

  Widget _moodActionIcon(String emoji, String label, double value) {
    bool isSelected = _selectedMood == label;
    return GestureDetector(
      onTap: () => _updateMoodSelection(label, value),
      child: Column(children: [
        AnimatedContainer(duration: const Duration(milliseconds: 300), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isSelected ? Colors.deepPurple.withOpacity(0.2) : Colors.white.withOpacity(0.3), shape: BoxShape.circle, border: Border.all(color: isSelected ? Colors.deepPurple : Colors.transparent, width: 2)), child: Text(emoji, style: const TextStyle(fontSize: 35))),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ]),
    );
  }

  Widget _buildWeeklyMoodChart() {
    return Container(
      height: 200, padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(15)),
      child: BarChart(BarChartData(
        maxY: 5,
        barGroups: weeklyMoodData.entries.map((e) => BarChartGroupData(x: weeklyMoodData.keys.toList().indexOf(e.key), barRods: [BarChartRodData(toY: e.value, color: e.value >= 4 ? Colors.green : (e.value >= 3 ? Colors.orange : Colors.red), width: 12)])).toList(),
        titlesData: FlTitlesData(bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text(weeklyMoodData.keys.elementAt(v.toInt()), style: const TextStyle(fontSize: 10)))), leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))),
        gridData: const FlGridData(show: false), borderData: FlBorderData(show: false),
      )),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) => ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
  Widget _buildInfoCard({required Widget child}) => Container(width: double.infinity, padding: const EdgeInsets.all(15), margin: const EdgeInsets.symmetric(vertical: 5), decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(15)), child: child);
  Widget _smallBtn(String text, VoidCallback onPressed) => ElevatedButton(onPressed: onPressed, style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.8), foregroundColor: Colors.black, textStyle: const TextStyle(fontSize: 10)), child: Text(text));
}
