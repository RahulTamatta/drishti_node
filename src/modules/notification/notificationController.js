
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

const Notification = require("../../models/notification");
const Event = require("../../models/event");
const User = require("../../models/user");
const appError = require("../../common/utils/appError");
const httpStatus = require("../../common/utils/status.json");
const createResponse = require("../../common/utils/createResponse");

const createNotification = async (request, response) => {
  try {
    const { userId, eventId, title, description, type ,  scheduledAt } = request.body;

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
      type,
      scheduledAt 
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

    console.log(`DEBUG: eventId=${eventId}, userId=${userId}`);

    // Find event with more robust error handling
    const event = await Event.findById(eventId);
    if (!event) {
      console.log("DEBUG: Event not found");
      return createResponse(
        response,
        httpStatus.NOT_FOUND,
        "Event not found"
      );
    }

    console.log("DEBUG: Event found", event);

    // Check if user is already subscribed
    const isSubscribed = event.notifyTo.includes(userId);
    console.log(`DEBUG: isSubscribed=${isSubscribed}`);

    if (isSubscribed) {
      console.log("DEBUG: User is already subscribed. Proceeding to unsubscribe...");

      // Unsubscribe logic
      await Event.findByIdAndUpdate(eventId, {
        $pull: { notifyTo: userId }
      });

      console.log("DEBUG: User unsubscribed from event notifyTo list");

      // Remove existing notifications
      const deletedNotifications = await Notification.deleteMany({
        user: userId,
        event: eventId,
        type: 'subscription'
      });

      console.log(`DEBUG: Deleted ${deletedNotifications.deletedCount} subscription notifications`);

      // Update isOneHourReminder flag to false
      const updatedReminders = await Notification.updateMany(
        { user: userId, event: eventId, isOneHourReminder: true },
        { $set: { isOneHourReminder: false } }
      );

      console.log(`DEBUG: Updated ${updatedReminders.modifiedCount} reminders to set isOneHourReminder=false`);

      return createResponse(
        response,
        httpStatus.OK,
        "Unsubscribed successfully",
        { isOneHourReminder: false }
      );
    } else {
      console.log("DEBUG: User is not subscribed. Proceeding to subscribe...");

      // Subscribe logic
      await Event.findByIdAndUpdate(eventId, {
        $addToSet: { notifyTo: userId }
      });

      console.log("DEBUG: User added to event notifyTo list");

      // Ensure event.dateFrom exists before creating reminder
      const reminderTime = event.dateFrom
        ? new Date(event.dateFrom.getTime() - 60 * 60 * 1000)
        : null;

      console.log(`DEBUG: reminderTime=${reminderTime}`);

      const notification = await Notification.create({
        user: userId,
        event: eventId,
        title: "Event Subscription",
        description: `You have subscribed to the event: ${event.title}`,
        type: "subscription"
      });

      console.log("DEBUG: Subscription notification created", notification);

      const reminderNotification = reminderTime
        ? await Notification.create({
            user: userId,
            event: eventId,
            title: "Event Reminder",
            description: `Your event "${event.title}" starts in 1 hour`,
            type: "reminder",
            scheduledTime: reminderTime,
            isOneHourReminder: true
          })
        : null;

      console.log("DEBUG: Reminder notification created", reminderNotification);

      return createResponse(
        response,
        httpStatus.OK,
        "Subscribed successfully",
        {
          isSubscribed: true,
          notification,
          reminderNotification
        }
      );
    }
  } catch (error) {
    console.error('ERROR: Subscription Error:', error);
    createResponse(
      response,
      httpStatus.INTERNAL_SERVER_ERROR,
      "Failed to process subscription",
      { error: error.message }
    );
  }
};


