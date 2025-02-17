const crypto = require("crypto");
const CryptoJS = require('crypto-js');
require('dotenv').config();

// Make sure these environment variables are set
const ENCRYPTION_KEY = process.env.ENCRYPTION_KEY || 'your-fallback-encryption-key-32chars';
const IV = process.env.ENCRYPTION_IV || 'your-fallback-iv-16-chars';

const encode = (data) => {
  try {
    if (!data) {
      throw new Error('Data to encrypt is required');
    }

    // Convert key and IV to proper format
    const key = CryptoJS.enc.Utf8.parse(ENCRYPTION_KEY);
    const iv = CryptoJS.enc.Utf8.parse(IV);

    // Encrypt the data
    const encrypted = CryptoJS.AES.encrypt(data, key, {
      iv: iv,
      mode: CryptoJS.mode.CBC,
      padding: CryptoJS.pad.Pkcs7
    });

    return encrypted.toString();
  } catch (error) {
    console.error('Encryption error:', error);
    throw new Error('Failed to encrypt data: ' + error.message);
  }
};

const decode = (encryptedData) => {
  try {
    if (!encryptedData) {
      throw new Error('Encrypted data is required');
    }

    // Convert key and IV to proper format
    const key = CryptoJS.enc.Utf8.parse(ENCRYPTION_KEY);
    const iv = CryptoJS.enc.Utf8.parse(IV);

    // Decrypt the data
    const decrypted = CryptoJS.AES.decrypt(encryptedData, key, {
      iv: iv,
      mode: CryptoJS.mode.CBC,
      padding: CryptoJS.pad.Pkcs7
    });

    return decrypted.toString(CryptoJS.enc.Utf8);
  } catch (error) {
    console.error('Decryption error:', error);
    throw new Error('Failed to decrypt data: ' + error.message);
  }
};

module.exports = {
  encode,
  decode
};
