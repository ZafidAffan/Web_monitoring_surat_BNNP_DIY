const db = require('../config/db');


// 1. Kirim disposisi
exports.createDisposisi = (req, res) => {
  const { id_surat, ke_user, perintah, keterangan } = req.body;

  const sql = `
    INSERT INTO disposisi
    (id_surat, dari_user, ke_user, perintah, keterangan)
    VALUES (?, ?, ?, ?, ?)
  `;

  db.query(
    sql,
    [id_surat, req.user.id, ke_user, perintah, keterangan],
    (err) => {
      if (err) return res.status(500).json(err);

      // Update status surat
      db.query(
        `UPDATE surat_masuk SET status = 'Didisposisi' WHERE id_surat = ?`,
        [id_surat]
      );

      res.json({ message: 'Disposisi berhasil dikirim' });
    }
  );
};

// 2. Lihat disposisi masuk
exports.getDisposisiMasuk = (req, res) => {
  const sql = `
    SELECT d.*, s.no_surat, s.perihal
    FROM disposisi d
    JOIN surat_masuk s ON d.id_surat = s.id_surat
    WHERE d.ke_user = ?
    ORDER BY d.tanggal_disposisi DESC
  `;

  db.query(sql, [req.user.id], (err, result) => {
    if (err) return res.status(500).json(err);
    res.json(result);
  });
};

// 3. Konfirmasi dibaca
exports.konfirmasiDisposisi = (req, res) => {
  const sql = `
    UPDATE disposisi
    SET status_konfirmasi = 'diterima',
        tanggal_konfirmasi = NOW(),
        status_proses = 'diproses'
    WHERE id_disposisi = ?
      AND ke_user = ?
  `;

  db.query(sql, [req.params.id, req.user.id], (err) => {
    if (err) return res.status(500).json(err);
    res.json({ message: 'Disposisi dikonfirmasi' });
  });
};

// 4. Update status proses
exports.updateStatusProses = (req, res) => {
  const { status_proses, id_surat } = req.body;

  db.query(
    `UPDATE disposisi SET status_proses = ? WHERE id_disposisi = ?`,
    [status_proses, req.params.id],
    (err) => {
      if (err) return res.status(500).json(err);

      if (status_proses === 'selesai') {
        db.query(
          `UPDATE surat_masuk SET status = 'Selesai' WHERE id_surat = ?`,
          [id_surat]
        );
      }

      res.json({ message: 'Status disposisi diperbarui' });
    }
  );
};
