const express = require("express");
const { firebase } = require("../common/config/firebase");
const appError = require("../common/utils/appError");
const httpStatus = require("../common/utils/status.json");

const app = express();
const bucket = firebase.storage().bucket();

const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB
const ALLOWED_TYPES = ['image/jpeg', 'image/png', 'image/jpg'];
const MAX_RETRIES = 3;
const RETRY_DELAY = 1000; // 1 second

async function uploadFilesToBucket(files) {
  const uploadedFiles = [];
  const errors = [];

  try {
    console.log('Starting file upload process...');
    
    if (!Array.isArray(files) || files.length === 0) {
      console.log('No files to upload');
      return [];
    }

    for (const file of files) {
      try {
        // Validate file
        if (!file.buffer || !file.mimetype) {
          throw new appError(httpStatus.BAD_REQUEST, 'Invalid file data');
        }

        if (file.size > MAX_FILE_SIZE) {
          throw new appError(httpStatus.BAD_REQUEST, `File size exceeds ${MAX_FILE_SIZE / (1024 * 1024)}MB limit`);
        }

        if (!ALLOWED_TYPES.includes(file.mimetype)) {
          throw new appError(httpStatus.BAD_REQUEST, `Invalid file type. Allowed types: ${ALLOWED_TYPES.join(', ')}`);
        }

        // Prepare file path
        const folder = file.fieldname === 'profileImage' ? 'profile-images' : 'teacher-ids';
        const timestamp = Date.now();
        const safeFilename = file.originalname.replace(/[^a-zA-Z0-9.-]/g, '_');
        const filename = `${folder}/${timestamp}-${safeFilename}`;
        
        // Upload with retry mechanism
        let lastError;
        for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
          try {
            const fileRef = bucket.file(filename);
            
            // Upload with metadata
            await fileRef.save(file.buffer, {
              metadata: {
                contentType: file.mimetype,
                metadata: {
                  originalname: file.originalname,
                  fieldname: file.fieldname,
                  timestamp: timestamp
                }
              }
            });

            // Make file public
            await fileRef.makePublic();

            // Get public URL
            const encodedFilename = encodeURIComponent(filename);
            const publicUrl = `https://storage.googleapis.com/${bucket.name}/${encodedFilename}`;
            
            uploadedFiles.push({
              fieldname: file.fieldname,
              originalname: file.originalname,
              url: publicUrl
            });

            console.log(`Successfully uploaded ${filename} on attempt ${attempt}`);
            lastError = null;
            break;
          } catch (error) {
            lastError = error;
            console.error(`Upload attempt ${attempt} failed for ${filename}:`, error);
            
            if (attempt < MAX_RETRIES) {
              await new Promise(resolve => setTimeout(resolve, RETRY_DELAY * attempt));
            }
          }
        }

        if (lastError) {
          throw lastError;
        }
      } catch (error) {
        errors.push({
          file: file.originalname,
          error: error.message
        });
        
        // Try to clean up if file was partially uploaded
        try {
          const fileRef = bucket.file(filename);
          await fileRef.delete();
        } catch (deleteError) {
          console.error('Error cleaning up failed upload:', deleteError);
        }
      }
    }

    if (errors.length > 0) {
      if (errors.length === files.length) {
        // All uploads failed
        throw new appError(
          httpStatus.INTERNAL_SERVER_ERROR,
          `All file uploads failed: ${JSON.stringify(errors)}`
        );
      } else {
        // Some uploads succeeded
        console.warn('Some files failed to upload:', errors);
      }
    }

    return uploadedFiles;
  } catch (error) {
    console.error('File upload error:', error);
    throw error;
  }
}

module.exports = uploadFilesToBucket;
