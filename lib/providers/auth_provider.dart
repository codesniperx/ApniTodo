import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  String? userName;
  String? profilePicUrl;
  DateTime? createdAt;

  User? get user => _user;

  // 🔹 Constructor: Listen for auth changes
  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (_user != null) {
        fetchUserData(); // always fetch user profile data
      } else {
        _clearLocalData();
      }
      notifyListeners();
    });
  }

  // 🔹 Sign Up
  Future<String?> signUp(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      _user = userCredential.user;

      if (_user != null) {
        await _firestore.collection("users").doc(_user!.uid).set({
          "uid": _user!.uid,
          "username": name,
          "email": email,
          "profilePicUrl": null,
          "createdAt": FieldValue.serverTimestamp(),
        });

        userName = name;
        profilePicUrl = null;
        notifyListeners();
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // 🔹 Sign In
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await fetchUserData(); // 👈 after login fetch profile
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // 🔹 Fetch user data
  Future<void> fetchUserData() async {
    if (_user == null) return;

    final doc = await _firestore.collection('users').doc(_user!.uid).get();
    if (doc.exists) {
      userName = doc['username'];
      profilePicUrl = doc['profilePicUrl'];
      if (doc['createdAt'] != null) {
        createdAt = (doc['createdAt'] as Timestamp).toDate();
      }
      notifyListeners();
    }
  }

  // 🔹 Add task
  Future<void> addTask(String title, String description) async {
    if (_user == null) return;

    final taskRef = _firestore
        .collection('users')
        .doc(_user!.uid)
        .collection('tasks')
        .doc();

    await taskRef.set({
      'id': taskRef.id,
      'title': title,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending', // default status
    });
  }

  // 🔹 Get task counts
  Future<Map<String, int>> getTaskCounts() async {
    if (_user == null) return {"total": 0, "pending": 0, "completed": 0};

    final snapshot = await _firestore
        .collection('users')
        .doc(_user!.uid)
        .collection('tasks')
        .get();

    int total = snapshot.docs.length;
    int pending = snapshot.docs
        .where((doc) => doc['status'] == 'pending')
        .length;
    int completed = snapshot.docs
        .where((doc) => doc['status'] == 'completed')
        .length;

    return {"total": total, "pending": pending, "completed": completed};
  }

  // 🔹 Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    _clearLocalData();
    notifyListeners();
  }

  // 🔹 Reset local provider state
  void _clearLocalData() {
    _user = null;
    userName = null;
    profilePicUrl = null;
    createdAt = null;
  }
}
