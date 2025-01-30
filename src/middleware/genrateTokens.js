
// utils/tokenService.js
const jwt = require('jsonwebtoken');

process.env.JWT_ACCESS_EXPIRATION_MINUTES = 30;
process.env.JWT_REFRESH_EXPIRATION_DAYS = 7;
process.env.JWT_SECRET = 'your-secret-key'; // Move to .env file

const createToken = async (user) => {
  const accessExpiration = new Date(
    Date.now() + process.env.JWT_ACCESS_EXPIRATION_MINUTES * 60000
  );
  const refreshExpiration = new Date(
    Date.now() + process.env.JWT_REFRESH_EXPIRATION_DAYS * 86400000
  );

  const accessToken = jwt.sign(
    {
      id: user._id ? user._id : user.id,
      role: user.role,
      type: 'access'
    },
    process.env.JWT_SECRET,
    {
      expiresIn: '30m',
    }
  );

  const refreshToken = jwt.sign(
    {
      id: user._id ? user._id : user.id,
      role: user.role,
      type: 'refresh'
    },
    process.env.JWT_SECRET,
    {
      expiresIn: '7d',
    }
  );

  return {
    role: user.role,
    accessToken,
    accessTokenExpiresAt: accessExpiration,
    refreshToken,
    refreshTokenExpiresAt: refreshExpiration,
    user,
  };
};

module.exports = {
  createToken
};

// const generateToken = async (request, response) => {
//   try {
//     const refreshToken = request.body.refreshtoken;
//     if (!refreshToken) {
//       return createResponse(
//         response,
//         status.UNAUTHORIZED,
//         request.t("auth.NOT_VALID_TOKEN")
//       );
//     }

//     return jwt.verify(
//       refreshToken,
//       process.env.JWT_SECRET,
//       async function (error, decoded) {
//         if (error) {
//           if (error.message == "jwt expired") {
//             return createResponse(
//               response,
//               status.UNAUTHORIZED,
//               request.t("auth.TOKEN_EXPIRED")
//             );
//           } else {
//             return createResponse(response, status.UNAUTHORIZED, error);
//           }
//         }
//         const isUser = await User.findOne({
//           _id: decoded.id,
//           role: decoded.role,
//         });
//         if (isUser?.status === STATUS.DEACTIVE) {
//           return createResponse(
//             response,
//             status.FORBIDDEN,
//             request.t("user.DEACTIVE_ACCOUNT")
//           );
//         }
//         if (isUser?.status === STATUS.DELETED) {
//           return createResponse(
//             response,
//             status.GONE,
//             request.t("user.ACCOUNT_DELETED")
//           );
//         }
//         const user = await createToken(decoded);
//         const tokens = {
//           role: user.role,
//           accessToken: user.accessToken,
//           accessTokenExpire: user.accessTokenExpiresAt,
//           refreshToken: user.refreshToken,
//           refreshTokenExpire: user.refreshTokenExpiresAt,
//         };
//         return createResponse(
//           response,
//           status.OK,
//           request.t("auth.NEW_ACCESS_TOKEN"),
//           tokens
//         );
//       }
//     );
//   } catch (error) {
//     const errorMessage = error.message || "Internal Server Error";
//     const statusCode = error.status || status.INTERNAL_SERVER_ERROR;
//     return createResponse(response, statusCode, errorMessage);
//   }
// };

// const generateResetPasswordToken = (user) => {
//   return jwt.sign({ user }, config.resetPassword.secret, {
//     expiresIn: config.resetPassword.expiry + "h",
//   });
// };

// const verifyResetPasswordToken = (token) => {
//   try {
//     const decoded = jwt.verify(token, config.resetPassword.secret);
//     return { decoded, error: null };
//   } catch (error) {
//     return { decoded: null, error };
//   }
// };

module.exports = {
  createToken,
  // generateResetPasswordToken,
  // generateToken,
  // verifyResetPasswordToken,
};
