const attendanceService = require("../services/attendanceService");
const AttendanceRecord = require("../models/AttendanceRecord");
const markAttendance = async (req, res) => {
  try {
    const result = await attendanceService.markAttendance(req.body);

    if (!result.success) {
      return res.status(400).json({
        success: false,
        message: result.message,
      });
    }

    return res.status(200).json({
      success: true,
      message: result.message,
      attendance: result.attendance,
    });

  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
const getLiveAttendance = async (req, res) => {
  try {
    const result = await attendanceService.getLiveAttendance();

    if (!result.success) {
      return res.status(400).json(result);
    }

    return res.status(200).json(result);

  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
const checkAttendanceStatus = async (req, res) => {
  try {
    const { enrollmentId } = req.params;

    const result = await attendanceService.checkAttendanceStatus(enrollmentId);

    return res.status(200).json(result);

  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const getAttendanceHistory = async (req, res) => {
  console.log("History Controller Running");
  try {
    const { enrollmentId } = req.query;

    const result = await attendanceService.getAttendanceHistory(enrollmentId);

    if (!result.success) {
      return res.status(404).json(result);
    }

    return res.status(200).json(result);

  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
const getSessionAttendance = async (req, res) => {
  try {
    const { sessionId } = req.params;

    const attendance = await AttendanceRecord.find({
      session: sessionId,
      status: "Present",
    })
      .populate(
        "student",
        "rollNo name enrollmentId department semester section"
      )
      .sort({ attendanceTime: 1 });

    const students = attendance.map((record) => ({
      rollNo: record.student?.rollNo ?? "",
      enrollmentId: record.student?.enrollmentId ?? "",
      name: record.student?.name ?? "",
      department: record.student?.department ?? "",
      semester: record.student?.semester ?? "",
      section: record.student?.section ?? "",
      status: record.status,
    }));

    return res.status(200).json({
      success: true,
      totalPresent: students.length,
      students,
    });

  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
module.exports = {
  markAttendance,
  checkAttendanceStatus,
  getLiveAttendance,
  getAttendanceHistory,
  getSessionAttendance,
};