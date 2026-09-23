const bcrypt = require("bcryptjs");

const Student = require("../models/Student");
const Teacher = require("../models/Teacher");

const registerStudent = async (req, res) => {
  try {
    const {
      rollNo,
      name,
      enrollmentId,
      password,
      department,
      semester,
      section,
    } = req.body;

    const existingStudent = await Student.findOne({
      $or: [{ enrollmentId }, { rollNo }],
    });
    if (existingStudent) {
      return res.status(400).json({
        message: "Student already exists",
      });
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

    res.status(201).json({
      message: "Student registered successfully",
      student,
    });
  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};

const registerTeacher = async (req, res) => {
  try {
    const {
      teacherId,
      name,
      password,
      department,
    } = req.body;

    const existingTeacher = await Teacher.findOne({
      teacherId,
    });

    if (existingTeacher) {
      return res.status(400).json({
        message: "Teacher already exists",
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const teacher = new Teacher({
      teacherId,
      name,
      password: hashedPassword,
      department,
    });

    await teacher.save();

    res.status(201).json({
      message: "Teacher registered successfully",
      teacher,
    });

  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};
module.exports = {
  registerStudent,
  registerTeacher,
};