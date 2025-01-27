const mongoose = require("mongoose");

const notificationSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true
  },
  description: {
    type: String,
    required: true
  },
  eventId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Event",
    required: true
  },
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true
  },
  status: {
    type: String,
    default: 'pending'
  },

  createdAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

const Notification = mongoose.model("Notification", notificationSchema);

module.exports = Notification;
