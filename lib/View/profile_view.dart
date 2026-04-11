import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/post_model.dart';
import 'login_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              auth.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
                (route) => false,
              );
            },
          )
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // قسم بيانات المستخدم
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(user.image),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${user.firstName} ${user.lastName}",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(user.email, style: const TextStyle(color: Colors.grey)),
                  const Divider(height: 40),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "My Posts",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  FutureBuilder<List<Post>>(
                    future: _apiService.getPosts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      } else {
                        final myPosts = snapshot.data!
                            .where((post) => post.userId == user.id)
                            .toList();

                        if (myPosts.isEmpty) {
                          return const Text("You haven't posted anything yet.");
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: myPosts.length,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                              child: ListTile(
                                title: Text(myPosts[index].title, 
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                subtitle: Text(myPosts[index].body, maxLines: 1),
                                leading: const Icon(Icons.article_outlined),
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