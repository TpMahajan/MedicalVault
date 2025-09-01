import mongoose from "mongoose";

const documentSchema = new mongoose.Schema({
  title: { type: String, required: true },
  fileId: { type: mongoose.Schema.Types.ObjectId, required: true },
  mimeType: { type: String },
  createdAt: { type: Date, default: Date.now }
});

export default mongoose.model("Document", documentSchema);
