class AttendanceSession {
  final String id;

  final String teacherId;

  final String department;

  final int semester;

  final String section;

  final String subject;

  final String status;

  AttendanceSession({
    required this.id,
    required this.teacherId,
    required this.department,
    required this.semester,
    required this.section,
    required this.subject,
    required this.status,
  });

  factory AttendanceSession.fromJson(Map<String, dynamic> json) {
    return AttendanceSession(
      id: json["_id"],

      teacherId: json["teacherId"],

      department: json["department"],

      semester: json["semester"],

      section: json["section"],

      subject: json["subject"],

      status: json["status"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "teacherId": teacherId,
      "department": department,
      "semester": semester,
      "section": section,
      "subject": subject,
      "status": status,
    };
  }
}
