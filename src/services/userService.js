const User = require('../models/user');
const ApiError = require('../utils/ApiError');
const { validateEmail, validatePhoneNumber } = require('../utils/validation');

class UserService {
  async createProfile(userData, profileImage, teacherIdCard) {
    const { userName, name, email, mobileNo, role, teacherId } = userData;

    
    if (!userName || !name || !email || !mobileNo || !role) {
      throw new ApiError(400, 'Missing required fields');
    }

    
    if (!validateEmail(email)) {
      throw new ApiError(400, 'Invalid email format');
    }

    if (!validatePhoneNumber(mobileNo)) {
      throw new ApiError(400, 'Invalid phone number format');
    }

    
    const existingUser = await User.findOne({
      $or: [{ userName }, { email }]
    });

    if (existingUser) {
      throw new ApiError(409, 'Username or email already exists');
    }

    
    if (role === 'teacher') {
      if (!teacherId || !teacherIdCard) {
        throw new ApiError(400, 'Teacher ID and ID card are required for teacher role');
      }
    }

    
    const user = new User({
      userName,
      name,
      email,
      mobileNo,
      role,
      teacherId: role === 'teacher' ? teacherId : undefined,
      profileImage: profileImage?.path,
      teacherIdCard: teacherIdCard?.path,
      teacherRoleApproved: role === 'teacher' ? 'pending' : undefined
    });

    await user.save();
    return user;
  }

  async updateProfile(userId, updateData, profileImage, teacherIdCard) {
    const user = await User.findById(userId);
    if (!user) {
      throw new ApiError(404, 'User not found');
    }

    
    if (updateData.email && !validateEmail(updateData.email)) {
      throw new ApiError(400, 'Invalid email format');
    }

    if (updateData.mobileNo && !validatePhoneNumber(updateData.mobileNo)) {
      throw new ApiError(400, 'Invalid phone number format');
    }

    
    const allowedUpdates = ['userName', 'name', 'email', 'mobileNo', 'role', 'teacherId'];
    allowedUpdates.forEach(field => {
      if (updateData[field] !== undefined) {
        user[field] = updateData[field];
      }
    });

    
    if (profileImage) {
      user.profileImage = profileImage.path;
    }

    if (teacherIdCard) {
      user.teacherIdCard = teacherIdCard.path;
    }

    await user.save();
    return user;
  }

  async getProfile(userId) {
    const user = await User.findById(userId);
    if (!user) {
      throw new ApiError(404, 'User not found');
    }
    return user;
  }

  async deleteProfile(userId) {
    const user = await User.findByIdAndDelete(userId);
    if (!user) {
      throw new ApiError(404, 'User not found');
    }
    return user;
  }
}

module.exports = new UserService();
