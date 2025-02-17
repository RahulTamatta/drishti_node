const Joi = require("joi");
const constants = require("../../common/utils/constants");

const onBoardUserV = {
  body: Joi.object().keys({
    userName: Joi.string().required().trim(),
    name: Joi.string().required().trim(),
    email: Joi.string().email().allow('').trim(),
    mobileNo: Joi.string().allow('').trim(),
    role: Joi.string().valid(constants.ROLES.USER, constants.ROLES.TEACHER).default(constants.ROLES.USER),
    bio: Joi.string().allow('').trim(),
    teacherId: Joi.when('role', {
      is: constants.ROLES.TEACHER,
      then: Joi.string().required().trim(),
      otherwise: Joi.string().allow('').optional()
    }),
    youtubeUrl: Joi.string().allow('').trim().uri().optional(),
    xUrl: Joi.string().allow('').trim().uri().optional(),
    instagramUrl: Joi.string().allow('').trim().uri().optional(),
    nearByVisible: Joi.boolean().default(false),
    locationSharing: Joi.boolean().default(false)
  })
};

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
