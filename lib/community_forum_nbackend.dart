import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityForumPage extends StatefulWidget {
  const CommunityForumPage({super.key});

  @override
  _CommunityForumPageState createState() => _CommunityForumPageState();
}

class _CommunityForumPageState extends State<CommunityForumPage> {
  String selectedCategory = "All";
  final List<String> categories = ["All", "Study", "Mental Health", "jobs"];
  final TextEditingController _postController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Backend Function: අලුත් Post එකක් Database එකට Save කිරීම ---
  Future<void> _addNewPost() async {
    if (_postController.text.trim().isNotEmpty) {
      String content = _postController.text.trim();
      String categoryToSave = selectedCategory == "All" ? "Study" : selectedCategory;
      
      _postController.clear(); // TextField එක clear කිරීම

      try {
        await _firestore.collection('forum_posts').add({
          "user": "Tharushi (You)", // මෙතනට පස්සේ Auth නම ගන්න පුළුවන්
          "time": FieldValue.serverTimestamp(), // Backend time එක ගන්න
          "category": categoryToSave,
          "content": content,
          "likes": 0,
          "comments": [],
        });
      } catch (e) {
        print("Error saving post: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0D7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Community Forum", style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          // Category Filtering Tabs
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                bool isSelected = selectedCategory == categories[index];
                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = categories[index]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: Text(
                      categories[index],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.blueAccent : Colors.black54,
                        decoration: isSelected ? TextDecoration.underline : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // --- Backend logic: Real-time Data Feed (StreamBuilder) ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: selectedCategory == "All"
                  ? _firestore.collection('forum_posts').orderBy('time', descending: true).snapshots()
                  : _firestore.collection('forum_posts')
                      .where('category', isEqualTo: selectedCategory)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No reviews found."));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return PostCard(doc: snapshot.data!.docs[index]);
                  },
                );
              },
            ),
          ),

          // Post Input Area (Enter Key එකෙන් Post වෙනවා)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _postController,
                    onSubmitted: (value) => _addNewPost(), // Enter key එකෙන් post වීම
                    decoration: InputDecoration(
                      hintText: "Review in $selectedCategory...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _addNewPost,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  const PostCard({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    var data = doc.data() as Map<String, dynamic>;
    List comments = data['comments'] ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data['user'], style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(data['content']),
          const Divider(),
          Row(
            children: [
              // Like Backend Update
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.redAccent),
                onPressed: () {
                  doc.reference.update({'likes': FieldValue.increment(1)});
                },
              ),
              Text("${data['likes']}"),
              const SizedBox(width: 20),
              const Icon(Icons.chat_bubble_outline, size: 18),
              const SizedBox(width: 5),
              Text("${comments.length}"),
            ],
          ),

          // --- Comments පෙන්වීම සහ අලුතින් Add කිරීම ---
          if (comments.isNotEmpty)
            ...comments.map((c) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text("• $c", style: const TextStyle(fontSize: 12, color: Colors.black54)),
            )),

          TextField(
            onSubmitted: (val) {
              if (val.trim().isNotEmpty) {
                // Backend: Array එකකට අලුත් comment එකක් එකතු කිරීම
                doc.reference.update({
                  'comments': FieldValue.arrayUnion([val.trim()])
                });
              }
            },
            decoration: const InputDecoration(
              hintText: "Add comment and press Enter...",
              hintStyle: TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}