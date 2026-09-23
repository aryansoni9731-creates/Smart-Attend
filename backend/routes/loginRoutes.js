const express = require("express");
const router = express.Router();
const { loginStudent, loginTeacher } = require("../controllers/loginController");

router.post("/student", loginStudent);
router.post("/teacher", loginTeacher);

module.exports = router;
