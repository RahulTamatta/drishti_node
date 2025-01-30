const jwt = require('jsonwebtoken');

// Set environment variables with standard expiration times
process.env.JWT_ACCESS_EXPIRATION_MINUTES = 30;          // 30 minutes
process.env.JWT_REFRESH_EXPIRATION_DAYS = 7;            // 7 days
process.env.JWT_SECRET = 'your-secret-key';             // Replace with actual secret

const createToken = async (user) => {
  // Calculate expiration dates
  const accessExpiration = new Date(
    Date.now() + process.env.JWT_ACCESS_EXPIRATION_MINUTES * 60000
  );
  const refreshExpiration = new Date(
    Date.now() + process.env.JWT_REFRESH_EXPIRATION_DAYS * 86400000
  );

  // Create access token with 30 minutes expiration
  const accessToken = jwt.sign(
    {
      id: user._id ? user._id : user.id,
      role: user.role,
      type: 'access'
    },
    process.env.JWT_SECRET,
    {
      expiresIn: '30m',  // 30 minutes
    }
  );

  // Create refresh token with 7 days expiration
  const refreshToken = jwt.sign(
    {
      id: user._id ? user._id : user.id,
      role: user.role,
      type: 'refresh'
    },
    process.env.JWT_SECRET,
    {
      expiresIn: '7d',   // 7 days
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

// Example usage
const user = {
  _id: '12345',
  role: 'user'
};

createToken(user)
  .then(tokens => console.log('Generated tokens:', tokens))
  .catch(error => console.error('Error:', error));