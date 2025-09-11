// routes/qrRoutes.js
import express from "express";
import jwt from "jsonwebtoken";
import { auth } from "../middleware/auth.js";
import User from "../models/User.js";

const router = express.Router();

/**
 * Quick check: confirm this router is mounted
 * GET /api/qr/ping
 */
router.get("/ping", (req, res) => res.json({ ok: true, where: "qrRoutes" }));

/**
 * POST /api/qr/generate
 * Auth: required (patient)
 * Creates a short-lived JWT that carries the patient's userId and email.
 * Returns both the token and a URL that your QR can encode.
 */
router.post("/generate", auth, async (req, res) => {
  try {
    // Always read latest normalized email from DB
    const me = await User.findById(req.user._id).select("email name");
    if (!me) return res.status(404).json({ ok: false, msg: "User not found" });

    const payload = {
      typ: "vault_share",
      uid: req.user._id.toString(), // same id used by your login tokens
      email: me.email,              // handy because your files API keys by email
    };

    const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: "10m" });

    // Build a nice portal URL to embed in the QR
    const base = (process.env.BASE_URL || "").replace(/\/$/, "");
    const qrUrl = `${base}/portal/access?token=${encodeURIComponent(token)}`;

    return res.json({ ok: true, token, qrUrl });
  } catch (err) {
    console.error("QR generate error:", err);
    return res.status(500).json({ ok: false, msg: "QR generation failed" });
  }
});

/**
 * GET /api/qr/preview?token=...
 * Public (no auth): used by the web portal after scanning to show
 * patient info before the doctor clicks “Request Access”.
 */
router.get("/preview", async (req, res) => {
  try {
    const { token } = req.query;
    if (!token) return res.status(400).json({ ok: false, msg: "Missing token" });

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    if (decoded.typ !== "vault_share") {
      return res.status(400).json({ ok: false, msg: "Invalid token type" });
    }

    const user = await User.findById(decoded.uid).select("name email profilePicture");
    if (!user) return res.status(404).json({ ok: false, msg: "Patient not found" });

    return res.json({
      ok: true,
      patient: user,
      // helpful for UI countdowns
      expiresAt: decoded.exp ? decoded.exp * 1000 : null,
    });
  } catch (e) {
    return res.status(400).json({ ok: false, msg: "Invalid/expired token" });
  }
});

export default router;
