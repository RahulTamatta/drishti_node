const crypto = require("crypto");
const config = require("../config/config");
var password = config.crypto.CryptoPassword;
var iv = Buffer.from(config.crypto.Iv, "hex");
function sha1(input) {
  return crypto.createHash("sha1").update(input).digest();
}

function password_derive_bytes(password, salt, iterations, len) {
  var key = Buffer.from(password + salt);
  for (var i = 0; i < iterations; i++) {
    key = sha1(key);
  }
  if (key.length < len) {
    var hx = password_derive_bytes(password, salt, iterations - 1, 20);
    for (var counter = 1; key.length < len; ++counter) {
      key = Buffer.concat([
        key,
        sha1(Buffer.concat([Buffer.from(counter.toString()), hx])),
      ]);
    }
  }
  return Buffer.alloc(len, key);
}

async function encode(string) {
  var key = password_derive_bytes(password, "", 100, 32);
  var cipher = crypto.createCipheriv("aes-256-cbc", key, iv);
  var part1 = cipher.update(string, "utf8");
  var part2 = cipher.final();
  const encrypted = Buffer.concat([part1, part2]).toString("base64");
  return encrypted;
}

async function decode(string) {
  var key = password_derive_bytes(password, "", 100, 32);
  var decipher = crypto.createDecipheriv("aes-256-cbc", key, iv);
  var decrypted = decipher.update(string, "base64", "utf8");
  decrypted += decipher.final();
  return decrypted;
}

module.exports = { encode, decode };
