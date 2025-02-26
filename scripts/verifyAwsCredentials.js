require('dotenv').config();
const AWS = require('aws-sdk');

/**
 * Script to verify AWS credentials are properly set up
 */
async function verifyAwsCredentials() {
  console.log('Verifying AWS credentials...');
  
  try {
    // Check if environment variables are set
    if (!process.env.AWS_ACCESS_KEY_ID || !process.env.AWS_SECRET_ACCESS_KEY) {
      console.error('❌ AWS credentials are not set in environment variables');
      console.log('Please set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY in your .env file');
      process.exit(1);
    }

    if (!process.env.AWS_REGION) {
      console.warn('⚠️ AWS_REGION is not set. Using default region: us-east-1');
    }

    if (!process.env.S3_BUCKET_NAME) {
      console.error('❌ S3_BUCKET_NAME is not set in environment variables');
      console.log('Please set S3_BUCKET_NAME in your .env file');
      process.exit(1);
    }

    // Configure AWS with environment variables
    const s3 = new AWS.S3({
      accessKeyId: process.env.AWS_ACCESS_KEY_ID,
      secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
      region: process.env.AWS_REGION || 'us-east-1'
    });

    // Try to list buckets to verify credentials
    const data = await s3.listBuckets().promise();
    console.log('✅ AWS credentials are valid');
    console.log(`Found ${data.Buckets.length} buckets:`);
    data.Buckets.forEach(bucket => {
      console.log(` - ${bucket.Name} ${bucket.Name === process.env.S3_BUCKET_NAME ? '(Your target bucket)' : ''}`);
    });

    // Check if the specified bucket exists
    const bucketExists = data.Buckets.some(bucket => bucket.Name === process.env.S3_BUCKET_NAME);
    if (!bucketExists) {
      console.error(`❌ Bucket "${process.env.S3_BUCKET_NAME}" not found in your AWS account`);
    } else {
      console.log(`✅ Confirmed bucket "${process.env.S3_BUCKET_NAME}" exists`);
    }
  } catch (error) {
    console.error('❌ Error verifying AWS credentials:', error.message);
    if (error.code === 'InvalidAccessKeyId' || error.code === 'SignatureDoesNotMatch') {
      console.log('Please check your AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY values');
    }
    process.exit(1);
  }
}

verifyAwsCredentials();
