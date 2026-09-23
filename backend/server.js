require("dotenv").config();
const express = require("express");
const cors = require("cors");
const connectDB = require("./config/db");

const authRoutes = require("./routes/authRoutes");
const loginRoutes = require("./routes/loginRoutes");
const classroomRoutes = require("./routes/classroomRoutes");
const attendanceSessionRoutes = require("./routes/attendanceSessionRoutes");
const attendanceRoutes = require("./routes/attendanceRoutes");
const studentRoutes = require("./routes/studentRoutes");
const teacherRoutes = require("./routes/teacherRoutes");

const app = express();

connectDB();

app.use(cors());
app.use(express.json());

app.use("/api/auth", authRoutes);
app.use("/api/login", loginRoutes);
app.use("/api/classroom", classroomRoutes);
app.use("/api/session", attendanceSessionRoutes);
app.use("/api/attendance", attendanceRoutes);
app.use("/api/student", studentRoutes);
app.use("/api/teacher", teacherRoutes);

app.get("/", (req, res) => {
  res.json({
    name: "SmartAttend API",
    status: "online",
    version: "1.0.0",
  });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, "0.0.0.0", () => {
  console.log(`SmartAttend API running on port ${PORT}`);
});
