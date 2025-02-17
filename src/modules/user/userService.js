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
  try {
    const { mobileNo, countryCode } = request.body;
    console.log('Login request for:', { mobileNo, countryCode });

    // Validate required fields
    if (!mobileNo || !countryCode) {
      throw new appError(httpStatus.BAD_REQUEST, 'Mobile number and country code are required');
    }

    // Check if API key exists
    const API_KEY = process.env.TWO_FACTOR_API_KEY;
    if (!API_KEY) {
      throw new appError(httpStatus.INTERNAL_SERVER_ERROR, 'TWO_FACTOR_API_KEY is not defined');
    }

    try {
      // Call 2Factor API to send OTP
      console.log('Calling 2Factor API...');
      const response = await axios.get(
        `https://2factor.in/API/V1/${API_KEY}/SMS/${countryCode}${mobileNo}/AUTOGEN/OTP%20For%20Verification`
      );

      console.log('2Factor API response:', response.data);

      if (response.data.Status === "Success") {
        const sessionId = response.data.Details;
        const now = new Date();
        const expiration_time = AddMinutesToDate(now, 10);

        // Prepare data for encryption
        const details = {
          sessionId,
          expiration_time,
          mobile: mobileNo,
          countryCode
        };

        // Encrypt the data
        const encryptedData = await encode(JSON.stringify(details));
        
        return {
          success: true,
          message: "OTP sent successfully",
          data: encryptedData
        };
      } else {
        throw new appError(httpStatus.BAD_REQUEST, "Failed to send OTP");
      }
    } catch (apiError) {
      console.error('2Factor API Error:', apiError);
      throw new appError(
        httpStatus.SERVICE_UNAVAILABLE,
        "Failed to send OTP. Please try again later."
      );
    }
  } catch (error) {
    console.error('userLoginService Error:', error);
    throw error;
  }
};


const verifyOtp = async (request) => {
  try {
    const { otp, deviceToken, data } = request.body;
    console.log('Starting OTP verification process');
    console.log('Request body:', { 
      otp: otp ? 'REDACTED' : 'MISSING', 
      deviceToken: deviceToken ? deviceToken.substring(0, 20) + '...' : 'MISSING',
      dataLength: data ? data.length : 0
    });

    if (!otp || !data) {
      throw new appError(httpStatus.BAD_REQUEST, "OTP and data are required");
    }

    // Decode and validate the encrypted data
    let decodedObj;
    try {
      const decoded = await decode(data);
      decodedObj = JSON.parse(decoded);
    } catch (decodeError) {
      console.error('Decoding error:', decodeError);
      throw new appError(httpStatus.BAD_REQUEST, "Invalid encrypted data");
    }

    // Verify OTP with 2Factor API
    const API_KEY = process.env.TWO_FACTOR_API_KEY;
    try {
      const response = await axios.get(
        `https://2factor.in/API/V1/${API_KEY}/SMS/VERIFY/${decodedObj.sessionId}/${otp}`
      );

      if (response.data.Status !== "Success") {
        throw new appError(httpStatus.BAD_REQUEST, "Invalid OTP");
      }
    } catch (apiError) {
      throw new appError(httpStatus.BAD_REQUEST, "Failed to verify OTP");
    }

    // Find or create user
    let user = await User.findOne({ 
      mobileNo: decodedObj.mobile,
      countryCode: decodedObj.countryCode 
    });

    const isNewUser = !user;

    if (!user) {
      // Create new user with empty refresh tokens array
      const newUser = {
        mobileNo: decodedObj.mobile,
        countryCode: decodedObj.countryCode,
        role: ROLES.USER,
        deviceTokens: deviceToken ? [deviceToken] : [],
        refreshTokens: [], // Initialize as empty array
        isOnboarded: false,
        name: '',
        email: '',
        userName: '',
        profileImage: '',
        teacherRoleApproved: 'pending',
        teacherId: '',
        teacherIdCard: '',
        geometry: {
          type: 'Point',
          coordinates: [0, 0]
        },
        nearByVisible: false,
        locationSharing: false,
        bio: ''
      };
      
      console.log('Creating new user with data:', newUser);
      user = await User.create(newUser);
      console.log('Created new user:', user);
    } else {
      // Update existing user's device token
      if (deviceToken && !user.deviceTokens.includes(deviceToken)) {
        user.deviceTokens = [...user.deviceTokens, deviceToken];
      }

      // Reset refresh tokens if they're in an invalid state
      if (!Array.isArray(user.refreshTokens)) {
        user.refreshTokens = [];
      }

      // Clean up any invalid tokens
      user.refreshTokens = user.refreshTokens.filter(token => 
        token && 
        typeof token === 'object' && 
        token.token && 
        token.expiresAt
      );

      try {
        await user.save();
      } catch (saveError) {
        console.error('Error saving user device token:', saveError);
        // If save fails due to token validation, reset tokens
        user.refreshTokens = [];
        await user.save();
      }
    }

    // Generate new tokens
    const { accessToken, refreshToken, accessExpiration, refreshExpiration } = 
      await createToken(user._id.toString());

    // Log token details for debugging
    console.log('Token Generation Details:', {
      userId: user._id.toString(),
      refreshTokenType: typeof refreshToken,
      refreshTokenLength: refreshToken ? refreshToken.length : 0,
      existingTokenCount: user.refreshTokens.length
    });

    return {
      user,
      isNewUser,
      accessToken,
      refreshToken,
      accessExpiration,
      refreshExpiration
    };
  } catch (error) {
    console.error('OTP Verification Error:', {
      message: error.message,
      stack: error.stack,
      code: error.code,
      name: error.name
    });
    throw error;
  }
};


