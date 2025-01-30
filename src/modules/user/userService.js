const { isEmpty, generateJWT } = require("../../common/utils/app_functions");
const User = require("../../models/user");
const appError = require("../../common/utils/appError");
const httpStatus = require("../../common/utils/status.json");
const { createToken } = require("../../middleware/genrateTokens");
const { ROLES } = require("../../common/utils/constants");
const { encode, decode } = require("../../common/utils/crypto");
const { generateOTP } = require("../../common/utils/helpers");
const { uploadToS3, deleteFromS3 } = require("../../common/utils/uploadToS3");
const constants = require("../../common/utils/constants");
const sendSms = require("../../common/utils/messageService");
const OtpRecord = require('../../models/otp');
const { request } = require("express");
const Twilio = require('twilio');


function AddMinutesToDate(date, minutes) {
  return new Date(date.getTime() + minutes * 60000);
}



// After (correct initialization)
const client = new Twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);

const userLoginService = async (request) => {
  try {
    const { mobileNo, countryCode } = request.body;

    // Validate required fields
    if (!mobileNo || !countryCode) {
      throw new appError(httpStatus.BAD_REQUEST, "Mobile number and country code are required");
    }

    // Validate if TWILIO_VERIFY_SID exists
    if (!process.env.TWILIO_VERIFY_SID) {
      throw new appError(httpStatus.INTERNAL_SERVER_ERROR, "Twilio Verify Service not configured");
    }

    // Use Twilio Verify API to send OTP
    try {
      const formattedNumber = `${
        countryCode.startsWith('+') ? countryCode : `+${countryCode}`
      }${mobileNo}`;
      
      const verification = await client.verify.v2
        .services(process.env.TWILIO_VERIFY_SID)
        .verifications
        .create({
          to: formattedNumber,
          channel: 'sms'
        });

      // Save OTP record for cooldown tracking
      await OtpRecord.create({
        mobileNo,
        countryCode,
        createdAt: new Date(),
      });

      return { data: { message: "OTP sent successfully" } };
    } catch (twilioError) {
      console.error('Twilio API Error:', twilioError);
      if (twilioError.code === 60200) {
        throw new appError(httpStatus.BAD_REQUEST, "Invalid phone number format");
      }
      throw new appError(httpStatus.INTERNAL_SERVER_ERROR, "Failed to send OTP: " + twilioError.message);
    }
  } catch (error) {
    console.error('Service Error:', error);
    throw error;
  }
};

const verifyOtp = async (request) => {
  const { mobileNo, otp, deviceToken } = request.body; // Removed countryCode

  try {
    // Validate input (removed countryCode check)
    if (!mobileNo || !otp) {
      throw new appError(httpStatus.BAD_REQUEST, "Missing required fields");
    }

    // Validate OTP length
    if (otp.length !== 6 || !/^\d{6}$/.test(otp)) {
      throw new appError(httpStatus.BAD_REQUEST, "OTP must be 6 digits");
    }

    const formattedNumber = mobileNo.startsWith('+') ? mobileNo : `+${mobileNo}`;
    try {
      // Verify OTP using Twilio Verify API
      const verificationCheck = await client.verify.v2
        .services(process.env.TWILIO_VERIFY_SID)
        .verificationChecks
        .create({ 
          to: formattedNumber, 
          code: otp 
        });

      console.log('Verification Status:', verificationCheck.status);

      if (verificationCheck.status !== 'approved') {
        throw new appError(httpStatus.UNAUTHORIZED, "Invalid OTP");
      }

      // Find or create user (removed countryCode from creation)
      let user = await User.findOne({ mobileNo });
      if (!user) {
        user = await User.create({
          mobileNo,
          deviceTokens: deviceToken ? [deviceToken] : [],
        });
      } else if (deviceToken && !user.deviceTokens.includes(deviceToken)) {
        user.deviceTokens.push(deviceToken);
        await user.save();
      }

      // Generate and return JWT token
      const token = await createToken(user);
      if (!token) {
        throw new appError(httpStatus.INTERNAL_SERVER_ERROR, "Failed to generate auth token");
      }

      return token;

    } catch (twilioError) {
      console.error('Twilio Verification Error:', twilioError);
      
      // Handle specific Twilio error codes
      switch(twilioError.code) {
        case 20404:
          throw new appError(httpStatus.NOT_FOUND, "Verification code expired");
        case 20001:
          throw new appError(httpStatus.UNAUTHORIZED, "Invalid verification code");
        case 60200:
          throw new appError(httpStatus.BAD_REQUEST, "Invalid phone number format");
        case 60202:
          throw new appError(httpStatus.BAD_REQUEST, "Invalid verification code format");
        case 60203:
          throw new appError(httpStatus.TOO_MANY_REQUESTS, "Maximum verification attempts reached");
        default:
          throw new appError(
            httpStatus.INTERNAL_SERVER_ERROR, 
            "Verification failed: " + (twilioError.message || "Unknown error")
          );
      }
    }

  } catch (error) {
    console.error('Verification Service Error:', error);
    
    if (error instanceof appError) {
      throw error;
    }
    
    throw new appError(
      error.status || httpStatus.INTERNAL_SERVER_ERROR,
      error.message || "Verification failed"
    );
  }
};
const updateLocation = async (request) => {
  const { lat, long, location } = request.body;

  return await User.findByIdAndUpdate(
    request.user.id,
    {
      location: location,
      latlong: {
        type: "Point",
        coordinates: [parseFloat(long), parseFloat(lat)],
      },
    },
    {
      new: true,
    }
  );
};

