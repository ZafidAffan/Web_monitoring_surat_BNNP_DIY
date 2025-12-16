const express = require('express');
const router = express.Router();

const {
  createSuratMasuk,
  getSuratMasuk,
  getSuratMasukById,
  updateSuratMasuk,
  deleteSuratMasuk,
  countSuratMasuk
} = require('../controllers/suratMasukController');

const {
  verifyToken,
  allowRoles
} = require('../middleware/authMiddleware');

/* ================= ROUTES ================= */

// ⬅️ COUNT HARUS PALING ATAS (SEBELUM /:id)
router.get(
  '/count',
  verifyToken,
  allowRoles('admin', 'kepala'),
  countSuratMasuk
);

router.post(
  '/',
  verifyToken,
  allowRoles('admin'),
  createSuratMasuk
);

router.get(
  '/',
  verifyToken,
  allowRoles('admin', 'kepala', 'divisi'),
  getSuratMasuk
);

router.get(
  '/:id',
  verifyToken,
  getSuratMasukById
);

router.put(
  '/:id',
  verifyToken,
  updateSuratMasuk
);

router.delete(
  '/:id',
  verifyToken,
  deleteSuratMasuk
);

module.exports = router;
