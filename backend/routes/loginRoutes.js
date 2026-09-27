const express = require("express");
const router = express.Router();
const { loginStudent } = require("../controllers/loginController");

router.post("/student", loginStudent);

module.exports = router;
