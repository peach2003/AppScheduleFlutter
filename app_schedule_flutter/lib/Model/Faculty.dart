class Faculty {
  final String facid;
  final String facname;

  Faculty({required this.facid, required this.facname});

  // Phương thức chuyển từ Map (JSON) thành FacultyModel
  factory Faculty.fromJson(Map<String, dynamic> json) {
    return Faculty(
      facid: json['facid'] as String,
      facname: json['facname'] as String,
    );
  }
}
