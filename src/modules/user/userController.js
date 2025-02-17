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

const ROLES = constants.ROLES;

const handleFileUploads = async (files) => {
  const results = {
    profileImage: null,
    teacherIdCard: null
  };

  if (!files) return results;

  try {
    console.log('Processing files for upload:', {
      hasProfileImage: !!files.profileImage?.[0],
      hasTeacherIdCard: !!files.teacherIdCard?.[0]
    });

    // Validate files before upload
    const validateFile = (file) => {
      if (!file || !file.buffer) {
        throw new appError(httpStatus.BAD_REQUEST, 'Invalid file data');
      }

      if (file.size > 5 * 1024 * 1024) { // 5MB
        throw new appError(httpStatus.BAD_REQUEST, 'File size must be less than 5MB');
      }

      if (!['image/jpeg', 'image/png', 'image/jpg'].includes(file.mimetype)) {
        throw new appError(httpStatus.BAD_REQUEST, 'Only JPG and PNG files are allowed');
      }
    };

    // Prepare files array for upload
    const filesToUpload = [];
    if (files.profileImage?.[0]) {
      validateFile(files.profileImage[0]);
      filesToUpload.push(files.profileImage[0]);
    }
    if (files.teacherIdCard?.[0]) {
      validateFile(files.teacherIdCard[0]);
      filesToUpload.push(files.teacherIdCard[0]);
    }

    if (filesToUpload.length === 0) {
      console.log('No files to upload');
      return results;
    }

    // Upload files to Firebase
    const uploadedFiles = await uploadFilesToBucket(filesToUpload);
    console.log('Uploaded files:', uploadedFiles);

    // Map uploaded files back to results
    uploadedFiles.forEach(file => {
      if (file.fieldname === 'profileImage') {
        results.profileImage = file.url;
      } else if (file.fieldname === 'teacherIdCard') {
        results.teacherIdCard = file.url;
      }
    });

    // Validate upload results
    if (files.profileImage?.[0] && !results.profileImage) {
      throw new appError(httpStatus.INTERNAL_SERVER_ERROR, 'Failed to upload profile image');
    }
    if (files.teacherIdCard?.[0] && !results.teacherIdCard) {
      throw new appError(httpStatus.INTERNAL_SERVER_ERROR, 'Failed to upload teacher ID card');
    }

    return results;
  } catch (error) {
    console.error('Error in handleFileUploads:', error);
    
    // Clean up any successful uploads if there was an error
    try {
      if (results.profileImage) {
        await deleteFileFromUrl(results.profileImage);
      }
      if (results.teacherIdCard) {
        await deleteFileFromUrl(results.teacherIdCard);
      }
    } catch (cleanupError) {
      console.error('Error cleaning up files:', cleanupError);
    }

    throw error;
  }
};

// Helper function to delete file from Firebase using URL
async function deleteFileFromUrl(url) {
  try {
    const decodedUrl = decodeURIComponent(url);
    const filename = decodedUrl.split('/').pop();
    const fileRef = bucket.file(filename);
    await fileRef.delete();
  } catch (error) {
    console.error('Error deleting file:', error);
  }
}

const userLoginController = async (request, response) => {
  try {
    console.log("Login request body:", request.body);
    
    const data = await userService.userLoginService(request);
    console.log("Data from userLoginService:", data);

    if (!data) {
      throw new appError(
        httpStatus.CONFLICT,
        "Unable to send OTP"
      );
    }

    return createResponse(
      response,
      httpStatus.OK,
      "OTP sent successfully",
      data
    );
  } catch (error) {
    console.error("Error in userLoginController:", error);
    return createResponse(
      response,
      error.status || httpStatus.INTERNAL_SERVER_ERROR,
      error.message || "Failed to send OTP"
    );
  }
};

const updateLocationController = async (req, res) => {
  try {
    // Implement location update logic
    return createResponse(res, httpStatus.OK, "Location updated");
  } catch (error) {
    return createResponse(
      res,
      error.status || httpStatus.INTERNAL_SERVER_ERROR,
      error.message || "Location update failed"
    );
  }
};

const onBoardUserController = async (req, res) => {
  try {
    // Implement user onboarding logic
    return createResponse(res, httpStatus.OK, "User onboarded successfully");
  } catch (error) {
    return createResponse(
      res,
      error.status || httpStatus.INTERNAL_SERVER_ERROR,
      error.message || "Onboarding failed"
    );
  }
};

