const Classroom = require("../models/Classroom");

const createClassroom = async (req, res) => {
  try {
    const {
      department,
      semester,
      section,
      subject,
      teacher,
      students,
    } = req.body;

    const classroom = new Classroom({
      department,
      semester,
      section,
      subject,
      teacher,
      students,
    });

    await classroom.save();

    res.status(201).json({
      message: "Classroom created successfully",
      classroom,
    });

  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};

const getAllClassrooms = async (req, res) => {
  try {
    const classrooms = await Classroom.find()
      .populate("teacher")
      .populate("subject")
      .populate("students");

    res.status(200).json(classrooms);

  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};

module.exports = {
  createClassroom,
  getAllClassrooms,
};