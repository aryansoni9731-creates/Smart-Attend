const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const DeviceLock = require("../models/DeviceLock");
const AttendanceSession = require("../models/AttendanceSession");
const Student = require("../models/Student");
const { JWT_SECRET } = require("../config/auth");

const loginStudent = async (req, res) => {
  try {
    const { enrollmentId, password, deviceId } = req.body;

    const student = await Student.findOne({ enrollmentId });
    if (!student) {
      return res.status(404).json({
        success: false,
        message: "Student not found with this enrollment ID",
      });
    }

    const isMatch = await bcrypt.compare(password, student.password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: "Invalid credentials",
      });
    }

    // Anti-proxy check for active attendance session
    const activeSession = await AttendanceSession.findOne({ status: "Active" });
    if (activeSession && deviceId) {
      const existingLock = await DeviceLock.findOne({
        sessionId: activeSession._id,
        deviceId: deviceId,
      });

      if (existingLock && existingLock.enrollmentId !== enrollmentId) {
        return res.status(403).json({
          success: false,
          message: "This device is already assigned to another student in the current session.",
        });
      }

      if (!existingLock) {
        await DeviceLock.create({
          sessionId: activeSession._id,
          enrollmentId,
          deviceId,
        });
      }
    }

    const studentData = {
      _id: student._id,
      rollNo: student.rollNo,
      enrollmentId: student.enrollmentId,
      name: student.name,
      department: student.department,
      semester: student.semester,
      section: student.section,
    };

    const token = jwt.sign(
      { id: student._id, role: "student", enrollmentId: student.enrollmentId },
      JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.status(200).json({
      success: true,
      message: "Student login successful",
      token,
      student: studentData,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

module.exports = {
  loginStudent,
};
