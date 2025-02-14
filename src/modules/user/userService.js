const { isEmpty, generateJWT } = require("../../common/utils/app_functions");
const User = require("../../models/user");
const appError = require("../../common/utils/appError");
const httpStatus = require("../../common/utils/status.json");
const { createToken } = require("../../middleware/genrateTokens");
const { ROLES } = require("../../common/utils/constants");
const { encode, decode } = require("../../common/utils/crypto");
const { generateOTP } = require("../../common/utils/helpers");

const constants = require("../../common/utils/constants");
const sendSms = require("../../common/utils/messageService");
const uploadFilesToBucket = require("../../middleware/uploadTofireBase"); // Adjust path
const axios = require('axios');
function AddMinutesToDate(date, minutes) {
  return new Date(date.getTime() + minutes * 60000);
}
const userLoginService = async (request) => {
  const { mobileNo, countryCode, type } = request.body;
  let user = await User.findOne({
    mobileNo: mobileNo,
  });

  const API_KEY = process.env.TWO_FACTOR_API_KEY;

  if (!API_KEY) {
    throw new appError(httpStatus.INTERNAL_SERVER_ERROR, 'TWO_FACTOR_API_KEY is not defined');
  }

  try {
    const response = await axios.get(`https://2factor.in/API/V1/${API_KEY}/SMS/${countryCode}${mobileNo}/AUTOGEN/OTP%20For%20Verification`);

    // Check for success and also for specific error codes if 2factor API provides them
    if (response.data.Status === "Success") {
      const sessionId = response.data.Details;
      const now = new Date();
      const expiration_time = AddMinutesToDate(now, 10);

      let details = {
        sessionId: sessionId,
        expiration_time: expiration_time,
        mobile: mobileNo,
        countryCode: countryCode,
        type: type,
      };

      if (user) {
        details["userId"] = user._id.toString();
      }

      return { data: await encode(JSON.stringify(details)) };

    } else {
      console.error("2Factor API Error:", response.data);

      // More specific error handling based on 2factor API response
      let errorMessage = "Failed to send OTP";
      if (response.data && response.data.Details) { // Check if Details exists
        errorMessage = response.data.Details; // Try to extract more details from the API response
      }
      throw new appError(httpStatus.INTERNAL_SERVER_ERROR, errorMessage);

    }
  } catch (error) {
    console.error("Error sending OTP:", error);

    // Improved error message handling.  Include original error message if available.
    let errorMessage = "Error sending OTP";
    if (error.response && error.response.data && error.response.data.message) {
        errorMessage = error.response.data.message; // From backend
    } else if (error.message) {
        errorMessage = error.message; // From axios or other errors
    } else if (error.toString()) {
      errorMessage = error.toString();
    }
    throw new appError(httpStatus.INTERNAL_SERVER_ERROR, errorMessage);
  }
};


