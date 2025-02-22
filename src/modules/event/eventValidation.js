const Joi = require("joi");
const constants = require("../../common/utils/constants");

const createEventV = {
  body: Joi.object().keys({
    mode: Joi.string().valid("online", "offline", "both").required(),
    aol: Joi.array().items(Joi.string().valid("event", "course", "follow-up")).required(),
    title: Joi.array().items(Joi.string()).required(),
    date: Joi.object({
      from: Joi.date().required(),
      to: Joi.date().required()
    }),
    recurring: Joi.boolean(),
    duration: Joi.array().items(Joi.object({
      from: Joi.string().valid(...constants.TIME_INTERVALS),
      to: Joi.string().valid(...constants.TIME_INTERVALS)
    })).required(),
    meetingLink: Joi.string().trim(),
    description: Joi.string(),
    phoneNumber: Joi.string(),
    address: Joi.array().items(Joi.string()),
    registrationLink: Joi.string(),
    coordinates: Joi.array().items(Joi.number()).length(2),
    teachers: Joi.array().items(Joi.string())
  })
};

const getEventsV = {
  // body: Joi.object().keys({
  //   // mode: Joi.string().valid("online", "offline", "both"),
  //   // date: Joi.date(),
  //   // lat: Joi.number(),
  //   // long: Joi.number(),
  //   // aol:,
  //   // course,
  //   // date,
  //   // month,
  //   // year,
  //   // lat,
  //   // long,
  // }),
};

const subscribeToEventV = {
  params: Joi.object().keys({
    eventId: Joi.string().required().messages({
      "string.base": "Event ID must be a string",
      "any.required": "Event ID is required",
    }),
  }),
};


module.exports = {
  createEventV,
  getEventsV,
  subscribeToEventV
};
