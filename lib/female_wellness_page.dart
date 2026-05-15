import 'package:flutter/material.dart';

class FemaleWellnessPage extends StatefulWidget {
  final String userName;
  final String currentMood;

  const FemaleWellnessPage({
    super.key,
    required this.userName,
    required this.currentMood,
  });

  @override
  State<FemaleWellnessPage> createState() => _FemaleWellnessPageState();
}

class _FemaleWellnessPageState extends State<FemaleWellnessPage> {

  final Map<String, Map<String, String>> moodData = {
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

  final List<Map<String, dynamic>> yogaExercises = [
    {
      'name': 'Mountain Pose (Tadasana)',
      'desc': 'Improves posture and focus.',
      'steps': ['Stand with feet together.', 'Distribute weight evenly.', 'Lift your chest and roll shoulders back.', 'Breathe deeply.']
    },
    {
      'name': 'Tree Pose (Vrikshasana)',
      'desc': 'Enhances balance and stability.',
      'steps': ['Stand tall.', 'Shift weight to one foot.', 'Place the other foot on your inner thigh or calf.', 'Bring hands to prayer position.']
    },
    {
      'name': 'Downwards Dog (Adho Mukha)',
      'desc': 'Stretches the entire body.',
      'steps': ['Start on hands and knees.', 'Lift your hips toward the ceiling.', 'Straighten legs and reach heels toward floor.', 'Relax your neck.']
    },
    {
      'name': 'Warrior II (Virabhadrasana)',
      'desc': 'Builds strength and stamina.',
      'steps': ['Step feet wide apart.', 'Turn one foot out 90 degrees.', 'Bend that knee over the ankle.', 'Stretch arms out to the sides.']
    },
    {
      'name': 'Child’s Pose (Balasana)',
      'desc': 'Relieves stress and anxiety.',
      'steps': ['Kneel on the floor.', 'Sit back on your heels.', 'Fold forward and rest your forehead on the floor.', 'Extend arms forward.']
    },
    {
      'name': 'Cat-Cow Pose (Marjaryasana)',
      'desc': 'Improves spine flexibility.',
      'steps': ['Start on all fours.', 'Inhale, drop your belly and look up (Cow).', 'Exhale, arch your back and tuck chin (Cat).', 'Repeat slowly.']
    },
    {
      'name': 'Cobra Pose (Bhujangasana)',
      'desc': 'Strengthens the spine and chest.',
      'steps': ['Lie face down.', 'Place hands under shoulders.', 'Inhale and gently lift your chest off the floor.', 'Keep elbows close to body.']
    },
    {
      'name': 'Bridge Pose (Setu Bandha)',
      'desc': 'Opens the heart and reduces fatigue.',
      'steps': ['Lie on your back with knees bent.', 'Place feet flat on the floor.', 'Lift your hips toward the ceiling.', 'Interlace hands under your back.']
    },
    {
      'name': 'Plank Pose (Phalakasana)',
      'desc': 'Tones the core and arms.',
      'steps': ['Start in a push-up position.', 'Keep body in a straight line.', 'Engage your core muscles.', 'Hold and breathe.']
    },
    {
      'name': 'Corpse Pose (Savasana)',
      'desc': 'Total relaxation for mind and body.',
      'steps': ['Lie flat on your back.', 'Arms at your sides, palms up.', 'Close your eyes.', 'Relax every muscle and breathe naturally.']
    },
  ];

  String moodMessage = "";
  String insightMessage = "";
  String yogaMessage = "";
  String waterMessage = "";
  String breakTime = ""; 

  @override
  void initState() {
    super.initState();
    _updateMoodDetails();
  }

  void _updateMoodDetails() {
    final data = moodData[widget.currentMood] ?? moodData['Happy']!;
    setState(() {
      moodMessage = data['message']!;
      insightMessage = data['nutrition']!;
      yogaMessage = data['yoga']!;
      waterMessage = data['water']!;
      breakTime = data['break_time']!; 
    });
  }

  void _showStepByStep(Map<String, dynamic> exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(exercise['name'], style: const TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("How to do it:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...((exercise['steps'] as List).map((step) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text("• $step"),
                ))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Got it!", style: TextStyle(color: Colors.pink))),
        ],
      ),
    );
  }

  void _showYogaList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              const Text("10 Essential Yoga Exercises", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
              const Text("Click on any exercise to see steps", style: TextStyle(fontSize: 12, color: Colors.grey)),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: yogaExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = yogaExercises[index];
                    return ListTile(
                      onTap: () => _showStepByStep(exercise),
                      leading: CircleAvatar(backgroundColor: Colors.pink[50], child: Text("${index + 1}", style: const TextStyle(color: Colors.pink))),
                      title: Text(exercise['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(exercise['desc']!),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.pinkAccent),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildUserGreeting(),
                      const SizedBox(height: 20),
                      _buildInfoCard(
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/girl_avatar.png',
                              height: 60,
                              errorBuilder: (c, e, s) => const Icon(Icons.face, size: 50, color: Colors.pink),
                            ),
                            const SizedBox(width: 15),
                            Expanded(child: Text(moodMessage, style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic))),
                          ],
                        ),
                      ),
                      
                     
                      _buildInfoCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Take a Break.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text("Take a short break now.", style: TextStyle(fontSize: 12, color: Colors.black54)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 19, 18, 18).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                breakTime, 
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 9, 9, 9))
                              ),
                            ),
                          ],
                        ),
                      ),

                      _buildInfoCard(title: "Nutrition Insight", child: Text(insightMessage)),
                      
                      _buildInfoCard(
                        title: "Yoga Suggestion",
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(yogaMessage),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: _showYogaList,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.pinkAccent.withOpacity(0.8),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    ),
                                    child: const Text("Yoga Exercise", style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Image.asset(
                                'assets/images/yoga_pose.png', 
                                height: 80,
                                fit: BoxFit.contain,
                                errorBuilder: (c, e, s) => const Icon(Icons.self_improvement, size: 60, color: Colors.black26),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      _buildInfoCard(title: "Hydration Goal", child: Text(waterMessage)),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
          Text("${widget.currentMood} Care Plan", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Icon(Icons.favorite, color: Colors.pinkAccent),
        ],
      ),
    );
  }

  Widget _buildUserGreeting() {
    return Row(
      children: [
        const CircleAvatar(radius: 35, backgroundColor: Colors.white, child: Icon(Icons.person, size: 40, color: Colors.pinkAccent)),
        const SizedBox(width: 15),
        Text("Hello ${widget.userName} 👋", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildInfoCard({String? title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(color: Colors.black12),
          ],
          child,
        ],
      ),
    );
  }
}
