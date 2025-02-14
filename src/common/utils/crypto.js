const crypto = require("crypto");
const CryptoJS = require('crypto-js');
require('dotenv').config();

const encode = async (data) => {
  try {
    // Convert data to string if it's an object
    const stringData = typeof data === 'object' ? JSON.stringify(data) : String(data);
    
    // Use CryptoJS for encryption
    const encrypted = CryptoJS.AES.encrypt(
      stringData,
      process.env.ENCRYPTION_KEY
    ).toString();
    
    console.log('Encryption successful:', {
      original: stringData,
      encrypted: encrypted
    });
    
    return encrypted;
  } catch (error) {
    console.error('Encryption error:', error);
    throw new Error('Failed to encrypt data');
  }
};