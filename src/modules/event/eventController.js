const eventService = require("./eventService");
const Event = require("../../models/event");
const appError = require("../../common/utils/appError");
const httpStatus = require("../../common/utils/status.json");
const createResponse = require("../../common/utils/createResponse");

const createEvent = async (request, response) => {
  try {
    console.log("Received request to create event:", request.body);

    // Validate duration format
    if (!request.body.duration || !Array.isArray(request.body.duration) || request.body.duration.length === 0) {
      throw new appError(httpStatus.BAD_REQUEST, request.t("Event.DurationRequired"));
    }

    // Ensure each duration object has from and to fields
    request.body.duration.forEach((duration, index) => {
      if (!duration.from || !duration.to) {
        throw new appError(
          httpStatus.BAD_REQUEST,
          `Duration at index ${index} must have both 'from' and 'to' fields`
        );
      }
    });

    // Format the times to ensure proper 24-hour format
    request.body.duration = request.body.duration.map(duration => {
      const formatTime = (timeStr) => {
        if (!timeStr) return timeStr;
        const [time, period] = timeStr.split(/([AMP]M)/);
        const [hours, minutes] = time.split(':');
        let hour = parseInt(hours);
        
        if (period === 'PM' && hour < 12) hour += 12;
        if (period === 'AM' && hour === 12) hour = 0;
        
        return `${hour.toString().padLeft(2, '0')}:${minutes}`;
      };

      return {
        from: formatTime(duration.from),
        to: formatTime(duration.to)
      };
    });

    const data = await eventService.createEvent(request);
    console.log("Event service response:", data);

    if (!data) {
      console.log("Event creation failed: No data returned");
      throw new appError(
        httpStatus.CONFLICT,
        request.t("event.UnableToCreateEvent")
      );
    }

    console.log("Event created successfully:", data);
    createResponse(
      response,
      httpStatus.OK,
      request.t("event.CreateEvent"),
      data
    );
  } catch (error) {
    console.error("Error creating event:", error);
    createResponse(
      response,
      error.status || httpStatus.INTERNAL_SERVER_ERROR,
      error.message || "An unexpected error occurred"
    );
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
    // Verify user authentication
    if (!request.user || !request.user.id) {
      throw new appError(httpStatus.UNAUTHORIZED, "User not authenticated");
    }

    const userId = request.user.id;
    console.log(`User ID: ${userId} is attempting to retrieve notifications.`);

    // Get event ID from request parameters
    const { eventId } = request.params;  // Assuming eventId is passed in the request params

    // Find event by ID
    let event = await Event.findById(eventId);
    if (!event) {
      return response.status(404).json({ message: "Event not found." });
    }

    // Check if the user is a participant or subscriber of the event
    if (!event.participants.includes(userId) && !event.subscribers.includes(userId)) {
      console.log(`User ID: ${userId} is not a participant or subscriber for the event: ${event.title}`);
      
      const notification = await Notification.create({
        title: "No Active Events",
        description: "You are currently not registered for any upcoming events",
        userId: userId,
        eventId: event._id,
        status: "pending",
      });

      return createResponse(
        response,
        httpStatus.OK,
        "User is not part of any upcoming event",
        notification
      );
    }

    // Process notification for the event
    console.log(`Creating notification for event: ${event.title} (Event ID: ${event._id}) for user: ${userId}`);

    const notification = await Notification.create({
      title: `Event Notification: ${event.title}`,
      description: `Upcoming event: ${event.title}`,
      eventId: event._id,
      userId: userId,
      status: "pending",
    });

    console.log(`Notification created for user with ID: ${userId}`);

    createResponse(response, httpStatus.OK, "Notification created", notification);

  } catch (error) {
    console.error(`Error for user ID: ${request.user.id} - ${error.message}`);
    createResponse(
      response,
      error.status || httpStatus.INTERNAL_SERVER_ERROR,
      error.message || "An error occurred"
    );
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

