const user = require("./modules/user/userRoute");
const event = require("./modules/event/eventRoute");
const course = require("./modules/courses/coursesRoute");
const address = require("./modules/address/addressRoute");
const cronJob = require("./common/utils/cron");
const banner = require("./modules/banners/bannersRoute");
const notification = require("./modules/notification/notificationRoute")
const profile = require("./modules/profile/profileRoute")

// const room = require("./modules/room/roomRoute");

module.exports = (app) => {
  cronJob();
  app.use("/user", user);
  app.use("/event", event);
  app.use("/course", course);
  app.use("/address", address);
  app.use("/banner", banner);
  app.use('/notification', notification);
  app.use('/profile', profile)

  // app.use("/room", room);
  app.get("/", (request, response) => {
    response.send({ result: "success" });
  });
};
