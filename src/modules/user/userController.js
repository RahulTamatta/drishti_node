const userService = require("../user/userService");
const constants = require("../../common/utils/constants");
const appError = require("../../common/utils/appError");
const createResponse = require("../../common/utils/createResponse");
const httpStatus = require("../../common/utils/status.json");
const uploadFilesToBucket = require("../../middleware/uploadTofireBase");
const User = require('../../models/user');
const { decode } = require('../../common/utils/crypto');
const mongoose = require("mongoose");

const { createToken } = require('../../middleware/genrateTokens');
// const onBoardUser =require("./userService");
const jwt = require('jsonwebtoken');
const userLoginController = async (request, response) => {
  try {
    const data = await userService.userLoginService(request);
    console.log("Data from userLoginService:", data); // Log the data returned

    if (!data) {
      console.error("userLoginService returned null or undefined"); // Log if data is nullish
      throw new appError(
        httpStatus.CONFLICT,
        request.t("user.UNABLE_TO_LOGIN")
      );
    }

    createResponse(
      response,
      httpStatus.OK,
      request.t("user.USER_LOGGED_IN"),
      data
    );
  } catch (error) {
    console.error("Error in userLoginController:", error); // Log the entire error object
    createResponse(response, error.status || httpStatus.INTERNAL_SERVER_ERROR, error.message || "An unexpected error occurred"); // Provide a default status
  }
};
const verifyOtpController = async (request, response) => {
  try {
    console.log('Starting OTP verification process');
    console.log('Request body:', {
      otp: request.body.otp,
      deviceToken: request.body.deviceToken,
      dataLength: request.body.data?.length
    });
    
    // 1. Input Validation
    if (!request.body || !request.body.otp || !request.body.data) {
      throw new appError(httpStatus.BAD_REQUEST, "Missing required fields: otp and data are required");
    }

    // 2. OTP Validation
    const otp = String(request.body.otp || '').trim();
    if (!otp || otp.length !== 6 || !/^\d+$/.test(otp)) {
      throw new appError(httpStatus.BAD_REQUEST, "Invalid OTP format - must be 6 digits");
    }

    // 3. Decrypt Data with error handling
    let decryptedData;
    try {
      decryptedData = await decode(request.body.data);
      console.log('Successfully decrypted data');
    } catch (decryptError) {
      console.error('Decryption error:', decryptError);
      throw new appError(httpStatus.BAD_REQUEST, "Failed to decrypt data: " + decryptError.message);
    }

    // 4. Parse Decrypted Data with error handling
    let decodedObj;
    try {
      decodedObj = JSON.parse(decryptedData);
      console.log('Parsed data:', {
        mobile: decodedObj.mobile,
        countryCode: decodedObj.countryCode
      });
    } catch (parseError) {
      console.error('JSON parse error:', parseError);
      throw new appError(httpStatus.BAD_REQUEST, "Invalid data format: " + parseError.message);
    }

    // 5. Validate Mobile Number
    if (!decodedObj.mobile) {
      throw new appError(httpStatus.BAD_REQUEST, "Mobile number is required");
    }

    // 6. Find or Create User with detailed error handling
    let user;
    try {
      // Find existing user
      user = await User.findOne({ 
        mobileNo: decodedObj.mobile,
        countryCode: decodedObj.countryCode || '+91'
      }).exec();

      console.log('User search result:', user ? 'Found existing user' : 'User not found');

      const isNewUser = !user;
      
      if (isNewUser) {
        // Create new user if doesn't exist
        const newUserData = {
          mobileNo: decodedObj.mobile,
          countryCode: decodedObj.countryCode || '+91',
          deviceTokens: request.body.deviceToken ? [request.body.deviceToken] : [],
          role: constants.ROLES.USER,
          isOnboarded: false,
          nearByVisible: false,
          locationSharing: false,
          teacherRoleApproved: 'pending'
        };

        console.log('Creating new user with data:', newUserData);

        user = await User.create(newUserData);
        console.log('New user created successfully:', user._id);
      } else if (request.body.deviceToken) {
        // Update device token for existing user
        if (!user.deviceTokens.includes(request.body.deviceToken)) {
          console.log('Adding new device token to existing user');
          user.deviceTokens.push(request.body.deviceToken);
          await user.save();
          console.log('Device token added successfully');
        }
      }

      // 7. Generate Tokens
      console.log('Generating tokens for user:', user._id);
      
      const accessExpiration = new Date(
        Date.now() + (process.env.JWT_ACCESS_EXPIRATION_MINUTES || 30) * 60 * 1000
      );
      const refreshExpiration = new Date(
        Date.now() + (process.env.JWT_REFRESH_EXPIRATION_DAYS || 7) * 24 * 60 * 60 * 1000
      );

      // Generate access token
      const accessToken = jwt.sign(
        {
          id: user._id,
          role: user.role || 'user',
          type: 'access'
        },
        process.env.JWT_SECRET,
        { expiresIn: `${process.env.JWT_ACCESS_EXPIRATION_MINUTES || 30}m` }
      );

      // Generate refresh token
      const refreshToken = jwt.sign(
        {
          id: user._id,
          role: user.role || 'user',
          type: 'refresh'
        },
        process.env.JWT_SECRET,
        { expiresIn: `${process.env.JWT_REFRESH_EXPIRATION_DAYS || 7}d` }
      );

      console.log('Tokens generated successfully');

      // Store refresh token
      await User.findByIdAndUpdate(user._id, {
        $push: {
          refreshTokens: {
            token: refreshToken,
            expiresAt: refreshExpiration
          }
        }
      });

      console.log('Refresh token stored successfully');

      // 8. Prepare Response
      const responseData = {
        success: true,
        message: "User logged in successfully",
        data: {
          accessToken,
          refreshToken,
          accessTokenExpiresAt: accessExpiration.toISOString(),
          refreshTokenExpiresAt: refreshExpiration.toISOString(),
          user: {
            id: user._id,
            mobileNo: user.mobileNo,
            role: user.role,
            isOnboarded: user.isOnboarded,
            countryCode: user.countryCode,
            deviceTokens: user.deviceTokens,
            teacherRoleApproved: user.teacherRoleApproved,
            nearByVisible: user.nearByVisible,
            locationSharing: user.locationSharing
          },
          isNewUser
        }
      };

      console.log('Response prepared:', {
        userId: responseData.data.user.id,
        hasAccessToken: !!responseData.data.accessToken,
        hasRefreshToken: !!responseData.data.refreshToken
      });

      return response.status(httpStatus.OK).json(responseData);

    } catch (dbError) {
      console.error('Database operation error:', {
        error: dbError.message,
        stack: dbError.stack,
        code: dbError.code
      });
      
      // Handle specific MongoDB errors
      if (dbError.code === 11000) {
        throw new appError(
          httpStatus.CONFLICT,
          "Duplicate mobile number found"
        );
      }
      
      throw new appError(
        httpStatus.INTERNAL_SERVER_ERROR,
        `Error processing user data: ${dbError.message}`
      );
    }

  } catch (error) {
    console.error("OTP Verification Error:", {
      message: error.message,
      stack: error.stack,
      code: error.code,
      name: error.name
    });

    const errorResponse = {
      success: false,
      message: error.message || "Unable to login",
      data: null
    };

    const statusCode = error.status || httpStatus.INTERNAL_SERVER_ERROR;
    return response.status(statusCode).json(errorResponse);
  }
};

