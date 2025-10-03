class UserPost {
  final String title;
  final String caption;
  final String imagePath;

  UserPost({
    required this.title,
    required this.caption,
    required this.imagePath,
  });
}

// List global untuk simpan postingan user
List<UserPost> userPosts = [];
