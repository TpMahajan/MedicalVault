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

    const { category } = req.body; // 👈 Flutter se bhejna hoga

    const newFile = await File.create({
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
    res.status(500).json({ msg: "Upload failed", err });
  }
});

// ---------------- List Files (grouped by category) ----------------
router.get("/", async (req, res) => {
  try {
    const files = await File.find().sort({ createdAt: -1 });

    // group by category
    const grouped = {
      Prescription: [],
      Report: [],
      Bill: [],
      Other: [],
    };

    files.forEach((f) => {
      const filePath = path.resolve(f.path);
      let fileBytes = null;

      if (fs.existsSync(filePath)) {
        fileBytes = fs.readFileSync(filePath); // Buffer
      }

      const fileData = {
        _id: f._id,
        fileName: f.originalName,
        fileType: f.mimeType?.split("/").pop() || "file",
        uploadedAt: f.createdAt,
        fileBytes,
      };

      grouped[f.category || "Other"].push(fileData);
    });

    res.json(grouped);
  } catch (err) {
    res.status(500).json({ msg: "Error fetching files", err });
  }
});

// ---------------- Download ----------------
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

    // delete from disk
    const filePath = path.resolve(file.path);
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }

    // delete from DB
    await File.deleteOne({ _id: file._id });

    res.json({ ok: true, msg: "File deleted" });
  } catch (err) {
    res.status(500).json({ msg: "Error deleting file", err });
  }
});

export default router;