const addFiles = async (req, res) => {
  try {
    const files = await handleFileUploads(req.files);
    return createResponse(res, httpStatus.OK, "Files uploaded successfully", files);
  } catch (error) {
    return createResponse(
      res,
      error.status || httpStatus.INTERNAL_SERVER_ERROR,
      error.message || "File upload failed"
    );
  }
};

const addTeacherRole = async (req, res) => {
  try {
    // Implement teacher role addition logic
    return createResponse(res, httpStatus.OK, "Teacher role added");
  } catch (error) {
    return createResponse(
      res,
      error.status || httpStatus.INTERNAL_SERVER_ERROR,
      error.message || "Failed to add teacher role"
    );
  }
};

const getAllUsers = async (req, res) => {
  try {
    const users = await User.find().select('-password');
    return createResponse(res, httpStatus.OK, "Users retrieved", users);
  } catch (error) {
    return createResponse(
      res,
      error.status || httpStatus.INTERNAL_SERVER_ERROR,
      error.message || "Failed to get users"
    );
  }
};

const getAllTeachers = async (req, res) => {
  try {
    const teachers = await User.find({ role: ROLES.TEACHER }).select('-password');
    return createResponse(res, httpStatus.OK, "Teachers retrieved", teachers);
  } catch (error) {
    return createResponse(
      res,
      error.status || httpStatus.INTERNAL_SERVER_ERROR,
      error.message || "Failed to get teachers"
    );
  }
};

const actionOnTeacherAccount = async (req, res) => {
  try {
    // Implement teacher account action logic
    return createResponse(res, httpStatus.OK, "Action completed successfully");
  } catch (error) {
    return createResponse(
      res,
      error.status || httpStatus.INTERNAL_SERVER_ERROR,
      error.message || "Action failed"
    );
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

    // Call the service function to verify OTP
    const result = await userService.verifyOtp(request);
    
    if (!result || !result.user) {
      throw new appError(httpStatus.INTERNAL_SERVER_ERROR, "Invalid verification result");
    }

    // Safely access user properties with null checks and defaults
    const user = result.user;
    const userId = user._id ? user._id.toString() : null;

    if (!userId) {
      throw new appError(httpStatus.INTERNAL_SERVER_ERROR, "Invalid user ID");
    }

    // Prepare the response with null checks and default values
    const responseData = {
      success: true,
      message: "User logged in successfully",
      data: {
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        accessTokenExpiresAt: result.accessExpiration,
        refreshTokenExpiresAt: result.refreshExpiration,
        user: {
          id: userId,
          mobileNo: user.mobileNo || '',
          role: user.role || 'user',
          isOnboarded: !!user.isOnboarded,
          countryCode: user.countryCode || '+91',
          deviceTokens: Array.isArray(user.deviceTokens) ? user.deviceTokens : [],
          teacherRoleApproved: user.teacherRoleApproved || 'pending',
          nearByVisible: !!user.nearByVisible,
          locationSharing: !!user.locationSharing
        },
        isNewUser: !!result.isNewUser
      }
    };

    console.log('Response prepared:', {
      userId: responseData.data.user.id,
      hasAccessToken: !!responseData.data.accessToken,
      hasRefreshToken: !!responseData.data.refreshToken
    });

    return response.status(httpStatus.OK).json(responseData);

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

const getTeachersRequest = async (req, res) => {
  try {
    const requests = await User.find({ 
      role: ROLES.TEACHER, 
      status: 'pending' 
    }).select('-password');
    return createResponse(res, httpStatus.OK, "Teacher requests retrieved", requests);
  } catch (error) {
    return createResponse(
      res,
      error.status || httpStatus.INTERNAL_SERVER_ERROR,
      error.message || "Failed to get teacher requests"
    );
  }
};

const updateSocialMediaLinks = async (req, res) => {
  try {
    // Implement social media links update logic
    return createResponse(res, httpStatus.OK, "Social media links updated");
  } catch (error) {
    return createResponse(
      res,
      error.status || httpStatus.INTERNAL_SERVER_ERROR,
      error.message || "Failed to update social media links"
    );
  }
};

const generateTokenController = async (req, res) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) {
      return createResponse(res, httpStatus.BAD_REQUEST, "Refresh token required");
    }
    const newToken = await createToken(refreshToken);
    return createResponse(res, httpStatus.OK, "Token refreshed", { token: newToken });
  } catch (error) {
    return createResponse(
      res,
      error.status || httpStatus.INTERNAL_SERVER_ERROR,
      error.message || "Token refresh failed"
    );
  }
};

