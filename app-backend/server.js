import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';
import dotenv from 'dotenv';

// Config
import connectDB from './config/database.js';
import { initializeFirebase } from './config/firebase.js';

// Middleware
import { apiLimiter } from './middleware/rateLimit.js';

// Routes
import authRoutes from './routes/auth.js';
import userRoutes from './routes/user.js';
import notificationRoutes from './routes/notifications.js';
import documentRoutes from './routes/document.js';   // 👈 Added

// Load environment variables
dotenv.config();

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 5000;
const ENV = process.env.NODE_ENV || 'development';

/* ----------------------------- Middleware ----------------------------- */

// Security headers
app.use(
  helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'"],
        scriptSrc: ["'self'"],
        imgSrc: ["'self'", "data:", "https:"],
      },
    },
    crossOriginEmbedderPolicy: false,
  })
);

// CORS
app.use(
  cors({
    origin:
      ENV === 'production'
        ? ['https://yourdomain.com'] // Replace with real Flutter web domain
        : ['http://localhost:3000', 'http://localhost:8080'],
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  })
);

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Compression
app.use(compression());

// Logging
app.use(morgan(ENV === 'development' ? 'dev' : 'combined'));

// Rate limiting for API
app.use('/api/', apiLimiter);

/* ----------------------------- Routes ----------------------------- */

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: '🚀 Server is running',
    environment: ENV,
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
  });
});

// API routes
app.use('/api/auth', authRoutes);
app.use('/api/user', userRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/documents', documentRoutes);        // 👈 Documents route added

// Static file serving for uploaded docs
app.use('/uploads', express.static('uploads'));   // 👈 direct access via URL

// Root
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Welcome to Flutter App Backend API',
    version: '1.0.0',
    endpoints: {
      auth: '/api/auth',
      user: '/api/user',
      notifications: '/api/notifications',
      documents: '/api/documents',
    },
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: `Route ${req.originalUrl} not found`,
  });
});

// Global error handler
app.use((error, req, res, next) => {
  console.error('Global error handler:', error);

  res.status(error.statusCode || 500).json({
    success: false,
    message: error.message || 'Internal Server Error',
    ...(ENV === 'development' && { stack: error.stack }),
  });
});

/* ----------------------------- Start Server ----------------------------- */

const startServer = async () => {
  try {
    // Connect to MongoDB
    await connectDB();

    // Initialize Firebase (optional)
    try {
      initializeFirebase();
    } catch (err) {
      console.warn('⚠️ Firebase init failed:', err.message);
    }

    // Start Express server
    app.listen(PORT, () => {
      console.log(`🚀 Server running on port ${PORT}`);
      console.log(`📱 Environment: ${ENV}`);
      console.log(`🔗 Health: http://localhost:${PORT}/health`);
      console.log(`📚 API: http://localhost:${PORT}/api`);
    });
  } catch (err) {
    console.error('❌ Failed to start server:', err);
    process.exit(1);
  }
};

// Handle crashes gracefully
process.on('unhandledRejection', (err) => {
  console.error('❌ Unhandled Promise Rejection:', err);
  process.exit(1);
});
process.on('uncaughtException', (err) => {
  console.error('❌ Uncaught Exception:', err);
  process.exit(1);
});

startServer();
