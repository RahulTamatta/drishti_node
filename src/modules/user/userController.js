const userService = require("../user/userService");
const userValidation = require("../user/userValidation");
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


const searchTeachersController = async (req, res) => {
  try {
    const { userName } = req.query;
    console.log('Searching for teachers with query:', userName);

    const query = {
      role: constants.ROLES.TEACHER,
      isOnboarded: true
    };

    if (userName) {
      query.$or = [
        { userName: { $regex: userName, $options: 'i' } },
        { name: { $regex: userName, $options: 'i' } }
      ];
    }

    const teachers = await User.find(query)
      .select('_id userName email teacherId name profileImage')
      .limit(20)
      .lean()
      .then(docs => docs.map(doc => ({
        ...doc,
        id: doc._id,
        _id: undefined
      })));

    return createResponse(
      res,
      httpStatus.OK,
      "Teachers found successfully",
      { data: teachers }
    );
  } catch (error) {
    console.error('Search teachers error:', error);
    return createResponse(
      res,
      error.status || httpStatus.INTERNAL_SERVER_ERROR,
      error.message || "Failed to search teachers"
    );
  }
};



const onBoardUserController = async (req, res) => {
  try {
    // Detailed request logging
    console.log('=== onBoardUserController START ===');
    console.log('Request body type:', typeof req.body);
    console.log('Request body:', req.body);
    console.log('Request body keys:', Object.keys(req.body));
    console.log('userName value:', req.body.userName);
    console.log('Content-Type:', req.get('Content-Type'));
    console.log('Files:', req.files);
    console.log('User:', req.user);
    console.log('=== Request Data END ===');

    if (!req.user || !req.user.id) {
      return createResponse(
        res,
        httpStatus.UNAUTHORIZED,
        'Authentication required'
      );
    }

    const updatedUser = await userService.onBoardUser(req);
    console.log('onBoardUserController - Updated user:', updatedUser);

    if (!updatedUser) {
      return createResponse(
        res,
        httpStatus.BAD_REQUEST,
        'Failed to update user'
      );
    }

    // Transform user data for response
    const userData = {
      id: updatedUser._id.toString(),
      mobileNo: updatedUser.mobileNo || '',
      countryCode: updatedUser.countryCode || '+91',
      deviceTokens: Array.isArray(updatedUser.deviceTokens) ? updatedUser.deviceTokens : [],
      isOnboarded: Boolean(updatedUser.isOnboarded),
      role: updatedUser.role?.toLowerCase() || 'user',
      createdAt: updatedUser.createdAt?.toISOString() || new Date().toISOString(),
      updatedAt: updatedUser.updatedAt?.toISOString() || new Date().toISOString(),
      email: updatedUser.email || '',
      name: updatedUser.name || '',
      profileImage: updatedUser.profileImage || '',
      teacherRoleApproved: updatedUser.teacherRoleApproved?.toLowerCase() || 'pending',
      userName: updatedUser.userName || '',
      teacherId: updatedUser.teacherId || '',
      teacherIdCard: updatedUser.teacherIdCard || ''
    };

    return createResponse(
      res,
      httpStatus.OK,
      'User onboarded successfully',
      userData
    );
  } catch (error) {
    console.error('onBoardUserController Error:', error);
    return createResponse(
      res,
      error.status || httpStatus.INTERNAL_SERVER_ERROR,
      error.message || 'Onboarding failed'
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
    const { teacherId, action } = req.body;
    
    if (!teacherId || !action) {
      throw new appError(httpStatus.BAD_REQUEST, 'Teacher ID and action are required');
    }

    if (!['approve', 'suspend'].includes(action)) {
      throw new appError(httpStatus.BAD_REQUEST, 'Invalid action. Must be either approve or suspend');
    }

    const status = action === 'approve' ? constants.STATUS.ACCEPTED : constants.STATUS.REJECTED;
    const result = await userService.actionOnTeacherAccount({ 
      teacherId, 
      status,
      adminId: req.user._id // Add admin ID who performed the action
    });

    return createResponse(
      res,
      httpStatus.OK,
      `Teacher ${action === 'approve' ? 'approved' : 'suspended'} successfully`,
      result
    );
  } catch (error) {
    console.error('Error in actionOnTeacherAccount:', error);
    return createResponse(
      res,
      error.status || httpStatus.INTERNAL_SERVER_ERROR,
      error.message || `Failed to ${req.body.action} teacher`
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
      teacherRoleApproved: 'pending'
    }).select('-password');
    return createResponse(res, httpStatus.OK, "Teacher requests retrieved", requests);
  } catch (error) {
    console.error('Error in getTeachersRequest:', error);
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

const createAddressController = async (req, res) => {
  try {
    // Validate user authentication
    if (!req.user || !req.user.id) {
      return createResponse(res, httpStatus.UNAUTHORIZED, 'Authentication required');
    }

    // Add user ID to request body
    req.body.userId = req.user.id;

    // Call service to create address
    const result = await userService.createAddressService(req);

    return createResponse(
      res,
      httpStatus.CREATED,
      'Address created successfully',
      result
    );
  } catch (error) {
    console.error('Create address controller error:', error);
    return createResponse(
      res,
      error.status || httpStatus.INTERNAL_SERVER_ERROR,
      error.message || 'Failed to create address'
    );
  }
};

const createEventController = async (req, res) => {
  try {
    const event = await userService.createEventService(req);
    return createResponse(res, httpStatus.CREATED, 'Event created successfully', event);
  } catch (error) {
    return createResponse(res, error.status || httpStatus.INTERNAL_SERVER_ERROR, error.message || 'Failed to create event');
  }
};

module.exports = {
  userLoginController,
  updateLocationController,
  searchTeachersController,
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
  getUser,
  createAddressController,
  createEventController,
};