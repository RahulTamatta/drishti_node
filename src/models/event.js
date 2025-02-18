const mongoose = require("mongoose");
const { TIME_INTERVALS } = require("../common/utils/constants");

const eventSchema = new mongoose.Schema(
  {
    title: {
      type: [String],
      enum: ["Sudarshan Kriya", "Medha Yoga", "Utkarsh Yoga", "Sahaj Samadh", "Ganesh Homa", "Durga Puja"],
    },
    mode: { type: String, enum: ["online", "offline"] },
    aol: { type: [String], enum: ["event", "course", "follow-up"] },
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    date: {
      from: { type: mongoose.Schema.Types.Date },
      to: { type: mongoose.Schema.Types.Date },
    },
    timeOffset: String,
    duration: [
      {
        from: { type: String, enum: TIME_INTERVALS },
        to: { type: String, enum: TIME_INTERVALS },
      },
    ],
    meetingLink: { type: String, trim: true },
    recurring: Boolean,
    description: String,
    address: [],
 // In the Event model schema
phoneNumber: [{ type: String }], // Changed from String to array of strings
    registrationLink: String,
    location: {
      type: { type: String, enum: ["Point"], default: "Point" },
      coordinates: { type: [Number], required: true },
    },
    teachers: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }],
    deletedAt: { type: mongoose.Schema.Types.Date },
    notifyTo: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }],
    imagesAndCaptions: [
      {
        userId: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
        images: [{ caption: String, isPrivate: Boolean, image: String }],
      },
    ],
    subscribers: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }],
    participants: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }],
  },
  { timestamps: true }
);

eventSchema.index({ location: "2dsphere" });

const Event = mongoose.model("Event", eventSchema);

module.exports = Event;
