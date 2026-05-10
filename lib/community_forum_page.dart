import 'package:flutter/material.dart';

class CommunityForumPage extends StatefulWidget {
  const CommunityForumPage({super.key});

  @override
  _CommunityForumPageState createState() => _CommunityForumPageState();
}

class _CommunityForumPageState extends State<CommunityForumPage> {
  String selectedCategory = "All";
  final List<String> categories = ["All", "Study", "Mental Health", "jobs"];
  final TextEditingController _postController = TextEditingController();

  // Reviews list එකට Mental Health සහ Jobs add කළා
  List<Map<String, dynamic>> posts = [
    {
      "user": "Tharushi (You)",
      "time": "10.00 AM",
      "category": "Study",
      "content": "Anyone have effective focus tips for studying when stressed?",
      "likes": 20,
      "isLiked": false,
      "comments": ["Try deep breathing!", "Take 5 min breaks."],
    },
    {
      "user": "Maleesha",
      "time": "10.00 AM",
      "category": "Mental Health",
      "content": "Meditation helped me a lot during final exams. Highly recommend!",
      "likes": 12,
      "isLiked": false,
      "comments": ["Agree!", "How long do you meditate?"],
    },
    {
      "user": "Kasun",
      "time": "09.30 AM",
      "category": "jobs",
      "content": "Tips for getting an internship in the aviation industry?",
      "likes": 15,
      "isLiked": false,
      "comments": ["Focus on AMOS software knowledge.", "Update your LinkedIn profile."],
    },
  ];

  // Aluth post එකක් add කරන function එක
  void _addNewPost() {
    if (_postController.text.isNotEmpty) {
      setState(() {
        posts.insert(0, {
          "user": "Tharushi (You)",
          "time": "Just now",
          "category": selectedCategory == "All" ? "Study" : selectedCategory,
          "content": _postController.text,
          "likes": 0,
          "isLiked": false,
          "comments": [],
        });
        _postController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List filteredPosts = selectedCategory == "All"
        ? posts
        : posts.where((p) => p['category'] == selectedCategory).toList();

    return Scaffold(
      backgroundColor: Color(0xFFE0D7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Community Forum", style: TextStyle(color: Colors.black)),
        actions: [IconButton(icon: Icon(Icons.search, color: Colors.black), onPressed: () {})],
      ),
      body: Column(
        children: [
          // Category Tabs
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = categories[index];
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      categories[index],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: selectedCategory == categories[index] ? Colors.blue : Colors.black54,
                        decoration: selectedCategory == categories[index] ? TextDecoration.underline : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Post Feed
          Expanded(
            child: ListView.builder(
              itemCount: filteredPosts.length,
              itemBuilder: (context, index) {
                return PostCard(post: filteredPosts[index]);
              },
            ),
          ),

          // Post Input Area
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _postController,
                      onSubmitted: (value) => _addNewPost(), // Enter click කළොත් post වෙනවා
                      decoration: InputDecoration(
                        hintText: "Write a review in $selectedCategory...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.blue),
                    onPressed: _addNewPost,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  const PostCard({super.key, required this.post});

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool showComments = false;
  final TextEditingController _commentController = TextEditingController();

  void _addComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        widget.post['comments'].add(_commentController.text);
        _commentController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: Colors.blue[100], child: Icon(Icons.person, color: Colors.blue)),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.post['user'], style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("${widget.post['category']} • ${widget.post['time']}", style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(widget.post['content'], style: TextStyle(fontSize: 15)),
          SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    widget.post['isLiked'] = !widget.post['isLiked'];
                    widget.post['isLiked'] ? widget.post['likes']++ : widget.post['likes']--;
                  });
                },
                child: Row(
                  children: [
                    Icon(widget.post['isLiked'] ? Icons.favorite : Icons.favorite_border, color: widget.post['isLiked'] ? Colors.red : Colors.black54),
                    SizedBox(width: 5),
                    Text("${widget.post['likes']}"),
                  ],
                ),
              ),
              SizedBox(width: 25),
              GestureDetector(
                onTap: () => setState(() => showComments = !showComments),
                child: Row(
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 20),
                    SizedBox(width: 5),
                    Text("${widget.post['comments'].length} Comments"),
                  ],
                ),
              ),
            ],
          ),
          
          // Comment Section
          if (showComments) ...[
            Divider(),
            ...widget.post['comments'].map<Widget>((c) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text("• $c", style: TextStyle(color: Colors.black87)),
            )).toList(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(hintText: "Add a comment...", hintStyle: TextStyle(fontSize: 12)),
                    onSubmitted: (v) => _addComment(),
                  ),
                ),
                IconButton(icon: Icon(Icons.check, size: 20), onPressed: _addComment),
              ],
            )
          ]
        ],
      ),
    );
  }
}