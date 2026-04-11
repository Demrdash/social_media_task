import 'package:dio/dio.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../models/comment_model.dart';

class ApiService {
  final Dio _dio = Dio();

  // 1. Login
  Future<UserModel?> login(String username, String password) async {
    try {
      final response = await _dio.post(
        'https://dummyjson.com/auth/login',
        data: {'username': username, 'password': password},
      );
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      }
    } catch (e) {
      print("Login Error: $e");
    }
    return null;
  }

  // 2. Fetch User Profile (New)
  Future<UserModel?> getUserProfile(int userId) async {
    try {
      final response = await _dio.get('https://dummyjson.com/users/$userId');
      if (response.statusCode == 200) {
        var data = response.data;
        data['accessToken'] = ""; 
        return UserModel.fromJson(data);
      }
    } catch (e) {
      print("Profile Error: $e");
    }
    return null;
  }

  // 3. Fetch Posts
  Future<List<Post>> getPosts() async {
    try {
      final response = await _dio.get('https://jsonplaceholder.typicode.com/posts');
      return (response.data as List).map((item) => Post.fromJson(item)).toList();
    } catch (e) {
      throw Exception("Error fetching posts: $e");
    }
  }

  // 4. Fetch Comments
  Future<List<Comment>> getComments(int postId) async {
    try {
      final response = await _dio.get('https://jsonplaceholder.typicode.com/posts/$postId/comments');
      return (response.data as List).map((item) => Comment.fromJson(item)).toList();
    } catch (e) {
      throw Exception("Error fetching comments: $e");
    }
  }
}