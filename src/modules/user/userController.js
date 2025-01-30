// const userService = require("./userService");
const userService = require("./userService.js");
const constants = require("../../common/utils/constants");
const appError = require("../../common/utils/appError");
const createResponse = require("../../common/utils/createResponse");
const httpStatus = require("../../common/utils/status.json");
const uploadFilesToBucket = require("../../middleware/uploadTofireBase");
const Twilio = require('twilio');
const OtpRecord = require('../../models/otp');
const User = require('../../models/user');

const { createToken } = require("../../middleware/genrateTokens");

// Initialize Twilio client
const client = new Twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);

const userLoginService = async (request) => {
  try {
    const { mobileNo, countryCode } = request.body;

    // Validate required fields
    if (!mobileNo || !countryCode) {
      throw new appError(httpStatus.BAD_REQUEST, "Mobile number and country code are required");
    }

    // Check for recent OTP requests (30-second cooldown)
    const lastOtpRecord = await OtpRecord.findOne({ mobileNo }).sort({ createdAt: -1 });
    if (lastOtpRecord && (new Date() - lastOtpRecord.createdAt < 30000)) {
      throw new appError(httpStatus.CONFLICT, "Please wait 30 seconds before requesting a new OTP.");
    }

    // Use Twilio Verify API to send OTP
    const verification = await client.verify.v2.services(process.env.TWILIO_VERIFY_SID)
      .verifications
      .create({ to: `${countryCode}${mobileNo}`, channel: 'sms' });

    // Save OTP record for cooldown tracking
    await OtpRecord.create({
      mobileNo,
      countryCode,
      createdAt: new Date(),
    });

    return { data: { message: "OTP sent successfully" } };
  } catch (error) {
    if (error.status === 409) {
      throw new appError(httpStatus.CONFLICT, "Please wait before requesting another OTP.");
    }
    throw new appError(httpStatus.INTERNAL_SERVER_ERROR, "Failed to send OTP");
  }
};

const verifyOtp = async (request) => {
  const { mobileNo, countryCode, otp, deviceToken } = request.body;

  try {
    // Verify OTP using Twilio Verify API
    const verificationCheck = await client.verify.v2.services(process.env.TWILIO_VERIFY_SID)
      .verificationChecks
      .create({ to: `${countryCode}${mobileNo}`, code: otp });

    if (verificationCheck.status !== 'approved') {
      throw new appError(httpStatus.UNAUTHORIZED, "Invalid OTP");
    }

    // Find or create user
    let user = await User.findOne({ mobileNo });
    if (!user) {
      user = await User.create({
        mobileNo,
        countryCode,
        deviceTokens: [deviceToken],
      });
    } else if (!user.deviceTokens.includes(deviceToken)) {
      user.deviceTokens.push(deviceToken);
      await user.save();
    }

    // Generate and return JWT token
    return createToken(user);
  } catch (error) {
    throw new appError(httpStatus.INTERNAL_SERVER_ERROR, "OTP verification failed");
  }
};

const updateLocationController = async (request, response) => {
  try {
    const data = await userService.updateLocation(request);
    if (!data) {
      throw new appError(
        httpStatus.CONFLICT,
        request.t("user.UNABLE_TO_UPDATE_LOCATION")
      );
    }
    createResponse(
      response,
      httpStatus.OK,
      request.t("user.USER_LOCATION_UPDATED"),
      data
    );
  } catch (error) {
    createResponse(response, error.status, error.message);
  }
};

const onBoardUserController = async (request, response) => {
  try {
    const data = await userService.onBoardUser(request);
    if (!data) {
      throw new appError(
        httpStatus.CONFLICT,
        request.t("user.UNABLE_TO_ONBOARD_USER")
      );
    }
    createResponse(
      response,
      httpStatus.OK,
      request.t("user.USER_ONBOARDED"),
      data
    );
  } catch (error) {
    console.log("error------", error);
    createResponse(response, error.status, error.message);
  }
};

async function getUser(request, response) {
  try {
    const data = await userService.getUser(request.user.id);
    console.log("data", data);
    if (!data) {
      throw new appError(httpStatus.CONFLICT);
    }
    createResponse(response, httpStatus.OK, "user log in", data);
  } catch (error) {
    createResponse(response, error.status, error.message);
  }
}

async function getAllUsers(request, response) {
  try {
    const data = await userService.getAllUsers();
    if (!data) {
      throw new appError(httpStatus.CONFLICT);
    }
    createResponse(response, httpStatus.OK, "user log in", data);
  } catch (error) {
    createResponse(response, error.status, error.message);
  }
}

const getAllTeachers = async (request, response) => {
  try {
    const data = await userService.getAllTeachers(request);
    if (!data) {
      throw new appError(httpStatus.CONFLICT);
    }
    createResponse(response, httpStatus.OK, "get all teachers", data);
  } catch (error) {
    createResponse(response, error.status, error.message);
  }
};
async function actionOnTeacherAccount(request, response) {
  try {
    let { status } = request.query;

    const data = await userService.actionOnTeacherAccount(request);
    let msg;
    if (data) {
      if (status === constants.STATUS.ACCEPTED) {
        msg = "Teacher request accepted";
      } else if (status === constants.STATUS.REJECTED) {
        msg = "Teacher request rejected";
      } else {
        msg = "Teacher request rejected";
      }
      return createResponse(response, 201, msg);
    }
  } catch (error) {
    return createResponse(response, error.status, error.message);
  }
}
async function getTeachersRequest(request, response) {
  try {
    const data = await userService.getTeachersRequest(request);
    if (!data) {
      throw new appError(
        httpStatus.CONFLICT,
        request.t("user.UNABLE_TO_GET_TEACHERS_REQUEST")
      );
    }

    return createResponse(
      response,
      201,
      request.t("user.GET_TEACHERS_REQUEST"),
      data
    );
  } catch (error) {
    return createResponse(response, error.status, error.message);
  }
}

