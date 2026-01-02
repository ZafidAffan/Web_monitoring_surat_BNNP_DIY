const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const suratMasukController = require('../controllers/suratMasukController');

// ================= MULTER =================
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, Date.now() + ext);
  }
});

const upload = multer({ storage });

// ================= ROUTES =================
router.post(
  '/',
  upload.single('file_surat'), // field harus sama dengan frontend
  suratMasukController.createSuratMasuk
);

router.get('/', suratMasukController.getSuratMasuk);

module.exports = router;
