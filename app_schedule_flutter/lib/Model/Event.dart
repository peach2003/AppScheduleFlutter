class Event {
  String? event_id;
  String title;
  String content;
  String image;
  DateTime createdAt;
  String link;

  Event({
    this.event_id,
    required this.title,
    required this.content,
    required this.image,
    required this.createdAt,
    required this.link,
  });

  // Chuyển đổi đối tượng từ Firebase Snapshot sang Event
  factory Event.fromSnapshot(Map<dynamic, dynamic> snapshot) {
    // Kiểm tra nếu title là null, cung cấp giá trị mặc định
    String eventTitle = snapshot['title'] != null && snapshot['title'].toString().isNotEmpty
        ? snapshot['title'] as String
        : 'No Title Available';

    return Event(
      event_id: snapshot['event_id'] != null ? snapshot['event_id'] as String : 'Unknown Event ID',
      title: eventTitle,  // Sử dụng biến đã kiểm tra null
      content: snapshot['content'] != null ? snapshot['content'] as String : 'No Content Available',
      image: snapshot['image'] != null ? snapshot['image'] as String : 'No Image Available',
      createdAt: snapshot['created_at'] != null
          ? DateTime.parse(snapshot['created_at'])
          : DateTime.now(),
      link: snapshot['link'] != null ? snapshot['link'] as String : 'No link Available',
    );
  }

  // Chuyển đối tượng Event thành JSON
  Map<String, dynamic> toJson() {
    return {
      'event_id': event_id,
      'title': title,
      'content': content,
      'image': image,
      'created_at': createdAt.toIso8601String(),
      'link': link,
    };
  }
}
