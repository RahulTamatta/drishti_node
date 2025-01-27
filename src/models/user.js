const mongoose = require("mongoose");
const constants = require("../common/utils/constants");

const userSchema = new mongoose.Schema(
  {
    profileImage: String,
    userName: { type: String, unique: true },
    name: String,
    email: String,
    mobileNo: String,
    bio: {
      type: String
    },
    teacherId: String,
    teacherIdCard: String,
    deviceTokens: [],
    countryCode: String,
    isOnboarded: { type: Boolean, default: false },
    teacherRoleApproved: {
      type: String,
      default: constants.STATUS.PENDING,
      enum: [
        constants.STATUS.PENDING,
        constants.STATUS.ACCEPTED,
        constants.STATUS.REJECTED,
      ],
    },
    location: String,
    latlong: {
      type: {
        type: String,
        enum: ['Point'],
        // required: true,
      },
      coordinates: {
        type: [Number],
        // required: true,
      },
    },

    role: {
      type: String,
      enum: [
        constants.ROLES.ADMIN,
        constants.ROLES.TEACHER,
        constants.ROLES.USER,
      ],
      default: constants.ROLES.USER,
    },
    deletedAt: mongoose.Schema.Types.Date,
    youtubeUrl: String,
    xUrl: String,
    instagramUrl: String,
    nearByVisible: { type: Boolean, default: false },
    locationSharing: { type: Boolean, default: false },

    teacherRequestHandledBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
    },
    //notificationEnabled: { type: Boolean, default: false },  // New field

  },
  {
    timestamps: true,
  }
);

//userSchema.index({ "latlong.coordinates": "2dsphere" });
userSchema.index({ latlong: '2dsphere' });


const User = mongoose.model("User", userSchema);

module.exports = User;