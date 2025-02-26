const AWS = require('aws-sdk');
const AppError = require('./appError');
const httpStatus = require('./status.json');
const config = require("../config/config");
const path = require("path");

/**
 * Uploads a file to AWS S3 bucket
 * @param {Buffer} buffer - File buffer to upload
 * @param {String} key - Key for the file in S3
 * @param {String} mimeType - MIME type of the file
 * @returns {Promise<Object>} Upload result
 */
const uploadToS3 = async (buffer, key, mimeType) => {
  try {
    // Configure AWS with environment variables instead of JWT
    const s3 = new AWS.S3({
      accessKeyId: process.env.AWS_ACCESS_KEY_ID,
      secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
      region: process.env.AWS_REGION
    });

    // Set up the upload parameters
    const params = {
      Bucket: process.env.S3_BUCKET_NAME,
      Key: key,
      Body: buffer,
      ContentType: mimeType,
      ACL: 'public-read'
    };

    // Upload to S3
    const uploadResult = await s3.upload(params).promise();
    console.log('File uploaded successfully:', uploadResult.Location);
    
    return uploadResult;
  } catch (error) {
    console.error('Error uploading file to S3:', error);
    throw new AppError(
      `File upload failed: ${error.message || error}`,
      httpStatus.INTERNAL_SERVER_ERROR
    );
  }
};

const deleteFromS3 = async (fileName) => {
  const deleteParams = {
    Bucket: config.aws.s3Bucket,
    Key: fileName.split("/").pop(),
  };
  await s3.deleteObject(deleteParams).promise();
};

module.exports = { uploadToS3, deleteFromS3 };
