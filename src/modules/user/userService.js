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
const mongoose = require('mongoose');
const Address = require('../../models/address');

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

    // Call 2Factor API to send OTP
    console.log('Calling 2Factor API...');
    const response = await axios.get(
      `https://2factor.in/API/V1/${API_KEY}/SMS/${countryCode}${mobileNo}/AUTOGEN/OTP%20For%20Verification`
    );

    console.log('2Factor API response:', response.data);

    if (response.data.Status !== "Success") {
      const errorMessage = response.data.Details || 'Failed to send OTP';
      throw new appError(httpStatus.INTERNAL_SERVER_ERROR, errorMessage);
    }

    // Check if user exists
    const user = await User.findOne({ mobileNo, countryCode });
    console.log('User lookup result:', { exists: !!user });

    // Prepare data for encryption
    const details = {
      sessionId: response.data.Details,
      expiration_time: AddMinutesToDate(new Date(), 10).toISOString(),
      mobile: mobileNo,
      countryCode: countryCode
    };

    if (user) {
      details.userId = user._id.toString();
    }

    // Encrypt the data
    try {
      const encryptedData = await encode(JSON.stringify(details));
      console.log('Data encrypted successfully:', {
        hasSessionId: !!details.sessionId,
        hasUserId: !!details.userId,
        encryptedLength: encryptedData.length
      });

      return { data: encryptedData };
    } catch (encryptError) {
      console.error('Encryption error:', encryptError);
      throw new appError(httpStatus.INTERNAL_SERVER_ERROR, 'Failed to secure OTP data');
    }
  } catch (error) {
    console.error('Login service error:', {
      message: error.message,
      status: error.status,
      stack: error.stack
    });
    throw error instanceof appError ? error : new appError(
      httpStatus.INTERNAL_SERVER_ERROR,
      error.message || 'Failed to process login request'
    );
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
      // First try to decrypt the data
      const decryptedData = await decode(data);
      console.log('Decrypted data:', decryptedData);

      // Then parse the JSON
      try {
        decodedObj = JSON.parse(decryptedData);
        console.log('Parsed data:', decodedObj);

        // Validate required fields
        if (!decodedObj.sessionId || !decodedObj.mobile || !decodedObj.countryCode) {
          throw new Error('Missing required fields in encrypted data');
        }
      } catch (parseError) {
        console.error('JSON parsing error:', parseError);
        throw new appError(httpStatus.BAD_REQUEST, "Invalid data format");
      }
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
        username: '',
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



const uploadToFirebase = require('../../common/utils/uploadToFirebase');

const onBoardUser = async (userId, userData, files) => {
  try {
    const user = await User.findById(userId);
    if (!user) {
      throw new AppError("User not found", httpStatus.NOT_FOUND);
    }

    // Update user data fields
    Object.keys(userData).forEach((key) => {
      if (key !== 'files' && key !== 'teacherIdCard') {
        user[key] = userData[key];
      }
    });

    // Handle profile image upload if provided
    if (files && files.profileImage && files.profileImage[0]) {
      try {
        const file = files.profileImage[0];
        const key = `profiles/${userId}/${Date.now()}-${file.originalname}`;
        
        console.log('Uploading profile image to S3...');
        const uploadResult = await uploadToS3(
          file.buffer,
          key,
          file.mimetype
        );
        
        user.profileImage = uploadResult.Location;
        console.log('Profile image uploaded successfully');
      } catch (uploadError) {
        console.error('Profile image upload error:', uploadError);
        // Continue with user update even if image upload fails
        // This prevents blocking the entire onboarding process
      }
    }

    // Handle teacher ID card upload if provided and user is a teacher
    if (userData.role === 'TEACHER' && files && files.teacherIdCard && files.teacherIdCard[0]) {
      try {
        const file = files.teacherIdCard[0];
        const key = `teachers/${userId}/${Date.now()}-${file.originalname}`;
        
        console.log('Uploading teacher ID card to S3...');
        const uploadResult = await uploadToS3(
          file.buffer,
          key,
          file.mimetype
        );
        
        user.teacherIdCard = uploadResult.Location;
        console.log('Teacher ID card uploaded successfully');
      } catch (uploadError) {
        console.error('Teacher ID card upload error:', uploadError);
        throw new AppError(
          "Teacher ID card upload failed. Please try again.",
          httpStatus.INTERNAL_SERVER_ERROR
        );
      }
    }

    // Save the updated user
    await user.save();
    return user;
  } catch (error) {
    console.error('onBoardUser error:', error);
    throw new AppError(
      error.message || "Failed to onboard user",
      error.status || httpStatus.INTERNAL_SERVER_ERROR
    );
  }
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
        !isEmpty(params.username) &&
        params.username != currentUser.username
      ) {
        const userWithUsername = await User.findOne({
          username: params.username,
          deletedAt: null,
        });
        if (isEmpty(userWithUsername)) {
          user.username = params.username;
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
    username: user.username || '',
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
  const { teacherId, status, adminId } = request;

  try {
    const user = await User.findById(teacherId);
    if (!user) {
      throw new appError(
        httpStatus.NOT_FOUND,
        'Teacher not found'
      );
    }

    if (user.role !== constants.ROLES.TEACHER) {
      throw new appError(
        httpStatus.BAD_REQUEST,
        'User is not a teacher'
      );
    }

    // Validate the status
    if (![constants.STATUS.ACCEPTED, constants.STATUS.REJECTED].includes(status)) {
      throw new appError(
        httpStatus.BAD_REQUEST,
        'Invalid status. Must be either accepted or rejected'
      );
    }

    const updatedUser = await User.findByIdAndUpdate(
      teacherId,
      {
        teacherRoleApproved: status,
        teacherRequestHandledBy: adminId,
        updatedAt: new Date()
      },
      { new: true }
    ).populate('teacherRequestHandledBy', 'name email');

    return updatedUser;
  } catch (error) {
    console.error('Error in actionOnTeacherAccount service:', error);
    throw new appError(
      error.status || httpStatus.INTERNAL_SERVER_ERROR,
      error.message || 'Failed to update teacher status'
    );
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
    }).select("username profileImage role")

    return users;
  } catch (error) {
    throw new Error("Error fetching nearby users: " + error.message);
  }
};