const  verifyOtp = async (request) => {
  try {
    const { otp, deviceToken, data } = request.body;
    
    // Decode and validate the encrypted data
    const decoded = await decode(data);
    const decodedObj = JSON.parse(decoded);

    // Verify expiration
    const expirationTime = new Date(decodedObj.expiration_time);
    if (expirationTime <= new Date()) {
      throw new appError(httpStatus.UNAUTHORIZED, "OTP expired");
    }

    // Verify OTP with 2Factor API
    const verifyResponse = await axios.get(
      `https://2factor.in/API/V1/${process.env.TWO_FACTOR_API_KEY}/SMS/VERIFY/${decodedObj.sessionId}/${otp}`
    );

    if (verifyResponse.data.Status !== "Success") {
      throw new appError(httpStatus.UNAUTHORIZED, "Invalid OTP");
    }

    try {
      // Find existing user
      let user = await User.findOne({
        mobileNo: decodedObj.mobile,
        countryCode: decodedObj.countryCode
      });

      const isNewUser = !user;

      if (isNewUser) {
        // Create new user
        user = await User.create({
          mobileNo: decodedObj.mobile,
          countryCode: decodedObj.countryCode,
          deviceTokens: deviceToken ? [deviceToken] : [],
          role: 'USER',
          isOnboarded: false,
          refreshTokens: [] // Initialize empty refresh tokens array
        });
      } else if (deviceToken && !user.deviceTokens.includes(deviceToken)) {
        // Update existing user's device tokens
        user.deviceTokens.push(deviceToken);
        user = await user.save(); // Save and get updated user
      }

      // Generate tokens for the user
      const tokens = await createToken(user);

      return {
        success: true,
        isNewUser,
        user: {
          _id: user._id,
          mobileNo: user.mobileNo,
          countryCode: user.countryCode,
          role: user.role,
          isOnboarded: user.isOnboarded
        },
        ...tokens
      };

    } catch (dbError) {
      console.error('Database operation error:', dbError);
      throw new appError(
        httpStatus.INTERNAL_SERVER_ERROR,
        "Error processing user data"
      );
    }

  } catch (error) {
    console.error("OTP Verification Error:", error);
    throw new appError(
      error.status || httpStatus.INTERNAL_SERVER_ERROR,
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
        coordinates: [parseFloat(long), parseFloat(lat)],
      },
    },
    {
      new: true,
    }
  );
};



const onBoardUser = async (request) => {
  console.log("request.user.id:", request.user.id);
  console.log("request.user:", request.user);
  console.log("onBoardUser called. Request body:", request.body);  // Log request body inside
  console.log("onBoardUser called. Request files:", request.files);  // Log request files inside
  console.log("onBoardUser called. Request user:", request.user);  // Log request user inside
  console.log("onBoardUser called. Request user ID:", request.user?.id);  // Log user ID (safely)


  const { name, email, userName, mobileNo, bio, teacherId, role, youtubeUrl, xUrl, instagramUrl, nearByVisible, locationSharing } = request.body;

  let profileImg = "";
  let teacherIdCard = "";

  try {  // Wrap the file upload in a try-catch

    if (request.files && Object.keys(request.files).length !== 0) {
      const filesToUpload = [];
      if (request.files.profileImage && request.files.profileImage.length > 0) {
        filesToUpload.push(request.files.profileImage[0]);
      }
      if (request.files.teacherIdCard && request.files.teacherIdCard.length > 0) {
        filesToUpload.push(request.files.teacherIdCard[0]);
      }

      if (filesToUpload.length > 0) {
        const uploadedFiles = await uploadFilesToBucket(filesToUpload);
        console.log("Uploaded files:", uploadedFiles); // Log the result of the upload
        uploadedFiles.forEach(file => {
          if (file.label.startsWith('profileImage')) {
            profileImg = file.link;
          } else if (file.label.startsWith('teacherIdCard')) {
            teacherIdCard = file.link;
          }
        });
      }
    }
  } catch (fileUploadError) {
    console.error("File upload error in onBoardUser:", fileUploadError);
    console.error("File upload error (stringified):", JSON.stringify(fileUploadError, null, 2));
    throw new appError(httpStatus.INTERNAL_SERVER_ERROR, "File upload failed: " + fileUploadError.message);
  }


  const Email = email ? email.toLowerCase() : null; // Handle if email is undefined

  try {
    const isExistingEmail = await User.findOne({
      email: Email,
      _id: { $ne: request.user.id },
    });
    console.log("isExistingEmail:", isExistingEmail);

    const isExistingUserName = await User.findOne({
      userName: userName,
      _id: { $ne: request.user.id },
    });
    console.log("isExistingUserName:", isExistingUserName);

    if (isExistingEmail) {
      throw new appError(httpStatus.CONFLICT, request.t("user.EMAIL_EXISTENT"));
    }
    if (isExistingUserName) {
      throw new appError(httpStatus.CONFLICT, request.t("user.UserName_EXISTENT"));
    }
  } catch (findError) {
    console.error("Error checking existing user:", findError);
    console.error("Error checking existing user (stringified):", JSON.stringify(findError, null, 2));
    throw findError; // Re-throw the error
  }


  let updatedUser;
  try { // Wrap the database operation in a try-catch
      if (role === constants.ROLES.TEACHER) {
          updatedUser = await User.findByIdAndUpdate(
              request.user.id,
              {
                  name,
                  email: Email,
                  userName,
                  mobileNo,
                  profileImage: profileImg,
                  isOnboarded: true,
                  teacherIdCard,
                  teacherId,
                  role: constants.ROLES.TEACHER,
                  bio,
                  youtubeUrl,
                  xUrl,
                  instagramUrl,
                  nearByVisible,
                  locationSharing,
              },
              { new: true }
          );
      } else {
          updatedUser = await User.findByIdAndUpdate(
              request.user.id,
              {
                  name,
                  email: Email,
                  mobileNo,
                  userName,
                  profileImage: profileImg,
                  isOnboarded: true,
                  bio,
                  role: constants.ROLES.USER,
                  youtubeUrl,
                  xUrl,
                  instagramUrl,
                  nearByVisible,
                  locationSharing,
              },
              { new: true }
          );
      }
      console.log("onBoardUser: Updated user data:", updatedUser);
  } catch (dbError) {
      console.error("Database update error in onBoardUser:", dbError);
      console.error("Database update error (stringified):", JSON.stringify(dbError, null, 2));
      throw new appError(httpStatus.INTERNAL_SERVER_ERROR, "Database error: " + dbError.message);
  }

  return updatedUser;
};

