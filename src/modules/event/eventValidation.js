const Joi = require("joi");
const constants = require("../../common/utils/constants");

const createEventV = {
  body: Joi.object().keys({
    description: Joi.string().trim().required().messages({
      "string.base": "Title must be a string",
      "string.empty": "Title is required",
      "any.required": "Title is required",
    }),
    mode: Joi.string().valid("online", "offline").required().messages({
      "any.only": 'Mode must be one of "online", "offline", or "both"',
      "any.required": "Mode is required",
    }),
    aol: Joi.array()
      .items(Joi.string().valid("event", "course", "follow-up"))
      .required()
      .messages({
        "any.only": 'AOL must be one of "event", "course", or "follow-up"',
        "any.required": "AOL is required",
      }),
    date: Joi.object({
      from: Joi.date().required().messages({
        "date.base": 'Date "from" must be a valid date',
        "any.required": 'Date "from" is required',
      }),
      to: Joi.date().required().messages({
        "date.base": 'Date "to" must be a valid date',
        "any.required": 'Date "to" is required',
      }),
    }).required(),
    timeOffset: Joi.string().required(),
    duration: Joi.array().items(
      Joi.object({
        from: Joi.string().valid(...constants.TIME_INTERVALS).required(),
        to: Joi.string().valid(...constants.TIME_INTERVALS).required(),
      })
    ).required(),
    meetingLink: Joi.string().trim(),
    recurring: Joi.boolean().required(),
    title: Joi.array().items(Joi.string()).required(),
    address: Joi.array().items(Joi.string()).required(),
    phoneNumber: Joi.array().items(Joi.string()).required(),
    registrationLink: Joi.string(),
    location: Joi.object({
      type: Joi.string().valid('Point').required(),
      coordinates: Joi.array().items(Joi.number()).length(2).required()
    }).required(),
    teachers: Joi.array().items(Joi.string()).required(),
    deletedAt: Joi.date(),
  }),
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
