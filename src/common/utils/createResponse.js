const createResponse = (
  response,
  status = 500,
  message = "Internal Server error",
  payload = null
) => {
  if (!response || !response.status) {
    console.error('Invalid response object provided to createResponse');
    return;
  }
  
  try {
    return response.status(status).json({
      success: status >= 200 && status < 300,
      message: message,
      data: payload,
    });
  } catch (err) {
    console.error('Error in createResponse:', err);
    return response.status(500).json({
      success: false,
      message: 'Internal server error',
      data: null
    });
  }
};

module.exports = createResponse;
