const mysql = require('mysql2');
const path = require('path');

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

// ================= CREATE SURAT MASUK =================
exports.createSuratMasuk = (req, res) => {
  try {
    const { no_surat, tanggal_surat, tanggal_terima, dari, perihal } = req.body;

    if (!req.file) {
      return res.status(400).json({ message: 'File PDF wajib diupload' });
    }

    if (!no_surat || !tanggal_surat || !tanggal_terima || !dari || !perihal) {
      return res.status(400).json({ message: 'Semua field wajib diisi' });
    }

    const kodeTracking = 'TRK-' + Date.now();
    const filePath = `/uploads/${req.file.filename}`;

    const query = `
      INSERT INTO surat_masuk (
        no_surat,
        tanggal_surat,
        tanggal_terima,
        dari,
        perihal,
        file_surat,
        kode_tracking,
        status
      ) VALUES (?, ?, ?, ?, ?, ?, ?, 'Menunggu')
    `;

    db.query(
      query,
      [no_surat, tanggal_surat, tanggal_terima, dari, perihal, filePath, kodeTracking],
      (err) => {
        if (err) {
          console.error('ERROR INSERT SURAT:', err);
          return res.status(500).json({ message: 'Gagal menyimpan surat' });
        }

        res.status(201).json({
          message: 'Surat masuk berhasil ditambahkan',
          kode_tracking: kodeTracking
        });
      }
    );
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

// ================= GET SURAT MASUK =================
exports.getSuratMasuk = (req, res) => {
  db.query("SELECT * FROM surat_masuk ORDER BY created_at DESC", (err, results) => {
    if (err) return res.status(500).json({ message: 'Error ambil data' });
    res.json(results);
  });
};
