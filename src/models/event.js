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
    phoneNumber: [{ type: String }], // Changed from String to array of strings
    registrationLink: String,
    location: {
      type: {
        type: String,
        enum: ['Point'],
        required: true
      },
      coordinates: {
        type: [Number],
        required: true,
        validate: {
          validator: function(coords) {
            return coords.length === 2 && 
                   coords[0] >= -180 && coords[0] <= 180 && // longitude 
                   coords[1] >= -90 && coords[1] <= 90;     // latitude
          },
          message: 'Invalid coordinates. Must be [longitude, latitude]'
        }
      }
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
