"use strict";
var cron = require("node-cron");

const Event = require("../../models/event");
const { sendNotification } = require("./notification");
// import User from "../../models/user";
// import config from "../config";
// import {
//   EVENT_STATUS,
//   NOTIFICATION_EVENT,
//   ROLES,
//   STATUS,
// } from "../helpers/constant";
// import { sendNotification } from "./notification";

function parseTime(timeStr) {
  const [time, modifier] = timeStr.split(/(AM|PM)/i);
  let [hours, minutes] = time.split(":").map(Number);

  if (modifier.toLowerCase() === "pm" && hours < 12) {
    hours += 12;
  }
  if (modifier.toLowerCase() === "am" && hours === 12) {
    hours = 0;
  }

  return { hours, minutes };
}

async function notifyUsers(event) {
  const users = event.notifyTo;
  const subject = `Upcoming Event: ${event.title}`;
  const text = `Reminder: The event "${event.title}" will start in one hour.`;

  for (const user of users) {
    for (const token in user.deviceTokens) {
      await sendNotification(text, subject, token, event._id);
    }
  }
}
module.exports = () => {
  cron.schedule("* * * * *", async () => {
    const currentDate = new Date();

    const startOfDay = new Date(currentDate.setHours(0, 0, 0, 0));
    const endOfDay = new Date(currentDate.setHours(23, 59, 59, 999));
    const events = await Event.find({
      "date.from": { $lte: endOfDay },
      "date.to": { $gte: startOfDay },
    }).populate("notifyTo");
    console.log("event outside loop--", events);
    for (const event of events) {
      console.log("event inside loop-- ", event);
      const eventStart = new Date(event.date.from);
      const eventTime = parseTime(event.timeOffset);

      eventStart.setHours(eventTime.hours);
      eventStart.setMinutes(eventTime.minutes);

      const currentTime = new Date();
      const timeDifferenceInMinutes = Math.round(
        (eventStart - currentTime) / (1000 * 60)
      );
      console.log("timeDifferenceInMinutes--", timeDifferenceInMinutes);
      if (timeDifferenceInMinutes <= 60 && timeDifferenceInMinutes > 0) {
        console.log("event inside if--", event);
        //   await notifyUsers(event);
      }
    }

    // const currentDate = new Date();
    // const oneHourLater = new Date(currentDate.getTime() + 60 * 60 * 1000);

    // const events = await Event.find({
    //   "date.from": { $gte: currentDate },
    //   "date.from": { $lte: oneHourLater },
    // }).populate("notifyTo");
    // console.log("event outside loop--", events);

    // for (const event of events) {
    //   console.log("event inside loop-- ", event);

    //   const eventStart = new Date(event.date.from);
    //   const eventTime = parseTime(event.timeOffset);

    //   eventStart.setHours(eventTime.hours);
    //   eventStart.setMinutes(eventTime.minutes);

    //   if (eventStart.getTime() - currentDate.getTime() <= 60 * 60 * 1000) {
    //     console.log("event--", event);
    //     //    notifyUsers(event).catch(err =>console.log(err));
    //   }
    // }

    //   const events = await Event.find({
    //     eventstatus: { $nin: [EVENT_STATUS.CANCEL] },
    //   });

    //   for (let i = 0; i < events.length; i++) {
    //     const event = events[i];
    //     const endDate = new Date(event.enddatetime);
    //     const startDate = new Date(event.startdatetime);
    //     let newStatus;

    //     if (endDate < currentDate) {
    //       newStatus = EVENT_STATUS.COMPLETED;
    //     } else if (startDate <= currentDate && endDate >= currentDate) {
    //       newStatus = EVENT_STATUS.ONGOING;
    //     } else if (startDate > currentDate) {
    //       newStatus = EVENT_STATUS.UPCOMING;
    //     }

    //     event.eventstatus = newStatus;

    //     const startTime: any = new Date(eventsToUpdate[i].bookingend);
    //     const currentTime: any = new Date();
    //     const timeDifferenceInMinutes = Math.round(
    //       (startTime - currentTime) / (1000 * 60)
    //     );
    //     // console.log("booking end time     -----------", startTime);
    //     // console.log(
    //     //   "timeDifferenceInMinutes     -----------",
    //     //   timeDifferenceInMinutes
    //     // );
    //     if (timeDifferenceInMinutes === 2880) {
    //       if (
    //         eventsToUpdate[i]?.tickets.filter(
    //           (ticket: any) =>
    //             !ticket.soldout && ticket.ticketssold < ticket.totaltickets
    //         ).length > 0
    //       ) {
    //         const users = await User.find({
    //           role: ROLES.USER,
    //           isonboarded: true,
    //           status: { $nin: [STATUS.DEACTIVE, STATUS.DELETED] },
    //         });
    //         if (config.env === "ec2Production") {
    //           sendNotification(
    //             NOTIFICATION_EVENT.IF_TICKETS_48_BEFORE.action,
    //             users,
    //             `Hurry Up! Booking is ending up for ${eventsToUpdate[i].title} in 48 hours.`,
    //             eventsToUpdate[i]
    //           ).catch((err) => {
    //             console.error("Error sending notification:", err);
    //           });
    //         }
    //       }
    //     }

    //     if (timeDifferenceInMinutes === 1440) {
    //       if (
    //         eventsToUpdate[i]?.tickets.filter(
    //           (ticket: any) =>
    //             !ticket.soldout && ticket.ticketssold < ticket.totaltickets
    //         ).length > 0
    //       ) {
    //         const users = await User.find({
    //           role: ROLES.USER,
    //           isonboarded: true,
    //           status: { $nin: [STATUS.DEACTIVE, STATUS.DELETED] },
    //         });
    //         if (config.env === "ec2Production") {
    //           sendNotification(
    //             NOTIFICATION_EVENT.IF_TICKETS_24_BEFORE.action,
    //             users,
    //             `Hurry Up! Booking is ending up for ${eventsToUpdate[i].title} in 24 hours. `,
    //             eventsToUpdate[i]
    //           ).catch((err) => {
    //             console.error("Error sending notification:", err);
    //           });
    //         }
    //       }
    //     }
    //     const bookingStartTime: any = new Date(eventsToUpdate[i].bookingstart);

    //     const bookingTimeDifference = Math.round(
    //       (bookingStartTime - currentTime) / (1000 * 60)
    //     );
    //     if (bookingTimeDifference === 0) {
    //       const users = await User.find({
    //         role: ROLES.USER,
    //         isonboarded: true,
    //         status: { $nin: [STATUS.DEACTIVE, STATUS.DELETED] },
    //       });

    //       if (config.env === "ec2Production") {
    //         sendNotification(
    //           NOTIFICATION_EVENT.EVENT_BOOKING_START.action,
    //           users,
    //           `Ticket booking has been started for ${eventsToUpdate[i].title}. Book before it gets Soldout. `,
    //           eventsToUpdate[i]
    //         ).catch((err) => {
    //           console.error("Error sending notification:", err);
    //         });
    //       }
    //     }
    //   }
    //   await Promise.all(eventsToUpdate.map((event: any) => event.save()));

    //   // console.log("Event statuses updated successfully!");
    // } catch (err) {
    //   console.error("Error updating event statuses:", err);
    // }
  });
};
