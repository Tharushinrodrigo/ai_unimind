import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';


import 'focus_page.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;

  File? _image;
  final picker = ImagePicker();

  bool notificationEnabled = true;
  bool partTimeEnabled = true;



  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error Picking Image : $e");
    }
  }



  void _showEditDialog(
    String title,
    String dbField,
    String currentValue,
  ) {
    TextEditingController controller =
        TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),

        title: Text("Edit $title"),

        content: TextField(
          controller: controller,

          decoration: InputDecoration(
            hintText: "Enter $title",

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        actions: [

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
            ),

            onPressed: () async {
              if (user != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .set({
                  dbField: controller.text,
                }, SetOptions(merge: true));

                if (mounted) {
                  Navigator.pop(context);
                }
              }
            },

            child: const Text(
              "Save",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("Please Login First"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFB9B7FF),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          Map<String, dynamic> userData =
              snapshot.data?.data() as Map<String, dynamic>? ??
                  {};

          return Container(
            width: double.infinity,

            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,

                colors: [
                  Color(0xFFB8B6FF),
                  Color(0xFFE8D8FF),
                  Colors.white,
                ],
              ),
            ),

            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 15,
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      // ================= HEADER =================

                      Row(
                        children: [

                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const FocusPage(),
                                ),
                              );
                            },

                            child: Container(
                              padding: const EdgeInsets.all(8),

                              decoration: BoxDecoration(
                                color:
                                    Colors.white.withOpacity(0.4),

                                borderRadius:
                                    BorderRadius.circular(12),
                              ),

                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                size: 22,
                              ),
                            ),
                          ),

                          const SizedBox(width: 20),

                          const Text(
                            "My Profile",

                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // ================= PROFILE =================

                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          GestureDetector(
                            onTap: _pickImage,

                            child: CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.white,

                              backgroundImage: _image != null
                                  ? FileImage(_image!)
                                  : null,

                              child: _image == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 45,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                          ),

                          const SizedBox(width: 15),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                // AUTO UPDATE NAME

                                Text(
                                  userData['name'] ??
                                      "User",

                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  user?.email ?? "",

                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                  ),
                                ),

                                const SizedBox(height: 15),

                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 10,
                                  ),

                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withOpacity(0.5),

                                    borderRadius:
                                        BorderRadius.circular(
                                            25),
                                  ),

                                  child: Text(
                                    userData['lifestyle'] ??
                                        "Female Student + Job",

                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight:
                                          FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 35),

                      // ================= PERSONAL INFO =================

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,

                        children: [

                          const Text(
                            "Personal Info",

                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const Text(
                            "Tap Any Field To Edit",

                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // NAME

                      _buildProfileTile(
                        title: "Name",
                        value:
                            userData['name'] ?? "Not Set",
                        dbField: "name",
                      ),

                      // GENDER

                      _buildProfileTile(
                        title: "Gender",
                        value:
                            userData['gender'] ?? "Not Set",
                        dbField: "gender",
                      ),

                      // AGE

                      _buildProfileTile(
                        title: "Age",
                        value:
                            userData['age'] ?? "Not Set",
                        dbField: "age",
                      ),

                      // VILLAGE

                      _buildProfileTile(
                        title: "Village",
                        value:
                            userData['village'] ?? "Not Set",
                        dbField: "village",
                      ),

                      // COUNTRY

                      _buildProfileTile(
                        title: "Country",
                        value:
                            userData['country'] ?? "Not Set",
                        dbField: "country",
                      ),

                      // RESIDENCE

                      _buildProfileTile(
                        title: "Residence",
                        value:
                            userData['residence'] ?? "Not Set",
                        dbField: "residence",
                      ),

                      // DEGREE

                      _buildProfileTile(
                        title: "Degree",
                        value:
                            userData['degree'] ?? "Not Set",
                        dbField: "degree",
                      ),

                      // UNIVERSITY TIME

                      _buildProfileTile(
                        title: "University Time",
                        value:
                            userData['uniTime'] ?? "Not Set",
                        dbField: "uniTime",
                      ),

                      // JOB

                      _buildProfileTile(
                        title: "Part Time Job",
                        value:
                            userData['job'] ?? "Not Set",
                        dbField: "job",
                      ),

                      // JOB TIME

                      _buildProfileTile(
                        title: "Part Time Working Hours",
                        value:
                            userData['jobTime'] ?? "2 h",
                        dbField: "jobTime",
                      ),

                      const SizedBox(height: 35),

                      // ================= PREFERENCES =================

                      const Text(
                        "Preferences",

                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(20),

                        decoration: BoxDecoration(
                          color:
                              Colors.white.withOpacity(0.35),

                          borderRadius:
                              BorderRadius.circular(28),
                        ),

                        child: Column(
                          children: [

                            // NOTIFICATIONS

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,

                              children: [

                                const Text(
                                  "Notification Preferences",

                                  style: TextStyle(
                                    fontSize: 17,
                                  ),
                                ),

                                Switch(
                                  value:
                                      notificationEnabled,

                                  onChanged: (value) {
                                    setState(() {
                                      notificationEnabled =
                                          value;
                                    });
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            // LIFESTYLE

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,

                              children: [

                                const Text(
                                  "Lifestyle",

                                  style: TextStyle(
                                    fontSize: 17,
                                  ),
                                ),

                                Row(
                                  children: [

                                    Text(
                                      userData['lifestyle'] ??
                                          "student + Job",

                                      style:
                                          const TextStyle(
                                        fontSize: 17,
                                      ),
                                    ),

                                    const SizedBox(width: 5),

                                    const Icon(
                                      Icons
                                          .arrow_forward_ios,
                                      size: 15,
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            // DAILY PART TIME AUTO UPDATE

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,

                              children: [

                                const Text(
                                  "Daily Part - Time",

                                  style: TextStyle(
                                    fontSize: 17,
                                  ),
                                ),

                                Row(
                                  children: [

                                    Text(
                                      userData['jobTime'] ??
                                          "2 h",

                                      style:
                                          const TextStyle(
                                        fontSize: 17,
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    Switch(
                                      value:
                                          partTimeEnabled,

                                      onChanged: (value) {
                                        setState(() {
                                          partTimeEnabled =
                                              value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= PROFILE TILE =================

  Widget _buildProfileTile({
    required String title,
    required String value,
    required String dbField,
  }) {
    return InkWell(
      onTap: () {
        _showEditDialog(
          title,
          dbField,
          value,
        );
      },

      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 18,
        ),

        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
        ),

        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,

          children: [

            Text(
              title,

              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),

            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,

                style: const TextStyle(
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
