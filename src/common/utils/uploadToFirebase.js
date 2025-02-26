const { bucket } = require('../../config/firebase-config');
const { v4: uuidv4 } = require('uuid');
const path = require('path');

const uploadToFirebase = async (fileBuffer, destination, mimeType) => {
  try {
    if (!fileBuffer || !destination) {
      throw new Error('File buffer and destination are required');
    }

    // Create a unique filename with proper extension
    const fileExt = path.extname(destination);
    const uniqueFilename = `${path.dirname(destination)}/${Date.now()}_${uuidv4()}${fileExt}`;
    const file = bucket.file(uniqueFilename);

    const options = {
      metadata: {
        contentType: mimeType,
      },
      resumable: false, // Set to false for small files for better performance
      validation: 'md5'
    };

    // Upload using promise-based approach
    await file.save(fileBuffer, options);

    // Make file public and get URL
    await file.makePublic();
    const publicUrl = `https://storage.googleapis.com/${bucket.name}/${uniqueFilename}`;

    return publicUrl;
  } catch (error) {
    console.error('Upload to Firebase error:', error);
    throw error;
  }
};

module.exports = uploadToFirebase;
