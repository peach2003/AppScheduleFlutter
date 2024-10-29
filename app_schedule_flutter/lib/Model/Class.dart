class Class {
  final String claid;
  final String claname;
  final String facid;

  Class({required this.claid, required this.claname, required this.facid });

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      claid: json['claid'] as String,
      claname: json['claname'] as String,
      facid: json['facid'] as String,
    );
  }
}