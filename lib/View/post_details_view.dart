import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../services/api_service.dart';

class PostDetailsView extends StatelessWidget {
  final Post post;
  const PostDetailsView({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final ApiService apiService = ApiService();

    return Scaffold(
      appBar: AppBar(title: const Text("Post Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Section
            Text(post.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 10),
            Text(post.body, style: const TextStyle(fontSize: 16)),
            const Divider(height: 40),
            const Text("Comments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            // Comments Section
            FutureBuilder<List<Comment>>(
              future: apiService.getComments(post.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text("Error loading comments: ${snapshot.error}");
                } else {
                  final comments = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true, // مهم جداً داخل الـ Column
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(comments[index].email, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          subtitle: Text(comments[index].body),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}