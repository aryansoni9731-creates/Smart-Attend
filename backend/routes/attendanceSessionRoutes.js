const express = require("express");
const router = express.Router();

const {
  startSession,
  endSession,
  getActiveSession,
} = require("../controllers/attendanceSessionController");


router.post("/start", startSession);

router.post("/end", endSession);

router.get("/active", getActiveSession);


module.exports = router;