const locationSharing = async (req, res) => {
  try {
    // Implement location sharing logic
    return createResponse(res, httpStatus.OK, "Location sharing updated");
  } catch (error) {
    return createResponse(
      res,
      error.status || httpStatus.INTERNAL_SERVER_ERROR,
      error.message || "Failed to update location sharing"
    );
  }
};

const getNearbyVisible = async (req, res) => {
  try {
    // Implement nearby visible users logic
    return createResponse(res, httpStatus.OK, "Nearby visible users retrieved");
  } catch (error) {
    return createResponse(
      res,
      error.status || httpStatus.INTERNAL_SERVER_ERROR,
      error.message || "Failed to get nearby visible users"
    );
  }
};

const getSocialMediaController = async (req, res) => {
  try {
    const { userId } = req.params;
    const user = await User.findById(userId).select('socialMediaLinks');
    return createResponse(res, httpStatus.OK, "Social media links retrieved", user?.socialMediaLinks);
  } catch (error) {
    return createResponse(
      res,
      error.status || httpStatus.INTERNAL_SERVER_ERROR,
      error.message || "Failed to get social media links"
    );
  }
};

const searchUsers = async (req, res) => {
  try {
    const { query } = req.body;
    
    if (!query) {
      return createResponse(
        res, 
        httpStatus.BAD_REQUEST, 
        "Query is required"
      );
    }
    
    const users = await User.find({
      $or: [
        { name: { $regex: query, $options: 'i' } },
        { userName: { $regex: query, $options: 'i' } },
      ]
    })
    .select('name userName profileImage')
    .limit(10);
    
    return createResponse(
      res, 
      httpStatus.OK, 
      "Users found", 
      users
    );
  } catch (error) {
    console.error("Search users error:", error);
    return createResponse(
      res, 
      error.status || httpStatus.INTERNAL_SERVER_ERROR,
      error.message || "Error searching users"
    );
  }
};

async function getUser(request, response) {
  try {
    console.log('Getting user profile for:', request.user?.id);

    if (!request.user || !request.user.id) {
      console.log('No user in request:', request.user);
      return createResponse(
        response,
        httpStatus.UNAUTHORIZED,
        "User not authenticated"
      );
    }

    const user = await User.findById(request.user.id)
      .select('-refreshTokens -password')
      .lean();

    console.log('Found user from DB:', user);

    
    if (!user) {
      console.log('User not found in DB for id:', request.user.id);
      throw new appError(httpStatus.NOT_FOUND, "User not found");
    }
    console.log('Raw user document from DB:', user);

    // Transform user data to ensure no null values and proper types
    const data = {
      _id: user._id.toString(), // Keep _id for MongoDB compatibility
      id: user._id.toString(),  // Add id for frontend compatibility
      mobileNo: user.mobileNo || '',
      countryCode: user.countryCode || '',
      deviceTokens: Array.isArray(user.deviceTokens) ? user.deviceTokens : [],
      isOnboarded: Boolean(user.isOnboarded),
      createdAt: user.createdAt ? user.createdAt.toISOString() : new Date().toISOString(),
      updatedAt: user.updatedAt ? user.updatedAt.toISOString() : new Date().toISOString(),
      role: user.role || 'user',
      email: user.email || '',
      name: user.name || '',
      profileImage: user.profileImage || '',
      teacherRoleApproved: user.teacherRoleApproved || 'pending',
      userName: user.userName || '',
      teacherId: user.teacherId || '',
      teacherIdCard: user.teacherIdCard || '',
      bio: user.bio || '',
      youtubeUrl: user.youtubeUrl || '',
      xUrl: user.xUrl || '',
      instagramUrl: user.instagramUrl || '',
      nearByVisible: Boolean(user.nearByVisible),
      locationSharing: Boolean(user.locationSharing),
      geometry: user.geometry || { type: 'Point', coordinates: [0, 0] }
    };

    console.log('Sending transformed user data:', data);
    console.log('Processed user data for response:', data);
    return createResponse(
      response,
      httpStatus.OK,
      "User found",
      data
    );
  } catch (error) {
    console.error('Error in getUser:', error);
    return createResponse(
      response,
      error.status || httpStatus.INTERNAL_SERVER_ERROR,
      error.message || "Failed to retrieve user profile"
    );
  }
}

module.exports = {
  userLoginController,
  updateLocationController,
  onBoardUserController,
  addFiles,
  addTeacherRole,
  getAllUsers,
  getAllTeachers,
  actionOnTeacherAccount,
  verifyOtpController,
  getTeachersRequest,
  updateSocialMediaLinks,
  generateTokenController,
  locationSharing,
  getNearbyVisible,
  getSocialMediaController,
  searchUsers,
  getUser
};