const Joi = require("joi");
const constants = require("../../common/utils/constants");

// In userValidation.js
const onBoardUserV = Joi.object({
  userName: Joi.string().required(),
  name: Joi.string().required(),
  email: Joi.string().email().required(),
  mobileNo: Joi.string().length(10).required(),
  role: Joi.string().valid("user", "teacher").required(),
  teacherId: Joi.when("role", {
    is: "teacher",
    then: Joi.string().required(),
    otherwise: Joi.optional(),
  }),
  // Add other fields if needed
});

const userLoginV = {
  body: Joi.object().keys({
    mobileNo: Joi.string().required(),
    countryCode: Joi.string(),
    type: Joi.string().required(),
  }),
};

const updateLocationV = {
  body: Joi.object().keys({
    lat: Joi.number().required(),
    long: Joi.number().required(),
    location: Joi.string().required(),
  }),
};

const updateSocialMediaLinksV = {
  body: Joi.object().keys({
    youtubeUrl: Joi.string().allow(""),
    xUrl: Joi.string().allow(""),
    instagramUrl: Joi.string().allow(""),
  }),
};

const actionOnTeacherAccountV = {
  body: Joi.object().keys({
    id: Joi.string(),
    status: Joi.string().valid(
      constants.STATUS.PENDING,
      constants.STATUS.ACCEPTED,
      constants.STATUS.REJECTED
    ),
  }),
};

const teachersListingV = {
  query: Joi.object().keys({
    status: Joi.string().valid(
      constants.STATUS.PENDING,
      constants.STATUS.ACCEPTED,
      constants.STATUS.REJECTED
    ),
    search: Joi.string(),
  }),
};

module.exports = {
  updateLocationV,
  onBoardUserV,
  userLoginV,
  actionOnTeacherAccountV,
  teachersListingV,
  updateSocialMediaLinksV,
};
