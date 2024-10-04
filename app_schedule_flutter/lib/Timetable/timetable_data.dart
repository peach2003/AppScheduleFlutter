class Timetable {
  final int date;
  final String monthName;
  final String subjectName;
  final String dayName;
  final String time;

  Timetable(this.date,
      this.monthName,
      this.subjectName,
      this.dayName,
      this.time);
}

List<Timetable> timetable = [
  new Timetable(11, "JAN", "OOP", "Monday", "9:30am"),
  new Timetable(12, "JAN", "Phân tích thiết kế hệ thống thông tin", "Monday", "9:30am"),
  new Timetable(13, "JAN", "OOP", "Monday", "9:30am"),
  new Timetable(14, "JAN", "OOP", "Monday", "9:30am"),
  new Timetable(15, "JAN", "OOP", "Monday", "9:30am")
];