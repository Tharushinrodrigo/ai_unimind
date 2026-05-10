import 'package:flutter/material.dart';
import 'focus_backend.dart';

class FocusHistoryPage extends StatefulWidget {
  const FocusHistoryPage({super.key});

  @override
  State<FocusHistoryPage> createState() => _FocusHistoryPageState();
}

class _FocusHistoryPageState extends State<FocusHistoryPage> {
  final FocusBackend _backend = FocusBackend();
  late Future<List<Map<String, dynamic>>> _historyFuture;

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> _dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  String _getDayName(int weekday) => _dayNames[weekday - 1];

  @override
  void initState() {
    super.initState();
    _historyFuture = _initAndLoadHistory();
  }

  Future<List<Map<String, dynamic>>> _initAndLoadHistory() async {
    await _backend.init();
    _backend.cleanupOldHistory();
    return _backend.historyData;
  }

  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split(' ');
    if (parts.length < 3) return DateTime.now();
    final month = _monthNames.indexOf(parts[0]) + 1;
    final day = int.tryParse(parts[1].replaceAll(',', '')) ?? 1;
    final year = int.tryParse(parts[2]) ?? DateTime.now().year;
    return DateTime(year, month, day);
  }

  String _monthKey(String dateStr) {
    final parts = dateStr.split(' ');
    return parts.length >= 3 ? '${parts[0]} ${parts[2]}' : dateStr;
  }

  int _getWeekOfMonth(int day) {
    return (day - 1) ~/ 7 + 1;
  }

  Map<String, Map<int, List<Map<String, dynamic>>>> _groupByMonthAndWeek(List<Map<String, dynamic>> history) {
    final grouped = <String, Map<int, List<Map<String, dynamic>>>>{};
    for (var entry in history) {
      final monthKey = _monthKey(entry['date'] as String);
      final parts = (entry['date'] as String).split(' ');
      final day = int.tryParse(parts[1].replaceAll(',', '')) ?? 1;
      final week = _getWeekOfMonth(day);
      grouped.putIfAbsent(monthKey, () => {}).putIfAbsent(week, () => []).add(entry);
    }
    return grouped;
  }

  void _editHistoryTask(int dayIndex, int taskIndex) {
    final taskCtrl = TextEditingController(
      text: _backend.historyData[dayIndex]['tasks'][taskIndex]['task'],
    );
    final timeCtrl = TextEditingController(
      text: _backend.historyData[dayIndex]['tasks'][taskIndex]['time'],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Past Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: timeCtrl,
              decoration: const InputDecoration(labelText: 'Time'),
            ),
            TextField(
              controller: taskCtrl,
              decoration: const InputDecoration(labelText: 'Task'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _backend.updateHistoryTask(dayIndex, taskIndex, timeCtrl.text, taskCtrl.text);
              });
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _editDailyWork(int dayIndex, String doneWork, String notDoneWork) {
    final doneCtrl = TextEditingController(text: doneWork);
    final notDoneCtrl = TextEditingController(text: notDoneWork);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Daily Work Summary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: doneCtrl,
              decoration: const InputDecoration(labelText: 'Done Work'),
              maxLines: 3,
            ),
            TextField(
              controller: notDoneCtrl,
              decoration: const InputDecoration(labelText: 'Not Done Work'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _backend.updateDailyWork(dayIndex, doneCtrl.text, notDoneCtrl.text);
              });
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Weekly History',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading history'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No history available for the last 3 months.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          }

          final history = List<Map<String, dynamic>>.from(snapshot.data!);
          history.sort((a, b) => _parseDate(b['date'] as String).compareTo(_parseDate(a['date'] as String)));
          final groupedHistory = _groupByMonthAndWeek(history);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: groupedHistory.entries.map((monthEntry) {
              final monthTitle = monthEntry.key;
              final weeks = monthEntry.value;
              final weekWidgets = <Widget>[];
              weeks.forEach((weekNum, weekHistory) {
                weekHistory.sort((a, b) => _parseDate(b['date'] as String).compareTo(_parseDate(a['date'] as String)));
                final parts = monthTitle.split(' ');
                final monthName = parts[0];
                final year = int.parse(parts[1]);
                final monthIndex = _monthNames.indexOf(monthName) + 1;
                final lastDay = DateTime(year, monthIndex + 1, 0).day;
                final dateToEntry = <String, Map<String, dynamic>>{};
                for (var entry in weekHistory) {
                  dateToEntry[entry['date'] as String] = entry;
                }
                final dayWidgets = <Widget>[];
                final startDay = (weekNum - 1) * 7 + 1;
                final endDay = weekNum * 7 > lastDay ? lastDay : weekNum * 7;
                for (int day = endDay; day >= startDay; day--) {
                  final dateStr = "${_monthNames[monthIndex-1]} $day, $year";
                  final dayName = _getDayName(DateTime(year, monthIndex, day).weekday);
                  if (dateToEntry.containsKey(dateStr)) {
                    final entry = dateToEntry[dateStr]!;
                    final dayIndex = _backend.historyData.indexOf(entry);
                    final progress = _backend.calculateDailyProgress(dayIndex);
                    final tasks = List<Map<String, dynamic>>.from(entry['tasks'] as List<dynamic>);
                    final completedTasks = tasks.where((task) => task['isDone'] == true).toList();
                    final incompleteTasks = tasks.where((task) => task['isDone'] != true).toList();
                    dayWidgets.add(
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ExpansionTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$dateStr - $dayName',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    '${(progress * 100).toInt()}% complete',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: Colors.grey[200],
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          children: [
                            if (completedTasks.isNotEmpty)
                              const Padding(
                                padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                                child: Text(
                                  'Completed Tasks',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ...completedTasks.map((task) {
                              final taskIndex = tasks.indexOf(task);
                              return ListTile(
                                leading: const Icon(Icons.check_circle, color: Colors.green),
                                title: Text(task['task']),
                                subtitle: Text(task['time']),
                                trailing: IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 20),
                                  onPressed: () => _editHistoryTask(dayIndex, taskIndex),
                                ),
                              );
                            }),
                            if (incompleteTasks.isNotEmpty)
                              const Padding(
                                padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                                child: Text(
                                  'Incomplete Tasks',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            ...incompleteTasks.map((task) {
                              final taskIndex = tasks.indexOf(task);
                              return ListTile(
                                leading: const Icon(Icons.radio_button_unchecked, color: Colors.orange),
                                title: Text(task['task']),
                                subtitle: Text(task['time']),
                                trailing: IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 20),
                                  onPressed: () => _editHistoryTask(dayIndex, taskIndex),
                                ),
                              );
                            }),
                            if (completedTasks.isEmpty && incompleteTasks.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'No tasks recorded for this day.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            const Padding(
                              padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                              child: Text(
                                'Done Work',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                entry['doneWork'] ?? '',
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => _editDailyWork(dayIndex, entry['doneWork'] ?? '', entry['notDoneWork'] ?? ''),
                                child: const Text('Edit Work Summary'),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                              child: Text(
                                'Not Done Work',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                entry['notDoneWork'] ?? '',
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    dayWidgets.add(
                      Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text(
                            '$dateStr - $dayName',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: const Text(
                            'No tasks recorded for this day.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    );
                  }
                }
                weekWidgets.add(
                  ExpansionTile(
                    title: Text(
                      'Week $weekNum (${_monthNames[monthIndex-1]} $startDay - $endDay, $year)',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    children: dayWidgets,
                  ),
                );
              });
              return ExpansionTile(
                title: Text(
                  monthTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                children: weekWidgets,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
