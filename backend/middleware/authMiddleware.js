const jwt = require("jsonwebtoken");

const JWT_SECRET = process.env.JWT_SECRET || "smart_attend_default_secret_key_2026";

// Verify Bearer JWT Token Middleware
const verifyToken = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({
      success: false,
      message: "Access denied. No token provided.",
    });
  }

  const token = authHeader.split(" ")[1];

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: "Invalid or expired token.",
    });
  }
};

// Teacher Role Guard
const isTeacher = (req, res, next) => {
  if (req.user && req.user.role === "teacher") {
    next();
  } else {
    res.status(403).json({
      success: false,
      message: "Access restricted to teachers only.",
    });
  }
};

// Student Role Guard
const isStudent = (req, res, next) => {
  if (req.user && req.user.role === "student") {
    next();
  } else {
    res.status(403).json({
      success: false,
      message: "Access restricted to students only.",
    });
  }
};

module.exports = {
  verifyToken,
  isTeacher,
  isStudent,
  JWT_SECRET,
};
