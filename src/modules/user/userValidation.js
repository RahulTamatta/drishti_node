const Joi = require("joi");
const constants = require("../../common/utils/constants");

const onBoardUserV = {
  body: Joi.object().keys({
    name: Joi.string(),
    email: Joi.string().required(),
    mobileNo: Joi.string().required(),
    userName: Joi.string().required(),
    bio: Joi.string().optional(),
    profileImage: Joi.object({
      originalname: Joi.string().required(),
      mimetype: Joi.string().valid("image/jpeg", "image/png").required(),
      size: Joi.number().max(10485760).required(), // 10 MB limit
    }),
    teacherIdCard: Joi.object({
      originalname: Joi.string().required(),
      mimetype: Joi.string().valid("image/jpeg", "image/png").required(),
      size: Joi.number().max(10485760).required(), // 10 MB limit
      url: Joi.string().uri().required()

    }),
    teacherId: Joi.string().allow(""),
    role: Joi.string()
      .allow(constants.ROLES.TEACHER, constants.ROLES.USER)
      .required(),
  }),
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