const updateLocation = async (request) => {
  try {
    const { lat, long, location } = request.body;

    // Validate coordinates
    const latitude = parseFloat(lat);
    const longitude = parseFloat(long);

    if (isNaN(latitude) || isNaN(longitude)) {
      throw new appError(httpStatus.BAD_REQUEST, "Invalid coordinates");
    }

    if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
      throw new appError(httpStatus.BAD_REQUEST, "Coordinates out of range");
    }

    // Update user with proper GeoJSON Point
    const updatedUser = await User.findByIdAndUpdate(
      request.user.id,
      {
        location: location,
        geometry: {
          type: 'Point',
          coordinates: [longitude, latitude] // GeoJSON format is [longitude, latitude]
        }
      },
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
    console.error('Location update error:', error);
    throw error instanceof appError ? error : new appError(
      httpStatus.INTERNAL_SERVER_ERROR,
      error.message || "Failed to update location"
    );
  }
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
    if (!refreshToken || typeof refreshToken !== 'string') {
      return createResponse(res, httpStatus.UNAUTHORIZED, "Valid refresh token is required");
    }

    // Verify refresh token
    let decoded;
    try {
      decoded = await new Promise((resolve, reject) => {
        jwt.verify(refreshToken, process.env.JWT_SECRET, (err, decoded) => {
          if (err) {
            console.error("Refresh token verification error:", err);
            reject(err);
          }
          resolve(decoded);
        });
      });
    } catch (verifyError) {
      console.error("Token verification failed:", verifyError);
      return createResponse(res, httpStatus.UNAUTHORIZED, "Invalid refresh token");
    }

    // Find user and validate token
    const user = await User.findById(decoded.id);
    if (!user) {
      console.error("User not found for token:", decoded.id);
      return createResponse(res, httpStatus.UNAUTHORIZED, "Invalid refresh token");
    }

    // Validate that the token exists in user's refresh tokens
    const tokenExists = user.refreshTokens.includes(refreshToken);
    if (!tokenExists) {
      console.error("Token not found in user's refresh tokens");
      return createResponse(res, httpStatus.UNAUTHORIZED, "Invalid refresh token");
    }

    // Remove used refresh token
    user.refreshTokens = user.refreshTokens.filter(token => token !== refreshToken);
    await user.save();

    // Generate new tokens
    const tokens = await createToken(user._id.toString());
    console.log('New tokens generated:', {
      userId: user._id.toString(),
      tokensGenerated: !!tokens.accessToken && !!tokens.refreshToken
    });

    return createResponse(res, httpStatus.OK, "New tokens generated successfully", {
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      accessTokenExpiresAt: tokens.accessExpiration,
      refreshTokenExpiresAt: tokens.refreshExpiration
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
  console.log('getUser service - currentUser:', currentUser);
  
  if (!currentUser) {
    throw new appError(httpStatus.UNAUTHORIZED, 'Authentication required');
  }

  const user = await User.findById(currentUser)
    .select('-password -refreshTokens')
    .lean();

  console.log('getUser service - Found user:', user);

  if (!user) {
    throw new appError(httpStatus.NOT_FOUND, 'User not found');
  }

  // Transform user data with defaults
  const userData = {
    _id: user._id.toString(), // Keep _id for MongoDB compatibility
    id: user._id.toString(),  // Add id for Flutter compatibility
    mobileNo: user.mobileNo || '',
    countryCode: user.countryCode || '+91',
    deviceTokens: Array.isArray(user.deviceTokens) ? user.deviceTokens : [],
    isOnboarded: Boolean(user.isOnboarded),
    role: user.role?.toLowerCase() || 'user',
    createdAt: user.createdAt?.toISOString() || new Date().toISOString(),
    updatedAt: user.updatedAt?.toISOString() || new Date().toISOString(),
    email: user.email || '',
    name: user.name || '',
    profileImage: user.profileImage || '',
    teacherRoleApproved: user.teacherRoleApproved?.toLowerCase() || 'pending',
    userName: user.userName || '',
    teacherId: user.teacherId || '',
    teacherIdCard: user.teacherIdCard || ''
  };

  console.log('getUser service - Transformed user data:', userData);
  return userData;
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