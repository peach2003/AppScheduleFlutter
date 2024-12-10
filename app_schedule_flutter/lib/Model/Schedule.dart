class Schedule {
  final String claid;
  final String daystart;
  final String dayend;
  final String rooid;
  final String scheid;
  final String subid;
  final String weekday;
  final String timestart;
  final String timeend;

  Schedule({
    required this.claid,
    required this.daystart,
    required this.dayend,
    required this.rooid,
    required this.scheid,
    required this.subid,
    required this.weekday,
    required this.timestart,
    required this.timeend,
  });

  // Phương thức chuyển đổi từ Firebase snapshot
  factory Schedule.fromSnapshot(Map<dynamic, dynamic> snapshot) {
    return Schedule(
      scheid: snapshot['scheid']?.toString() ?? '',  // Đảm bảo rằng dữ liệu tồn tại và chuyển thành chuỗi
      claid: snapshot['claid']?.toString() ?? '',
      subid: snapshot['subid']?.toString() ?? '',
      rooid: snapshot['rooid']?.toString() ?? '',
      daystart: snapshot['daystart']?.toString() ?? '',
      dayend: snapshot['dayend']?.toString() ?? '',
      timestart: snapshot['timestart']?.toString() ?? '',
      timeend: snapshot['timeend']?.toString() ?? '',
      weekday: snapshot['weekday']?.toString() ?? '',  // Đảm bảo lấy giá trị của weekday nếu có
    );
  }


}
