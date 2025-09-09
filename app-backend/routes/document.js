import express from "express";
import multer from "multer";
import path from "path";
import { CloudinaryStorage } from "multer-storage-cloudinary";
import { v2 as cloudinary } from "cloudinary";
import File from "../models/File.js";

const router = express.Router();

// ---------------- Cloudinary Config ----------------
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

// ---------------- Cloudinary Storage ----------------
const storage = new CloudinaryStorage({
  cloudinary,
  params: async (req, file) => {
    const ext = path.extname(file.originalname).toLowerCase();
    const baseName = path.parse(file.originalname).name.replace(/\s+/g, "_");

    let resourceType = "image"; // default

    if ([".pdf", ".doc", ".docx", ".xls", ".xlsx"].includes(ext)) {
      resourceType = "raw"; // PDFs/docs
    } else if ([".mp4", ".mov", ".avi"].includes(ext)) {
      resourceType = "video";
    }

    return {
      folder: "medical-vault",
      public_id: `${Date.now()}-${baseName}`, // do NOT append extension manually
      resource_type: resourceType,
    };
  },
});

const upload = multer({ storage });

// ---------------- Upload ----------------
router.post("/upload", upload.single("file"), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ msg: "No file uploaded" });

    console.log("📂 Uploaded file:", req.file);

    const { email, title, category, date, notes } = req.body;

    const newFile = await File.create({
      userId: email,
      title: title || req.file.originalname,
      notes: notes || "",
      date: date || new Date().toISOString(),
      originalName: req.file.originalname,
      mimeType: req.file.mimetype,
      size: req.file.size,
      url: req.file.path,                  // ✅ already correct Cloudinary URL
      publicId: req.file.filename,         // ✅ needed for delete
      resourceType: req.file.resource_type, // ✅ needed for delete
      category: category || "Other",
    });

    res.json({ ok: true, file: newFile });
  } catch (err) {
    console.error("❌ Upload error:", err);
    res.status(500).json({ msg: "Upload failed", err: err.message });
  }
});

// ---------------- List Files ----------------
router.get("/", async (req, res) => {
  try {
    const { email, category } = req.query;
    const query = {};

    if (email) query.userId = email;
    if (category) query.category = { $regex: new RegExp(`^${category}$`, "i") };

    const files = await File.find(query).sort({ createdAt: -1 });

    res.json({
      success: true,
      count: files.length,
      documents: files.map((f) => ({
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
        resourceType: f.resourceType || "auto",
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

    // ✅ Redirect user to correct Cloudinary URL
    return res.redirect(file.url);
  } catch (err) {
    res.status(500).json({ msg: "Error downloading file", err: err.message });
  }
});

// ---------------- Delete ----------------
router.delete("/:id", async (req, res) => {
  try {
    const file = await File.findById(req.params.id);
    if (!file) return res.status(404).json({ msg: "Not found" });

    if (file.publicId) {
      await cloudinary.uploader.destroy(file.publicId, {
        resource_type: file.resourceType || "auto",
      });
    }

    await File.deleteOne({ _id: file._id });
    res.json({ ok: true, msg: "File deleted successfully" });
  } catch (err) {
    res.status(500).json({ msg: "Error deleting file", err: err.message });
  }
});

export default router;
