const express = require("express");
const router = express.Router();

const {
    createTracking,
    getTrackingBySurat,
    updateTrackingStatus
} = require("../controllers/trackingController");

router.post("/", createTracking);
router.get("/:id_surat", getTrackingBySurat);
router.put("/:id_surat", updateTrackingStatus);

module.exports = router;
