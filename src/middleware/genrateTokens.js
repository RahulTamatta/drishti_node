// utils/tokenService.js
const jwt = require('jsonwebtoken');
const User = require('../models/user');
const createResponse = require('../common/utils/createResponse');
const httpStatus = require('../common/utils/status.json');

// Environment variables for token expiration and secret
process.env.JWT_ACCESS_EXPIRATION_MINUTES = 30;
process.env.JWT_REFRESH_EXPIRATION_DAYS = 7;
process.env.JWT_SECRET = 'sdkfjsdfklsjfejrfisdldskfvjdlkcnldskfjsklfjsdkjfckvncvnlnkln'; // 



const createToken = async (user) => {
  try {
    console.log('Creating tokens for user:', user._id);

    if (!user || !user._id) {
      throw new Error('Invalid user data for token generation');
    }

    const accessExpiration = new Date(
      Date.now() + (process.env.JWT_ACCESS_EXPIRATION_MINUTES || 30) * 60 * 1000
    );
    const refreshExpiration = new Date(
      Date.now() + (process.env.JWT_REFRESH_EXPIRATION_DAYS || 7) * 24 * 60 * 60 * 1000
    );

    const accessToken = jwt.sign(
      {
        id: user._id,
        role: user.role || 'USER',
        type: 'access'
      },
      process.env.JWT_SECRET,
      { expiresIn: `${process.env.JWT_ACCESS_EXPIRATION_MINUTES || 30}m` }
    );

    const refreshToken = jwt.sign(
      {
        id: user._id,
        role: user.role || 'USER',
        type: 'refresh'
      },
      process.env.JWT_SECRET,
      { expiresIn: `${process.env.JWT_REFRESH_EXPIRATION_DAYS || 7}d` }
    );

    // Save refresh token
    await User.findByIdAndUpdate(user._id, {
      $push: {
        refreshTokens: {
          token: refreshToken,
          expiresAt: refreshExpiration
        }
      }
    });

    return {
      role: user.role,
      accessToken,
      refreshToken,
      accessTokenExpiresAt: accessExpiration.toISOString(),
      refreshTokenExpiresAt: refreshExpiration.toISOString(),
      user: {
        id: user._id,
        mobileNo: user.mobileNo,
        role: user.role,
        isOnboarded: user.isOnboarded
      }
    };
  } catch (error) {
    console.error('Token generation error:', error);
    throw error;
  }
};

const generateToken = async (req, res) => {
  try {
    const refreshToken = req.body.refreshToken;
    if (!refreshToken) {
      return createResponse(res, httpStatus.UNAUTHORIZED, "Refresh token is required");
    }

    // Verify refresh token
    const decoded = await new Promise((resolve, reject) => {
      jwt.verify(refreshToken, process.env.JWT_SECRET, (err, decoded) => {
        if (err) {
          console.error("Refresh token verification error:", err);
          reject(err);
        }
        resolve(decoded);
      });
    });

    // Find user and validate refresh token
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

    return createResponse(res, httpStatus.OK, "New access token generated", tokens);
  } catch (error) {
    console.error("Error in generateToken:", error);
    if (error.name === 'JsonWebTokenError' || error.name === 'TokenExpiredError') {
      return createResponse(res, httpStatus.UNAUTHORIZED, "Invalid or expired refresh token");
    }
    return createResponse(res, httpStatus.INTERNAL_SERVER_ERROR, "Internal server error");
  }
};

const generateResetPasswordToken = (user) => {
  return jwt.sign({ user }, config.resetPassword.secret, {
    expiresIn: config.resetPassword.expiry + "h",
  });
};

const verifyResetPasswordToken = (token) => {
  try {
    const decoded = jwt.verify(token, config.resetPassword.secret);
    return { decoded, error: null };
  } catch (error) {
    return { decoded: null, error };
  }
};

module.exports = {
  createToken,
  generateToken,
  generateResetPasswordToken,
  verifyResetPasswordToken,
};