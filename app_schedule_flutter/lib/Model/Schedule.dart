class Schedule {
  String scheid;
  String claid;
  String subid;
  String rooid;
  String daystart;
  String dayend;
  String timestart;
  String timeend;

  Schedule({
    required this.scheid,
    required this.claid,
    required this.subid,
    required this.rooid,
    required this.daystart,
    required this.dayend,
    required this.timestart,
    required this.timeend,
  });

  // Phương thức chuyển đổi từ Firebase snapshot
  factory Schedule.fromSnapshot(Map<dynamic, dynamic> snapshot) {
    return Schedule(
      scheid: snapshot['scheid'].toString(),
      claid: snapshot['claid'].toString(),
      subid: snapshot['subid'].toString(),
      rooid: snapshot['rooid'].toString(),
      daystart: snapshot['daystart'].toString(),
      dayend: snapshot['dayend'].toString(),
      timestart: snapshot['timestart'].toString(),
      timeend: snapshot['timeend'].toString(),
    );
  }
}
