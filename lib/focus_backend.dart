import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FocusBackend {
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const List<String> _dayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  String _getDayName(int weekday) => _dayNames[weekday - 1];

  String _formatDate(DateTime date) {
    return '${_monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }

  // Initialize SharedPreferences
  Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    await loadHistory();
    await loadTasks();
    await checkAndResetForNewDay();
    _isInitialized = true;
  }
  Map<String, dynamic> userData = {
    "peakTime": "6.00 - 8.00 pm",
    "focusMessage": "STUDY LIGHT SUBJECTS !",
  };

  List<Map<String, dynamic>> schedule = [
    {"time": "6.00 - 7.00", "task": "Database Systems", "isDone": false},
    {"time": "7.00 - 7.15", "task": "Rest", "isDone": false},
    {"time": "7.15 - 10.00", "task": "Final Project", "isDone": false},
  ];

  String subjectName = "Coding";
 
  double get progressValue {
    if (schedule.isEmpty) return 0.0;
    int completedCount = schedule.where((item) => item['isDone'] == true).length;
    return completedCount / schedule.length;
  }


  void toggleTask(int index) {
    schedule[index]['isDone'] = !schedule[index]['isDone'];
    saveTasks();
  }

  List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  // History data - loaded from storage
  List<Map<String, dynamic>> historyData = [];

  // Load history from storage
  Future<void> loadHistory() async {
    String? historyJson = _prefs.getString('focus_history');
    if (historyJson != null) {
      List<dynamic> decoded = json.decode(historyJson);
      historyData = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      // Default sample data if no stored data
      historyData = [
        {
          "date": "April 1, 2026",
          "day": "Wednesday",
          "doneWork": "Completed database assignment and reviewed project notes.",
          "notDoneWork": "Did not finish the final project presentation slides.",
          "tasks": [
            {"time": "6.00 - 7.00", "task": "Database Systems", "isDone": true},
            {"time": "7.00 - 7.15", "task": "Rest", "isDone": true},
            {"time": "7.15 - 10.00", "task": "Final Project", "isDone": false},
          ],
        },
        {
          "date": "March 31, 2026",
          "day": "Tuesday",
          "doneWork": "Finished coding the main module and wrote documentation.",
          "notDoneWork": "Did not start the testing phase.",
          "tasks": [
            {"time": "8.00 - 9.00", "task": "Coding", "isDone": true},
            {"time": "9.00 - 10.00", "task": "Documentation", "isDone": true},
          ],
        },
        {
          "date": "March 30, 2026",
          "day": "Monday",
          "doneWork": "Completed all assigned readings and started on homework.",
          "notDoneWork": "Did not finish the group project discussion.",
          "tasks": [
            {"time": "9.00 - 10.00", "task": "Reading", "isDone": true},
            {"time": "10.00 - 11.00", "task": "Homework", "isDone": true},
            {"time": "2.00 - 3.00", "task": "Group Project", "isDone": false},
          ],
        },
        {
          "date": "March 29, 2026",
          "day": "Sunday",
          "doneWork": "Rested and prepared meals for the week.",
          "notDoneWork": "Did not complete the weekend chores.",
          "tasks": [
            {"time": "10.00 - 11.00", "task": "Rest", "isDone": true},
            {"time": "11.00 - 12.00", "task": "Meal Prep", "isDone": true},
            {"time": "1.00 - 2.00", "task": "Chores", "isDone": false},
          ],
        },
        {
          "date": "March 28, 2026",
          "day": "Saturday",
          "doneWork": "Went for a run and cleaned the house.",
          "notDoneWork": "Did not finish organizing the closet.",
          "tasks": [
            {"time": "8.00 - 9.00", "task": "Exercise", "isDone": true},
            {"time": "9.00 - 10.00", "task": "Cleaning", "isDone": true},
            {"time": "11.00 - 12.00", "task": "Organizing", "isDone": false},
          ],
        },
        {
          "date": "March 27, 2026",
          "day": "Friday",
          "doneWork": "Finished the week's assignments and relaxed.",
          "notDoneWork": "Did not review for the upcoming exam.",
          "tasks": [
            {"time": "4.00 - 5.00", "task": "Assignments", "isDone": true},
            {"time": "5.00 - 6.00", "task": "Relax", "isDone": true},
            {"time": "7.00 - 8.00", "task": "Exam Review", "isDone": false},
          ],
        },
        {
          "date": "March 26, 2026",
          "day": "Thursday",
          "doneWork": "Attended all classes and completed lab work.",
          "notDoneWork": "Did not finish the research paper outline.",
          "tasks": [
            {"time": "9.00 - 12.00", "task": "Classes", "isDone": true},
            {"time": "1.00 - 2.00", "task": "Lab Work", "isDone": true},
            {"time": "3.00 - 4.00", "task": "Research Paper", "isDone": false},
          ],
        },
        {
          "date": "March 25, 2026",
          "day": "Wednesday",
          "doneWork": "Worked on the project and studied math.",
          "notDoneWork": "Did not complete the physics homework.",
          "tasks": [
            {"time": "10.00 - 11.00", "task": "Project Work", "isDone": true},
            {"time": "11.00 - 12.00", "task": "Math Study", "isDone": true},
            {"time": "2.00 - 3.00", "task": "Physics Homework", "isDone": false},
          ],
        },
        {
          "date": "March 24, 2026",
          "day": "Tuesday",
          "doneWork": "Completed coding exercises and attended meeting.",
          "notDoneWork": "Did not finish the report.",
          "tasks": [
            {"time": "8.00 - 9.00", "task": "Coding", "isDone": true},
            {"time": "9.00 - 10.00", "task": "Meeting", "isDone": true},
            {"time": "11.00 - 12.00", "task": "Report", "isDone": false},
          ],
        },
        {
          "date": "March 23, 2026",
          "day": "Monday",
          "doneWork": "Started the week with planning and reading.",
          "notDoneWork": "Did not complete the assignment.",
          "tasks": [
            {"time": "9.00 - 10.00", "task": "Planning", "isDone": true},
            {"time": "10.00 - 11.00", "task": "Reading", "isDone": true},
            {"time": "1.00 - 2.00", "task": "Assignment", "isDone": false},
          ],
        },
        {
          "date": "March 22, 2026",
          "day": "Sunday",
          "doneWork": "Rested and did some light exercise.",
          "notDoneWork": "Did not finish the book I was reading.",
          "tasks": [
            {"time": "10.00 - 11.00", "task": "Rest", "isDone": true},
            {"time": "11.00 - 12.00", "task": "Exercise", "isDone": true},
            {"time": "2.00 - 3.00", "task": "Reading Book", "isDone": false},
          ],
        },
        {
          "date": "March 21, 2026",
          "day": "Saturday",
          "doneWork": "Went shopping and cooked dinner.",
          "notDoneWork": "Did not clean the garage.",
          "tasks": [
            {"time": "10.00 - 11.00", "task": "Shopping", "isDone": true},
            {"time": "12.00 - 1.00", "task": "Cooking", "isDone": true},
            {"time": "3.00 - 4.00", "task": "Garage Cleaning", "isDone": false},
          ],
        },
        {
          "date": "March 20, 2026",
          "day": "Friday",
          "doneWork": "Finished work early and socialized.",
          "notDoneWork": "Did not prepare for the weekend trip.",
          "tasks": [
            {"time": "9.00 - 5.00", "task": "Work", "isDone": true},
            {"time": "6.00 - 7.00", "task": "Socializing", "isDone": true},
            {"time": "8.00 - 9.00", "task": "Trip Prep", "isDone": false},
          ],
        },
        {
          "date": "March 19, 2026",
          "day": "Thursday",
          "doneWork": "Completed all tasks on time.",
          "notDoneWork": "Did not attend the optional seminar.",
          "tasks": [
            {"time": "8.00 - 9.00", "task": "Task 1", "isDone": true},
            {"time": "9.00 - 10.00", "task": "Task 2", "isDone": true},
            {"time": "4.00 - 5.00", "task": "Seminar", "isDone": false},
          ],
        },
        {
          "date": "March 18, 2026",
          "day": "Wednesday",
          "doneWork": "Studied hard and completed exercises.",
          "notDoneWork": "Did not finish the essay.",
          "tasks": [
            {"time": "10.00 - 11.00", "task": "Study", "isDone": true},
            {"time": "11.00 - 12.00", "task": "Exercises", "isDone": true},
            {"time": "2.00 - 3.00", "task": "Essay", "isDone": false},
          ],
        },
        {
          "date": "March 17, 2026",
          "day": "Tuesday",
          "doneWork": "Attended classes and worked on project.",
          "notDoneWork": "Did not complete the quiz.",
          "tasks": [
            {"time": "9.00 - 12.00", "task": "Classes", "isDone": true},
            {"time": "1.00 - 2.00", "task": "Project", "isDone": true},
            {"time": "3.00 - 4.00", "task": "Quiz", "isDone": false},
          ],
        },
        {
          "date": "March 16, 2026",
          "day": "Monday",
          "doneWork": "Organized schedule and started assignments.",
          "notDoneWork": "Did not finish the reading.",
          "tasks": [
            {"time": "8.00 - 9.00", "task": "Organize", "isDone": true},
            {"time": "9.00 - 10.00", "task": "Assignments", "isDone": true},
            {"time": "11.00 - 12.00", "task": "Reading", "isDone": false},
          ],
        },
        {
          "date": "March 15, 2026",
          "day": "Sunday",
          "doneWork": "Rested and spent time with family.",
          "notDoneWork": "Did not go for a walk.",
          "tasks": [
            {"time": "10.00 - 11.00", "task": "Rest", "isDone": true},
            {"time": "12.00 - 1.00", "task": "Family Time", "isDone": true},
            {"time": "3.00 - 4.00", "task": "Walk", "isDone": false},
          ],
        },
        {
          "date": "March 14, 2026",
          "day": "Saturday",
          "doneWork": "Did household chores and relaxed.",
          "notDoneWork": "Did not finish the DIY project.",
          "tasks": [
            {"time": "9.00 - 10.00", "task": "Chores", "isDone": true},
            {"time": "11.00 - 12.00", "task": "Relax", "isDone": true},
            {"time": "2.00 - 3.00", "task": "DIY Project", "isDone": false},
          ],
        },
        {
          "date": "March 13, 2026",
          "day": "Friday",
          "doneWork": "Completed work tasks and planned weekend.",
          "notDoneWork": "Did not call friends.",
          "tasks": [
            {"time": "9.00 - 5.00", "task": "Work Tasks", "isDone": true},
            {"time": "6.00 - 7.00", "task": "Planning", "isDone": true},
            {"time": "8.00 - 9.00", "task": "Call Friends", "isDone": false},
          ],
        },
        {
          "date": "March 12, 2026",
          "day": "Thursday",
          "doneWork": "Studied subjects and did practice problems.",
          "notDoneWork": "Did not attend the club meeting.",
          "tasks": [
            {"time": "10.00 - 11.00", "task": "Study", "isDone": true},
            {"time": "11.00 - 12.00", "task": "Practice", "isDone": true},
            {"time": "4.00 - 5.00", "task": "Club Meeting", "isDone": false},
          ],
        },
        {
          "date": "March 11, 2026",
          "day": "Wednesday",
          "doneWork": "Worked on assignments and reviewed notes.",
          "notDoneWork": "Did not complete the lab report.",
          "tasks": [
            {"time": "9.00 - 10.00", "task": "Assignments", "isDone": true},
            {"time": "10.00 - 11.00", "task": "Review Notes", "isDone": true},
            {"time": "2.00 - 3.00", "task": "Lab Report", "isDone": false},
          ],
        },
        {
          "date": "March 10, 2026",
          "day": "Tuesday",
          "doneWork": "Attended lectures and took notes.",
          "notDoneWork": "Did not finish the group discussion.",
          "tasks": [
            {"time": "9.00 - 12.00", "task": "Lectures", "isDone": true},
            {"time": "1.00 - 2.00", "task": "Notes", "isDone": true},
            {"time": "3.00 - 4.00", "task": "Group Discussion", "isDone": false},
          ],
        },
        {
          "date": "March 9, 2026",
          "day": "Monday",
          "doneWork": "Started the week strong with planning.",
          "notDoneWork": "Did not complete the warm-up exercises.",
          "tasks": [
            {"time": "8.00 - 9.00", "task": "Planning", "isDone": true},
            {"time": "9.00 - 10.00", "task": "Task 1", "isDone": true},
            {"time": "10.00 - 11.00", "task": "Warm-up", "isDone": false},
          ],
        },
        {
          "date": "March 8, 2026",
          "day": "Sunday",
          "doneWork": "Rested and prepared for the week.",
          "notDoneWork": "Did not finish the weekly review.",
          "tasks": [
            {"time": "10.00 - 11.00", "task": "Rest", "isDone": true},
            {"time": "12.00 - 1.00", "task": "Preparation", "isDone": true},
            {"time": "3.00 - 4.00", "task": "Weekly Review", "isDone": false},
          ],
        },
        {
          "date": "March 7, 2026",
          "day": "Saturday",
          "doneWork": "Did errands and exercised.",
          "notDoneWork": "Did not complete the home improvement task.",
          "tasks": [
            {"time": "9.00 - 10.00", "task": "Errands", "isDone": true},
            {"time": "11.00 - 12.00", "task": "Exercise", "isDone": true},
            {"time": "2.00 - 3.00", "task": "Home Improvement", "isDone": false},
          ],
        },
        {
          "date": "March 6, 2026",
          "day": "Friday",
          "doneWork": "Finished all work and relaxed.",
          "notDoneWork": "Did not plan the next week.",
          "tasks": [
            {"time": "9.00 - 5.00", "task": "Work", "isDone": true},
            {"time": "6.00 - 7.00", "task": "Relax", "isDone": true},
            {"time": "8.00 - 9.00", "task": "Planning", "isDone": false},
          ],
        },
        {
          "date": "March 5, 2026",
          "day": "Thursday",
          "doneWork": "Completed studies and attended meetings.",
          "notDoneWork": "Did not finish the presentation.",
          "tasks": [
            {"time": "10.00 - 11.00", "task": "Studies", "isDone": true},
            {"time": "11.00 - 12.00", "task": "Meetings", "isDone": true},
            {"time": "2.00 - 3.00", "task": "Presentation", "isDone": false},
          ],
        },
        {
          "date": "March 4, 2026",
          "day": "Wednesday",
          "doneWork": "Worked on projects and learned new skills.",
          "notDoneWork": "Did not complete the tutorial.",
          "tasks": [
            {"time": "9.00 - 10.00", "task": "Projects", "isDone": true},
            {"time": "10.00 - 11.00", "task": "Learning", "isDone": true},
            {"time": "1.00 - 2.00", "task": "Tutorial", "isDone": false},
          ],
        },
        {
          "date": "March 3, 2026",
          "day": "Tuesday",
          "doneWork": "Attended classes and collaborated.",
          "notDoneWork": "Did not finish the assignment.",
          "tasks": [
            {"time": "9.00 - 12.00", "task": "Classes", "isDone": true},
            {"time": "1.00 - 2.00", "task": "Collaboration", "isDone": true},
            {"time": "3.00 - 4.00", "task": "Assignment", "isDone": false},
          ],
        },
        {
          "date": "March 2, 2026",
          "day": "Monday",
          "doneWork": "Organized tasks and started work.",
          "notDoneWork": "Did not complete the initial setup.",
          "tasks": [
            {"time": "8.00 - 9.00", "task": "Organize", "isDone": true},
            {"time": "9.00 - 10.00", "task": "Work", "isDone": true},
            {"time": "10.00 - 11.00", "task": "Setup", "isDone": false},
          ],
        },
        {
          "date": "March 1, 2026",
          "day": "Sunday",
          "doneWork": "Rested and reflected on the month.",
          "notDoneWork": "Did not start the new goals.",
          "tasks": [
            {"time": "10.00 - 11.00", "task": "Rest", "isDone": true},
            {"time": "12.00 - 1.00", "task": "Reflection", "isDone": true},
            {"time": "3.00 - 4.00", "task": "Goals", "isDone": false},
          ],
        },
      ];
      await saveHistory();
    }
  }

  // Load current tasks from storage
  Future<void> loadTasks() async {
    String? tasksJson = _prefs.getString('current_tasks');
    if (tasksJson != null) {
      List<dynamic> decoded = json.decode(tasksJson);
      schedule = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }
  }

  // Save current tasks to storage
  Future<void> saveTasks() async {
    String tasksJson = json.encode(schedule);
    await _prefs.setString('current_tasks', tasksJson);
  }

  // Check if it's a new day and reset tasks accordingly
  Future<void> checkAndResetForNewDay() async {
    String? lastDate = _prefs.getString('last_date');
    String currentDate = _formatDate(DateTime.now());

    if (lastDate != null && lastDate != currentDate) {
      // It's a new day, migrate yesterday's tasks to history
      DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
      String yesterdayDate = _formatDate(yesterday);
      String yesterdayDay = _getDayName(yesterday.weekday);

      // Add yesterday's tasks to history
      addDayToHistory(yesterdayDate, yesterdayDay, List<Map<String, dynamic>>.from(schedule));

      // Clear today's schedule for new day
      schedule.clear();
      await saveTasks();
    }

    // Update last date
    await _prefs.setString('last_date', currentDate);
  }

  // Save history to storage
  Future<void> saveHistory() async {
    String historyJson = json.encode(historyData);
    await _prefs.setString('focus_history', historyJson);
  }

  // Computed weekly progress from last 7 days of history
  List<double> get weeklyProgress {
    List<double> progresses = [];
    for (int i = 0; i < 7 && i < historyData.length; i++) {
      progresses.add(calculateDailyProgress(i));
    }
    while (progresses.length < 7) {
      progresses.add(0.0);
    }
    return progresses;
  }

  int seconds = 1500;
  Timer? timer;
  bool isRunning = false;

  String get formattedTime {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return "${mins.toString().padLeft(2, '0')} : ${secs.toString().padLeft(2, '0')}";
  }

  void toggleTimer(Function onTick, Function onComplete) {
    if (isRunning) {
      timer?.cancel();
      isRunning = false;
    } else {
      isRunning = true;
      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (seconds > 0) {
          seconds--;
          onTick();
        } else {
          t.cancel();
          isRunning = false;
          onComplete();
        }
      });
    }
  }

  void setTimer(int minutes) => seconds = minutes * 60;

  void updateSchedule(int index, String time, String task) {
    schedule[index] = {"time": time, "task": task, "isDone": false};
    saveTasks();
  }

  void addScheduleItem(String time, String task) {
    schedule.add({"time": time, "task": task, "isDone": false});
    saveTasks();
  }

  void removeScheduleItem(int index) {
    schedule.removeAt(index);
    saveTasks();
  }

  void updateSubject(String name, double progress) {
    subjectName = name;
  }

  // History methods
  double calculateDailyProgress(int dayIndex) {
    List tasks = historyData[dayIndex]['tasks'];
    if (tasks.isEmpty) return 0.0;
    int completedCount = tasks.where((item) => item['isDone'] == true).length;
    return completedCount / tasks.length;
  }

  void toggleHistoryTask(int dayIndex, int taskIndex) {
    historyData[dayIndex]['tasks'][taskIndex]['isDone'] = 
        !historyData[dayIndex]['tasks'][taskIndex]['isDone'];
    saveHistory();
  }

  void updateHistoryTask(int dayIndex, int taskIndex, String newTime, String newTask) {
    historyData[dayIndex]['tasks'][taskIndex]['time'] = newTime;
    historyData[dayIndex]['tasks'][taskIndex]['task'] = newTask;
    saveHistory();
  }

  void updateDailyWork(int dayIndex, String doneWork, String notDoneWork) {
    historyData[dayIndex]['doneWork'] = doneWork;
    historyData[dayIndex]['notDoneWork'] = notDoneWork;
    saveHistory();
  }

  void addDayToHistory(String date, String day, List<Map<String, dynamic>> tasks, {String doneWork = '', String notDoneWork = ''}) {
    historyData.insert(0, {
      "date": date,
      "day": day,
      "doneWork": doneWork,
      "notDoneWork": notDoneWork,
      "tasks": tasks,
    });
    saveHistory();
  }

  // Cleanup history older than 3 months
  void cleanupOldHistory() {
    DateTime now = DateTime.now();
    DateTime threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
    
    historyData.removeWhere((entry) {
      // Parse date string like "April 1, 2026"
      String dateStr = entry['date'];
      List<String> parts = dateStr.split(' ');
      if (parts.length < 3) return false;
      String monthStr = parts[0];
      int day = int.tryParse(parts[1].replaceAll(',', '')) ?? 1;
      int year = int.tryParse(parts[2]) ?? now.year;
      
      Map<String, int> months = {
        'January': 1, 'February': 2, 'March': 3, 'April': 4, 'May': 5, 'June': 6,
        'July': 7, 'August': 8, 'September': 9, 'October': 10, 'November': 11, 'December': 12
      };
      int month = months[monthStr] ?? 1;
      
      DateTime entryDate = DateTime(year, month, day);
      return entryDate.isBefore(threeMonthsAgo);
    });
    saveHistory();
  }
}
