import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  // دالة تسجيل الدخول
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners(); // بنقول للتطبيق "حدث نفسك"

    final user = await ApiService().login(username, password);
    
    if (user != null) {
      _user = user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', user.token);
      await prefs.setInt('userId', user.id); // حفظ الـ ID عشان نستخدمه في الـ Profile
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // جلب بيانات البروفايل
  Future<void> fetchProfile() async {
    if (_user != null) return;
    
    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId');
    
    if (userId != null) {
      _user = await ApiService().getUserProfile(userId);
      notifyListeners();
    }
  }

  // تسجيل الخروج
  void logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}