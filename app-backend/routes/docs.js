import express from "express";
import multer from "multer";
import File from "../models/File.js";

const router = express.Router();

// ------- Multer Disk Storage Setup --------
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/"); // 👈 uploads folder project root me hona chahiye
  },
  filename: (req, file, cb) => {
    const uniqueName = Date.now() + "-" + file.originalname;
    cb(null, uniqueName);
  }
});

const upload = multer({ storage });

// ---------------- Upload ----------------
router.post("/upload", upload.single("file"), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ msg: "No file uploaded" });

    const newFile = await File.create({
      originalName: req.file.originalname,
      storedName: req.file.filename,
      mimeType: req.file.mimetype,
      size: req.file.size,
      path: req.file.path,
      url: `/uploads/${req.file.filename}`
    });

    res.json({ ok: true, file: newFile });
  } catch (err) {
    console.error(err);
    res.status(500).json({ msg: "Upload failed", err });
  }
});

// ---------------- List Files ----------------
router.get("/", async (req, res) => {
  try {
    const files = await File.find().sort({ createdAt: -1 });
    res.json(files);
  } catch (err) {
    res.status(500).json({ msg: "Error fetching files", err });
  }
});

// ---------------- Download / Preview ----------------
router.get("/download/:id", async (req, res) => {
  try {
    const file = await File.findById(req.params.id);
    if (!file) return res.status(404).json({ msg: "Not found" });

    res.download(file.path, file.originalName);
  } catch (err) {
    res.status(500).json({ msg: "Error downloading file", err });
  }
});

// ---------------- Delete ----------------
router.delete("/:id", async (req, res) => {
  try {
    const file = await File.findById(req.params.id);
    if (!file) return res.status(404).json({ msg: "Not found" });

    await File.deleteOne({ _id: file._id });
    res.json({ ok: true, msg: "File deleted" });
  } catch (err) {
    res.status(500).json({ msg: "Error deleting file", err });
  }
});

export default router;
