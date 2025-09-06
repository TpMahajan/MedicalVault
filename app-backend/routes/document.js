import express from "express";
import multer from "multer";
import fs from "fs";
import path from "path";
import File from "../models/File.js";

const router = express.Router();

// ------- Multer Disk Storage Setup --------
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/"); // uploads folder project root me hona chahiye
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

    const { email, title, category, date, notes } = req.body;

    const newFile = await File.create({
      userId: email, // 👈 user email
      title: title || req.file.originalname,
      notes: notes || "",
      date: date || new Date().toISOString(),
      originalName: req.file.originalname,
      storedName: req.file.filename,
      mimeType: req.file.mimetype,
      size: req.file.size,
      path: req.file.path,
      url: `/uploads/${req.file.filename}`,
      category: category || "Other",
    });

    res.json({ ok: true, file: newFile });
  } catch (err) {
    console.error(err);
    res.status(500).json({ msg: "Upload failed", err: err.message });
  }
});

// ---------------- List Files ----------------
router.get("/", async (req, res) => {
  try {
    const { email, category } = req.query;
    const query = {};

    if (email) query.userId = email;
    if (category) query.category = { $regex: new RegExp(`^${category}$`, "i") }; // case-insensitive

    const files = await File.find(query).sort({ createdAt: -1 });

    res.json({
      success: true,
      count: files.length,
      documents: files.map(f => ({
        id: f._id.toString(),
        userId: f.userId,
        title: f.title || f.originalName,
        notes: f.notes,
        date: f.date,
        fileName: f.originalName,
        fileType: f.mimeType?.split("/").pop() || "file",
        uploadedAt: f.createdAt,
        url: f.url,
        category: f.category,
      })),
    });
  } catch (err) {
    res.status(500).json({ success: false, msg: "Error fetching files", err: err.message });
  }
});

// ---------------- Download ----------------
router.get("/download/:id", async (req, res) => {
  try {
    const file = await File.findById(req.params.id);
    if (!file) return res.status(404).json({ msg: "Not found" });

    res.download(file.path, file.originalName);
  } catch (err) {
    res.status(500).json({ msg: "Error downloading file", err: err.message });
  }
});

// ---------------- Delete ----------------
router.delete("/:id", async (req, res) => {
  try {
    const file = await File.findById(req.params.id);
    if (!file) return res.status(404).json({ msg: "Not found" });

    const filePath = path.resolve(file.path);
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }

    await File.deleteOne({ _id: file._id });

    res.json({ ok: true, msg: "File deleted" });
  } catch (err) {
    res.status(500).json({ msg: "Error deleting file", err: err.message });
  }
});

export default router;
