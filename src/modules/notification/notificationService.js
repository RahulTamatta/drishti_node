const schedule = require('node-schedule');
const Notification = require("../../models/notification");
const Event = require("../../models/event");
const appError = require("../../common/utils/appError");
const httpStatus = require("../../common/utils/status.json");
const User = require('../../models/user')


async function createNotification(request) {
    const { title, description, eventId, userId } = request.body;

    if (!title || !description || !eventId || !userId) {
        throw new appError(httpStatus.BAD_REQUEST, "Missing required fields");
    }

    const event = await Event.findById(eventId);
    const user = await User.findById(userId);

    if (!event) {
        throw new appError(httpStatus.NOT_FOUND, "Event not found");
    }
    if (!user) {
        throw new appError(httpStatus.NOT_FOUND, "User not found");
    }

    // Parse event start time
    const eventStartTime = new Date(event.date.from);
    if (isNaN(eventStartTime.getTime())) {
        throw new appError(httpStatus.BAD_REQUEST, "Invalid event start date");
    }

    // event start 5 min
    // let notificationTime = new Date(eventStartTime.getTime() - 5 * 60 * 1000);

    let notificationTime = new Date(eventStartTime.getTime() - 2 * 60 * 60 * 1000);
    if (notificationTime < new Date()) {
        notificationTime = new Date();
    }

    const notification = new Notification({
        title,
        description,
        eventId,
        userId,
        scheduledAt: notificationTime,
        createdAt: new Date(),
        status: 'scheduled'
    });

    await notification.save();
    schedule.scheduleJob(notificationTime, async () => {
        try {
            // Get participants of the event
            const participants = await Event.findById(eventId).populate('notifyTo');

            const participantDetails = participants.notifyTo.map(participant => ({
                title,
                description: `${description}\nEvent Date: ${event.date.from.toLocaleDateString()}\nEvent Time: ${new Date(event.date.from).toLocaleTimeString()}\nGoogle Meet Link: ${event.meetingLink}`,
                eventId,
                userId: participant._id,
            }));

            console.log("event detail ------------------------>", participantDetails)
            // Send notifications or update existing ones
            for (const detail of participantDetails) {
                await Notification.findOneAndUpdate(
                    { eventId: detail.eventId, userId: detail.userId },
                    { ...detail, status: 'sent' },
                    { upsert: true, new: true }
                );
            }
        } catch (error) {
            console.error("Error sending notifications:", error);
        }
    });

    return {
        message: "Notification created and scheduling setup complete",
        scheduledAt: notificationTime,
        notificationId: notification._id,

    };
}

async function getNotifications() {
    return await Notification.find().sort({ date: -1 })
}

async function getNotificationById(request) {
    const { id } = request.params;
    const notification = await Notification.findById(id);
    if (!notification) {
        throw new appError(httpStatus.NOT_FOUND, "Notification not found");
    }
    
    return notification;
}



module.exports = {
    createNotification,
    getNotifications,
    getNotificationById,
    // updateEventById
};
