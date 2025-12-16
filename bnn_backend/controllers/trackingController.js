const db = require("../config/db");

// ==========================================
// CREATE tracking (POST)
// ==========================================
exports.createTracking = (req, res) => {
    const {
        id_surat,
        status,
        keterangan,
        id_divisi,
        id_subdivisi,
        id_user
    } = req.body;

    const sql = `
        INSERT INTO tracking 
        (id_surat, status, keterangan, id_divisi, id_subdivisi, id_user, waktu)
        VALUES (?, ?, ?, ?, ?, ?, NOW())
    `;

    db.query(
        sql,
        [id_surat, status, keterangan, id_divisi, id_subdivisi, id_user],
        (err, result) => {
            if (err) return res.status(500).json({ error: err });

            res.json({
                message: "Tracking berhasil ditambahkan",
                id_tracking: result.insertId
            });
        }
    );
};

// ==========================================
// GET tracking berdasarkan id_surat
// ==========================================
exports.getTrackingBySurat = (req, res) => {
    const sql = `
        SELECT * FROM tracking 
        WHERE id_surat = ?
        ORDER BY waktu ASC
    `;

    db.query(sql, [req.params.id_surat], (err, result) => {
        if (err) return res.status(500).json({ error: err });
        res.json(result);
    });
};

// ==========================================
// UPDATE tracking (status terbaru)
// ==========================================
exports.updateTrackingStatus = (req, res) => {
    const { status, keterangan, id_divisi, id_subdivisi, id_user } = req.body;

    const sql = `
        UPDATE tracking SET 
            status = ?, 
            keterangan = ?, 
            id_divisi = ?, 
            id_subdivisi = ?, 
            id_user = ?, 
            waktu = NOW()
        WHERE id_surat = ?
    `;

    db.query(
        sql,
        [status, keterangan, id_divisi, id_subdivisi, id_user, req.params.id_surat],
        (err) => {
            if (err) return res.status(500).json({ error: err });

            res.json({ message: "Status tracking berhasil diperbarui" });
        }
    );
};
