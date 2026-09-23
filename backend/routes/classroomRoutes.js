const express = require("express");
const router = express.Router();

const {
  createClassroom,
  getAllClassrooms,
} = require("../controllers/classroomController");

router.post("/create", createClassroom);

router.get("/all", getAllClassrooms);

module.exports = router;