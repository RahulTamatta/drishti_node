const Joi = require("joi");

const addressCreateV = {
  body: Joi.object().keys({
    title: Joi.string(),
    city: Joi.string(),
    state: Joi.string(),
    country: Joi.string(),
    pin: Joi.string(),
    location: Joi.string(),
    latlong: Joi.object().keys({  // latlong field for location
      type: Joi.string().valid('Point').required(),
      coordinates: Joi.array().items(Joi.number()).length(2).required(), // Array for latitude and longitude
    }).required(),
    lat: Joi.number(),
    long: Joi.number(),
    address: Joi.string(),
    userId: Joi.string().required(), // Add userId and make it required
  }),
};

const addressUpdateV = {
  body: Joi.object().keys({
    title: Joi.string(),
    city: Joi.string(),
    state: Joi.string(),
    country: Joi.string(),
    pin: Joi.string(),
    location: Joi.string(),
    latlong: Joi.object().keys({
      type: Joi.string().valid('Point'),
      coordinates: Joi.array().items(Joi.number()).length(2), // Array for latitude and longitude
    }),
    lat: Joi.number(),
    long: Joi.number(),
    address: Joi.string(),
    userId: Joi.string(), // Add userId (optional for update)
  }),
};

module.exports = {
  addressCreateV,
  addressUpdateV,
};
