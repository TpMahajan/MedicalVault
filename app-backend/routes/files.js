import express from "express";
import File from "../models/File.js";

const router = express.Router();

/**
 * GET /api/files/:email
 * Email se files fetch karo aur category-wise group karke bhejo
 */
router.get("/:email", async (req, res) => {
  try {
    const { email } = req.params;

    // Fetch all files for this user
    const files = await File.find({ userId: email });

    // Group by category
    const grouped = {
      reports: files.filter(f => f.category?.toLowerCase() === "report"),
      prescriptions: files.filter(f => f.category?.toLowerCase() === "prescription"),
      bills: files.filter(f => f.category?.toLowerCase() === "bill"),
      insurance: files.filter(f => f.category?.toLowerCase() === "insurance"),
      others: files.filter(
        f =>
          !["report", "prescription", "bill", "insurance"].includes(
            f.category?.toLowerCase()
          )
      ),
    };

    res.json({
      success: true,
      email,
      counts: {
        reports: grouped.reports.length,
        prescriptions: grouped.prescriptions.length,
        bills: grouped.bills.length,
        insurance: grouped.insurance.length,
        others: grouped.others.length,
      },
      records: grouped,
    });
  } catch (error) {
    console.error("❌ Error fetching files:", error);
    res.status(500).json({ message: "Failed to fetch files" });
  }
});

export default router;
