class Subject {
  final String subid;
  final String subname;
  final int credit;


  Subject({required this.subid, required this.subname, required this.credit});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      subid: json['subid'] as String,
      subname: json['subname'] as String,
      credit: json['credit'] as int,
    );
  }
}