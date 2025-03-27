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
    this.secret,
  });

  factory MemoList.fromJson(Map<String, dynamic> json) {
    return MemoList(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
      likeCnt: json['likeCnt'],
      hateCnt: json['hateCnt'],
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [], // 비어있는 경우 빈 리스트 반환
      secret: json.containsKey('secret') ? json['secret'] : null,
    );
  }
}
