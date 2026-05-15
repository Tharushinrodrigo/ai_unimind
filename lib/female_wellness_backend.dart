
class WellnessBackend {

  final Map<String, Map<String, String>> moodDatabase = {
    'Happy': {
      'message': 'Keep that beautiful smile! Your energy is contagious today.',
      'nutrition': 'Enjoy some colorful berries to maintain your high energy.',
      'yoga': 'Dancer Pose (Natarajasana) for balance and joy.',
      'water': 'Infuse your water with fresh mint for a refreshing kick.',
      'break_time': '15.00',
    },
    'Sad': {
      'message': 'It is okay to feel this way. Be gentle with yourself today.',
      'nutrition': 'Warm oatmeal with walnuts can be very comforting.',
      'yoga': 'Child’s Pose (Balasana) for deep relaxation and peace.',
      'water': 'Sip on warm herbal tea to soothe your soul.',
      'break_time': '20.00',
    },
    'Stressed': {
      'message': 'Take a deep breath. Let that heat transform into strength.',
      'nutrition': 'Crunchy vegetables like carrots can help release tension.',
      'yoga': 'Thunderbolt Pose (Vajrasana) to calm your nervous system.',
      'water': 'Cool cucumber water will help lower your inner heat.',
      'break_time': '10.00',
    },
    'Neutral': {
      'message': 'Focus on your breath. You are safe and you are grounded.',
      'nutrition': 'A handful of almonds can help stabilize your mood.',
      'yoga': 'Tree Pose (Vrikshasana) to find your center and focus.',
      'water': 'Drink plain water slowly to ground your senses.',
      'break_time': '12.00',
    },
    'Tired': {
      'message': 'Your body needs rest. Listen to it and recharge.',
      'nutrition': 'Banana and peanut butter for a steady energy boost.',
      'yoga': 'Legs-Up-The-Wall (Viparita Karani) to restore energy.',
      'water': 'Ice-cold water can give your system a quick wake-up call.',
      'break_time': '30.00',
    },
  };

  String currentMessage = "";
  String currentNutrition = "";
  String currentYoga = "";
  String currentWater = "";
  String currentBreakTime = "";

 
  void updateWellnessPlan(String mood) {
 
    var data = moodDatabase[mood] ?? moodDatabase['Neutral']!;

    currentMessage = data['message']!;
    currentNutrition = data['nutrition']!;
    currentYoga = data['yoga']!;
    currentWater = data['water']!;
    currentBreakTime = data['break_time']!;
  }

 
  String getAiWellnessAdvice(String mood) {
    if (mood == 'Stressed' || mood == 'Tired') {
      return "AI Notice: Your stress levels seem high. Prioritize your $currentBreakTime mins break.";
    } else if (mood == 'Happy') {
      return "AI Notice: You're in a great state! It's a perfect time for a focused workout.";
    } else {
      return "AI Notice: Staying hydrated is the best way to maintain your current balance.";
    }
  }
}
