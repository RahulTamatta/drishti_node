const admin = require('firebase-admin');
const { v4: uuidv4 } = require('uuid');

// Initialize Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert({
      projectId: process.env.FIREBASE_PROJECT_ID,
      privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    }),
    storageBucket: process.env.BUCKET_NAME
  });
}

const bucket = admin.storage().bucket();

const uploadToFirebase = async (buffer, path, contentType) => {
  try {
    // Create a unique filename
    const filename = `${path}_${uuidv4()}`;
    const file = bucket.file(filename);

    // Create write stream and upload
    const stream = file.createWriteStream({
      metadata: {
        contentType: contentType,
      },
      resumable: false
    });

    return new Promise((resolve, reject) => {
      stream.on('error', (error) => {
        console.error('Upload stream error:', error);
        reject(error);
      });

      stream.on('finish', async () => {
        try {
          // Make the file public
          await file.makePublic();

          // Get the public URL
          const publicUrl = `https://storage.googleapis.com/${bucket.name}/${filename}`;
          resolve(publicUrl);
        } catch (error) {
          console.error('Error making file public:', error);
          reject(error);
        }
      });

      // Write the buffer to the stream
      stream.end(buffer);
    });
  } catch (error) {
    console.error('Upload to Firebase error:', error);
    throw error;
  }
};

module.exports = uploadToFirebase;
