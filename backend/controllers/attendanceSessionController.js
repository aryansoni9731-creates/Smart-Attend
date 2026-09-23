const AttendanceSession = require("../models/AttendanceSession");
const AttendanceRecord = require("../models/AttendanceRecord");

const startSession = async (req, res) => {
  try {
    const {
      teacherId,
      department,
      semester,
      section,
      subject,
    } = req.body;

    const activeSession = await AttendanceSession.findOne({
      status: "Active",
    });

    if (activeSession) {
      return res.status(400).json({
        message: "Another attendance session is already active.",
      });
    }
    const session = new AttendanceSession({
      teacherId,
      department,
      semester,
      section,
      subject,
    });

    await session.save();

    res.status(201).json({
      message: "Attendance session started successfully.",
      session,
    });

  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};
const endSession = async (req, res) => {
  try {
    const { sessionId } = req.body;

    const session = await AttendanceSession.findById(sessionId);

    if (!session) {
      return res.status(404).json({
        success: false,
        message: "Attendance session not found",
      });
    }

    // Close session
    session.status = "Closed";
    session.endTime = new Date();

    await session.save();

    // Count present students
    const presentCount = await AttendanceRecord.countDocuments({
      session: session._id,
      status: "Present",
    });

    // Send summary
    return res.status(200).json({
      success: true,
      message: "Attendance session ended successfully",

      summary: {
        subject: session.subject,
        semester: session.semester,
        section: session.section,
        totalPresent: presentCount,
      },
    });

  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

const getActiveSession = async (req, res) => {
  try {
    const sessions = await AttendanceSession.find({
      status: "Active",
    });

    res.status(200).json(sessions);

  } catch (error) {
    res.status(500).json({
      message: error.message,
    });
  }
};
module.exports = {
  startSession,
  endSession,
  getActiveSession,
};