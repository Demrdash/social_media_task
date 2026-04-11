class Post {
  final int id;
  final int userId; // أضفنا هذا الحقل
  final String title;
  final String body;

  Post({
    required this.id, 
    required this.userId, // أضفناه هنا أيضاً
    required this.title, 
    required this.body
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      userId: json['userId'] as int, // تأكد من جلب القيمة من الـ JSON
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}