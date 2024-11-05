class Teacher {
  final String teaid;
  final String teaname;
  final String email;
  final int phone;

  Teacher({required this.teaid, required this.teaname, required this.email, required this.phone});

  factory Teacher.fromSnapshot(Map<dynamic, dynamic> snapshot) {
    return Teacher(
      teaid: snapshot['teaid'] as String,
      teaname: snapshot['teaname'] as String,
      email: snapshot['email'] as String,
      phone: snapshot['phone'] as int,
    );
  }
}
