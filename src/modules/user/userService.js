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

// Initialize Twilio client
const twilioClient = Twilio(
  process.env.TWILIO_ACCOUNT_SID,
  process.env.TWILIO_AUTH_TOKEN
);

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
  const { mobileNo, otp, deviceToken } = request.body;

  try {
    // 1. Validate required fields
    if (!mobileNo || !otp) {
      throw new appError(httpStatus.BAD_REQUEST, "Mobile number and OTP are required");
    }

    // 2. Validate OTP format (6-digit string)
    if (!/^\d{6}$/.test(otp)) {
      throw new appError(httpStatus.BAD_REQUEST, "OTP must be 6 numeric digits");
    }

    // 3. Validate Indian phone number format
    if (!/^\d{10}$/.test(mobileNo)) {
      throw new appError(
        httpStatus.BAD_REQUEST,
        "Invalid phone number. Use 10-digit Indian number (e.g., 8291541168)"
      );
    }

    // 4. Force E.164 format for Twilio
    const twilioPhoneNumber = `+91${mobileNo}`;

    // 5. Verify with Twilio
    const verificationCheck = await twilioClient.verify.v2
      .services(process.env.TWILIO_VERIFY_SID)
      .verificationChecks.create({
        to: twilioPhoneNumber,
        code: otp
      });

    // 6. Check verification status
    if (verificationCheck.status !== "approved") {
      throw new appError(httpStatus.UNAUTHORIZED, "Invalid or expired OTP");
    }

    // 7. Find/Create user
    let user = await User.findOne({ mobileNo });

    // New user creation
    if (!user) {
      user = await User.create({
        mobileNo,
        deviceTokens: deviceToken ? [deviceToken] : [],
      });
    }
    // Existing user - update device token
    else if (deviceToken && !user.deviceTokens.includes(deviceToken)) {
      user.deviceTokens.push(deviceToken);
      await user.save();
    }

    // 8. Generate JWT and ensure it exists
    const tokenData = await createToken(user);
    if (!tokenData || !tokenData.accessToken) {
      throw new appError(
        httpStatus.INTERNAL_SERVER_ERROR,
        "Failed to generate authentication token"
      );
    }

    // 9. Return response with guaranteed token data
    return {
      success: true,
      message: "OTP verified successfully",
      data: {
        role: user.role,
        accessToken: tokenData.accessToken,
        accessTokenExpiresAt: tokenData.accessTokenExpiresAt.toISOString(),
        refreshToken: tokenData.refreshToken,
        refreshTokenExpiresAt: tokenData.refreshTokenExpiresAt.toISOString(),
        user: {
          _id: user._id,
          mobileNo: user.mobileNo,
          role: user.role,
          createdAt: user.createdAt,
          updatedAt: user.updatedAt
        }
      }
    };

  } catch (error) {
    // Handle Twilio errors
    if (error.code === 60200) {
      throw new appError(
        httpStatus.BAD_REQUEST,
        "Invalid phone number format. Contact support."
      );
    }

    // Handle known operational errors
    if (error instanceof appError) {
      throw error;
    }

    // Generic error fallback
    throw new appError(
      error.statusCode || httpStatus.INTERNAL_SERVER_ERROR,
      error.message || "OTP verification failed"
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
  try {
    const { name, email, userName, mobileNo, bio, teacherId, role } = request.body;

    // Input validation
    if (!name || !email || !userName || !mobileNo) {
      throw new appError(httpStatus.BAD_REQUEST, "Missing required fields");
    }

    // Handle file uploads safely
    const profileImg = request.files?.profileImage?.[0]?.location || "";
    const teacherIdCard = request.files?.teacherIdCard?.[0]?.location || "";

    // Email validation and normalization
    const normalizedEmail = email.toLowerCase().trim();
    
    // Check for existing email and username in a single query
    const existingUser = await User.findOne({
      $and: [
        { _id: { $ne: request.user.id } },
        {
          $or: [
            { email: normalizedEmail },
            { userName: userName.trim() }
          ]
        }
      ]
    });

    // Handle existing user conflict
    if (existingUser) {
      // Clean up uploaded files if they exist
      if (Object.keys(request.files || {}).length > 0) {
        const filesToDelete = [
          teacherIdCard && request.files?.teacherIdCard[0]?.location,
          profileImg && request.files?.profileImage[0]?.location
        ].filter(Boolean);
        
        await Promise.all(filesToDelete.map(file => deleteFromS3(file)));
      }

      throw new appError(
        httpStatus.CONFLICT,
        existingUser.email === normalizedEmail 
          ? "Email already exists"
          : "Username already exists"
      );
    }

    // Prepare update data
    const updateData = {
      name: name.trim(),
      email: normalizedEmail,
      userName: userName.trim(),
      mobileNo,
      profileImage: profileImg,
      isOnboarded: true,
      bio: bio?.trim(),
      role: role === ROLES.TEACHER ? ROLES.TEACHER : ROLES.USER
    };

    // Add teacher-specific fields if applicable
    if (role === ROLES.TEACHER) {
      if (!teacherId || !teacherIdCard) {
        throw new appError(httpStatus.BAD_REQUEST, "Teacher ID and ID card are required for teacher role");
      }
      updateData.teacherIdCard = teacherIdCard;
      updateData.teacherId = teacherId;
    }

    // Update user with new data
    const updatedUser = await User.findByIdAndUpdate(
      request.user.id,
      updateData,
      {
        new: true,
        runValidators: true
      }
    );

    if (!updatedUser) {
      throw new appError(httpStatus.NOT_FOUND, "User not found");
    }

    return updatedUser;

  } catch (error) {
    // Clean up any uploaded files in case of error
    if (Object.keys(request.files || {}).length > 0) {
      try {
        const filesToDelete = [
          request.files?.teacherIdCard?.[0]?.location,
          request.files?.profileImage?.[0]?.location
        ].filter(Boolean);
        
        await Promise.all(filesToDelete.map(file => deleteFromS3(file)));
      } catch (cleanupError) {
        console.error('Error cleaning up files:', cleanupError);
      }
    }

    // Re-throw the original error
    throw error;
  }
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
  try {
    // Find the current user
    const user = await User.findById(request.user.id);
    if (!user) {
      throw new appError(
        httpStatus.NOT_FOUND,
        "User not found"
      );
    }

    // Create update object
    const updates = {};
    
    // Handle email update
    if (params.email) {
      const normalizedEmail = params.email.toLowerCase().trim();
      if (normalizedEmail !== user.email) {
        const emailExists = await User.findOne({ 
          email: normalizedEmail,
          _id: { $ne: request.user.id }
        });
        
        if (emailExists) {
          throw new appError(
            httpStatus.CONFLICT,
            "Email already exists"
          );
        }
        updates.email = normalizedEmail;
      }
    }

    // Handle mobile number update
    if (params.mobileNo && params.countryCode) {
      if (params.mobileNo !== user.mobileNo || params.countryCode !== user.countryCode) {
        const mobileExists = await User.findOne({
          mobileNo: params.mobileNo,
          countryCode: params.countryCode,
          _id: { $ne: request.user.id }
        });

        if (mobileExists) {
          throw new appError(
            httpStatus.CONFLICT,
            "Mobile number already exists"
          );
        }
        updates.mobileNo = params.mobileNo;
        updates.countryCode = params.countryCode;
      }
    }

    // Handle username update
    if (params.userName && params.userName !== user.userName) {
      const usernameExists = await User.findOne({
        userName: params.userName,
        _id: { $ne: request.user.id },
        deletedAt: null
      });

      if (usernameExists) {
        throw new appError(
          httpStatus.CONFLICT,
          "Username already exists"
        );
      }
      updates.userName = params.userName;
    }

    // Handle other basic updates
    if (params.fullName) updates.fullName = params.fullName.trim();
    if (params.location) updates.location = params.location;
    
    // Handle teacher-specific updates
    if (params.isTeacher && params.teacherId) {
      if (!user.role || user.role !== ROLES.TEACHER) {
        throw new appError(
          httpStatus.BAD_REQUEST,
          "Cannot update teacher ID for non-teacher user"
        );
      }
      updates.teacherId = params.teacherId;
    }

    // If no updates were provided
    if (Object.keys(updates).length === 0) {
      return { data: user };
    }

    // Update the user with all collected changes
    const updatedUser = await User.findByIdAndUpdate(
      request.user.id,
      { $set: updates },
      { 
        new: true,
        runValidators: true
      }
    );

    if (!updatedUser) {
      throw new appError(
        httpStatus.NOT_FOUND,
        "User not found"
      );
    }

    return { data: updatedUser };

  } catch (error) {
    // Handle mongoose validation errors
    if (error.name === 'ValidationError') {
      throw new appError(
        httpStatus.BAD_REQUEST,
        Object.values(error.errors).map(err => err.message).join(', ')
      );
    }
    
    // Re-throw known application errors
    if (error instanceof appError) {
      throw error;
    }

    // Handle unexpected errors
    throw new appError(
      httpStatus.INTERNAL_SERVER_ERROR,
      "An error occurred while updating user"
    );
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