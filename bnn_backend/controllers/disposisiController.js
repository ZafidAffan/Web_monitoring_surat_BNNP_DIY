const mysql = require('mysql2');

// ================= DATABASE =================
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'bnn_surat_2'
});

// ================= AMBIL DIVISI =================
exports.getDivisi = (req, res) => {
  const query = `SELECT id_divisi, nama_divisi FROM divisi`;
  db.query(query, (err, results) => {
    if (err) return res.status(500).json({ message: 'Gagal ambil divisi', error: err });
    res.json(results);
  });
};

// ================= AMBIL DISPOSISI BERDASARKAN DIVISI =================
exports.getDisposisiByDivisi = (req, res) => {
  const { id_divisi } = req.params;
  const role = req.user.role;

  let query = '';
  let params = [];

  if (role === 'umum') {
    query = `SELECT * FROM disposisi ORDER BY tanggal_disposisi DESC`;
  } else {
    query = `SELECT * FROM disposisi WHERE ke_divisi = ? ORDER BY tanggal_disposisi DESC`;
    params = [id_divisi];
  }

  db.query(query, params, (err, results) => {
    if (err) return res.status(500).json({ message: 'Gagal ambil disposisi', error: err });
    res.json(results);
  });
};

// ================= AMBIL SEMUA DISPOSISI UMUM =================
exports.getAllDisposisiUmum = (req, res) => {
  const query = `SELECT * FROM disposisi ORDER BY tanggal_disposisi DESC`;
  db.query(query, (err, results) => {
    if (err) return res.status(500).json({ message: 'Gagal ambil disposisi umum', error: err });
    res.json(results);
  });
};

// ================= TAMBAH DISPOSISI KEPALA =================
exports.tambahDisposisiKepala = (req, res) => {
  const { id_surat, ke_divisi, perintah, keterangan } = req.body;
  const dari_user = req.user.id_user;

  if (!id_surat || !ke_divisi)
    return res.status(400).json({ message: 'id_surat dan ke_divisi wajib diisi' });

  const statusProses = 'menunggu_umum';
  const statusSurat = 'Disposisi Divisi Umum';

  const insertDisposisi = `
    INSERT INTO disposisi
      (id_surat, dari_user, ke_divisi, perintah, keterangan, tanggal_disposisi, status_konfirmasi, status_proses)
    VALUES (?, ?, ?, ?, ?, NOW(), 'belum diterima', ?)
  `;

  db.query(
    insertDisposisi,
    [id_surat, dari_user, ke_divisi, perintah || 'Disposisi', keterangan || '', statusProses],
    (err, result) => {
      if (err)
        return res.status(500).json({ message: 'Gagal tambah disposisi Kepala', error: err });

      const id_disposisi = result.insertId;

      // Update status surat
      const updateSurat = `UPDATE surat_masuk SET status = ? WHERE id_surat = ?`;
      db.query(updateSurat, [statusSurat, id_surat], (err2) => {
        if (err2)
          return res.status(500).json({
            message: 'Disposisi berhasil tapi gagal update status surat',
            error: err2
          });

        // Insert ke tracking dengan status "kembali ke Umum"
        const insertTracking = `
          INSERT INTO surat_tracking
            (id_surat, status, keterangan, id_divisi, id_user)
          VALUES (?, ?, ?, ?, ?)
        `;

        const trackingData = [
          id_surat,
          'kembali ke Umum',
          keterangan || 'Disposisi dari Kepala',
          ke_divisi || null,
          dari_user || null
        ];

        console.log('INSERT TRACKING DATA (Kepala->Umum):', trackingData);

        db.query(insertTracking, trackingData, (err3, result3) => {
          if (err3) {
            console.log('Error insert tracking:', err3);
            return res.status(500).json({
              message: 'Disposisi berhasil tapi gagal tambah tracking',
              error: err3
            });
          }

          res.status(201).json({
            message: 'Disposisi Kepala berhasil dan tracking tersimpan',
            id_disposisi,
            ke_divisi,
            status_proses: statusProses
          });
        });
      });
    }
  );
};

