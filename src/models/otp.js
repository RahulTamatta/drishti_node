const mongoose = require("mongoose");

const otpSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "user",
    },
    otp: String,
    expiration_time: Date,
    verified: {
      type: Boolean,
      default: false,
    },
  },

  {
    timestamps: true,
  }
);

const Otp = mongoose.model("Otp", otpSchema);

module.exports = Otp;
