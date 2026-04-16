import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// كلاس صغير عشان يرضي ملف الـ Profile بتاعك
class UserData {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String image;

  UserData({required this.id, required this.email, required this.firstName, required this.lastName, required this.image});
}

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // تعديل الـ User getter عشان يرجع بيانات متوافقة مع الـ Profile بتاعك
  dynamic get user {
    User? fireUser = _auth.currentUser;
    if (fireUser == null) return null;
    
    // بنحول بيانات فايربيز لشكل يفهمه الـ Profile view بتاعك
    return UserData(
      id: fireUser.uid,
      email: fireUser.email ?? "",
      firstName: fireUser.displayName ?? "User",
      lastName: "",
      image: fireUser.photoURL ?? "https://via.placeholder.com/150",
    );
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', userCredential.user!.uid);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Error occurred";
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }

  Future<void> fetchProfile() async => notifyListeners();
}