const generateTokenController = async (req, res) => {
  try {
    const refreshToken = req.body.refreshToken;
    if (!refreshToken) {
      return createResponse(res, httpStatus.BAD_REQUEST, "Refresh token is required");
    }

    return await generateToken(req, res);
  } catch (error) {
    console.error("Error in generateTokenController:", error);
    return createResponse(
      res,
      error.status || httpStatus.INTERNAL_SERVER_ERROR,
      error.message || "An error occurred during token refresh"
    );
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
    console.log("=== onBoardUserController START ===");
    console.log("Request headers:", request.headers);
    console.log("Request body:", request.body);
    console.log("Request files:", request.files);

    // Validate required fields
    const requiredFields = ['userName', 'name', 'email', 'mobileNo', 'role'];
    for (const field of requiredFields) {
      if (!request.body[field]) {
        throw new Error(`Missing required field: ${field}`);
      }
    }

    // Process the uploaded file
    let profileImageUrl = '';
    if (request.files && request.files.profileImage) {
      console.log("Processing profile image...");
      const uploadResult = await uploadFilesToBucket([request.files.profileImage[0]]);
      profileImageUrl = uploadResult[0].link;
      console.log("Profile image uploaded:", profileImageUrl);
    }

    // Create update data object
    const updateData = {
      userName: request.body.userName,
      name: request.body.name,
      email: request.body.email.toLowerCase(),
      mobileNo: request.body.mobileNo,
      role: request.body.role,
      bio: request.body.bio || '',
      profileImage: profileImageUrl,
      isOnboarded: true,
      nearByVisible: request.body.nearByVisible === 'true',
      locationSharing: request.body.locationSharing === 'true'
    };

    // Add teacher specific fields if applicable
    if (request.body.role === 'teacher') {
      if (!request.body.teacherId) {
        throw new Error('Teacher ID is required for teacher role');
      }
      updateData.teacherId = request.body.teacherId;
    }

    console.log("Update data:", updateData);

    // Update user in database
    const updatedUser = await User.findByIdAndUpdate(
      request.user.id,
      updateData,
      { new: true }
    );

    console.log("Updated user:", updatedUser);

    return createResponse(
      response,
      httpStatus.OK,
      "Profile updated successfully",
      updatedUser
    );

  } catch (error) {
    console.error("onBoardUserController Error:", error);
    return createResponse(
      response,
      error.status || httpStatus.INTERNAL_SERVER_ERROR,
      error.message || "Failed to update profile"
    );
  }
};

