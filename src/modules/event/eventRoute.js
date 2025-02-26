const router = require("express").Router();
const eventController = require("./eventController");
const validate = require("../../middleware/validate");
const { createEventV, getEventsV, subscribeToEventV } = require("./eventValidation");
const auth = require("../../middleware/authentication");
const { ROLES } = require("../../common/utils/constants");
const methodNotAllowed = require("../../middleware/methodNotAllowed");
router
  .route("/")
  .post(
    [auth(ROLES.TEACHER), validate(createEventV)],
    eventController.createEvent
  )
  .all(methodNotAllowed);
router
  .route("/all-events")
  .post(auth(ROLES.ALL), eventController.getEvents)
  .all(methodNotAllowed);

router
  .route("/horizontal")
  .post(eventController.getHorizontalEvents)
  .all(methodNotAllowed);

//this is show  emtydata
router
  .route("/myevents")
  .get(auth([ROLES.TEACHER]), eventController.getMyEvents)
  .all(methodNotAllowed);
// this is geting the data 
router
  .route("/byId/:eventId")
  .get(auth(ROLES.TEACHER), eventController.getEvent)
  .all(methodNotAllowed);

router
  .route("/notifyme/:id")
  .patch(auth(ROLES.ALL), eventController.notificatifyMe)
  .all(methodNotAllowed);
// fatch data
router
  .route("/getParticepent/:id")
  .get(auth(ROLES.ALL), eventController.getParticepent)
  .all(methodNotAllowed);
router
  .route("/deleteEvent/:id")
  .delete(auth(ROLES.TEACHER), eventController.deleteEvent)
  .all(methodNotAllowed);
router
  .route("/editEvent/:id")
  .patch(auth(ROLES.TEACHER), eventController.editEvent)
  .all(methodNotAllowed);
router
  .route("/getAttendedEvents")
  .get(auth(ROLES.ALL), eventController.getAttendedEvents)
  .all(methodNotAllowed);

router
  .route('/subscribe/:eventId')
  .post(auth(ROLES.USER), validate(subscribeToEventV), eventController.subscribeToEvent)
  .all(methodNotAllowed);

router
  .route('/:eventId/subscribers')
  .get(auth(ROLES.ALL), eventController.getSubscribers)
  .all(methodNotAllowed);

router
  .route('/nearEvent')
  .post(auth(ROLES.ALL), eventController.getNearEventController)
  .all(methodNotAllowed);

// router
//   .route('/:eventId')
//   .get(auth(ROLES.ALL), eventController.getParticepents)
//   .all(methodNotAllowed);

module.exports = router;
