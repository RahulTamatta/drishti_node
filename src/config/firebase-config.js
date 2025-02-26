const admin = require('firebase-admin');

// Initialize Firebase Admin with proper error handling
const initializeFirebase = () => {
  try {
    if (!admin.apps.length) {
      admin.initializeApp({
        credential: admin.credential.cert({
          projectId: process.env.FIREBASE_PROJECT_ID,
          privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
          clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        }),
        storageBucket: "gs://srisridrishti-c1673.firebasestorage.app"  // Fixed bucket name format
      });
    }
    return admin.storage().bucket();
  } catch (error) {
    console.error('Firebase initialization error:', error);
    throw error;
  }
};

const bucket = initializeFirebase();

module.exports = { admin, bucket };
