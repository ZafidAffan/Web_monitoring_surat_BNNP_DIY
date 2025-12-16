const db = require('../config/db');

/* ================= CREATE ================= */
exports.createSuratMasuk = (req, res) => {
  console.log("BODY DITERIMA:", req.body);

  const {
    no_surat,
    tanggal_surat,
    tanggal_terima,
    dari,
    perihal
  } = req.body;

  const sql = `
    INSERT INTO surat_masuk 
    (no_surat, tanggal_surat, tanggal_terima, dari, perihal)
    VALUES (?, ?, ?, ?, ?)
  `;

  db.query(
    sql,
    [no_surat, tanggal_surat, tanggal_terima, dari, perihal],
    (err, result) => {
      if (err) return res.status(500).json({ error: err });

      res.status(201).json({
        message: "Surat masuk berhasil ditambahkan",
        id: result.insertId
      });
    }
  );
};

/* ================= GET ALL ================= */
exports.getSuratMasuk = (req, res) => {
  const sql = `SELECT * FROM surat_masuk ORDER BY id DESC`;

  db.query(sql, (err, results) => {
    if (err) return res.status(500).json({ error: err });
    res.json(results);
  });
};

/* ================= GET BY ID ================= */
exports.getSuratMasukById = (req, res) => {
  const { id } = req.params;

  db.query(
    `SELECT * FROM surat_masuk WHERE id = ?`,
    [id],
    (err, results) => {
      if (err) return res.status(500).json({ error: err });
      if (results.length === 0)
        return res.status(404).json({ message: "Data tidak ditemukan" });

      res.json(results[0]);
    }
  );
};

/* ================= UPDATE ================= */
exports.updateSuratMasuk = (req, res) => {
  const { id } = req.params;
  const {
    no_surat,
    tanggal_surat,
    tanggal_terima,
    dari,
    perihal
  } = req.body;

  const sql = `
    UPDATE surat_masuk SET
      no_surat = ?,
      tanggal_surat = ?,
      tanggal_terima = ?,
      dari = ?,
      perihal = ?
    WHERE id = ?
  `;

  db.query(
    sql,
    [no_surat, tanggal_surat, tanggal_terima, dari, perihal, id],
    (err) => {
      if (err) return res.status(500).json({ error: err });
      res.json({ message: "Surat masuk berhasil diupdate" });
    }
  );
};

/* ================= DELETE ================= */
exports.deleteSuratMasuk = (req, res) => {
  const { id } = req.params;

  db.query(
    `DELETE FROM surat_masuk WHERE id = ?`,
    [id],
    (err) => {
      if (err) return res.status(500).json({ error: err });
      res.json({ message: "Surat masuk berhasil dihapus" });
    }
  );
};

/* ================= COUNT ================= */
exports.countSuratMasuk = (req, res) => {
  db.query(
    `SELECT COUNT(*) AS total FROM surat_masuk`,
    (err, results) => {
      if (err) return res.status(500).json({ error: err });
      res.json(results[0]);
    }
  );
};
