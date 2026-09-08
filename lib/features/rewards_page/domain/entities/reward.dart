class Reward {
  final String id;
  final String imageUrl;
  final String title;
  final String description;
  final String? churchId;
  final String? chapterId;

  const Reward({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
    this.churchId,
    this.chapterId,
  });

  factory Reward.fromMap(String id, Map<String, dynamic> map) {
    return Reward(
      id: id,
      imageUrl: map['imageUrl'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      churchId: map['churchId'],
      chapterId: map['chapterId'],
    );
  }
}