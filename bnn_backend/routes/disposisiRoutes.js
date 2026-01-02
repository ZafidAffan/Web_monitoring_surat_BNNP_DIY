const express = require('express');
const router = express.Router();

const disposisiController = require('../controllers/disposisiController');
const authMiddleware = require('../middleware/authMiddleware');
const roleMiddleware = require('../middleware/roleMiddleware');

// 🔹 Ambil daftar divisi
router.get(
  '/divisi',
  authMiddleware,
  roleMiddleware('admin', 'umum', 'kepala'),
  disposisiController.getDivisi
);

// 🔹 Ambil disposisi berdasarkan divisi
router.get(
  '/divisi/:id_divisi',
  authMiddleware,
  roleMiddleware('admin', 'kepala', 'divisi', 'umum'),
  disposisiController.getDisposisiByDivisi
);

// 🔹 Ambil semua disposisi untuk Umum
router.get(
  '/umum/all',
  authMiddleware,
  roleMiddleware('umum'),
  disposisiController.getAllDisposisiUmum
);

// 🔹 Tambah disposisi dari Kepala
router.post(
  '/tambah-kepala',
  authMiddleware,
  roleMiddleware('kepala'),
  disposisiController.tambahDisposisiKepala
);

// 🔹 Tambah disposisi dari Umum
router.post(
  '/tambah-umum',
  authMiddleware,
  roleMiddleware('umum'),
  disposisiController.tambahDisposisiUmum
);

// 🔹 Update status disposisi (opsional)
router.put(
  '/:id_disposisi/update-status',
  authMiddleware,
  roleMiddleware('umum'),
  disposisiController.updateStatusDisposisi
);

// 🔹 Konfirmasi disposisi Umum (baru)
router.put(
  '/umum/:id_disposisi/konfirmasi',
  authMiddleware,
  roleMiddleware('umum'),
  disposisiController.konfirmasiDisposisiUmum
);

module.exports = router;
