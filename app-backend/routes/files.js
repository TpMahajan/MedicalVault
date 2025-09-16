import express from "express";
import File from "../models/document.js"; // your 'files' collection schema

const router = express.Router();

// GET /api/files/:userId → fetch all files for a user and group by category
router.get("/:userId", async (req, res) => {
  try {
    const { userId } = req.params;

    // Fetch all files belonging to this user
    const files = await File.find({ userId });

    // Group by category
    const grouped = {
      reports: files.filter(f => f.category?.toLowerCase() === "report"),
      prescriptions: files.filter(f => f.category?.toLowerCase() === "prescription"),
      bills: files.filter(f => f.category?.toLowerCase() === "bill"),
      insurance: files.filter(f => f.category?.toLowerCase() === "insurance"),
    };

    res.json(grouped);
  } catch (error) {
    console.error("❌ Error fetching files:", error);
    res.status(500).json({ message: "Failed to fetch files" });
  }
});

export default router;