const addTeacherRole = async (request, response) => {
  try {
    const { teacherIdCard } = request.files;
    if (!teacherIdCard) {
      throw new appError(
        httpStatus.CONFLICT,
        "please select a teacher id card"
      );
    }

    const params = request.body;
    params.teacherIdCard = await uploadFilesToBucket(teacherIdCard[0]);

    const data = await userService.addTeacherRole(request, params);
    if (!data) {
      throw new appError(httpStatus.CONFLICT);
    }
    createResponse(
      response,
      httpStatus.OK,
      "teacher id uploaded successfully",
      data
    );
  } catch (error) {
    createResponse(response, error.status, error.message);
  }
};

const addFiles = async (request, response) => {
  try {
    const { profilePic } = request.files;
    const fileWithUrls = await uploadFilesToBucket(profilePic);
    const data = await userService.uploadDocuments(fileWithUrls, request);
    if (!data) {
      throw new appError(httpStatus.CONFLICT);
    }
    console.log("data-----------", data);
    return createResponse(response, httpStatus.OK, "user log in", data);
  } catch (error) {
    console.log("error-----------", error);
    createResponse(response, error.status, error.message);
  }
};

const updateSocialMediaLinks = async (request, response) => {
  try {
    const data = await userService.updateSocialMediaLinks(request);
    if (!data) {
      throw new appError(httpStatus.CONFLICT);
    }
    console.log("data-----------", data);
    return createResponse(
      response,
      httpStatus.OK,
      "social media updated",
      data
    );
  } catch (error) {
    console.log("error-----------", error);
    createResponse(response, error.status, error.message);
  }
};
const locationSharing = async (request, response) => {
  try {
    const data = await userService.locationSharing(request);
    if (!data) {
      throw new appError(httpStatus.CONFLICT);
    }
    console.log("data-----------", data);
    return createResponse(response, httpStatus.OK, "location sharing", data);
  } catch (error) {
    console.log("error-----------", error);
    createResponse(response, error.status, error.message);
  }
};

const getSocialMediaController = async (request, response) => {
  try {
    const data = await userService.getSocialMedia(request);
    return createResponse(response, httpStatus.OK, "Social media links retrieved successfully", data);
  } catch (error) {
    console.log("error-----------", error);
    createResponse(response, error.status || httpStatus.INTERNAL_SERVER_ERROR, error.message || "Failed to fetch social media");
  }
};

const getNearbyVisible = async (request, response) => {
  const { longitude, latitude, radius } = request.body;

  if (!longitude || !latitude) {
    return createResponse(response, httpStatus.BAD_REQUEST, "Longitude and Latitude are required.");
  }
  try {
    const users = await userService.getNearbyVisibleUsers(longitude, latitude, radius);
    if (!users.length) {
      throw new appError(httpStatus.NON_AUTHORITATIVE_INFORMATION, "No nearby users found.");
    }

    createResponse(response, httpStatus.OK, "Nearby users fetched successfully.", users);
  } catch (error) {
    createResponse(response, error.status || httpStatus.INTERNAL_SERVER_ERROR, error.message);
  }
};

const updateUserController = async (request, response) => {
  try {
    const data = await userService.updateUserService(request);
    if (!data) {
      throw new appError(
        httpStatus.CONFLICT,
        request.t("User.UnableToEditUser")
      );
    }
    createResponse(
      response,
      httpStatus.OK,
      request.t("User.EditUser"),
      data
    );
  } catch (error) {
    createResponse(response, error.status, error.message);
  }
};


const searchAllUser = async (request, response) => {
  try {
    const data = await userService.searchAllUserService(request);
    if (!data) {
      throw new appError(
        httpStatus.CONFLICT,
        request.t("User.UnableToEditUser")
      );
    }
    createResponse(
      response,
      httpStatus.OK,
      request.t("User.EditUser"),
      data
    );
  } catch (error) {
    createResponse(response, error.status, error.message);
  }
};

const checkUserRoleController = async (request, response) => {
  try {
    const data = await userService.checkUserRoleService(request);
    if (!data) {
      throw new appError(httpStatus.NOT_FOUND, request.t("User.NotFound"));
    }
    createResponse(response, httpStatus.OK, data.message, data.data);
  } catch (error) {
    createResponse(response, httpStatus.BAD_REQUEST, error.message);
  }
};


module.exports = {
  userLoginController,
  onBoardUserController,
  updateLocationController,
  getUser,
  addFiles,
  addTeacherRole,
  getAllUsers,
  actionOnTeacherAccount,
  getAllTeachers,
  verifyOtpController,
  getTeachersRequest,
  updateSocialMediaLinks,
  locationSharing,
  getSocialMediaController,
  getNearbyVisible,
  updateUserController,
  searchAllUser,
  checkUserRoleController

};


