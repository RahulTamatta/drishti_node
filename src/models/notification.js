const mongoose = require("mongoose");
const constants = require("../common/utils/constants");

const notificationSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },
    event: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Event",
      required: true
    },
    title: {
      type: String,
      required: true
    },
    description: {
      type: String,
      required: true
    },
    type: {
      type: String,
      enum: ["subscription", "reminder", "event_update"],
      default: "subscription"
    },
    status: {
      type: String,
      enum: ["pending", "read", "archived"],
      default: "pending"
    },
    scheduledTime: {
      type: Date
    },
    isOneHourReminder: {
      type: Boolean,
      default: false
    }
  },
  {
    timestamps: true
  }
);

const Notification = mongoose.model("Notification", notificationSchema);

module.exports = Notification;