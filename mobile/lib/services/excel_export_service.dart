import 'dart:io';

import 'package:excel/excel.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class ExcelExportService {
  Future<void> exportAttendance({
    required String subject,
    required int semester,
    required String section,
    required List<dynamic> students,
  }) async {
    try {


      final excel = Excel.createExcel();
      final sheet = excel['Attendance'];

      // Header
      sheet.appendRow([
        TextCellValue("Roll No"),
        TextCellValue("Enrollment ID"),
        TextCellValue("Student Name"),
        TextCellValue("Department"),
        TextCellValue("Semester"),
        TextCellValue("Section"),
        TextCellValue("Status"),
      ]);

      // Student Data
      for (final student in students) {

        sheet.appendRow([
          TextCellValue(student["rollNo"]?.toString() ?? ""),
          TextCellValue(student["enrollmentId"]?.toString() ?? ""),
          TextCellValue(student["name"]?.toString() ?? ""),
          TextCellValue(student["department"]?.toString() ?? ""),
          IntCellValue(student["semester"] ?? 0),
          TextCellValue(student["section"]?.toString() ?? ""),
          TextCellValue(student["status"]?.toString() ?? "Present"),
        ]);
      }

      final directory = await getApplicationDocumentsDirectory();


      final file = File(
        "${directory.path}/Attendance_${subject}_Sem${semester}_$section.xlsx",
      );

      final bytes = excel.encode();

      if (bytes == null) {

        return;
      }

      await file.writeAsBytes(bytes, flush: true);


      final result = await OpenFilex.open(file.path);


    } catch (e, stackTrace) {



    }
  }
}
