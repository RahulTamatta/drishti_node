const createResponse = (
  response,
  status = 500,
  message = "Internal Server error",
  payload
) => {
  return response.status(status).json({
    message: message,
    data: payload,
  });
};

module.exports = createResponse;
