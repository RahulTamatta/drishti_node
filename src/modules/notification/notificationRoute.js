const router = require("express").Router();
const notificationController = require("./notificationController");
const auth = require("../../middleware/authentication");
const { ROLES } = require("../../common/utils/constants");
const methodNotAllowed = require("../../middleware/methodNotAllowed");

router
  .route("/")
  .get(
    auth(ROLES.USER), 
    notificationController.getUserNotifications
  )
  .post(
    auth(ROLES.USER),
    notificationController.createNotification
  )
  .all(methodNotAllowed);

router
  .route("/subscribe/:eventId")
  .post(
    auth(ROLES.USER), 
    notificationController.subscribeNotification
  )
  .all(methodNotAllowed);

router
  .route("/:id")
  .get(
    auth(ROLES.USER),
    notificationController.getUserNotifications
  )
  .all(methodNotAllowed);

module.exports = router;