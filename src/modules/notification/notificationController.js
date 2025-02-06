// const notificationService = require("./notificationService");
// const appError = require("../../common/utils/appError");
// const httpStatus = require("../../common/utils/status.json");
// const createResponse = require("../../common/utils/createResponse");


const Notification = require("../../models/notification");
const Event = require("../../models/event");
const User = require("../../models/user");
const appError = require("../../common/utils/appError");
const httpStatus = require("../../common/utils/status.json");
const createResponse = require("../../common/utils/createResponse");

const createNotification = async (request, response) => {
  try {
    const { userId, eventId, title, description, type } = request.body;

    console.log('Debug - Incoming IDs:', { userId, eventId });

    // Verify event and user exist
    const event = await Event.findById(eventId);
    const user = await User.findById(userId);

    console.log('Debug - Found entities:', {
      eventFound: !!event,
      userFound: !!user,
      eventData: event,
      userData: user
    });

    if (!event || !user) {
      throw new appError(httpStatus.NOT_FOUND, "Event or User not found");
    }

    const notification = await Notification.create({
      user: userId,
      event: eventId,
      title,
      description,
      type
    });

    createResponse(
      response, 
      httpStatus.CREATED, 
      "Notification created successfully", 
      notification
    );
  } catch (error) {
    createResponse(response, error.status, error.message);
  }
};

const subscribeNotification = async (request, response) => {
  try {
    const { eventId } = request.params;
    const userId = request.user.id;

    console.log('Debug - Subscribe Notification:', {
      eventId,
      userId,
      userObject: request.user
    });

    // Find event
    const event = await Event.findById(eventId);
    console.log('Debug - Found event:', {
      eventFound: !!event,
      eventData: event
    });

    if (!event) {
      throw new appError(httpStatus.NOT_FOUND, "Event not found");
    }

    // Create subscription notification
    const notification = await Notification.create({
      user: userId,
      event: eventId,
      title: "Event Subscription",
      description: `You have subscribed to the event: ${event.title}`,
      type: "subscription"
    });

    // Create one-hour reminder notification
    const reminderNotification = await Notification.create({
      user: userId,
      event: eventId,
      title: "Event Reminder",
      description: `Your event "${event.title}" starts in 1 hour`,
      type: "reminder",
      scheduledTime: new Date(event.dateFrom.getTime() - 60 * 60 * 1000), // 1 hour before event
      isOneHourReminder: true
    });

    createResponse(
      response, 
      httpStatus.OK, 
      "Subscribed successfully", 
      { notification, reminderNotification }
    );
  } catch (error) {
    createResponse(response, error.status, error.message);
  }
};

const getUserNotifications = async (request, response) => {
  try {
    const userId = request.user.id;

    const notifications = await Notification.find({ user: userId })
      .populate('event')
      .sort({ createdAt: -1 });

    createResponse(
      response, 
      httpStatus.OK, 
      "Notifications retrieved", 
      notifications
    );
  } catch (error) {
    createResponse(response, error.status, error.message);
  }
};

// Scheduler function to send reminders
const sendEventReminders = async () => {
  const now = new Date();
  const notifications = await Notification.find({
    isOneHourReminder: true,
    scheduledTime: { $lte: now },
    status: "pending"
  }).populate('user').populate('event');

  for (const notification of notifications) {
    // Here you would integrate with a push notification service
    // like Firebase Cloud Messaging (FCM) or OneSignal
    sendPushNotification(
      notification.user.deviceTokens, 
      notification.title, 
      notification.description
    );

    notification.status = "read";
    await notification.save();
  }
};

module.exports = {
  createNotification,
  subscribeNotification,
  getUserNotifications,
  sendEventReminders
};


// const createNotification = async (request, response) => {
//     try {
//         const data = await notificationService.createNotification(request);
//         if (!data) {
//             throw new appError(
//                 httpStatus.CONFLICT,
//                 request.t("notification.UnableToCreateNotification")
//             );
//         }
//         createResponse(
//             response,
//             httpStatus.OK,
//             request.t("notification.NotificationCreated"),
//             data
//         );
//     } catch (error) {
//         createResponse(response, error.status, error.message);
//     }
// };

// const getNotifications = async (request, response) => {
//     try {
//         const data = await notificationService.getNotifications(request);
//         if (!data) {
//             throw new appError(
//                 httpStatus.CONFLICT,
//                 request.t("notification.UnableToGetNotifications")
//             );
//         }
//         createResponse(
//             response,
//             httpStatus.OK,
//             request.t("notification.NotificationsFetched"),
//             data
//         );
//     } catch (error) {
//         createResponse(response, error.status, error.message);
//     }
// };

// // Controller function
// const getNotificationById = async (request, response) => {
//     try {
//         const data = await notificationService.getNotificationById(request);
//         if (!data) {
//             throw new appError(
//                 httpStatus.CONFLICT,
//                 request.t("notification.UnableToGetNotification")
//             );
//         }
//         createResponse(
//             response,
//             httpStatus.OK,
//             request.t("notification.NotificationFetched"),
//             data
//         );
//     } catch (error) {
//         createResponse(response, error.status, error.message);
//     }
// };
// module.exports = {
//     createNotification,
//     getNotifications,
//     getNotificationById,

// };
