const express = require("express");
const router = express.Router();

const { registerStudent } = require("../controllers/studentController");

// ==========================
// REGISTER STUDENT
// ==========================
router.post(
  "/register",
  registerStudent
);

module.exports = router;
