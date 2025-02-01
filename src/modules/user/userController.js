// const userService = require("./userService");
const userService = require("./userService.js");
const constants = require("../../common/utils/constants");
const appError = require("../../common/utils/appError");
const createResponse = require("../../common/utils/createResponse");
const httpStatus = require("../../common/utils/status.json");
const uploadFilesToBucket = require("../../middleware/uploadTofireBase");
const { response } = require("express");




const userLoginController = async (request, response) => {
  try {
    const data = await userService.userLoginService(request);
    if (!data || !data.data) {
      throw new appError(httpStatus.CONFLICT, "Authentication failed");
    }
    createResponse(
      response,
      httpStatus.OK,
      request.t("user.USER_LOGGED_IN"),
      data
    );
  } catch (error) {
    console.error("Login error:", error);
    let status = error.status || httpStatus.CONFLICT;
    let message = error.message;

    // Handle Twilio 409 Conflict error
    if (error.message.includes("Conflict") || error.status === 409) {
      status = httpStatus.CONFLICT;
      message = "Please wait before requesting another OTP.";
    }

    createResponse(response, status, message);
  }
};

const verifyOtpController = async (request, response) => {
  try {
    // Validate request body
    if (!request.body || !request.body.otp || !request.body.mobileNo) {
      throw new appError(httpStatus.BAD_REQUEST, "Missing required fields");
    }

    // Extract and convert OTP to string
    const { mobileNo, data, deviceToken } = request.body;
    const otp = String(request.body.otp); // Force OTP to be a string

    // Validate OTP length (6 digits)
    if (otp.length !== 6) {
      throw new appError(httpStatus.BAD_REQUEST, "OTP must be 6 digits");
    }

    // Call the service with CORRECT parameters
    const result = await userService.verifyOtp({
      body: {
        otp, // Pass as string
        mobileNo,
        deviceToken,
        data
      }
    });
    // Check response
    if (!result) {
      throw new appError(httpStatus.CONFLICT, request.t("user.UNABLE_TO_LOGIN"));
    }

    // Success response
    createResponse(
      response,
      httpStatus.OK,
      request.t("user.USER_LOGGED_IN"),
      result
    );

  } catch (error) {
    // Log the error for debugging
    console.error("OTP Verification Controller Error:", {
      error: error.message,
      stack: error.stack,
      status: error.status,
      body: request.body
    });

    // Determine appropriate status code
    const status = error.status || httpStatus.INTERNAL_SERVER_ERROR;
    
    // Get appropriate error message
    let message = error.message;
    if (status === httpStatus.INTERNAL_SERVER_ERROR && !message) {
      message = request.t("user.UNABLE_TO_LOGIN");
    }

    // Send error response
    createResponse(response, status, message);
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

// 1. First, let's fix the controller with proper error handling
const onBoardUserController = async (request, response) => {
  try {
    // Validate request body
    if (!request.body) {
      throw new appError(httpStatus.BAD_REQUEST, "Request body is required");
    }

    // Log incoming request for debugging
    console.log("OnBoard Request:", {
      body: request.body,
      files: request.files,
      userId: request.user?.id
    });

    // Validate user authentication
    if (!request.user?.id) {
      throw new appError(httpStatus.UNAUTHORIZED, "User not authenticated");
    }

    const data = await userService.onBoardUser(request);
    
    return createResponse(
      response,
      httpStatus.OK,
      "User onboarded successfully",
      data
    );

  } catch (error) {
    console.error("OnBoard Error:", {
      message: error.message,
      stack: error.stack,
      status: error.status
    });

    // Handle different types of errors
    if (error instanceof appError) {
      return createResponse(response, error.status, error.message);
    }

    // Handle mongoose validation errors
    if (error.name === 'ValidationError') {
      return createResponse(
        response,
        httpStatus.BAD_REQUEST,
        Object.values(error.errors).map(err => err.message).join(', ')
      );
    }

    // Handle file upload errors
    if (error.code === 'LIMIT_FILE_SIZE' || error.code === 'LIMIT_UNEXPECTED_FILE') {
      return createResponse(
        response,
        httpStatus.BAD_REQUEST,
        "File upload error: " + error.message
      );
    }

    return createResponse(
      response,
      httpStatus.INTERNAL_SERVER_ERROR,
      "Internal server error"
    );
  }
};

// 2. Improve the onBoardUser service
const onBoardUser = async (request) => {
  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    const { name, email, userName, mobileNo, bio, teacherId, role } = request.body;

    // Validate required fields
    const requiredFields = ['name', 'email', 'userName', 'mobileNo'];
    const missingFields = requiredFields.filter(field => !request.body[field]);
    if (missingFields.length > 0) {
      throw new appError(
        httpStatus.BAD_REQUEST,
        `Missing required fields: ${missingFields.join(', ')}`
      );
    }

    // Safely handle file paths
    const profileImg = request.files?.profileImage?.[0]?.location || "";
    const teacherIdCard = request.files?.teacherIdCard?.[0]?.location || "";

    // Validate and normalize email
    const normalizedEmail = email.toLowerCase().trim();
    if (!normalizedEmail.match(/^[^\s@]+@[^\s@]+\.[^\s@]+$/)) {
      throw new appError(httpStatus.BAD_REQUEST, "Invalid email format");
    }

    // Check existing user with email or username
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
    }).session(session);

    if (existingUser) {
      const errorMessage = existingUser.email === normalizedEmail 
        ? "Email already exists"
        : "Username already exists";
      throw new appError(httpStatus.CONFLICT, errorMessage);
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

    // Add teacher-specific fields
    if (role === ROLES.TEACHER) {
      if (!teacherId || !teacherIdCard) {
        throw new appError(
          httpStatus.BAD_REQUEST,
          "Teacher ID and ID card are required for teacher role"
        );
      }
      updateData.teacherIdCard = teacherIdCard;
      updateData.teacherId = teacherId;
    }

    // Update user with transaction
    const updatedUser = await User.findByIdAndUpdate(
      request.user.id,
      updateData,
      {
        new: true,
        runValidators: true,
        session
      }
    );

    if (!updatedUser) {
      throw new appError(httpStatus.NOT_FOUND, "User not found");
    }

    await session.commitTransaction();
    return updatedUser;

  } catch (error) {
    await session.abortTransaction();

    // Clean up uploaded files if there's an error
    if (Object.keys(request.files || {}).length > 0) {
      try {
        const filesToDelete = [
          request.files?.teacherIdCard?.[0]?.location,
          request.files?.profileImage?.[0]?.location
        ].filter(Boolean);
        
        await Promise.all(filesToDelete.map(file => deleteFromS3(file)));
      } catch (cleanupError) {
        console.error('File cleanup error:', cleanupError);
      }
    }

    throw error;
  } finally {
    session.endSession();
  }
};