// ================= TAMBAH DISPOSISI UMUM =================
exports.tambahDisposisiUmum = (req, res) => {
  const { id_surat, ke_divisi, perintah, keterangan } = req.body;
  const dari_user = req.user.id_user;

  if (!id_surat || !ke_divisi)
    return res.status(400).json({ message: 'id_surat dan ke_divisi wajib diisi' });

  const statusProses = 'menunggu_divisi';

  const sql = `
    INSERT INTO disposisi
      (id_surat, dari_user, ke_divisi, perintah, keterangan, tanggal_disposisi, status_konfirmasi, status_proses)
    VALUES (?, ?, ?, ?, ?, NOW(), 'belum diterima', ?)
  `;

  db.query(
    sql,
    [id_surat, dari_user, ke_divisi, perintah || 'Disposisi', keterangan || '', statusProses],
    (err, result) => {
      if (err) return res.status(500).json({ message: 'Gagal tambah disposisi Umum', error: err });

      const id_disposisi = result.insertId;

      // Ambil nama divisi untuk tracking
      const selectDivisi = `SELECT nama_divisi FROM divisi WHERE id_divisi = ?`;
      db.query(selectDivisi, [ke_divisi], (errDiv, divisiResult) => {
        let statusTracking = 'Disposisi Divisi';
        if (!errDiv && divisiResult.length > 0) {
          statusTracking = `Disposisi Divisi (${divisiResult[0].nama_divisi})`;
        }

        const insertTracking = `
          INSERT INTO surat_tracking
            (id_surat, status, keterangan, id_divisi, id_user)
          VALUES (?, ?, ?, ?, ?)
        `;
        const trackingData = [
          id_surat,
          statusTracking,
          keterangan || 'Disposisi dari Umum',
          ke_divisi || null,
          dari_user || null
        ];

        console.log('INSERT TRACKING DATA (Umum->Divisi):', trackingData);

        db.query(insertTracking, trackingData, (err3, result3) => {
          if (err3) {
            console.log('Error insert tracking:', err3);
            return res.status(500).json({
              message: 'Disposisi berhasil tapi gagal tambah tracking',
              error: err3
            });
          }

          res.status(201).json({
            message: 'Disposisi Umum berhasil dan tracking tersimpan',
            id_disposisi,
            status_proses: statusProses
          });
        });
      });
    }
  );
};

// ================= KONFIRMASI DISPOSISI UMUM =================
exports.konfirmasiDisposisiUmum = (req, res) => {
  const { id_disposisi } = req.params;
  const id_user = req.user.id_user;

  const selectDisposisi = `SELECT id_surat, ke_divisi, keterangan FROM disposisi WHERE id_disposisi = ?`;
  db.query(selectDisposisi, [id_disposisi], (err, results) => {
    if (err) return res.status(500).json({ message: 'Gagal ambil disposisi', error: err });
    if (results.length === 0) return res.status(404).json({ message: 'Disposisi tidak ditemukan' });

    const { id_surat, ke_divisi, keterangan } = results[0];

    const updateDisposisi = `
      UPDATE disposisi 
      SET status_proses = 'menunggu_divisi', status_konfirmasi = 'diterima' 
      WHERE id_disposisi = ?
    `;
    db.query(updateDisposisi, [id_disposisi], (err2) => {
      if (err2) return res.status(500).json({ message: 'Gagal update disposisi', error: err2 });

      const updateSurat = `UPDATE surat_masuk SET status = 'Disposisi Divisi' WHERE id_surat = ?`;
      db.query(updateSurat, [id_surat], (err3) => {
        if (err3) return res.status(500).json({ message: 'Gagal update surat', error: err3 });

        // Ambil nama divisi untuk tracking
        const selectDivisi = `SELECT nama_divisi FROM divisi WHERE id_divisi = ?`;
        db.query(selectDivisi, [ke_divisi], (errDiv, divisiResult) => {
          let statusTracking = 'Disposisi Divisi';
          if (!errDiv && divisiResult.length > 0) {
            statusTracking = `Disposisi Divisi (${divisiResult[0].nama_divisi})`;
          }

          const insertTracking = `
            INSERT INTO surat_tracking
              (id_surat, status, keterangan, id_divisi, id_user)
            VALUES (?, ?, ?, ?, ?)
          `;
          const trackingData = [
            id_surat,
            statusTracking,
            keterangan || 'Konfirmasi Umum',
            ke_divisi || null,
            id_user || null
          ];

          console.log('INSERT TRACKING DATA (Umum->Divisi):', trackingData);

          db.query(insertTracking, trackingData, (err4, result4) => {
            if (err4) {
              console.log('Error insert tracking:', err4);
              return res.status(500).json({ message: 'Gagal tambah tracking', error: err4 });
            }

            console.log('Tracking berhasil ditambahkan:', result4);

            res.json({
              message: 'Disposisi dikonfirmasi, status disposisi & surat berhasil diperbarui'
            });
          });
        });
      });
    });
  });
};

// ================= UPDATE STATUS DISPOSISI =================
exports.updateStatusDisposisi = (req, res) => {
  const { id_disposisi } = req.params;
  const { newStatus } = req.body;

  const sql = `UPDATE disposisi SET status_proses = ? WHERE id_disposisi = ?`;
  db.query(sql, [newStatus, id_disposisi], (err, result) => {
    if (err) return res.status(500).json({ message: 'Gagal update status', error: err });
    res.json({ message: 'Status berhasil diperbarui' });
  });
};
