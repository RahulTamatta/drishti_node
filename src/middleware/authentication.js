const jwt = require("jsonwebtoken");
const constants = require("../common/utils/constants.js");
const createResponse = require("../common/utils/createResponse.js");
const status = require("../common/utils/status.json");
const User = require("../models/user");
const auth = (user_Role) => async (request, response, next) => {
  const userRole = Array.isArray(user_Role) ? user_Role : [user_Role];
  const token = request.header("Authorization");

  if (!token && userRole.includes(constants.ROLES.GUEST)) {
    return next();
  }

  try {
    if (!token) {
      return createResponse(
        //new feature
        response,
        status.UNAUTHORIZED,
        "please provide a token"
      );
    }

    jwt.verify(token, process.env.JWT_SECRET, async function (error, verified) {
      if (error) {
        if (error.message == "jwt expired") {
          return createResponse(
            response,
            status.UNAUTHORIZED,
            "access_token is expired"
          );
        }
        return createResponse(response, status.GONE, error.message);
      }
      console.log("verify", verified);
      request["user"] = verified;
      const id = request.user.id;
      const user = await User.findById(id);
      const role = user.role;
      if (!user) {
        return createResponse(response, status.NOT_FOUND, "user not found");
      }
      if (userRole.includes(role)) {
        if (user?.status === constants.STATUS.DEACTIVE) {
          return createResponse(
            response,
            status.FORBIDDEN,
            "your account is deactivated please connect with your administrator"
          );
        }
        if (user?.status === constants.STATUS.DELETED) {
          return createResponse(
            response,
            status.GONE,
            "your account is deleted please connect with your administrator"
          );
        }
        request["user"] = user;
        return next();
      } else {
        return createResponse(response, status.FORBIDDEN, "unauthorized");
      }
    });
  } catch (error) {
    return createResponse(response, error.status, error.message);
  }
};
module.exports = auth;