const searchUsers = async (username) => {
  try {
    if (!username && username !== '') {
      throw new appError(httpStatus.BAD_REQUEST, "Username parameter is required");
    }

    const searchRegex = new RegExp(username, 'i');
    
    const users = await User.find({
      username: searchRegex,
      isOnboarded: true,
      status: { $ne: 'DELETED' }
    })
    .select('_id username mobileNo deviceTokens countryCode isOnboarded teacherRoleApproved role nearByVisible locationSharing createdAt updatedAt email name profileImage')
    .limit(20);

    return users;

  } catch (error) {
    console.error("Search users error:", error);
    throw error;
  }
};

const createAddressService = async (request) => {
  try {
    const { title, address, city, state, country, pin, latlong, userId } = request.body;

    // Validate required fields
    if (!address || !userId || !latlong) {
      throw new appError(httpStatus.BAD_REQUEST, 'Address, userId and coordinates are required');
    }

    // Validate latlong format
    if (!latlong.coordinates || !Array.isArray(latlong.coordinates) || latlong.coordinates.length !== 2) {
      throw new appError(httpStatus.BAD_REQUEST, 'Invalid coordinates format');
    }

    // Ensure userId is a valid MongoDB ObjectId
    if (!mongoose.Types.ObjectId.isValid(userId)) {
      throw new appError(httpStatus.BAD_REQUEST, 'Invalid user ID');
    }

    // Create GeoJSON point
    const point = {
      type: 'Point',
      coordinates: [
        parseFloat(latlong.coordinates[0]), // latitude
        parseFloat(latlong.coordinates[1])  // longitude
      ]
    };

    // Create new address document
    const newAddress = new Address({
      title: title || 'Home',
      address,
      city: city || '',
      state: state || '',
      country: country || 'India',
      pin: pin || '',
      userId,
      location: point
    });

    // Save the address
    const savedAddress = await newAddress.save();

    if (!savedAddress) {
      throw new appError(httpStatus.INTERNAL_SERVER_ERROR, 'Failed to save address');
    }

    // Update user's address reference if needed
    await User.findByIdAndUpdate(
      userId,
      { $addToSet: { addresses: savedAddress._id } },
      { new: true }
    );

    return {
      message: 'address.ADDRESS_CREATED',
      data: savedAddress
    };
  } catch (error) {
    console.error('Create address error:', error);
    throw error instanceof appError ? error : new appError(
      httpStatus.INTERNAL_SERVER_ERROR,
      error.message || 'Failed to create address'
    );
  }
};

const createEventService = async (request) => {
  try {
    const { mode, aol, title, date, recurring, durationFrom, durationTo, timeOffset, meetingLink, phoneNumber, address, description, registrationLink, coordinates, teachers } = request.body;

    // Validate required fields
    if (!mode || !aol || !title || !date || !durationFrom || !durationTo || !phoneNumber || !address) {
      throw new appError(httpStatus.BAD_REQUEST, 'Required fields are missing');
    }

    // Create new event
    const newEvent = new Event({
      mode,
      aol,
      title,
      date,
      recurring,
      duration: [{ from: durationFrom, to: durationTo }],
      timeOffset,
      meetingLink,
      phoneNumber,
      address,
      description,
      registrationLink,
      location: {
        type: 'Point',
        coordinates
      },
      teachers
    });

    const savedEvent = await newEvent.save();
    return savedEvent;
  } catch (error) {
    console.error('Error creating event:', error);
    throw new appError(httpStatus.INTERNAL_SERVER_ERROR, error.message || 'Failed to create event');
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
  generateToken,
  getSocialMedia,
  getNearbyVisibleUsers,
  searchUsers,
  createAddressService,
  createEventService,
};
