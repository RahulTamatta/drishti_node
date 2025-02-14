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

const decode = async (encryptedData) => {
  try {
    console.log('Attempting to decrypt:', encryptedData);
    
    // Split the encrypted data to get salt and data
    const encryptedParts = encryptedData.split('|');
    const encryptedText = encryptedParts[0] || encryptedData; // Fallback to full string if no separator

    // Decrypt using CryptoJS
    const bytes = CryptoJS.AES.decrypt(encryptedText, process.env.ENCRYPTION_KEY);
    const decrypted = bytes.toString(CryptoJS.enc.Utf8);
    
    if (!decrypted) {
      console.error('Decryption resulted in empty string');
      throw new Error('Decryption failed');
    }
    
    console.log('Decryption successful:', {
      input: encryptedData,
      decrypted: decrypted
    });
    
    return decrypted;
  } catch (error) {
    console.error('Decryption error:', error);
    throw new Error('Failed to decrypt data');
  }
};

module.exports = { encode, decode };
