class Room{
  final String rooid;
  final String rooname;

  Room({required this.rooid, required this.rooname});

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      rooid: json['rooid'] as String,
      rooname: json['rooname'] as String,
    );
  }
}