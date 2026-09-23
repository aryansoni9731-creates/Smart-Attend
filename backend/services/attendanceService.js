const { verifyBluetooth } = require("./bluetoothService");
const { verifyLocation } = require("./locationService");
const { verifyBiometric } = require("./biometricService");

const AttendanceRecord = require("../models/AttendanceRecord");
const AttendanceSession = require("../models/AttendanceSession");
const Student = require("../models/Student");

// ===========================================
// MARK ATTENDANCE
// ===========================================
const markAttendance = async (data) => {
  console.log("Attendance Service Called");

  const { enrollmentId } = data;

  // Step 1: Find Active Session
  const activeSession = await AttendanceSession.findOne({
    status: "Active",
  });

  if (!activeSession) {
    return {
      success: false,
      message: "No active attendance session.",
    };
  }

  // Step 2: Find Student
  const student = await Student.findOne({
    enrollmentId,
  });

  if (!student) {
    return {
      success: false,
      message: "Student not found.",
    };
  }

  // Step 3: Verify Student Class
  if (
    student.department !== activeSession.department ||
    student.semester !== activeSession.semester ||
    student.section !== activeSession.section
  ) {
    return {
      success: false,
      message: "You are not allowed to mark attendance for this class.",
    };
  }

  // Step 4: Prevent Duplicate Attendance
  const alreadyMarked = await AttendanceRecord.findOne({
    session: activeSession._id,
    student: student._id,
  });

  if (alreadyMarked) {
    return {
      success: false,
      message: "Attendance already marked.",
    };
  }

  // Step 5: Bluetooth Verification
  const bluetoothResult = await verifyBluetooth(data);

  if (!bluetoothResult.success) {
    return bluetoothResult;
  }

  // Step 6: Location Verification
  const locationResult = await verifyLocation(data);

  if (!locationResult.success) {
    return locationResult;
  }

  // Step 7: Biometric Verification
  const biometricResult = await verifyBiometric(data);

  if (!biometricResult.success) {
    return biometricResult;
  }

  // Step 8: Save Attendance
  const attendance = new AttendanceRecord({
    session: activeSession._id,
    student: student._id,
    bluetoothVerified: true,
    rssi: data.rssi,
    locationVerified: true,
    biometricVerified: true,
    status: "Present",
  });

  await attendance.save();

  return {
    success: true,
    message: "Attendance marked successfully.",
    attendance,
  };
};

// ===========================================
// LIVE ATTENDANCE
// ===========================================
const getLiveAttendance = async () => {
  const activeSession = await AttendanceSession.findOne({
    status: "Active",
  });

  if (!activeSession) {
    return {
      success: false,
      message: "No active attendance session.",
    };
  }

  const attendance = await AttendanceRecord.find({
    session: activeSession._id,
    status: "Present",
  })
    .populate(
      "student",
      "name enrollmentId rollNo department semester section"
    );

  return {
    success: true,
    message: "Live attendance fetched successfully.",
    data: {
      session: activeSession,
      totalPresent: attendance.length,
      attendance,
    },
  };
};

// ===========================================
// ATTENDANCE STATUS
// ===========================================
const checkAttendanceStatus = async (enrollmentId) => {
  const activeSession = await AttendanceSession.findOne({
    status: "Active",
  });

  if (!activeSession) {
    return {
      success: false,
      message: "No active attendance session.",
    };
  }

  const student = await Student.findOne({
    enrollmentId,
  });

  if (!student) {
    return {
      success: false,
      message: "Student not found.",
    };
  }

  const attendance = await AttendanceRecord.findOne({
    session: activeSession._id,
    student: student._id,
  });

  if (attendance) {
    return {
      success: true,
      marked: true,
      status: attendance.status,
      message: "Attendance already marked.",
    };
  }

  return {
    success: true,
    marked: false,
    message: "Attendance not marked yet.",
  };
};

// ===========================================
// ATTENDANCE HISTORY
// ===========================================
const getAttendanceHistory = async (enrollmentId) => {
  const student = await Student.findOne({
    enrollmentId,
  });

  if (!student) {
    return {
      success: false,
      message: "Student not found.",
    };
  }

  const records = await AttendanceRecord.find({
    student: student._id,
  })
    .select("-__v")
    .populate({
      path: "session",
      select: "-__v",
    })
    .populate("student", "name enrollmentId rollNo")
    .sort({ attendanceTime: -1 });

  const totalClasses = records.length;

  const present = records.filter(
    (record) => record.status === "Present"
  ).length;

  const rejected = records.filter(
    (record) => record.status === "Rejected"
  ).length;

  const attendancePercentage =
    totalClasses === 0
      ? 0
      : Number(((present / totalClasses) * 100).toFixed(2));

  return {
    success: true,
    message: "Attendance history fetched successfully.",
    data: {
      student: {
        name: student.name,
        enrollmentId: student.enrollmentId,
        rollNo: student.rollNo,
      },
      summary: {
        totalClasses,
        present,
        rejected,
        attendancePercentage,
      },
      records,
    },
  };
};

module.exports = {
  markAttendance,
  getLiveAttendance,
  checkAttendanceStatus,
  getAttendanceHistory,
};