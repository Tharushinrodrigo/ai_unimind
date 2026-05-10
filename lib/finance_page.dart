import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; 
import 'finance_backend.dart';
import 'focus_page.dart' as focus;
import 'dashboard_page.dart';
import 'wellness_page.dart';
import 'ai_chatbot_page.dart';
import 'ai_assistant_page.dart';
import 'community_forum_page.dart';
import 'my_profile_page.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});
  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  final FinanceBackend _finBackend = FinanceBackend();
  int _currentIndex = 2;

  // --- Functions ---

  // 1. Expense එකක් Edit හෝ Delete කිරීම
  void _editExpenseDialog(String name, double amount) {
    TextEditingController nameCtrl = TextEditingController(text: name);
    TextEditingController amountCtrl = TextEditingController(text: amount.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: "Amount"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () { 
              setState(() => _finBackend.monthlyExpenses.remove(name)); 
              _finBackend.calculateTotals(); 
              Navigator.pop(context); 
            }, 
            child: const Text("Delete", style: TextStyle(color: Colors.red))
          ),
          ElevatedButton(
            onPressed: () { 
              setState(() { 
                _finBackend.monthlyExpenses.remove(name); 
                _finBackend.monthlyExpenses[nameCtrl.text] = double.tryParse(amountCtrl.text) ?? 0; 
                _finBackend.calculateTotals(); 
              }); 
              Navigator.pop(context); 
            }, 
            child: const Text("Save")
          ),
        ],
      ),
    );
  }

  // 2. අලුත් Expense එකක් එකතු කිරීම
  void _addExpenseDialog() {
    TextEditingController nameCtrl = TextEditingController();
    TextEditingController amountCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Expense Name")),
            TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: "Amount"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () { 
              setState(() { 
                _finBackend.monthlyExpenses[nameCtrl.text] = double.tryParse(amountCtrl.text) ?? 0; 
                _finBackend.calculateTotals(); 
              }); 
              Navigator.pop(context); 
            }, 
            child: const Text("Add")
          ),
        ],
      ),
    );
  }

  // 3. Savings Goal එක ඇතුළත් කිරීම
  void _setGoalsDialog() {
    TextEditingController goalCtrl = TextEditingController(text: _finBackend.savingsGoal.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set Savings Goal"),
        content: TextField(
          controller: goalCtrl, 
          decoration: const InputDecoration(labelText: "Goal Amount (RS)"), 
          keyboardType: TextInputType.number
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () { 
              setState(() { 
                _finBackend.savingsGoal = double.tryParse(goalCtrl.text) ?? 0; 
              }); 
              Navigator.pop(context); 
            }, 
            child: const Text("Set Goal")
          ),
        ],
      ),
    );
  }

  void _showPastExpenses() {
    DateTime now = DateTime.now();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFB5B2FF),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 350,
          child: Column(
            children: [
              const Text("Past 3 Months Expenses", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Divider(color: Colors.black26),
              Expanded(
                child: ListView.builder(
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    DateTime pastMonthDate = DateTime(now.year, now.month - index, 1);
                    String monthName = DateFormat('MMMM yyyy').format(pastMonthDate);
                    double simulatedValue = _finBackend.spentTotal * (1 - (index * 0.15));

                    return Card(
                      color: Colors.white.withOpacity(0.9),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.history, color: Colors.blueAccent),
                        title: Text(monthName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: Text("RS.${simulatedValue.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: Colors.black), child: const Text("Close", style: TextStyle(color: Colors.white))),
            ],
          ),
        );
      },
    );
  }

  void _editBudgetDialog(String key) {
    TextEditingController ctrl = TextEditingController(text: _finBackend.weeklyBudget[key].toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $key Budget"),
        content: TextField(controller: ctrl, keyboardType: TextInputType.number),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: () { setState(() { _finBackend.weeklyBudget[key] = double.tryParse(ctrl.text) ?? 0; _finBackend.calculateTotals(); }); Navigator.pop(context); }, child: const Text("Save")),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(leading: Icon(icon, color: Colors.black), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)), onTap: onTap);
  }

  @override
  Widget build(BuildContext context) {
    _finBackend.calculateTotals();
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: Builder(builder: (context) => IconButton(icon: const Icon(Icons.menu, color: Colors.black), onPressed: () => Scaffold.of(context).openDrawer())),
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          Image.asset('assets/images/logo.png', height: 40, errorBuilder: (c,e,s) => const Icon(Icons.psychology, size: 40)),
          const SizedBox(width: 10), const Text("FINANCE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ]),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.settings, color: Colors.black), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const MyProfilePage()))),
          Center(child: Padding(padding: const EdgeInsets.only(right: 10), child: Text(today, style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)))),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: const Color(0xFFB5B2FF),
          child: ListView(
            children: [
              const DrawerHeader(child: Text("UniMind", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
              _drawerItem(Icons.dashboard, "Dashboard", () { Navigator.pop(context); Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  DashboardPage())); }),
              _drawerItem(Icons.book, "Study Focus", () { Navigator.pop(context); Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>focus.FocusPage())); }),
                  _drawerItem(Icons.attach_money, "Finance", () { Navigator.pop(context); }),
              _drawerItem(Icons.self_improvement, "Wellness", () { Navigator.pop(context); Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WellnessPage())); }),
              _drawerItem(Icons.chat_bubble_outline, "AI Chatbot", () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context)=> const ChatPage ())); }),
              _drawerItem(Icons.smart_toy_outlined, "AI Assistant", () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const VoiceAssistantScreen())); }),
              _drawerItem(Icons.people_outline, "Community Forum", () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) =>  CommunityForumPage())); }),
              _drawerItem(Icons.person_outline, "My Profile", () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const MyProfilePage())); }),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/images/focus.png', fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: Colors.white.withOpacity(0.3))),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 16),
                  _buildWeeklyBudgetCard(),
                  const SizedBox(height: 16),
                  _buildTipCard(),
                  const SizedBox(height: 16),
                  _buildExpenseListCard(),
                  const SizedBox(height: 16),
                  _buildInsightsCard(),
                  const SizedBox(height: 20),
                  Row(children: [
                    Expanded(child: ElevatedButton(onPressed: _addExpenseDialog, style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.9), minimumSize: const Size(100, 45), shape: const StadiumBorder()), child: const Text("Add Expense", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))),
                    const SizedBox(width: 10),
                    Expanded(child: ElevatedButton(onPressed: _setGoalsDialog, style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.9), minimumSize: const Size(100, 45), shape: const StadiumBorder()), child: const Text("Set Goals", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildSummaryCard() {
    double total = _finBackend.salary > 0 ? _finBackend.salary : 1;
    double spentPercent = (_finBackend.spentTotal / total) * 100;
    double remainingPercent = ((_finBackend.salary - _finBackend.spentTotal) / total) * 100;
    return Card(
      color: Colors.white.withOpacity(0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const Text("Budget Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 15),
          SizedBox(height: 150, child: PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 40, sections: [
            PieChartSectionData(value: _finBackend.spentTotal, title: '${spentPercent.toStringAsFixed(0)}%', color: Colors.redAccent, radius: 50, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
            PieChartSectionData(value: (_finBackend.salary - _finBackend.spentTotal) > 0 ? (_finBackend.salary - _finBackend.spentTotal) : 0, title: '${remainingPercent.toStringAsFixed(0)}%', color: Colors.blueAccent, radius: 50, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          ]))),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [_indicator(Colors.redAccent, "Spent"), const SizedBox(width: 20), _indicator(Colors.blueAccent, "Remaining")]),
          const Divider(height: 25),
          _statRow("Salary", "RS.${_finBackend.salary}"),
          _statRow("Budgeted", "RS.${_finBackend.budgetTotal}"),
          _statRow("Spent", "RS.${_finBackend.spentTotal}", color: Colors.red),
        ]),
      ),
    );
  }

  Widget _indicator(Color color, String text) => Row(children: [Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: color)), const SizedBox(width: 5), Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))]);

  Widget _buildWeeklyBudgetCard() {
    return Card(
      color: Colors.white.withOpacity(0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const Text("Weekly Budget (Tap to Edit)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          ..._finBackend.weeklyBudget.entries.map((e) => Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(10)),
            child: ListTile(title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600)), trailing: Text("RS.${e.value}", style: const TextStyle(fontWeight: FontWeight.bold)), onTap: () => _editBudgetDialog(e.key)),
          )),
        ]),
      ),
    );
  }

  Widget _buildTipCard() => Card(color: Colors.amber[50]!.withOpacity(0.8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: ListTile(leading: const Icon(Icons.lightbulb, color: Colors.amber), title: Text(_finBackend.aiSuggestion, style: const TextStyle(fontWeight: FontWeight.bold))));

  // 4. Expense List Card එකේ item එකක් click කරලා edit කරන්න පුළුවන් කළා
  Widget _buildExpenseListCard() {
    return Card(
      color: Colors.white.withOpacity(0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        ListTile(
          title: const Text("Expense List", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), 
          trailing: TextButton(onPressed: _showPastExpenses, child: const Text("View Past", style: TextStyle(color: Colors.black, decoration: TextDecoration.underline, fontWeight: FontWeight.bold)))
        ),
        ..._finBackend.monthlyExpenses.entries.map((e) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600)), 
            trailing: Text("RS.${e.value}", style: const TextStyle(fontWeight: FontWeight.bold)), 
            onTap: () => _editExpenseDialog(e.key, e.value) // මෙතනින් Edit Dialog එක open වෙනවා
          ),
        )),
      ]),
    );
  }

  // 5. Financial Insights සම්පූර්ණ කළා
  Widget _buildInsightsCard() {
    double savings = _finBackend.salary - _finBackend.spentTotal;
    if (savings < 0) savings = 0;
    double progress = _finBackend.savingsGoal > 0 ? (savings / _finBackend.savingsGoal) : 0;
    if (progress > 1.0) progress = 1.0;

    return Card(
      color: Colors.white.withOpacity(0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const Text("Financial Insights", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          SizedBox(height: 180, child: BarChart(BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: _finBackend.salary * 1.2,
            barGroups: [
              BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: _finBackend.salary, color: Colors.blueAccent, width: 20, borderRadius: BorderRadius.circular(4))]),
              BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: _finBackend.budgetTotal, color: Colors.orangeAccent, width: 20, borderRadius: BorderRadius.circular(4))]),
              BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: _finBackend.spentTotal, color: Colors.redAccent, width: 20, borderRadius: BorderRadius.circular(4))]),
            ],
            titlesData: FlTitlesData(
              show: true, 
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 0: return const Text('Sal', style: TextStyle(fontSize: 10)); // Salary
                  case 1: return const Text('Bud', style: TextStyle(fontSize: 10)); // Budgeted
                  case 2: return const Text('Spn', style: TextStyle(fontSize: 10)); // Spent
                  default: return const Text('');
                }
              }))
            ),
          ))),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _indicator(Colors.blueAccent, "Salary"), const SizedBox(width: 10),
            _indicator(Colors.orangeAccent, "Budget"), const SizedBox(width: 10),
            _indicator(Colors.redAccent, "Spent"),
          ]),
          const SizedBox(height: 20),
          const Text("Savings Progress", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress, 
            color: Colors.green, 
            minHeight: 10, 
            backgroundColor: Colors.grey[300]
          ),
          const SizedBox(height: 10),
          Text("Goal: RS.${_finBackend.savingsGoal}", style: const TextStyle(fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  Widget _statRow(String label, String val, {Color color = Colors.black}) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label), Text(val, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15))]));

  Widget _buildBottomNav() => BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) {
        setState(() => _currentIndex = i);
        if (i == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardPage()));
        if (i == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => focus.FocusPage()));
        if (i == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WellnessPage()));
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFFB5B2FF).withOpacity(0.8),
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black45,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: "Dashboard"),
        BottomNavigationBarItem(icon: Icon(Icons.book_outlined), label: "Study"),
        BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: "Finance"),
        BottomNavigationBarItem(icon: Icon(Icons.self_improvement), label: "Wellness"),
        BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: "..."),
      ],
    );
}