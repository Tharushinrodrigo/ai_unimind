class FocusBackend {
  // ... ඔයාගේ පරණ variables (userData, schedule, seconds ආදිය) මෙතන තියෙනවා

  // 1. History එක සඳහා දත්ත ගබඩාව (List of Maps)
  List<Map<String, dynamic>> historyData = [
    {
      "date": "April 1, 2026",
      "day": "Wednesday",
      "tasks": [
        {"time": "6.00 - 7.00", "task": "Database Systems", "isDone": true},
        {"time": "7.00 - 7.15", "task": "Rest", "isDone": true},
        {"time": "7.15 - 10.00", "task": "Final Project", "isDone": false},
      ]
    },
    {
      "date": "March 31, 2026",
      "day": "Tuesday",
      "tasks": [
        {"time": "8.00 - 9.00", "task": "Coding", "isDone": true},
        {"time": "9.00 - 10.00", "task": "Documentation", "isDone": true},
      ]
    }
  ];

  // 2. දවසක Progress එක ගණනය කරන Function එක
  double calculateDailyProgress(int dayIndex) {
    List tasks = historyData[dayIndex]['tasks'];
    if (tasks.isEmpty) return 0.0;
    int completedCount = tasks.where((item) => item['isDone'] == true).length;
    return completedCount / tasks.length;
  }

  // 3. පරණ Task එකක Status එක (isDone) මාරු කරන Function එක
  void toggleHistoryTask(int dayIndex, int taskIndex) {
    historyData[dayIndex]['tasks'][taskIndex]['isDone'] = 
        !historyData[dayIndex]['tasks'][taskIndex]['isDone'];
  }

  // 4. පරණ Task එකක් Edit කරන Function එක
  void updateHistoryTask(int dayIndex, int taskIndex, String newTime, String newTask) {
    historyData[dayIndex]['tasks'][taskIndex]['time'] = newTime;
    historyData[dayIndex]['tasks'][taskIndex]['task'] = newTask;
  }

  // 5. අලුත් දවසක History එකක් එකතු කිරීම (උදා: දවස අවසානයේදී)
  void addDayToHistory(String date, String day, List<Map<String, dynamic>> tasks) {
    historyData.insert(0, {
      "date": date,
      "day": day,
      "tasks": tasks,
    });
  }
}