// 3. Create a validation middleware
const validateOnboardRequest = (req, res, next) => {
  try {
    const { name, email, userName, mobileNo, role } = req.body;

    // Check required fields
    if (!name || !email || !userName || !mobileNo) {
      return createResponse(
        res,
        httpStatus.BAD_REQUEST,
        "Missing required fields"
      );
    }

    // Validate email format
    if (!email.match(/^[^\s@]+@[^\s@]+\.[^\s@]+$/)) {
      return createResponse(
        res,
        httpStatus.BAD_REQUEST,
        "Invalid email format"
      );
    }

    // Validate mobile number
    if (!mobileNo.match(/^\d{10}$/)) {
      return createResponse(
        res,
        httpStatus.BAD_REQUEST,
        "Invalid mobile number format"
      );
    }

    // Validate username
    if (!userName.match(/^[a-zA-Z0-9_]{3,30}$/)) {
      return createResponse(
        res,
        httpStatus.BAD_REQUEST,
        "Invalid username format. Use 3-30 characters, alphanumeric and underscore only"
      );
    }

    // Validate role if provided
    if (role && !Object.values(ROLES).includes(role)) {
      return createResponse(
        res,
        httpStatus.BAD_REQUEST,
        "Invalid role specified"
      );
    }

    next();
  } catch (error) {
    return createResponse(
      res,
      httpStatus.BAD_REQUEST,
      "Invalid request data"
    );
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


