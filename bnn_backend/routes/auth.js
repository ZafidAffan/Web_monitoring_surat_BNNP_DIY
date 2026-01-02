const express = require('express');
const router = express.Router();
const mysql = require('mysql2');
const jwt = require('jsonwebtoken');

// ================= KONEKSI DATABASE =================
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'bnn_surat_2'
});

db.connect(err => {
  if (err) throw err;
  console.log('Database connected');
});

// ================= LOGIN PLAIN TEXT =================
router.post('/login', (req, res) => {
  const { email, password } = req.body;

  // Validasi input
  if (!email || !password) {
    return res.status(400).json({ message: 'Email dan password wajib diisi' });
  }

  const query = 'SELECT * FROM users WHERE email = ? LIMIT 1';
  db.query(query, [email], (err, result) => {
    if (err) return res.status(500).json({ message: 'Server error', error: err });
    if (result.length === 0) return res.status(401).json({ message: 'Email tidak ditemukan' });

    const user = result[0];

    // Bandingkan password PLAIN TEXT
    if (user.password !== password) {
      return res.status(401).json({ message: 'Password salah' });
    }

    // Buat token JWT
    const token = jwt.sign(
      {
        id_user: user.id_user,
        role: user.role,
        divisi: user.id_divisi
      },
      process.env.JWT_SECRET,
      { expiresIn: '1d' }
    );

    // Kirim response ke Flutter, ubah semua int ke string supaya Flutter tidak error
    return res.status(200).json({
      message: 'Login berhasil',
      token,
      user: {
        id_user: user.id_user.toString(),
        nama: user.nama,
        email: user.email,
        role: user.role,
        divisi: user.id_divisi !== null ? user.id_divisi.toString() : ''
      }
    });
  });
});

module.exports = router;
