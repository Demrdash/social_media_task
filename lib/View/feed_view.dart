import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/post_model.dart';
import '../constants/app_colors.dart';
import 'post_details_view.dart';
import 'profile_view.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  final ApiService _apiService = ApiService();
  List<Post> _allPosts = [];
  List<Post> _filteredPosts = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final Map<int, bool> _likedPosts = {};
  final Map<int, int> _likeCount = {};

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
        // Initialize like counts
        for (var post in posts) {
          _likeCount[post.id] = (post.id % 100) + 15;
        }
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
      if (query.isEmpty) {
        _filteredPosts = _allPosts;
      } else {
        _filteredPosts = _allPosts
            .where((post) =>
                post.title.toLowerCase().contains(query.toLowerCase()) ||
                post.body.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleLike(int postId) {
    setState(() {
      if (_likedPosts[postId] ?? false) {
        _likedPosts[postId] = false;
        _likeCount[postId] = (_likeCount[postId] ?? 0) - 1;
      } else {
        _likedPosts[postId] = true;
        _likeCount[postId] = (_likeCount[postId] ?? 0) + 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text(
          "Social Feed",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileView()),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: CustomScrollView(
                slivers: [
                  // Search Bar
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    elevation: 0,
                    backgroundColor: AppColors.background,
                    toolbarHeight: 70,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _filterPosts,
                          decoration: InputDecoration(
                            hintText: "ما الذي تبحث عنه؟",
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Stories Section
                  SliverToBoxAdapter(
                    child: _buildStoriesSection(),
                  ),

                  // Posts List
                  _filteredPosts.isEmpty
                      ? SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: AppColors.textLight,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "لا توجد بوستات",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => _loadData(),
                                  child: const Text("تحديث"),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final post = _filteredPosts[index];
                              final isLiked = _likedPosts[post.id] ?? false;
                              final likes = _likeCount[post.id] ?? 0;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(
                                      color: AppColors.border,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Post Header
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 24,
                                              backgroundColor:
                                                  AppColors.primary,
                                              child: Text(
                                                "${post.userId}",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                children: [
                                                  Text(
                                                    "User ${post.userId}",
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColors
                                                          .textPrimary,
                                                    ),
                                                  ),
                                                  const Text(
                                                    "منذ ساعات",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: AppColors
                                                          .textLight,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.more_horiz,
                                              ),
                                              color: AppColors.textSecondary,
                                              onPressed: () {},
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Post Content
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: GestureDetector(
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PostDetailsView(
                                                post: post,
                                              ),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                post.title,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors
                                                      .textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                post.body,
                                                maxLines: 4,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: AppColors
                                                      .textPrimary,
                                                  height: 1.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      // Stats
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryLight,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.favorite,
                                                    size: 14,
                                                    color: AppColors.error,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '$likes',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: AppColors
                                                          .primary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Spacer(),
                                            GestureDetector(
                                              onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PostDetailsView(
                                                    post: post,
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                "45 تعليقات",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors
                                                      .textSecondary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 12),
                                      const Divider(
                                        height: 1,
                                        color: AppColors.border,
                                      ),

                                      // Action Buttons
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: InkWell(
                                                onTap: () =>
                                                    _toggleLike(post.id),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    vertical: 12,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        isLiked
                                                            ? Icons.favorite
                                                            : Icons
                                                                .favorite_outline,
                                                        size: 20,
                                                        color: isLiked
                                                            ? AppColors.error
                                                            : AppColors
                                                                .textSecondary,
                                                      ),
                                                      const SizedBox(
                                                        width: 8,
                                                      ),
                                                      Text(
                                                        "إعجاب",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: isLiked
                                                              ? AppColors
                                                                  .error
                                                              : AppColors
                                                                  .textSecondary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: InkWell(
                                                onTap: () =>
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            PostDetailsView(
                                                          post: post,
                                                        ),
                                                      ),
                                                    ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    vertical: 12,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .comment_outlined,
                                                        size: 20,
                                                        color: AppColors
                                                            .textSecondary,
                                                      ),
                                                      const SizedBox(
                                                        width: 8,
                                                      ),
                                                      const Text(
                                                        "تعليق",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: AppColors
                                                              .textSecondary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: InkWell(
                                                onTap: () {},
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    vertical: 12,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.share_outlined,
                                                        size: 20,
                                                        color: AppColors
                                                            .textSecondary,
                                                      ),
                                                      const SizedBox(
                                                        width: 8,
                                                      ),
                                                      const Text(
                                                        "مشاركة",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: AppColors
                                                              .textSecondary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            childCount: _filteredPosts.length,
                          ),
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildStoriesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 0.5,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            // Add Story Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                width: 80,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border,
                    width: 0.5,
                  ),
                  color: AppColors.background,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "قصتك",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Sample Stories
            ...[1, 2, 3, 4, 5].map(
              (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Container(
                  width: 80,
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://picsum.photos/100/140?random=$index',
                      ),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(
                      color: AppColors.secondary,
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$index',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.5),
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            'Story $index',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}