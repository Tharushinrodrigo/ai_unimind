import 'package:cloud_firestore/cloud_firestore.dart';

class WellnessBackend {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

 
  Future<void> saveMood({
    required String mood,
    required double value,
  }) async {
    try {
      await _db.collection('moods').add({
        'mood': mood,
        'value': value,
        'date': DateTime.now(),
      });
    } catch (e) {
      print("Error saving mood: $e");
    }
  }

  Stream<QuerySnapshot> getMoods() {
    return _db
        .collection('moods')
        .orderBy('date', descending: true)
        .snapshots();
  }


  Future<Map<String, double>> getWeeklyMoodData() async {
    Map<String, double> weeklyData = {
      "Mon": 0,
      "Tue": 0,
      "Wed": 0,
      "Thu": 0,
      "Fri": 0,
      "Sat": 0,
      "Sun": 0,
    };

    try {
      final snapshot = await _db.collection('moods').get();

      for (var doc in snapshot.docs) {
        DateTime date = (doc['date'] as Timestamp).toDate();
        String day = _getDayName(date.weekday);
        double value = (doc['value'] as num).toDouble();

        weeklyData[day] = value; // latest overwrite
      }
    } catch (e) {
      print("Error fetching weekly data: $e");
    }

    return weeklyData;
  }


  Future<List<Map<String, String>>> getSupportContacts() async {
    List<Map<String, String>> contacts = [];

    try {
      final snapshot =
          await _db.collection('support_contacts').get();

      for (var doc in snapshot.docs) {
        contacts.add({
          "name": doc['name'],
          "contact": doc['contact'],
        });
      }
    } catch (e) {
      print("Error fetching contacts: $e");
    }

    return contacts;
  }


  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return "Mon";
      case 2:
        return "Tue";
      case 3:
        return "Wed";
      case 4:
        return "Thu";
      case 5:
        return "Fri";
      case 6:
        return "Sat";
      case 7:
        return "Sun";
      default:
        return "";
    }
  }
}
