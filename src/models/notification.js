const mongoose = require("mongoose");
const constants = require("../common/utils/constants");

const notificationSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    event: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Event",
      required: true,
    },
    title: {
      type: String,
      required: true,
    },
    description: {
      type: String,
      required: true,
    },
    type: {
      type: String,
      enum: ["subscription", "reminder", "event_update"],
      default: "subscription",
    },
    status: {
      type: String,
      enum: ["pending", "read", "archived", "completed"],
      default: "pending",
    },
    scheduledAt: {
      type: Date,
      required: false,
    },
    isOneHourReminder: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

// Pre-save hook: ensure scheduledAt is set if not provided
notificationSchema.pre("save", function (next) {
  if (!this.scheduledAt) {
    // Default to 1 minute after creation time
    this.scheduledAt = new Date(Date.now() + 1 * 60 * 1000);
  }
  next();
});

const Notification = mongoose.model("Notification", notificationSchema);

module.exports = Notification;
