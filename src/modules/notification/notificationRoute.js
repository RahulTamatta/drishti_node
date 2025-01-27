const router = require("express").Router();
const validate = require("../../middleware/validate");
const { createNotificationV } = require("./notificationValidation");
const notificationController = require("./notificationController");
const methodNotAllowed = require("../../middleware/methodNotAllowed");

router
    .route("/")
    .post(
        [validate(createNotificationV)],
        notificationController.createNotification
    )
    .all(methodNotAllowed);
router
    .route("/all-notifications")
    .get(notificationController.getNotifications)
    .all(methodNotAllowed);

router
    .route("/:id")
    .get(notificationController.getNotificationById)
    .all(methodNotAllowed);

module.exports = router;