const handleFileUploads = async (files) => {
  const results = {
    profileImage: "",
    teacherIdCard: ""
  };

  if (!files) return results;

  try {
    if (files.profileImage?.[0]) {
      const uploadResult = await uploadFilesToBucket([files.profileImage[0]]);
      results.profileImage = uploadResult[0].link;
    }
    
    if (files.teacherIdCard?.[0]) {
      const uploadResult = await uploadFilesToBucket([files.teacherIdCard[0]]);
      results.teacherIdCard = uploadResult[0].link;
    }
  } catch (error) {
    console.error("File upload error:", error);
    throw new Error("File upload failed");
  }

  return results;
};

const onBoardUser = async (userId, userData) => {
  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    console.log("=== onBoardUser Service START ===");
    console.log("User ID:", userId);
    console.log("User Data:", userData);

    // Validate required fields
    const requiredFields = ['userName', 'name', 'email', 'mobileNo'];
    for (const field of requiredFields) {
      if (!userData[field]) {
        throw new Error(`Missing required field: ${field}`);
      }
    }

    // Check for existing email/username
    const existingUser = await User.findOne({
      $or: [
        { email: userData.email.toLowerCase() },
        { userName: userData.userName }
      ],
      _id: { $ne: userId }
    }).session(session);

    if (existingUser) {
      throw new Error(
        existingUser.email === userData.email ? 
        "Email already exists" : 
        "Username already exists"
      );
    }

    // Prepare update data
    const updateData = {
      name: userData.name,
      email: userData.email.toLowerCase(),
      userName: userData.userName,
      mobileNo: userData.mobileNo,
      isOnboarded: true,
      bio: userData.bio || "",
      role: userData.role || "user",
      youtubeUrl: userData.youtubeUrl || "",
      xUrl: userData.xUrl || "",
      instagramUrl: userData.instagramUrl || "",
      nearByVisible: userData.nearByVisible || false,
      locationSharing: userData.locationSharing || false
    };

    // Add profile image if provided
    if (userData.profileImage) {
      updateData.profileImage = userData.profileImage;
    }

    // Handle teacher-specific fields
    if (userData.role === 'teacher') {
      updateData.teacherId = userData.teacherId;
      updateData.teacherIdCard = userData.teacherIdCard;
    }

    console.log("Final update data:", updateData);

    // Update user
    const updatedUser = await User.findByIdAndUpdate(
      userId,
      updateData,
      { new: true, session }
    );

    if (!updatedUser) {
      throw new Error("User not found");
    }

    await session.commitTransaction();
    console.log("=== onBoardUser Service END ===");
    return updatedUser;

  } catch (error) {
    await session.abortTransaction();
    console.error("onBoardUser Service Error:", error);
    throw error;
  } finally {
    await session.endSession();
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
  getSocialMediaController,generateTokenController,
  getNearbyVisible,
};


