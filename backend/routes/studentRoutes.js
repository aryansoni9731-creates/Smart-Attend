const express = require("express");
const router = express.Router();

const {
  registerStudent,
  loginStudent,
} = require("../controllers/studentController");

// ==========================
// REGISTER STUDENT
// ==========================
router.post(
  "/register",
  registerStudent
);

// ==========================
// LOGIN STUDENT
// ==========================
router.post(
  "/login",
  loginStudent
);

module.exports = router;