const db = require('../db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

exports.login = (req, res) => {
  const { email, password } = req.body;

  const sql = 'SELECT * FROM users WHERE email = ?';
  db.query(sql, [email], async (err, result) => {
    if (err) return res.status(500).json(err);
    if (result.length === 0)
      return res.status(401).json({ message: 'Email tidak ditemukan' });

    const user = result[0];
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch)
      return res.status(401).json({ message: 'Password salah' });

    const token = jwt.sign(
      { id_user: user.id_user, role: user.role, divisi: user.id_divisi },
      process.env.JWT_SECRET,
      { expiresIn: '1d' }
    );

    res.json({
      token,
      role: user.role,
      divisi: user.id_divisi,
      nama: user.nama
    });
  });
};
