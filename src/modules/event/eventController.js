const eventService = require("./eventService");
const Event = require("../../models/event");
const appError = require("../../common/utils/appError");
const httpStatus = require("../../common/utils/status.json");
const createResponse = require("../../common/utils/createResponse");

const createEvent = async (request, response) => {
  try {
    const data = await eventService.createEvent(request);
    if (!data) {
      throw new appError(
        httpStatus.CONFLICT,
        request.t("event.UnableToCreateEvent")
      );
    }
    createResponse(
      response,
      httpStatus.OK,
      request.t("event.CreateEvent"),
      data
    );
  } catch (error) {
    console.log("error----------", error);
    createResponse(response, error.status, error.message);
  }
};

const getEvents = async (request, response) => {
  try {
    const data = await eventService.getEvents(request);
    if (!data) {
      throw new appError(
        httpStatus.CONFLICT,
        request.t("event.UnableToGetEvent")
      );
    }
    createResponse(
      response,
      httpStatus.OK,
      request.t("event.EventFetched"),
      data
    );
  } catch (error) {
    console.error(error);
    createResponse(response, error.status, error.message);
  }
};
const getEvent = async (request, response) => {
  try {
    const data = await eventService.getEvent(request);
    if (!data) {
      throw new appError(
        httpStatus.CONFLICT,
        request.t("event.UnableToCreateEvent")
      );
    }
    createResponse(
      response,
      httpStatus.OK,
      request.t("event.EventFetched"),
      data
    );
  } catch (error) {
    createResponse(response, error.status, error.message);
  }
};
const getMyEvents = async (request, response) => {
  try {
    const data = await eventService.getMyEvents(request);
    if (!data) {
      throw new appError(
        httpStatus.CONFLICT,
        request.t("event.UnableToCreateEvent")
      );
    }
    createResponse(
      response,
      httpStatus.OK,
      request.t("event.UnableToCreateEvent"),
      data
    );
  } catch (error) {
    createResponse(response, error.status, error.message);
  }
};
const notificatifyMe = async (request, response) => {
  try {
    // Check if user is authenticated
    if (!request.user || !request.user.id) {
      throw new appError(httpStatus.UNAUTHORIZED, "User not authenticated");
    }
    
    // Call event service to process notification
    const data = await eventService.notificatifyMe(request);
    
    // Check if data was successfully processed
    if (!data) {
      throw new appError(httpStatus.CONFLICT, request.t("event.UnableToNotify"));
    }
    
    // Send successful response
    createResponse(response, httpStatus.OK, request.t("event.AddedToNotify"), data);
  } catch (error) {
    // Handle any errors that occur
    createResponse(response, error.status || httpStatus.INTERNAL_SERVER_ERROR, error.message || "An error occurred");
  }
};

const getHorizontalEvents = async (request, response) => {
  try {
    const data = await eventService.getHorizontalEvents(request);
    if (!data) {
      throw new appError(
        httpStatus.CONFLICT,
        request.t("event.UnableToCreateEvent")
      );
    }
    createResponse(
      response,
      httpStatus.OK,
      request.t("event.HorizontalCreateEvent"),
      data
    );
  } catch (error) {
    createResponse(response, error.status, error.message);
  }
};
const getParticepent = async (request, response) => {
  try {
    const data = await eventService.getParticepents(request);
    if (!data) {
      throw new appError(
        httpStatus.CONFLICT,
        request.t("event.UnableToGetParticepents")
      );
    }
    createResponse(
      response,
      httpStatus.OK,
      request.t("event.GetParticepents"),
      data
    );
  } catch (error) {
    createResponse(response, error.status, error.message);
  }
};


const deleteEvent = async (request, response) => {
  try {
    const data = await eventService.deleteEvent(request);
    if (!data) {
      throw new appError(
        httpStatus.CONFLICT,
        request.t("event.UnableToDeleteEvent")
      );
    }
    createResponse(
      response,
      httpStatus.OK,
      request.t("event.EventDeleted"),
      data
    );
  } catch (error) {
    createResponse(response, error.status, error.message);
  }
};


const editEvent = async (request, response) => {
  try {
    const data = await eventService.editEvent(request);
    if (!data) {
      throw new appError(
        httpStatus.CONFLICT,
        request.t("event.UnableToEditEvent")
      );
    }
    createResponse(
      response,
      httpStatus.OK,
      request.t("event.EventEdited"),
      data
    );
  } catch (error) {
    createResponse(response, error.status, error.message);
  }
};

const getAttendedEvents = async (request, response) => {
  try {
    const data = await eventService.getAttendedEvents(request);
    if (!data) {
      throw new appError(
        httpStatus.CONFLICT,
        request.t("event.UnableToGetAttendedEvents")
      );
    }
    createResponse(
      response,
      httpStatus.OK,
      request.t("event.GetAttendedEvents"),
      data
    );
  } catch (error) {
    createResponse(response, error.status, error.message);
  }
};

const subscribeToEvent = async (req, res) => {
  try {
    const { eventId } = req.params;
    const { id, name } = req.body;

    // Validate if id and name are present
    if (!id || !name) {
      return res.status(400).json({ message: "User ID and name are required." });
    }

    // Find the event and update the notifyTo field
    let event = await Event.findById(eventId);
    if (!event) {
      return res.status(404).json({ message: "Event not found." });
    }

    if (!event.notifyTo.includes(id)) {
      event = await Event.findByIdAndUpdate(
        eventId,
        {
          $push: { notifyTo: id },
          $addToSet: { participants: { userId: id, name } }
        },
        { new: true }
      );
    }

    res.status(200).json({ message: "Subscription successful", event });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getSubscribers = async (req, res) => {
  try {
    const { eventId } = req.params;

    const subscribers = await eventService.getSubscribersByEventId(eventId);

    res.status(200).json(subscribers);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};


const getNearEventController = async (req, res) => {
  try {
    const { longitude, latitude, maxDistance } = req.body;
    if (!longitude || !latitude || !maxDistance) {
      return res.status(400).json({
        message: "Longitude, latitude, and maxDistance are required",
      });
    }
    const nearByEvents = await eventService.getNearEventService(longitude, latitude, maxDistance);
    if (!nearByEvents || nearByEvents.length === 0) {
      return res.status(200).json({
        message: "No events near you",
      });
    }
    return res.status(200).json({
      message: "Here are events near you",
      nearByEvents,
    });
  } catch (error) {
    return res.status(400).json({
      message: `Error finding nearby events: ${error.message}`,
    });
  }
};

module.exports = {
  createEvent,
  getEvents,
  getEvent,
  getMyEvents,
  notificatifyMe,
  getHorizontalEvents,
  getParticepent,
  deleteEvent,
  editEvent,
  getAttendedEvents,
  subscribeToEvent,
  getSubscribers,
  getNearEventController
};

