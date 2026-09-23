const express = require("express");
const router = express.Router();

const {
  markAttendance,
  checkAttendanceStatus,
  getLiveAttendance,
  getAttendanceHistory,
  getSessionAttendance,
} = require("../controllers/attendanceController");


router.post(
  "/mark",
  markAttendance
);


router.get(
  "/status/:enrollmentId",
  checkAttendanceStatus
);


router.get(
  "/live",
  getLiveAttendance
);


router.get(
  "/history",
  getAttendanceHistory
);


router.get(
  "/session/:sessionId",
  getSessionAttendance
);


module.exports = router;