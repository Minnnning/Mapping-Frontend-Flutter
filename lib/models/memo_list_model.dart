class MemoList {
  final int id;
  final String title;
  final String content;
  final String category;
  final int likeCnt;
  final int hateCnt;
  final List<String> images;
  final bool? secret;

  MemoList({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.likeCnt,
    required this.hateCnt,
    required this.images,
    this.secret = false,
  });

  factory MemoList.fromJson(Map<String, dynamic> json) {
    return MemoList(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      likeCnt: json['likeCnt'] as int,
      hateCnt: json['hateCnt'] as int,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      secret: json.containsKey('secret') && json['secret'] == true,
    );
  }
}