const generateToken = async (req, res) => {
  try {
    const refreshToken = req.body.refreshToken;
    if (!refreshToken) {
      return createResponse(res, httpStatus.UNAUTHORIZED, "Refresh token is required");
    }

    const decoded = await new Promise((resolve, reject) => {
      jwt.verify(refreshToken, process.env.JWT_SECRET, (err, decoded) => {
        if (err) {
          console.error("Refresh token verification error:", err);
          reject(err);
        }
        resolve(decoded);
      });
    });

    const user = await User.findOne({
      _id: decoded.id,
      'refreshTokens.token': refreshToken,
      'refreshTokens.expiresAt': { $gt: new Date() }
    });

    if (!user) {
      return createResponse(res, httpStatus.UNAUTHORIZED, "Invalid refresh token");
    }

    // Remove used refresh token
    await User.findByIdAndUpdate(user._id, {
      $pull: { refreshTokens: { token: refreshToken } }
    });

    // Generate new tokens
    const tokens = await createToken(user);

    return createResponse(res, httpStatus.OK, "New tokens generated successfully", {
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      accessTokenExpiresAt: tokens.accessTokenExpiresAt,
      refreshTokenExpiresAt: tokens.refreshTokenExpiresAt
    });
  } catch (error) {
    console.error("Error in generateToken:", error);
    if (error.name === 'JsonWebTokenError' || error.name === 'TokenExpiredError') {
      return createResponse(res, httpStatus.UNAUTHORIZED, "Invalid or expired refresh token");
    }
    return createResponse(res, httpStatus.INTERNAL_SERVER_ERROR, "Internal server error");
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

const searchUsers = async (userName) => {
  try {
    if (!userName && userName !== '') {
      throw new appError(httpStatus.BAD_REQUEST, "Username parameter is required");
    }

    const searchRegex = new RegExp(userName, 'i');
    
    const users = await User.find({
      userName: searchRegex,
      isOnboarded: true,
      status: { $ne: 'DELETED' }
    })
    .select('_id userName mobileNo deviceTokens countryCode isOnboarded teacherRoleApproved role nearByVisible locationSharing createdAt updatedAt email name profileImage')
    .limit(20);

    return users;

  } catch (error) {
    console.error("Search users error:", error);
    throw error;
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
  updateSocialMediaLinks,generateToken,
  getSocialMedia,
  getNearbyVisibleUsers,
  searchUsers,
};