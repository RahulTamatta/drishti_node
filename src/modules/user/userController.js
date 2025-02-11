const userService = require("../user/userService");
const constants = require("../../common/utils/constants");
const appError = require("../../common/utils/appError");
const createResponse = require("../../common/utils/createResponse");
const httpStatus = require("../../common/utils/status.json");
const uploadFilesToBucket = require("../../middleware/uploadTofireBase");
const User = require('../../models/user');
const { decode } = require('../../common/utils/crypto');
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
  console.log("onBoardUserController called. Request body:", request.body);
  if (request.files) {
    console.log("Files received:", request.files);
    console.log("Files received (details):", JSON.stringify(request.files)); // Log file details
  } else {
    console.log("No files received.");
  }

  try {
    console.log("Calling onBoardUser..."); // Log before calling onBoardUser
    const data = await onBoardUser(request);
    console.log("onBoardUserController: Data returned:", data);
    console.log("onBoardUserController: Data returned (stringified):", JSON.stringify(data)); // Log stringified data

    if (!data) {
      console.log("onBoardUser returned null or undefined. Throwing error."); // Log if data is null/undefined
      throw new appError(httpStatus.CONFLICT, request.t("user.UNABLE_TO_ONBOARD_USER"));
    }

    console.log("Creating success response..."); // Log before creating response
    createResponse(response, httpStatus.OK, request.t("user.USER_ONBOARDED"), data);
    console.log("Success response sent."); // Log after sending response

  } catch (error) {
    console.error("Error in onBoardUserController:", error); // Log the full error object!
    console.error("Error in onBoardUserController (stringified):", JSON.stringify(error, null, 2)); // Stringify with indentation for better readability

    const errorMessage = error.message || "Internal Server Error"; // Extract message
    const errorStatus = error.status || httpStatus.INTERNAL_SERVER_ERROR;

    console.error(`Sending error response: Status ${errorStatus}, Message: ${errorMessage}`);
    createResponse(response, errorStatus, errorMessage); // Send back the error message
    console.log("Error response sent."); // Log after sending error response
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


