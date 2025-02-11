const express = require("express");
const { firebase } = require("../common/config/firebase");
const app = express();

app.locals.bucket = firebase.storage().bucket();
async function uploadFilesToBucket(files) {
  // Add this at the start of your file
console.log('Bucket name:', process.env.BUCKET_URL);
console.log('Firebase initialized:', !!firebase);
  const fileWithUrls = [];

  if (!Array.isArray(files)) {
    files = [files];
  }

  for (const document of files) {
    try {
      console.log('Attempting to upload file:', document.originalname);
      console.log('File buffer size:', document.buffer.length);
      
      await app.locals.bucket
        .file(document.originalname)
        .createWriteStream()
        .end(document.buffer);

      const fileUrl = `https://firebasestorage.googleapis.com/v0/b/${process.env.BUCKET_URL}.appspot.com/o/${encodeURIComponent(document.originalname)}?alt=media`;
      console.log('Generated file URL:', fileUrl);

      fileWithUrls.push({
        label: `${document.originalname}${new Date().toLocaleDateString()}`,
        link: fileUrl,
      });
    } catch (error) {
      console.error('Detailed upload error:', {
        fileName: document.originalname,
        error: error.message, // Include the error message
        stack: error.stack,   // Include the stack trace
        bucketInfo: app.locals.bucket.name
      });
      // More informative error message:
      throw new Error(`File upload failed for ${document.originalname}: ${error.message}`);
    }
  }

  return fileWithUrls;
}


module.exports = uploadFilesToBucket;
