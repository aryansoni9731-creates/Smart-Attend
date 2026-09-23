const mongoose = require("mongoose");

const deviceLockSchema = new mongoose.Schema(
  {
    sessionId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "AttendanceSession",
      required: true,
    },

    enrollmentId: {
      type: String,
      required: true,
    },

    deviceId: {
      type: String,
      required: true,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model("DeviceLock", deviceLockSchema);