const onBoardUser = async (request) => {
  const { name, email, userName, mobileNo, bio, teacherId, role } =
    request.body;
  const profileImg =
    request.files?.profileImage != null ||
      request.files?.profileImage != undefined
      ? request.files?.profileImage[0]?.location
      : "";
  const teacherIdCard =
    request.files?.teacherIdCard != null ||
      request.files?.teacherIdCard != undefined
      ? request.files?.teacherIdCard[0]?.location
      : "";

  const Email = email.toLowerCase();
  const isExistingEmail = await User.findOne({
    email: Email,
    _id: { $ne: request.user.id },
  });
  const isExistingUserName = await User.findOne({
    userName: userName,
    _id: { $ne: request.user.id },
  });

  if (isExistingEmail || isExistingUserName) {
    if (Object.keys(request.files).length != 0) {
      if (teacherIdCard != "") {
        await deleteFromS3(request.files?.teacherIdCard[0]?.location);

        if (profileImg != "") {
          await deleteFromS3(request.files?.profileImage[0]?.location);
        }
      }
    }
    if (isExistingEmail) {
      throw new appError(httpStatus.CONFLICT, request.t("user.EMAIL_EXISTENT"));
    } else {
      throw new appError(
        httpStatus.CONFLICT,
        request.t("user.UserName_EXISTENT")
      );
    }
  }

  if (role === ROLES.TEACHER) {
    return await User.findByIdAndUpdate(
      request.user.id,
      {
        name: name,
        email: Email,
        userName: userName,
        mobileNo: mobileNo,
        profileImage: profileImg,
        isOnboarded: true,
        teacherIdCard: teacherIdCard,
        teacherId: teacherId,
        role: ROLES.TEACHER,
        bio: bio,
      },
      {
        new: true,
      }
    );
  }
  return await User.findByIdAndUpdate(
    request.user.id,
    {
      name: name,
      email: Email,
      mobileNo: mobileNo,
      userName: userName,
      profileImage: profileImg,
      isOnboarded: true,
      bio: bio,
      role: ROLES.USER,
    },
    {
      new: true,
    }
  );
};

async function addTeacherRole(request, params) {
  try {
    const user = await User.findById(request.user.id);
    if (user) {
      return await User.findByIdAndUpdate(
        request.user.id,
        {
          teacherId: params.teacherId,
          teacherIdCard: params.teacherIdCard[0].link,
          role: ROLES.TEACHER,
        },
        { new: true }
      );
    } else {
      throw new appError(
        httpStatus.NOT_FOUND,
        request.t("user.USER_NOT_FOUND")
      );
    }
  } catch (error) {
    throw new appError(httpStatus.INTERNAL_SERVER_ERROR, error.message);
  }
}

async function updateUser(params, request) {
  const currentUser = request.user;
  try {
    const user = await User.findById(request.user.id);
    if (user) {
      if (!isEmpty(params.email)) {
        const emailedUser = await User.findOne({ email: params.email });
        if (isEmpty(emailedUser)) {
          user.email = params.email;
          await user.save();
        } else {
          throw new appError(
            httpStatus.CONFLICT,
            request.t("user.EMAIL_EXISTENT")
          );
        }
      }
      if (params.isTeacher) {
        user.teacherId = params.teacherId;
        await user.save();
      }
      if (
        !isEmpty(params.mobileNo) &&
        !isEmpty(params.countryCode) &&
        params.mobileNo != currentUser.mobileNo
      ) {
        const mobiledUser = await User.findOne({
          mobileNo: params.mobileNo,
          countryCode: params.countryCode,
        });
        if (isEmpty(mobiledUser)) {
          user.mobileNo = params.mobileNo;
          user.countryCode = params.countryCode;
          await user.save();
        } else {
          throw new appError(
            httpStatus.CONFLICT,
            request.t("user.MOBILE_EXISTENT")
          );
        }
      }
      if (!isEmpty(params.fullName)) {
        user.fullName = params.fullName;
        await user.save();
      }

      if (
        !isEmpty(params.userName) &&
        params.userName != currentUser.userName
      ) {
        const userWithUserName = await User.findOne({
          userName: params.userName,
          deletedAt: null,
        });
        if (isEmpty(userWithUserName)) {
          user.userName = params.userName;
        } else {
          throw new appError(
            httpStatus.CONFLICT,
            request.t("user.USER_NAME_EXISTENT")
          );
        }
      }
      if (!isEmpty(params.location)) {
        user.location = params.location;
      }
      await user.save();
      returnVal.data = user;
    } else {
      throw new appError(
        httpStatus.NOT_FOUND,
        request.t("user.USER_NOT_FOUND")
      );
    }
    return returnVal;
  } catch (error) {
    throw new appError(error.status, error.message);
  }
}

