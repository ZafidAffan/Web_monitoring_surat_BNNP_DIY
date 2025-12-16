const express = require('express');
const router = express.Router();

const { verifyToken } = require('../middleware/authMiddleware');
const { allowRoles } = require('../middleware/roleMiddleware');
const {
  createDisposisi,
  getDisposisiMasuk,
  konfirmasiDisposisi,
  updateStatusProses
} = require('../controllers/disposisiController');

// Admin & Kepala kirim disposisi
router.post(
  '/',
  verifyToken,
  allowRoles('admin', 'kepala'),
  createDisposisi
);

// Disposisi masuk (kepala / divisi)
router.get(
  '/masuk',
  verifyToken,
  allowRoles('kepala', 'divisi', 'admin'),
  getDisposisiMasuk
);

// Konfirmasi (dibaca)
router.put(
  '/:id/konfirmasi',
  verifyToken,
  allowRoles('kepala', 'divisi'),
  konfirmasiDisposisi
);

// Update status proses (divisi)
router.put(
  '/:id/status',
  verifyToken,
  allowRoles('divisi'),
  updateStatusProses
);

module.exports = router;
