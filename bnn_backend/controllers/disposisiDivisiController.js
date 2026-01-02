const mysql = require('mysql2');

// ================= DATABASE =================
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'bnn_surat_2'
});

// =====================================================
// GET DISPOSISI SESUAI DIVISI USER LOGIN
// =====================================================
exports.getDisposisiByDivisi = (req, res) => {
  const id_divisi = req.user.divisi;

  const query = `
    SELECT 
      d.id_disposisi,
      d.id_surat,
      sm.no_surat,
      sm.perihal,
      sm.dari,
      d.perintah,
      d.keterangan,
      d.tanggal_disposisi,
      d.status_proses,
      d.status_konfirmasi
    FROM disposisi d
    JOIN surat_masuk sm 
      ON sm.id_surat = d.id_surat
    WHERE d.ke_divisi = ?
    ORDER BY d.tanggal_disposisi DESC
  `;

  db.query(query, [id_divisi], (err, results) => {
    if (err) {
      return res.status(500).json({
        message: 'Gagal mengambil disposisi divisi',
        error: err
      });
    }

    res.json(results);
  });
};

// =====================================================
// TERIMA DISPOSISI OLEH DIVISI
// =====================================================
exports.terimaDisposisiDivisi = (req, res) => {
  const { id_disposisi } = req.params;
  const id_user = req.user.id_user;
  const id_divisi = req.user.divisi;

  // ================= VALIDASI =================
  if (!id_disposisi) {
    return res.status(400).json({
      message: 'id_disposisi wajib dikirim'
    });
  }

  // ================= AMBIL DATA DISPOSISI =================
  const getDisposisi = `
    SELECT id_surat 
    FROM disposisi 
    WHERE id_disposisi = ? 
      AND ke_divisi = ?
  `;

  db.query(getDisposisi, [id_disposisi, id_divisi], (err, result) => {
    if (err || result.length === 0) {
      return res.status(404).json({
        message: 'Disposisi tidak ditemukan atau bukan milik divisi ini'
      });
    }

    const id_surat = result[0].id_surat;

    // ================= UPDATE DISPOSISI =================
    const updateDisposisi = `
      UPDATE disposisi
      SET 
        status_proses = 'selesai',
        status_konfirmasi = 'diterima'
      WHERE id_disposisi = ?
    `;

    db.query(updateDisposisi, [id_disposisi], (err2) => {
      if (err2) {
        return res.status(500).json({
          message: 'Gagal update status disposisi',
          error: err2
        });
      }

      // ================= UPDATE STATUS SURAT =================
      const updateSurat = `
        UPDATE surat_masuk
        SET status = 'Diterima'
        WHERE id_surat = ?
      `;

      db.query(updateSurat, [id_surat], (err3) => {
        if (err3) {
          return res.status(500).json({
            message: 'Gagal update status surat',
            error: err3
          });
        }

        // ================= INSERT TRACKING =================
        const insertTracking = `
          INSERT INTO surat_tracking
          (id_surat, status, keterangan, id_divisi, id_subdivisi, id_user, waktu)
          VALUES (?, ?, ?, ?, NULL, ?, NOW())
        `;

        db.query(
          insertTracking,
          [
            id_surat,
            'Diterima Divisi',
            'Surat diterima oleh divisi',
            id_divisi,
            id_user
          ],
          (err4) => {
            if (err4) {
              return res.status(500).json({
                message: 'Disposisi diterima tapi gagal simpan tracking',
                error: err4
              });
            }

            res.json({
              message: 'Disposisi berhasil diterima',
              id_disposisi,
              id_surat
            });
          }
        );
      });
    });
  });
};
