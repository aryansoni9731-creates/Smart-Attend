const mongoose = require("mongoose");
const AttendanceRecord = require("../models/AttendanceRecord");

const attendanceRecordSchema = new mongoose.Schema(
  {
    session: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "AttendanceSession",
      required: true,
    },

    student: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Student",
      required: true,
    },

    attendanceTime: {
      type: Date,
      default: Date.now,
    },

    bluetoothVerified: {
      type: Boolean,
      default: false,
    },

    rssi: {
      type: Number,
      default: 0,
    },

    locationVerified: {
      type: Boolean,
      default: false,
    },

    biometricVerified: {
      type: Boolean,
      default: false,
    },

    status: {
      type: String,
      enum: ["Present", "Rejected"],
      default: "Rejected",
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model("AttendanceRecord", attendanceRecordSchema);