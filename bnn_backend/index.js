require('dotenv').config();

const express = require("express");
const cors = require("cors");

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());
app.use("/uploads", express.static("uploads"));

// Import routes
const authRoutes = require("./routes/auth");
const trackingRoute = require("./routes/trackingRoutes");

// Register routes
app.use("/api/auth", authRoutes);
app.use('/api/tracking', trackingRoute);
app.use('/api/surat-masuk', require('./routes/suratMasuk'));
app.use('/api/disposisi', require('./routes/disposisi'));


// Start server
app.listen(3000, () => {
  console.log("Server running on http://localhost:3000");
});
