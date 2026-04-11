import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/post_model.dart';
import 'post_details_view.dart';
import 'profile_view.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  final ApiService _apiService = ApiService();
  List<Post> _allPosts = []; // القائمة الأصلية
  List<Post> _filteredPosts = []; // القائمة المفلترة
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController(); // للتحكم في نص البحث

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      final posts = await _apiService.getPosts();
      setState(() {
        _allPosts = posts;
        _filteredPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching posts: $e")),
        );
      }
    }
  }

  void _filterPosts(String query) {
    setState(() {
      _filteredPosts = _allPosts
          .where((post) => post.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Social Feed", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileView()),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: TextField(
              controller: _searchController,
              onChanged: _filterPosts,
              decoration: InputDecoration(
                hintText: "Search posts by title...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          _filterPosts("");
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                fillColor: Colors.grey[100],
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredPosts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off, size: 60, color: Colors.grey),
                      const SizedBox(height: 10),
                      const Text("No posts found!", style: TextStyle(fontSize: 18, color: Colors.grey)),
                      TextButton(onPressed: () => _loadData(), child: const Text("Refresh")),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredPosts.length,
                  itemBuilder: (context, index) {
                    final post = _filteredPosts[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PostDetailsView(post: post)),
                            ),
                            leading: CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              child: Text(post.id.toString(), style: const TextStyle(color: Colors.white)),
                            ),
                            title: Text(
                              post.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                            ),
                          ),
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Added to favorites"), duration: Duration(milliseconds: 500)),
                                    );
                                  },
                                  icon: const Icon(Icons.favorite_border, color: Colors.red),
                                  label: const Text("Like", style: TextStyle(color: Colors.black87)),
                                ),
                                TextButton.icon(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => PostDetailsView(post: post)),
                                  ),
                                  icon: const Icon(Icons.comment_outlined, color: Colors.blue),
                                  label: const Text("Comment", style: TextStyle(color: Colors.black87)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}