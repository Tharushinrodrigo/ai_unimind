import 'package:flutter/material.dart';
import 'focus_backend.dart';
import 'dashboard_page.dart';
import 'wellness_page.dart';
import 'finance_page.dart';
import 'ai_chatbot_page.dart';
import 'ai_assistant_page.dart';
import 'community_forum_page.dart';
import 'my_profile_page.dart';
import 'focus_history_page.dart';
import 'help_support_page.dart';

class FocusPage extends StatefulWidget {
  const FocusPage({super.key});
  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  final FocusBackend _backend = FocusBackend();
  int _selectedNavIndex = 1;

  @override
  void initState() {
    super.initState();
    _initBackend();
  }

  Future<void> _initBackend() async {
    await _backend.init();
  }

  void _updateUI() => setState(() {});

  void _openSettings() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Scaffold(
      appBar: AppBar(title: const Text("Settings"), backgroundColor: const Color(0xFFB5B2FF)),
      body: const Center(child: Text("Settings and Preferences here")),
    )));
  }

  void _showWeeklyPlan() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFE0E0FF).withOpacity(0.9),
        title: const Text("Weekly Progress", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(7, (i) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                SizedBox(width: 40, child: Text(_backend.days[i])),
                Expanded(child: LinearProgressIndicator(value: _backend.weeklyProgress[i], color: Colors.indigo, backgroundColor: Colors.white)),
                const SizedBox(width: 10),
                Text("${(_backend.weeklyProgress[i] * 100).toInt()}%"),
              ],
            ),
          )),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
      ),
    );
  }

  void _editSubject() {
    TextEditingController nameCtrl = TextEditingController(text: _backend.subjectName);
    double tempProgress = _backend.progressValue;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
        title: const Text("Edit Progress"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Subject Name")),
            Slider(value: tempProgress, onChanged: (v) => setDialogState(() => tempProgress = v)),
          ],
        ),
        actions: [
          ElevatedButton(onPressed: () {
            setState(() => _backend.updateSubject(nameCtrl.text, tempProgress));
            Navigator.pop(context);
          }, child: const Text("Save")),
        ],
      )),
    );
  }

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFB5B2FF),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => MyProfilePage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Focus History"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => FocusHistoryPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text("Help & Support"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => HelpSupportPage()));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editScheduleDialog(int index) {
    TextEditingController timeCtrl = TextEditingController(text: _backend.schedule[index]['time']);
    TextEditingController taskCtrl = TextEditingController(text: _backend.schedule[index]['task']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Schedule"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: "Time")),
            TextField(controller: taskCtrl, decoration: const InputDecoration(labelText: "Task")),
          ],
        ),
        actions: [
          ElevatedButton(onPressed: () {
            setState(() => _backend.updateSchedule(index, timeCtrl.text, taskCtrl.text));
            Navigator.pop(context);
          }, child: const Text("Save")),
          ElevatedButton(onPressed: () {
            setState(() => _backend.removeScheduleItem(index));
            Navigator.pop(context);
          }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text("Delete")),
        ],
      ),
    );
  }

  void _addNewScheduleItem() {
    TextEditingController timeCtrl = TextEditingController();
    TextEditingController taskCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Schedule Item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: "Time")),
            TextField(controller: taskCtrl, decoration: const InputDecoration(labelText: "Task")),
          ],
        ),
        actions: [
          ElevatedButton(onPressed: () {
            if (timeCtrl.text.isNotEmpty && taskCtrl.text.isNotEmpty) {
              setState(() => _backend.addScheduleItem(timeCtrl.text, taskCtrl.text));
              Navigator.pop(context);
            }
          }, child: const Text("Add")),
        ],
      ),
    );
  }

  void _showTimePickerDialog() {
    TextEditingController minutesCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set Focus Time"),
        content: TextField(
          controller: minutesCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Minutes"),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              int? mins = int.tryParse(minutesCtrl.text);
              if (mins != null && mins > 0) {
                _backend.setTimer(mins);
                _updateUI();
                Navigator.pop(context);
              }
            },
            child: const Text("Set"),
          ), 
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Image එක AppBar එකට යටින් යන්න
      drawer: Drawer(
        child: Container(
          color: const Color(0xFFB5B2FF),
          child: ListView(
            children: [
              const DrawerHeader(child: Text("UniMind", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
              _drawerItem(Icons.dashboard, "Dashboard", () { Navigator.pop(context); Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  DashboardPage())); }),
              _drawerItem(Icons.book, "Study Focus", () { Navigator.pop(context); Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const FocusPage())); }),
              _drawerItem(Icons.attach_money, "Finance", () { Navigator.pop(context); Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const FinancePage())); }),
              _drawerItem(Icons.self_improvement, "Wellness", () { Navigator.pop(context); Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WellnessPage())); }),
              _drawerItem(Icons.chat_bubble_outline, "AI Chatbot", () { Navigator.pop(context); Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ChatPage())); }),
              _drawerItem(Icons.smart_toy_outlined, "AI Assistant", () { Navigator.pop(context); Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const VoiceAssistantScreen())); }),
              _drawerItem(Icons.groups_outlined, "Community Forum", () { Navigator.pop(context); Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CommunityForumPage())); }),
              _drawerItem(Icons.person_outline, "My Profile", () { Navigator.pop(context); Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyProfilePage())); }),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        leading: Builder(builder: (context) => IconButton(icon: const Icon(Icons.menu, color: Colors.black), onPressed: () => Scaffold.of(context).openDrawer())),
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          Image.asset('assets/images/logo.png', height: 40, errorBuilder: (c,e,s) => const Icon(Icons.psychology, size: 40)),
          const SizedBox(width: 10), const Text("FOCUS", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ]),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.black), onPressed: _openSettings)],
      ),
      // මෙතන තමයි Background Image එක දාන්නේ
      body: Stack(
        children: [
          // 1. Background Image එක
          Positioned.fill(
            child: Image.asset(
              'assets/images/focus.png', // ඔයාගේ රූපයේ නම මෙතන තියෙනවා
              fit: BoxFit.cover, // Screen එක පුරාම පිරෙන්න
            ),
          ),
          // 2. Content එක කියවන්න ලේසි වෙන්න ලාවට සුදු පාට Layer එකක් (Optional)
          Positioned.fill(child: Container(color: Colors.white.withOpacity(0.3))),
          
          // 3. ප්‍රධාන Content එක
          SafeArea(
            child: _selectedNavIndex == 1 ? _buildStudyContent() : Center(child: Text("Page: $_selectedNavIndex")),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black45,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFB5B2FF).withOpacity(0.8), // ලාවට විනිවිද පේන ලෙස
        onTap: (i) {
          if (i == 4) { _showMoreMenu(); return; }
          if (i == 0) { Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => DashboardPage())); return; }
          if (i == 1) { setState(() => _selectedNavIndex = i); return; }
          if (i == 2) { Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const FinancePage())); return; }
          if (i == 3) { Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => WellnessPage())); return; }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.book_outlined), label: "Study"),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: "Finance"),
          BottomNavigationBarItem(icon: Icon(Icons.self_improvement), label: "Wellness"),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: "..."),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildStudyContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(15)),
          child: Row(children: [
            const Icon(Icons.lightbulb_outline, size: 40), const SizedBox(width: 15),
            Expanded(child: Text("Peak Focus Time : ${_backend.userData['peakTime']}\n${_backend.userData['focusMessage']}", style: const TextStyle(fontWeight: FontWeight.w600))),
          ]),
        ),
        const SizedBox(height: 30), _buildScheduleCard(), const SizedBox(height: 30), _buildFocusSubjectCard(),
        const SizedBox(height: 30), 
        GestureDetector(onTap: _showTimePickerDialog, child: Text(_backend.formattedTime, style: const TextStyle(fontSize: 65, fontWeight: FontWeight.bold))),
        const Text("Stay focused and achieve your goals!", style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () { _backend.toggleTimer(_updateUI, _updateUI); _updateUI(); },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.9), minimumSize: const Size(220, 45), shape: const StadiumBorder()),
          child: Text(_backend.isRunning ? "STOP SESSION" : "START FOCUS SESSION", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 15),
        TextButton(onPressed: _showWeeklyPlan, child: const Text("VIEW WEEKLY PLAN", style: TextStyle(color: Colors.black, decoration: TextDecoration.underline, fontWeight: FontWeight.bold))),
      ]),
    );
  }

  Widget _buildScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(15)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Today's Study Schedule", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(color: Colors.black),
        ...List.generate(_backend.schedule.length, (i) => ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Checkbox(
            value: _backend.schedule[i]['isDone'],
            activeColor: Colors.black,
            onChanged: (val) {
              setState(() => _backend.toggleTask(i));
            },
          ),
          title: Text("${_backend.schedule[i]['time']}  ${_backend.schedule[i]['task']}", style: const TextStyle(fontWeight: FontWeight.w500)),
          trailing: IconButton(icon: const Icon(Icons.edit, size: 16), onPressed: () => _editScheduleDialog(i)),
        )),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ElevatedButton.icon(
            onPressed: _addNewScheduleItem,
            icon: const Icon(Icons.add),
            label: const Text("Add New Schedule Item"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
          ),
        ),
      ]),
    );
  }

  Widget _buildFocusSubjectCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), border: Border.all(color: Colors.black38), borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(
              _backend.subjectName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: _editSubject),
        ]),
        const Text("High Priority", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text("Progress ${(_backend.progressValue * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold)),
        LinearProgressIndicator(value: _backend.progressValue, color: Colors.yellow[700], backgroundColor: Colors.white, minHeight: 8),
      ]),
    );
  }
}