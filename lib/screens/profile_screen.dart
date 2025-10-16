import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController bioController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isEditingBio = false;
  String bio = "Write about yourself here.....";
  bool notifications = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    bioController.text = bio;
    _loadUserData();
  }

  // Load user data from Firestore
  Future<void> _loadUserData() async {
    if (user == null) return;

    try {
      final userDoc = await _firestore.collection('users').doc(user!.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          bio = data['bio'] ?? "Write about yourself here.....";
          notifications = data['notifications'] ?? true;
          bioController.text = bio;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  // Save bio to Firestore
  Future<void> _saveBio() async {
    if (user == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      await _firestore.collection('users').doc(user!.uid).set({
        'bio': bioController.text.trim(),
        'notifications': notifications,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        bio = bioController.text.trim();
        isEditingBio = false;
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bio updated successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating bio: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Save notification preference
  Future<void> _saveNotificationPreference(bool value) async {
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user!.uid).set({
        'notifications': value,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        notifications = value;
      });
    } catch (e) {
      print('Error updating notification preference: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating preference'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getInitials(String email) {
    if (email.isEmpty || email == "No email") return "U";
    return email.substring(0, 1).toUpperCase();
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // User null check
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off,
                size: 80,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(height: 20),
              Text(
                "Please login to view profile",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Top Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Profile',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () {
                              // Settings functionality
                            },
                            icon: const Icon(Icons.settings),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Profile Picture & Info
                      Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Colors.blue, Colors.purple],
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    _getInitials(user?.email ?? "User"),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          Text(
                            // Fixed: Properly get user name from authProvider or Firebase user
                            user?.uid ??
                                user?.displayName ??
                                user?.email?.split('@')[0] ??
                                "Guest User",
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            'Task Master',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color,
                                ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // Stats Row - Fixed Implementation
                      StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection("users")
                            .doc(user!.uid)
                            .collection("tasks")
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                "Error loading stats",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            );
                          }

                          // Handle empty or no data state
                          final tasks = snapshot.hasData
                              ? snapshot.data!.docs
                              : [];
                          int total = tasks.length;
                          int completed = tasks.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return data['isCompleted'] == true;
                          }).length;
                          int pending = total - completed;

                          return Row(
                            children: [
                              _buildStatCard(
                                "Total",
                                "$total",
                                Icons.list_alt,
                                Colors.blue,
                              ),
                              const SizedBox(width: 10),
                              _buildStatCard(
                                "Completed",
                                "$completed",
                                Icons.check_circle,
                                Colors.green,
                              ),
                              const SizedBox(width: 10),
                              _buildStatCard(
                                "Pending",
                                "$pending",
                                Icons.pending_actions,
                                Colors.orange,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Bio Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bio',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  setState(() {
                                    isEditingBio = !isEditingBio;
                                    if (isEditingBio) {
                                      bioController.text = bio;
                                    }
                                  });
                                },
                          icon: const Icon(Icons.edit, size: 20),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    if (isEditingBio) ...[
                      TextField(
                        controller: bioController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Tell others about yourself...',
                          filled: true,
                          fillColor:
                              Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800]
                              : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: isLoading ? null : _saveBio,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: isLoading
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Save'),
                          ),

                          const SizedBox(width: 10),

                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    setState(() {
                                      isEditingBio = false;
                                      bioController.text =
                                          bio; // Reset to original
                                    });
                                  },
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        bio,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(height: 1.5),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Contact Information
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        const Icon(Icons.email, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            user?.email ?? "No email",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            user?.metadata.creationTime != null
                                ? "Joined on: ${user!.metadata.creationTime!.day}-${user!.metadata.creationTime!.month}-${user!.metadata.creationTime!.year}"
                                : "Joining date not available",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Settings/Preferences
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preferences',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        const Icon(Icons.notifications, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Notifications',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        Switch(
                          value: notifications,
                          onChanged: _saveNotificationPreference,
                          activeColor: Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    bioController.dispose();
    super.dispose();
  }
}