async function getUser(currentUser) {
  return await User.findById(currentUser);
}

async function getAllUsers() {
  return await User.aggregate([{ $match: { deletedAt: null } }]);
}

async function getUserAddress(request) {
  return await User.findById(request.user.id).select("address -_id");
}

async function getAllTeachers() {
  return await User.find({ role: ROLES.TEACHER });
}

async function actionOnTeacherAccount(request) {
  let { status, id } = request.query;

  try {
    const user = await User.findById(id);
    if (!user) {
      throw new appError(
        httpStatus.NOT_FOUND,
        request.t("user.TEACHER_NOT_FOUND")
      );
    }

    return await User.findByIdAndUpdate(
      id,
      {
        teacherRoleApproved: status,
        teacherRequestHandledBy: request.user.id,
      },
      { new: true }
    );
  } catch (error) {
    throw new appError(error.status, error.message);
  }
}

async function getTeachersRequest(request) {
  try {
    return await User.find({
      role: constants.ROLES.TEACHER,
      teacherRoleApproved: constants.STATUS.PENDING,
    });
  } catch (error) {
    throw new appError(error.status, error.message);
  }
}

async function uploadDocuments(params, request) {
  try {
    const user = await User.findById(request.user.id);
    if (user) {
      user.profileImageUrl = params[0].link;
      await user.save();
      return user;
    } else {
      throw new appError(
        httpStatus.NOT_FOUND,
        request.t("user.USER_NOT_FOUND")
      );
    }
  } catch (error) {
    throw new appError(error.status, error.message);
  }
}

async function updateSocialMediaLinks(request) {
  return await User.findByIdAndUpdate(
    request.user.id,
    { ...request.body },
    { new: true }
  );
}

async function locationSharing(request) {
  return await User.findByIdAndUpdate(
    request.user.id,
    { ...request.body },
    { new: true }
  );
}

const getSocialMedia = async (request) => {
  try {
    const userId = request.params.userId;
    const user = await User.findById(userId)
    if (!user) {
      throw new appError(httpStatus.NOT_FOUND, "User not found");
    }
    const socialLinks = {
      youtube: user.youtubeUrl || null,
      x: user.xUrl || null,
      instagram: user.instagramUrl || null
    };
    res.json(socialLinks);
    console.log(socialLinks)
  } catch (error) {
    throw new appError(httpStatus.INTERNAL_SERVER_ERROR, "Failed to retrieve social media links");
  }
};

const getNearbyVisibleUsers = async (longitude, latitude, radius = 1000) => {
  try {
    const users = await User.find({
      latlong: {
        $near: {
          $geometry: {
            type: "Point",
            coordinates: [longitude, latitude],
          },
          $maxDistance: radius,
        },
      },
    }).select("userName profileImage role")

    return users;
  } catch (error) {
    throw new Error("Error fetching nearby users: " + error.message);
  }
};


const updateUserService = async (request) => {
  return await User.findByIdAndUpdate(request.params.userId,
    { ...request.body },
    { new: true }
  )
};


const searchAllUserService = async (request) => {
  try {
    const { userName } = request.query;

    let filter = {};

    // If userName is provided, create a regex for case-insensitive search
    if (userName) {
      const query = userName.trim();
      filter["userName"] = { $regex: new RegExp(query, "i") };
    }

    // Fetch users based on the filter
    const users = await User.find(filter);

    // Return the filtered or complete user list
    return {
      message: "User.EditUser",
      data: users,
    };
  } catch (error) {
    console.error("Error fetching users:", error);
    throw new Error("User not found");
  }
};

const checkUserRoleService = async (request) => {
  try {
    const { userName } = request.query;
    if (!userName) {
      throw new Error("Username is required");
    }

    const query = userName.trim();
    const user = await User.findOne({ userName: { $regex: new RegExp(`^${query}$`, "i") } });

    if (!user) {
      return {
        message: "No teacher found with the provided teacherName.",
      };
    }

    if (user.role === constants.ROLES.TEACHER) {
      return {
        message: "User found",
        data: {
          userName: user.userName,
          email: user.email,
          teacherId: user.teacherId,
          id: user._id,
        },
      };
    } else {
      return {
        message: "User is not a teacher",
      };
    }
  } catch (error) {
    console.error("Error checking user role:", error);
    throw new Error(error.message || "An error occurred while checking the user role");
  }
};


module.exports = {
  userLoginService,
  updateLocation,
  onBoardUser,
  updateUser,
  getUser,
  uploadDocuments,
  addTeacherRole,
  getAllUsers,
  actionOnTeacherAccount,
  getAllTeachers,
  verifyOtp,
  getTeachersRequest,
  locationSharing,
  updateSocialMediaLinks,
  getSocialMedia,
  getNearbyVisibleUsers,
  updateUserService,
  searchAllUserService,
  checkUserRoleService

};