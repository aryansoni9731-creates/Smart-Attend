const express = require("express");
const router = express.Router();

const {
  registerStudent,
  registerTeacher,
} = require("../controllers/authController");

router.post("/student/register", registerStudent);

router.post("/teacher/register", registerTeacher);

module.exports = router;