const express = require('express');
const router = express.Router();
const mysql = require('mysql2');

const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',    // ganti jika berbeda
    password: '',    // ganti jika berbeda
    database: 'bnn_surat'
});

// LOGIN
router.post('/login', (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ message: "Email dan password wajib diisi" });
    }

    const query = "SELECT * FROM users WHERE email = ? LIMIT 1";
    db.query(query, [email], (err, result) => {
        if (err) return res.status(500).json({ message: "Server error", error: err });

        if (result.length === 0) {
            return res.status(401).json({ message: "Email tidak ditemukan" });
        }

        const user = result[0];

        if (user.password !== password) {
            return res.status(401).json({ message: "Password salah" });
        }

        return res.status(200).json({
            message: "Login berhasil",
            user: {
                id: user.id,
                email: user.email,
                role: user.role ?? "user"
            }
        });
    });
});

module.exports = router;
