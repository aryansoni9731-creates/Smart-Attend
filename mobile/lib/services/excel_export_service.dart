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
      print("========== EXCEL EXPORT STARTED ==========");
      print("Students Count: ${students.length}");

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
        print(student);

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

      print("Directory:");
      print(directory.path);

      final file = File(
        "${directory.path}/Attendance_${subject}_Sem${semester}_${section}.xlsx",
      );

      final bytes = excel.encode();

      if (bytes == null) {
        print("Excel encode returned null");
        return;
      }

      await file.writeAsBytes(bytes, flush: true);

      print("Excel Saved Successfully");
      print(file.path);

      final result = await OpenFilex.open(file.path);

      print("Open Result:");
      print(result);

      print("========== EXCEL EXPORT FINISHED ==========");
    } catch (e, stackTrace) {
      print("EXCEL EXPORT ERROR");
      print(e);
      print(stackTrace);
    }
  }
}
