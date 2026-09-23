const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const Student = require("../models/Student");
const { JWT_SECRET } = require("../middleware/authMiddleware");

const registerStudent = async (data) => {
  const { rollNo, name, enrollmentId, password, department, semester, section } = data;

  const rollExists = await Student.findOne({ rollNo });
  if (rollExists) {
    return {
      success: false,
      message: "Roll Number already registered.",
    };
  }

  const enrollmentExists = await Student.findOne({ enrollmentId });
  if (enrollmentExists) {
    return {
      success: false,
      message: "Enrollment ID already registered.",
    };
  }

  const hashedPassword = await bcrypt.hash(password, 10);

  const student = new Student({
    rollNo,
    name,
    enrollmentId,
    password: hashedPassword,
    department,
    semester,
    section,
  });

  await student.save();

  const studentData = {
    _id: student._id,
    rollNo: student.rollNo,
    name: student.name,
    enrollmentId: student.enrollmentId,
    department: student.department,
    semester: student.semester,
    section: student.section,
  };

  const token = jwt.sign(
    { id: student._id, role: "student", enrollmentId: student.enrollmentId },
    JWT_SECRET,
    { expiresIn: "7d" }
  );

  return {
    success: true,
    message: "Student registered successfully.",
    token,
    student: studentData,
  };
};

const loginStudent = async (data) => {
  const { enrollmentId, password } = data;

  const student = await Student.findOne({ enrollmentId });
  if (!student) {
    return {
      success: false,
      message: "Student not found.",
    };
  }

  const isMatch = await bcrypt.compare(password, student.password);
  if (!isMatch) {
    return {
      success: false,
      message: "Incorrect password.",
    };
  }

  const studentData = {
    _id: student._id,
    rollNo: student.rollNo,
    name: student.name,
    enrollmentId: student.enrollmentId,
    department: student.department,
    semester: student.semester,
    section: student.section,
  };

  const token = jwt.sign(
    { id: student._id, role: "student", enrollmentId: student.enrollmentId },
    JWT_SECRET,
    { expiresIn: "7d" }
  );

  return {
    success: true,
    message: "Login successful.",
    token,
    student: studentData,
  };
};

module.exports = {
  registerStudent,
  loginStudent,
};
