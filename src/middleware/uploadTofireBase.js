const express = require("express");
const { firebase } = require("../common/config/firebase");
const app = express();

app.locals.bucket = firebase.storage().bucket();
async function uploadFilesToBucket(files) {
  const fileWithUrls = [];

  if (!Array.isArray(files)) {
    files = [files];
  }

  for (const document of files) {
    try {
      await app.locals.bucket
        .file(document.originalname)
        .createWriteStream()
        .end(document.buffer);

      fileWithUrls.push({
        label: `${document.originalname}${new Date().toLocaleDateString()}`,
        link: `https://firebasestorage.googleapis.com/v0/b/${process.env.BUCKET_URL}/o/${document.originalname}?alt=media`,
      });
    } catch (error) {
      console.error(
        `Error uploading file ${document.originalname}: ${error.message}`
      );
    }
  }

  return fileWithUrls;
}

module.exports = uploadFilesToBucket;
