// index.js - HealthVault (integrated, production-ready)
import express from "express";
import mongoose from "mongoose";
import dotenv from "dotenv";
import cors from "cors";
import helmet from "helmet";
import compression from "compression";
import morgan from "morgan";
import jwt from "jsonwebtoken";
import multer from "multer";
import { ObjectId, GridFSBucket } from "mongodb";

// Load env (use your existing file; replace or remove path if you use .env)
dotenv.config({ path: "./db.env" }); // if you use db.env
// dotenv.config(); // uncomment this instead if you use .env

// Config imports (ensure these files exist)
import connectDB from "./config/database.js";
import { initializeFirebase } from "./config/firebase.js";

// App routes (ensure these exist)
import authRoutes from "./routes/authRoutes.js";
import userRoutes from "./routes/user.js";
import notificationRoutes from "./routes/notifications.js";
import docsRoutes from "./routes/docs.js";   // <-- Docs route import

// Middleware / utils
import { apiLimiter } from "./middleware/rateLimit.js";

const app = express();  // <-- APP INIT sabse pehle hona chahiye
const PORT = process.env.PORT || 5000;
const ENV = process.env.NODE_ENV || "development";

// Basic middleware
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
    },
  },
  crossOriginEmbedderPolicy: false,
}));
app.use(cors({
  origin: ENV === 'production' ? ['https://yourdomain.com'] : ['http://localhost:3000','http://localhost:8080'],
  credentials: true,
}));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(compression());
app.use(morgan(ENV === 'development' ? 'dev' : 'combined'));

// Rate limit for API
app.use('/api/', apiLimiter);

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/user', userRoutes);
app.use('/api/notifications', notificationRoutes);
app.use("/api/docs", docsRoutes);   // <-- Ab yaha rakha hai (app ke baad)

// Health and root
app.get('/health', (req, res) => res.json({ ok: true, env: ENV, time: new Date().toISOString() }));
app.get('/', (req, res) => res.json({ message: 'HealthVault API running' }));

/* ----------------- GridFS & Upload routes (will be available after DB connect) ----------------- */

// Multer in-memory storage (we stream from buffer into GridFS)
const upload = multer({ storage: multer.memoryStorage() });

// Documents collection helper (will use mongoose connection db after connect)
const Documents = () => mongoose.connection.db.collection('documents');

let bucket; // GridFSBucket instance will be assigned after DB connect

// Upload route
app.post('/api/docs/upload', upload.single('file'), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ msg: 'No file uploaded' });

    const { originalname, mimetype, buffer } = req.file;

    const uploadStream = bucket.openUploadStream(originalname, { contentType: mimetype });
    uploadStream.end(buffer);

    uploadStream.on('finish', async (file) => {
      const doc = {
        fileId: file._id,
        title: originalname,
        mimeType: mimetype,
        category: (req.body.category || 'uncategorized').toLowerCase(),
        createdAt: new Date(),
        uploadedBy: req.body.uploadedBy || null,
      };
      const { insertedId } = await Documents().insertOne(doc);
      res.json({ ok: true, docId: insertedId.toString(), fileId: file._id.toString() });
    });

    uploadStream.on('error', (err) => {
      console.error('GridFS upload error:', err);
      res.status(500).json({ msg: 'Upload error', err: String(err) });
    });

  } catch (err) {
    console.error('Upload exception:', err);
    res.status(500).json({ msg: 'Server error', err: String(err) });
  }
});

// Share token route
app.post('/api/docs/:docId/share', async (req, res) => {
  try {
    const doc = await Documents().findOne({ _id: new ObjectId(req.params.docId) });
    if (!doc) return res.status(404).json({ msg: 'Document not found' });

    const token = jwt.sign(
      { docId: doc._id.toString(), scope: 'share' },
      process.env.JWT_SECRET,
      { expiresIn: '10m' }
    );

    res.json({ token });
  } catch (err) {
    console.error('Share token error:', err);
    res.status(500).json({ msg: 'Server error', err: String(err) });
  }
});

// Access document via token
app.get('/api/docs/access', async (req, res) => {
  try {
    const { token } = req.query;
    if (!token) return res.status(400).json({ msg: 'Token required' });

    const payload = jwt.verify(token, process.env.JWT_SECRET);
    if (payload.scope !== 'share') return res.status(403).json({ msg: 'Invalid scope' });

    const doc = await Documents().findOne({ _id: new ObjectId(payload.docId) });
    if (!doc) return res.status(404).json({ msg: 'Document not found' });

    res.setHeader('Content-Type', doc.mimeType || 'application/octet-stream');
    res.setHeader('Content-Disposition', 'inline; filename="' + (doc.title || 'file') + '"');

    bucket.openDownloadStream(doc.fileId).pipe(res).on('error', (err) => {
      console.error('Download stream error:', err);
      if (!res.headersSent) res.status(500).end();
    });

  } catch (err) {
    console.warn('Access token verify failed:', err.message || err);
    return res.status(401).json({ msg: 'Invalid or expired token' });
  }
});

/* ----------------- Start server (connect DB first) ----------------- */

const startServer = async () => {
  try {
    await connectDB();

    const client = mongoose.connection.getClient();
    const db = client.db();
    bucket = new GridFSBucket(db, { bucketName: 'uploads' });
    console.log('🔹 GridFS bucket initialized');

    try {
      initializeFirebase();
      console.log('🔹 Firebase initialized');
    } catch (fbErr) {
      console.warn('⚠️ Firebase init failed (notifications disabled):', fbErr.message || fbErr);
    }

    app.listen(PORT, () => {
      console.log(`🚀 Server running on http://localhost:${PORT}`);
      console.log(`📚 Health check: http://localhost:${PORT}/health`);
    });

  } catch (err) {
    console.error('❌ Failed to start server:', err);
    process.exit(1);
  }
};

process.on('unhandledRejection', (err) => {
  console.error('❌ Unhandled Promise Rejection:', err);
  process.exit(1);
});
process.on('uncaughtException', (err) => {
  console.error('❌ Uncaught Exception:', err);
  process.exit(1);
});

startServer();
