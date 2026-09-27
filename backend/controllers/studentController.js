const studentService = require("../services/studentService");

// ==========================
// REGISTER STUDENT
// ==========================
const registerStudent = async (req, res) => {
  try {
    const result = await studentService.registerStudent(req.body);

    if (!result.success) {
      return res.status(400).json(result);
    }

    return res.status(201).json(result);
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

module.exports = {
  registerStudent,
};
