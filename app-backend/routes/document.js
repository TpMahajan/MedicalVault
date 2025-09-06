import express from "express";
import multer from "multer";
import fs from "fs";
import path from "path";
import File from "../models/File.js";

const router = express.Router();

// ------- Multer Disk Storage Setup --------
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/"); // uploads folder should exist in project root
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

    // Normalize Windows path to forward slash
    const normalizedPath = req.file.path.replace(/\\/g, "/");

    const newFile = await File.create({
      userId: email,
      title: title || req.file.originalname,
      notes: notes || "",
      date: date || new Date().toISOString(),
      originalName: req.file.originalname,
      storedName: req.file.filename,
      mimeType: req.file.mimetype,
      size: req.file.size,
      path: normalizedPath,            // ✅ normalized OS path
      url: "/" + normalizedPath,       // ✅ usable for frontend preview
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
        path: f.path,      // OS path if needed for delete
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

    const filePath = path.resolve(file.path.replace(/\//g, path.sep));
    res.download(filePath, file.originalName);
  } catch (err) {
    res.status(500).json({ msg: "Error downloading file", err: err.message });
  }
});

// ---------------- Delete ----------------
router.delete("/:id", async (req, res) => {
  try {
    const file = await File.findById(req.params.id);
    if (!file) return res.status(404).json({ msg: "Not found" });

    // Convert forward slash to OS-specific separator for deletion
    const filePath = path.resolve(file.path.replace(/\//g, path.sep));
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
