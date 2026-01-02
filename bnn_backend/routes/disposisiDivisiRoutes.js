const express = require('express');
const router = express.Router();

const disposisiDivisiController = require('../controllers/disposisiDivisiController');
const authMiddleware = require('../middleware/authMiddleware');
const roleMiddleware = require('../middleware/roleMiddleware');

// ================= DASHBOARD DIVISI =================
router.get(
  '/dashboard',
  authMiddleware,
  roleMiddleware('divisi'),
  disposisiDivisiController.getDisposisiByDivisi
);

// ================= TERIMA DISPOSISI =================
router.put(
  '/disposisi/:id_disposisi/terima',
  authMiddleware,
  roleMiddleware('divisi'),
  disposisiDivisiController.terimaDisposisiDivisi
);

module.exports = router;
