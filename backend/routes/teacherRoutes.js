const express = require("express");

const router = express.Router();

const {
  registerTeacher,
  loginTeacher,
} = require("../controllers/teacherController");

// Register Teacher
router.post("/register", registerTeacher);

// Login Teacher
router.post("/login", loginTeacher);

module.exports = router;
