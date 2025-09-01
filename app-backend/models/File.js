import mongoose from "mongoose";

const fileSchema = new mongoose.Schema(
  {
    originalName: { type: String, required: true },
    storedName: { type: String, required: true },
    mimeType: { type: String },
    size: { type: Number },
    path: { type: String },
    url: { type: String }
  },
  { timestamps: true }
);

export default mongoose.model("File", fileSchema);