const getUserNotifications = async (request, response) => {
  try {
    const userId = request.user.id;
    const now = new Date();

    // Find events the user is subscribed to or a participant in
    const subscribedEvents = await Event.find({
      $or: [
        { subscribers: userId },
        { participants: userId },
        { notifyTo: userId }
      ]
    });

    console.log('Subscribed Events:', subscribedEvents.length);

    // Check existing notifications to avoid duplicates
    const existingNotifications = await Notification.find({ 
      user: userId,
      event: { $in: subscribedEvents.map(event => event._id) }
    });

    // Filter events without existing notifications
    const eventsWithoutNotifications = subscribedEvents.filter(event => 
      !existingNotifications.some(notif => notif.event.toString() === event._id.toString())
    );

    // Create notifications only for events without existing notifications
    if (eventsWithoutNotifications.length > 0) {
      const eventNotifications = eventsWithoutNotifications.map(event => ({
        user: userId,
        event: event._id,
        title: `Subscription: ${event.title}`,
        description: `You are subscribed to the event: ${event.title}`,
        type: "subscription",
        status: "pending"
      }));

      await Notification.insertMany(eventNotifications);
    }

    // Create reminder notifications for upcoming events without existing reminders
    const upcomingEvents = subscribedEvents.filter(event => 
      event.date && 
      event.date.from && 
      new Date(event.date.from) > now &&
      !existingNotifications.some(notif => 
        notif.event.toString() === event._id.toString() && 
        notif.type === 'reminder'
      )
    );

    const reminderNotifications = upcomingEvents.map(event => ({
      user: userId,
      event: event._id,
      title: "Event Reminder",
      description: `Upcoming event: ${event.title}`,
      type: "reminder",
      status: "pending",
      scheduledTime: event.date.from
    }));

    if (reminderNotifications.length > 0) {
      await Notification.insertMany(reminderNotifications);
    }

    // Retrieve all notifications
    const notifications = await Notification.find({ 
      user: userId,
      $or: [
        { status: { $ne: 'archived' } },
        { type: 'reminder' }
      ]
    })
    .populate({
      path: 'event', 
      select: 'title meetingLink date'
    })
    .sort({ createdAt: -1 });

    console.log('Total Notifications Found:', notifications.length);

    // Format notifications for Flutter
    const formattedNotifications = notifications.map(notification => ({
      _id: notification._id,
      title: notification.title,
      description: notification.description,
      type: notification.type || 'subscription',
      status: notification.status || 'pending',
      event: notification.event ? {
        meetingLink: notification.event.meetingLink,
        title: notification.event.title,
        date: notification.event.date
      } : null,
      scheduledTime: notification.scheduledTime,
      isOneHourReminder: notification.type === 'reminder',
      createdAt: notification.createdAt
    }));

    createResponse(
      response, 
      httpStatus.OK, 
      "Notifications retrieved", 
      formattedNotifications
    );
  } catch (error) {
    console.error('Comprehensive Notification Retrieval Error:', error);
    createResponse(
      response, 
      error.status || httpStatus.INTERNAL_SERVER_ERROR, 
      error.message || "Unexpected error retrieving notifications"
    );
  }
};

// Scheduler function to send reminders
const sendEventReminders = async () => {
  const now = new Date();
  console.log(`Debug - Current Time: ${now.toISOString()}`);

  const notifications = await Notification.find({
    isOneHourReminder: true,
    scheduledTime: { $lte: now },
  }).populate('user').populate('event');

  console.log(`Debug - Found ${notifications.length} notifications to send reminders for.`);

  for (const notification of notifications) {
    console.log(`Debug - Sending reminder for notification: ${notification._id}, Title: ${notification.title}, User: ${notification.user}`);

    // Here you would integrate with a push notification service
    // like Firebase Cloud Messaging (FCM) or OneSignal
    await sendPushNotification(
      notification.user.deviceTokens, 
      notification.title, 
      notification.description
    );

    notification.status = "read";
    await notification.save();

    console.log(`Debug - Notification ${notification._id} marked as read.`);
  }
};
const getNotificationById = async (request, response) => {
  try {
    const { id } = request.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      throw new appError(httpStatus.BAD_REQUEST, "Invalid notification ID");
    }

    console.log('Debug - Getting notification by ID:', { notificationId: id });

    const notification = await Notification.findById(id)
      .populate('event')
      .populate('user');

    if (!notification) {
      throw new appError(httpStatus.NOT_FOUND, "Notification not found");
    }

    console.log('Debug - Found notification:', {
      notificationId: id,
      scheduledAt: notification.scheduledAt,
    });

    createResponse(
      response,
      httpStatus.OK,
      "Notification retrieved successfully",
      notification
    );
  } catch (error) {
    console.error('Error in getNotificationById:', error);
    createResponse(response, error.status || httpStatus.INTERNAL_SERVER_ERROR, error.message);
  }
};



const sendPushNotification = async ({ userId, title, body, data }) => {
  try {
    if (!mongoose.Types.ObjectId.isValid(userId)) {
      console.log('Invalid user ID:', userId);
      return;
    }

    if (!title || !body) {
      console.log('Push notification missing title or body');
      return;
    }

    const user = await User.findById(userId);
    if (!user?.fcmToken) {
      console.log('No FCM token found for user:', userId);
      return;
    }

    const message = {
      notification: {
        title,
        body,
      },
      data: data || {},
      token: user.fcmToken,
      android: {
        priority: 'high',
        notification: {
          channelId: 'event_reminders',
        },
      },
    };

    console.log('Sending push notification with data:', message);

    const response = await admin.messaging().send(message);
    console.log('Push notification sent:', response);
    return response;
  } catch (error) {
    console.error('Push notification error:', error);
    throw error;
  }
};


module.exports = {sendPushNotification,
  createNotification,
  subscribeNotification,
  getUserNotifications,
  sendEventReminders,
  getNotificationById
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
