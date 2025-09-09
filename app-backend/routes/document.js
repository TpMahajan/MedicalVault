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

// ---------------- File Type Detection ----------------
const getResourceType = (filename) => {
  const ext = path.extname(filename).toLowerCase();
  
  // Image types
  const imageExts = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.svg', '.tiff', '.ico'];
  if (imageExts.includes(ext)) return 'image';
  
  // Video types
  const videoExts = ['.mp4', '.mov', '.avi', '.mkv', '.wmv', '.flv', '.webm', '.m4v'];
  if (videoExts.includes(ext)) return 'video';
  
  // Raw/Document types (PDFs, Office docs, etc.)
  const rawExts = ['.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx', '.txt', '.rtf', '.odt', '.ods', '.odp'];
  if (rawExts.includes(ext)) return 'raw';
  
  // Default to raw for unknown types
  return 'raw';
};

// ---------------- Cloudinary Storage ----------------
const storage = new CloudinaryStorage({
  cloudinary,
  params: async (req, file) => {
    const ext = path.extname(file.originalname).toLowerCase();
    const baseName = path.parse(file.originalname).name.replace(/\s+/g, "_");
    const resourceType = getResourceType(file.originalname);

    console.log(`📁 Uploading ${file.originalname} as ${resourceType} type`);

    return {
      folder: "medical-vault",
      public_id: `${Date.now()}-${baseName}`,
      resource_type: resourceType,
      // For raw files, ensure they're accessible
      ...(resourceType === 'raw' && {
        format: ext.substring(1), // Remove the dot
        resource_type: 'raw'
      })
    };
  },
});

const upload = multer({ 
  storage,
  limits: {
    fileSize: 50 * 1024 * 1024, // 50MB limit
  },
  fileFilter: (req, file, cb) => {
    // Allow all file types
    cb(null, true);
  }
});

// ---------------- Upload ----------------
router.post("/upload", upload.single("file"), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ msg: "No file uploaded" });

    console.log("📂 Uploaded file:", req.file);

    const { email, title, category, date, notes } = req.body;
    const resourceType = getResourceType(req.file.originalname);

    const newFile = await File.create({
      userId: email,
      title: title || req.file.originalname,
      notes: notes || "",
      date: date || new Date().toISOString(),
      originalName: req.file.originalname,
      mimeType: req.file.mimetype,
      size: req.file.size,
      url: req.file.path,                  // ✅ Cloudinary URL
      publicId: req.file.filename,         // ✅ needed for delete
      resourceType: resourceType,          // ✅ correct resource type
      category: category || "Other",
    });

    res.json({ 
      ok: true, 
      file: {
        id: newFile._id.toString(),
        userId: newFile.userId,
        title: newFile.title,
        notes: newFile.notes,
        date: newFile.date,
        fileName: newFile.originalName,
        fileType: newFile.mimeType?.split("/").pop() || "file",
        uploadedAt: newFile.createdAt,
        url: newFile.url,
        category: newFile.category,
        resourceType: newFile.resourceType,
        publicId: newFile.publicId
      }
    });
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
    if (!file) return res.status(404).json({ msg: "File not found" });

    // Generate a signed URL for secure download
    const downloadUrl = cloudinary.url(file.publicId, {
      resource_type: file.resourceType || 'auto',
      secure: true,
      flags: 'attachment' // Force download instead of preview
    });

    console.log(`📥 Download URL generated for ${file.originalName}: ${downloadUrl}`);
    
    // Redirect to the signed URL
    return res.redirect(downloadUrl);
  } catch (err) {
    console.error("❌ Download error:", err);
    res.status(500).json({ msg: "Error downloading file", err: err.message });
  }
});

// ---------------- Get File Info ----------------
router.get("/info/:id", async (req, res) => {
  try {
    const file = await File.findById(req.params.id);
    if (!file) return res.status(404).json({ msg: "File not found" });

    res.json({
      success: true,
      file: {
        id: file._id.toString(),
        title: file.title,
        fileName: file.originalName,
        url: file.url,
        resourceType: file.resourceType,
        mimeType: file.mimeType,
        size: file.size,
        category: file.category,
        date: file.date
      }
    });
  } catch (err) {
    res.status(500).json({ msg: "Error fetching file info", err: err.message });
  }
});

// ---------------- Delete ----------------
router.delete("/:id", async (req, res) => {
  try {
    const file = await File.findById(req.params.id);
    if (!file) return res.status(404).json({ msg: "File not found" });

    console.log(`🗑️ Deleting file: ${file.originalName} (${file.publicId})`);

    // Delete from Cloudinary first
    if (file.publicId) {
      try {
        const result = await cloudinary.uploader.destroy(file.publicId, {
          resource_type: file.resourceType || "auto",
        });
        console.log("☁️ Cloudinary deletion result:", result);
      } catch (cloudinaryErr) {
        console.error("⚠️ Cloudinary deletion failed:", cloudinaryErr);
        // Continue with database deletion even if Cloudinary fails
      }
    }

    // Delete from database
    await File.deleteOne({ _id: file._id });
    
    console.log("✅ File deleted successfully from database");
    res.json({ 
      ok: true, 
      msg: "File deleted successfully",
      deletedFile: {
        id: file._id.toString(),
        title: file.title,
        fileName: file.originalName
      }
    });
  } catch (err) {
    console.error("❌ Delete error:", err);
    res.status(500).json({ msg: "Error deleting file", err: err.message });
  }
});

export default router;
