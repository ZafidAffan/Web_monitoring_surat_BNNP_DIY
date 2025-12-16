const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');

// contoh login sederhana
router.post('/login', (req, res) => {
  const { email } = req.body;

  // contoh payload
  const user = {
    id: 1,
    role: 'admin'
  };

  const token = jwt.sign(user, process.env.JWT_SECRET, {
    expiresIn: '1d'
  });

  res.json({
    message: 'Login berhasil',
    token
  });
});

module.exports = router;
