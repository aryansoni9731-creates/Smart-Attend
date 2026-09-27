const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const Teacher = require("../models/Teacher");
const { JWT_SECRET } = require("../config/auth");

const registerTeacher = async (req, res) => {
  try {
    const { teacherId, name, password, department } = req.body;

    const existingTeacher = await Teacher.findOne({ teacherId });
    if (existingTeacher) {
      return res.status(400).json({
        success: false,
        message: "Teacher ID already registered.",
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

    const teacherData = {
      _id: teacher._id,
      teacherId: teacher.teacherId,
      name: teacher.name,
      department: teacher.department,
    };

    const token = jwt.sign(
      { id: teacher._id, role: "teacher", teacherId: teacher.teacherId },
      JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.status(201).json({
      success: true,
      message: "Teacher registered successfully.",
      token,
      teacher: teacherData,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const loginTeacher = async (req, res) => {
  try {
    const { teacherId, password } = req.body;

    const teacher = await Teacher.findOne({ teacherId });
    if (!teacher) {
      return res.status(404).json({
        success: false,
        message: "Teacher not found.",
      });
    }

    const isMatch = await bcrypt.compare(password, teacher.password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: "Incorrect password.",
      });
    }

    const teacherData = {
      _id: teacher._id,
      teacherId: teacher.teacherId,
      name: teacher.name,
      department: teacher.department,
    };

    const token = jwt.sign(
      { id: teacher._id, role: "teacher", teacherId: teacher.teacherId },
      JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.status(200).json({
      success: true,
      message: "Teacher login successful.",
      token,
      teacher: teacherData,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

module.exports = {
  registerTeacher,
  loginTeacher,
};
