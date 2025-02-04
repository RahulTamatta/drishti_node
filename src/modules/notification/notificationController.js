const notificationService = require("./notificationService");
const appError = require("../../common/utils/appError");
const httpStatus = require("../../common/utils/status.json");
const createResponse = require("../../common/utils/createResponse");

const createNotification = async (request, response) => {
    try {
        const data = await notificationService.createNotification(request);
        if (!data) {
            throw new appError(
                httpStatus.CONFLICT,
                request.t("notification.UnableToCreateNotification")
            );
        }
        createResponse(
            response,
            httpStatus.OK,
            request.t("notification.NotificationCreated"),
            data
        );
    } catch (error) {
        createResponse(response, error.status, error.message);
    }
};

const getNotifications = async (request, response) => {
    try {
        const data = await notificationService.getNotifications(request);
        if (!data) {
            throw new appError(
                httpStatus.CONFLICT,
                request.t("notification.UnableToGetNotifications")
            );
        }
        createResponse(
            response,
            httpStatus.OK,
            request.t("notification.NotificationsFetched"),
            data
        );
    } catch (error) {
        createResponse(response, error.status, error.message);
    }
};

// Controller function
const getNotificationById = async (request, response) => {
    try {
        const data = await notificationService.getNotificationById(request);
        if (!data) {
            throw new appError(
                httpStatus.CONFLICT,
                request.t("notification.UnableToGetNotification")
            );
        }
        createResponse(
            response,
            httpStatus.OK,
            request.t("notification.NotificationFetched"),
            data
        );
    } catch (error) {
        createResponse(response, error.status, error.message);
    }
};
module.exports = {
    createNotification,
    getNotifications,
    getNotificationById,

};
