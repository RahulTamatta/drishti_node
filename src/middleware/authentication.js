const jwt = require("jsonwebtoken");
const constants = require("../common/utils/constants.js");
const createResponse = require("../common/utils/createResponse.js");
const status = require("../common/utils/status.json");
const User = require("../models/user");

const verifyJWT = (token, secret) => {
  return new Promise((resolve, reject) => {
    jwt.verify(token, secret, (error, decoded) => {
      if (error) reject(error);
      resolve(decoded);
    });
  });
};

const auth = (user_Role) => async (request, response, next) => {
  try {
    const userRole = Array.isArray(user_Role) ? user_Role : [user_Role];
    const authHeader = request.header("Authorization");
    
    // Handle guest role
    if (!authHeader && userRole.includes(constants.ROLES.GUEST)) {
      return next();
    }

    if (!authHeader) {
      return createResponse(
        response,
        status.UNAUTHORIZED,
        "Please provide an authorization token"
      );
    }

    // Extract token from Bearer format
    const token = authHeader.startsWith("Bearer ") 
      ? authHeader.slice(7) 
      : authHeader;

    try {
      const verified = await verifyJWT(token, process.env.JWT_SECRET);
      
      // Find and validate user
      const user = await User.findById(verified.id);
      
      if (!user) {
        return createResponse(
          response, 
          status.NOT_FOUND, 
          "User not found"
        );
      }

      // Check role authorization
      if (!userRole.includes(user.role)) {
        return createResponse(
          response, 
          status.FORBIDDEN, 
          "Unauthorized role"
        );
      }

      // Check user status
      switch (user.status) {
        case constants.STATUS.DEACTIVE:
          return createResponse(
            response,
            status.FORBIDDEN,
            "Your account is deactivated. Please contact your administrator"
          );
        case constants.STATUS.DELETED:
          return createResponse(
            response,
            status.GONE,
            "Your account is deleted. Please contact your administrator"
          );
      }

      // Attach user to request
      request.user = user;
      return next();

    } catch (error) {
      if (error.name === "TokenExpiredError") {
        return createResponse(
          response,
          status.UNAUTHORIZED,
          "Access token has expired"
        );
      }
      return createResponse(
        response, 
        status.GONE, 
        error.message
      );
    }

  } catch (error) {
    return createResponse(
      response, 
      error.status || status.INTERNAL_SERVER_ERROR, 
      error.message
    );
  }
};

module.exports = auth;