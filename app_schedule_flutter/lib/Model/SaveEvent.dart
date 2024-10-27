class SaveEvent {
  String? saveEventId;
  String userId;
  String eventId;
  String? note; // Optional field
  bool status;

  SaveEvent({
    this.saveEventId,
    required this.userId,
    required this.eventId,
    this.note, // Không bắt buộc
    required this.status,
  });

  // Tạo đối tượng từ Firebase Snapshot
  factory SaveEvent.fromSnapshot(Map<dynamic, dynamic> snapshot) {
    return SaveEvent(
      saveEventId: snapshot['saveEventId'],
      userId: snapshot['userId'],
      eventId: snapshot['eventId'],
      note: snapshot['note'],
      status: snapshot['status'] == 1, // Chuyển đổi giá trị thành boolean
    );
  }

  // Chuyển đối tượng SaveEvent thành JSON
  Map<String, dynamic> toJson() {
    return {
      'saveEventId': saveEventId,
      'userId': userId,
      'eventId': eventId,
      'note': note ?? '', // Nếu không có ghi chú thì để rỗng
      'status': status ? 1:0,
    };
  }
}
