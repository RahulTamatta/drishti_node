const mongoose = require("mongoose");
const Event = require("../../models/event");
const Subscription = require("../../models/subscribe");
const { getDistance } = require("../../common/utils/app_functions");
const appError = require("../../common/utils/appError");
const httpStatus = require("../../common/utils/status.json");
const constants = require("../../common/utils/constants");
const User = require("../../models/user");
const Notification = require("../../models/notification");
const ObjectId = mongoose.Types.ObjectId;
const { distortCoordinates } = require('../../common/utils/helpers');

// working
async function createEvent(request) {
  const { coordinates, ...remainingBody } = request.body;
  return await Event.create({
    userId: request.user.id,
    ...remainingBody,
    "location.coordinates": coordinates,
  });
}
// working
async function editEvent(request) {
  const { coordinates, ...remainingBody } = request.body;
  return await Event.findByIdAndUpdate(
    request.params.id,
    {
      userId: request.user.id,
      ...remainingBody,
      "location.coordinates": coordinates,
    },
    { new: true }
  );
}

// working
async function deleteEvent(request) {
  return await Event.findByIdAndDelete(request.params.id);
}

// working
async function getEvent(request) {
  return await Event.aggregate([
    { $match: { _id: new ObjectId(request.params.eventId) } },
    {
      $lookup: {
        from: "users",
        localField: "userId",
        foreignField: "_id",
        as: "userDetails",
      },
    },
    {
      $lookup: {
        from: "users",
        localField: "teachers",
        foreignField: "_id",
        as: "teachersDetails",
      },
    },
  ]);
}


function getStartOfDayAndNextDay(inputDate) {
  console.log("inputDate: " + inputDate);
  const startOfDay = `${inputDate.split("T")[0]}T00:00:00.000Z`;
  const nextDay = new Date(inputDate);
  nextDay.setDate(nextDay.getDate() + 1);
  const startOfNextDay = `${inputDate.split("T")[0]}T18:29:59.000Z`;

  return [startOfDay, startOfNextDay];
}
// working
// async function getEvents(request) {
//   console.log("user----------", request.user);
//   const { mode, aol, course, date, lat, long, page, pageSize } = request.body;
//   const pageSizeLimit = pageSize || 10;
//   const pageNo = page || 1;
//   let matchQuery = {};
//   const pipeline = [
//     {
//       $lookup: {
//         from: "users",
//         localField: "userId",
//         foreignField: "_id",
//         as: "userDetails",
//       },
//     },
//     {
//       $lookup: {
//         from: "users",
//         localField: "teachers",
//         foreignField: "_id",
//         as: "teachersDetails",
//       },
//     },
//     {
//       $lookup: {
//         from: "users",
//         localField: "notifyTo",
//         foreignField: "_id",
//         as: "participantsDetails",
//       },
//     },
//   ];
//   if (course) {
//     matchQuery["course"] = {
//       $regex: new RegExp(course.trim()),
//       $options: "i",
//     };
//   }

//   if (date) {
//     const [startOfDay, nextDay] = getStartOfDayAndNextDay(date);
//     matchQuery["$and"] = [
//       { "date.from": { $gte: new Date(startOfDay) } },
//       // { time: { $lte: new Date(nextDay) } },
//     ];
//   } else {
//     const [startOfDay, nextDay] = getStartOfDayAndNextDay(
//       new Date().toISOString()
//     );
//     matchQuery["$and"] = [
//       { "date.from": { $gte: new Date(startOfDay) } },
//       // { time: { $lte: new Date(nextDay) } },
//     ];
//   }

//   if (aol) {
//     matchQuery["aol"] = {
//       $in: [aol],
//     };
//   }
//   if (mode) {
//     matchQuery["mode"] = {
//       $in: [mode],
//     };
//   }

//   // if (Object.keys(matchQuery).length !== 0) {
//   //   const matchStage = { $match: matchQuery };
//   //   pipeline.push(matchStage);
//   // }

//   if (lat && long) {
//     const { latitude: distortedLat, longitude: distortedLon } =
//       distortCoordinates(parseFloat(lat), parseFloat(long));
//     console.log("Max", MAX_DISTANCE_IN_MILES)
//     pipeline.unshift({
//       $geoNear: {
//         near: {
//           type: "Point",
//           coordinates: [distortedLon, distortedLat],
//         },
//         distanceField: "distanceInMeters",
//         maxDistance: constants.MAX_DISTANCE_IN_MILES * 1609.34,
//         spherical: true,
//       },
//     });
//   }

//   return await Event.aggregate([
//     ...pipeline,
//     {
//       $unwind: "$duration",
//     },
//     {
//       $group: {
//         _id: "$duration.from",
//         events: {
//           $push: {
//             _id: "$_id",
//             title: "$title",
//             participantsDetails: "$participantsDetails",
//             mode: "$mode",
//             aol: "$aol",
//             userId: "$userId",
//             dateFrom: "$date.from",
//             dateTo: "$date.to",
//             userDetails: "$userDetails",
//             teachersDetails: "$teachersDetails",
//             durationFrom: "$duration.from",
//             durationTo: "$duration.to",
//             meetingLink: "$meetingLink",
//             recurring: "$recurring",
//             description: "$description",
//             address: "$address",
//             phoneNumber: "$phoneNumber",
//             registrationLink: "$registrationLink",
//             location: "$location",
//             teachers: "$teachers",
//             notifyTo: "$notifyTo",
//             distanceInKilometers: {
//               $divide: ["$distanceInMeters", 1000],
//             },
//           },
//         },
//       },
//     },
//     {
//       $sort: { _id: 1 },
//     },
//     {
//       $skip: (pageNo - 1) * pageSizeLimit,
//     },
//     {
//       $limit: pageSizeLimit,
//     },
//     {
//       $project: {
//         _id: 0,
//         from: "$_id",
//         events: 1,
//       },
//     },
//   ]);
// }

async function getEvents(request) {
  console.log("user----------", request.user);

  // Extract values from request body and query
  const { mode, aol, course, date, lat, long, page, pageSize } = request.body;
  const { matchQuery } = request.query; // Extracting matchQuery from req.query

  const pageSizeLimit = pageSize || 10;
  const pageNo = page || 1;
  let matchCondition = {};

  // Set up initial aggregation pipeline
  const pipeline = [
    {
      $lookup: {
        from: "users",
        localField: "userId",
        foreignField: "_id",
        as: "userDetails",
      },
    },
    {
      $lookup: {
        from: "users",
        localField: "teachers",
        foreignField: "_id",
        as: "teachersDetails",
      },
    },
    {
      $lookup: {
        from: "users",
        localField: "notifyTo",
        foreignField: "_id",
        as: "participantsDetails",
      },
    },
  ];

  // Handle course search (case-insensitive)
  if (course) {
    matchCondition["course"] = {
      $regex: new RegExp(course.trim(), "i"), // Case-insensitive match
    };
  }

  // Handle date range filtering
  if (date) {
    const [startOfDay, nextDay] = getStartOfDayAndNextDay(date);
    matchCondition["$and"] = [
      { "date.from": { $gte: new Date(startOfDay) } },
    ];
  } else {
    const [startOfDay, nextDay] = getStartOfDayAndNextDay(new Date().toISOString());
    matchCondition["$and"] = [
      { "date.from": { $gte: new Date(startOfDay) } },
    ];
  }

  // Handle AOL filter
  if (aol) {
    matchCondition["aol"] = {
      $in: [aol],
    };
  }

  // Handle mode filter
  if (mode) {
    matchCondition["mode"] = {
      $in: [mode],
    };
  }

  // Handle matchQuery filter for title, description, or any other searchable field
  if (matchQuery) {
    const query = matchQuery.trim();
    matchCondition["$or"] = [
      { title: { $regex: new RegExp(query, "i") } }, // Search by description
    ];
  }
  // Handle location-based filtering (if lat and long are provided)
  if (lat && long) {
    const { latitude: distortedLat, longitude: distortedLon } = distortCoordinates(parseFloat(lat), parseFloat(long));
    pipeline.unshift({
      $geoNear: {
        near: {
          type: "Point",
          coordinates: [distortedLon, distortedLat],
        },
        distanceField: "distanceInMeters",
        maxDistance: constants.MAX_DISTANCE_IN_MILES * 1609.34,
        spherical: true,
      },
    });
  }

  // Add match condition to the pipeline
  if (Object.keys(matchCondition).length > 0) {
    pipeline.push({
      $match: matchCondition,
    });
  }

  return await Event.aggregate([
    ...pipeline,
    {
      $unwind: "$duration",
    },
    {
      $group: {
        _id: "$duration.from",
        events: {
          $push: {
            _id: "$_id",
            title: "$title",
            participantsDetails: "$participantsDetails",
            mode: "$mode",
            aol: "$aol",
            userId: "$userId",
            dateFrom: "$date.from",
            dateTo: "$date.to",
            userDetails: "$userDetails",
            teachersDetails: "$teachersDetails",
            durationFrom: "$duration.from",
            durationTo: "$duration.to",
            meetingLink: "$meetingLink",
            recurring: "$recurring",
            description: "$description",
            address: "$address",
            phoneNumber: "$phoneNumber",
            registrationLink: "$registrationLink",
            location: "$location",
            teachers: "$teachers",
            notifyTo: "$notifyTo",
            distanceInKilometers: {
              $divide: ["$distanceInMeters", 1000],
            },
          },
        },
      },
    },
    {
      $sort: { _id: 1 },
    },
    {
      $skip: (pageNo - 1) * pageSizeLimit,
    },
    {
      $limit: pageSizeLimit,
    },
    {
      $project: {
        _id: 0,
        from: "$_id",
        events: 1,
      },
    },
  ]);
}




async function getHorizontalEvents(request) {
  const { mode, aol, course, date, lat, long, page, pageSize, fromTime } =
    request.body;
  const pageSizeLimit = pageSize || 10;
  const pageNo = page || 1;
  let matchQuery = {};
  const pipeline = [
    {
      $lookup: {
        from: "users",
        localField: "userId",
        foreignField: "_id",
        as: "userDetails",
      },
    },
    {
      $lookup: {
        from: "users",
        localField: "teachers",
        foreignField: "_id",
        as: "teachersDetails",
      },
    },
    {
      $lookup: {
        from: "users",
        localField: "notifyTo",
        foreignField: "_id",
        as: "participantsDetails",
      },
    },
  ];
  if (course) {
    matchQuery["course"] = {
      $regex: new RegExp(course.trim()),
      $options: "i",
    };
  }

  if (date) {
    const [startOfDay, nextDay] = getStartOfDayAndNextDay(date);
    matchQuery["$and"] = [
      { "date.from": { $gte: new Date(startOfDay) } },
      // { time: { $lte: new Date(nextDay) } },
    ];
  } else {
    const [startOfDay, nextDay] = getStartOfDayAndNextDay(
      new Date().toISOString()
    );
    matchQuery["$and"] = [
      { "date.from": { $gte: new Date(startOfDay) } },
      // { time: { $lte: new Date(nextDay) } },
    ];
  }

  if (aol) {
    matchQuery["aol"] = {
      $in: [aol],
    };
  }
  if (mode) {
    matchQuery["mode"] = {
      $in: [mode],
    };
  }

  if (Object.keys(matchQuery).length !== 0) {
    const matchStage = { $match: matchQuery };
    pipeline.push(matchStage);
  }
  if (lat && long) {
    pipeline.unshift({
      $geoNear: {
        near: {
          type: "Point",
          coordinates: [parseFloat(long), parseFloat(lat)],
        },
        distanceField: "distanceInMeters",
        maxDistance: constants.MAX_DISTANCE_IN_MILES * 1609.34,
        spherical: true,
        key: "location",  // Add the specific index field here

      },
    });
  }

  return await Event.aggregate([
    ...pipeline,
    {
      $unwind: "$duration",
    },
    {
      $match: {
        "duration.from": { $eq: fromTime },
      },
    },
    {
      $group: {
        _id: "$duration.from",
        events: {
          $push: {
            _id: "$_id",
            title: "$title",
            participantsDetails: "$participantsDetails",
            mode: "$mode",
            aol: "$aol",
            userId: "$userId",
            dateFrom: "$date.from",
            dateTo: "$date.to",
            userDetails: "$userDetails",
            teachersDetails: "$teachersDetails",
            durationFrom: "$duration.from",
            durationTo: "$duration.to",
            meetingLink: "$meetingLink",
            recurring: "$recurring",
            description: "$description",
            address: "$address",
            phoneNumber: "$phoneNumber",
            registrationLink: "$registrationLink",
            location: "$location",
            teachers: "$teachers",
            notifyTo: "$notifyTo",
            distanceInKilometers: {
              $divide: ["$distanceInMeters", 1000],
            },
          },
        },
      },
    },
    {
      $sort: { _id: 1 },
    },
    {
      $skip: (pageNo - 1) * pageSizeLimit,
    },
    {
      $limit: pageSizeLimit,
    },
    {
      $project: {
        _id: 0,
        from: "$_id",
        events: 1,
      },
    },
  ]);
}

async function getMyEvents(request) {
  return await Event.aggregate([
    {
      $match: {
        userId: new mongoose.Types.ObjectId(request.user.id),
      },
    },

    {
      $lookup: {
        from: "users",
        localField: "userId",
        foreignField: "_id",
        as: "userDetails",
      },
    },
    {
      $lookup: {
        from: "users",
        localField: "teachers",
        foreignField: "_id",
        as: "teachersDetails",
      },
    },
  ]);
}

const getNotification = async (request) => {
  return await Notification.find({ to: request.user.id }).sort({ _id: -1 });
};

const getParticepents = async (request) => {
  return await Event.aggregate([
    { $match: { _id: new ObjectId(request.params.id) } },
    {
      $lookup: {
        from: "users",
        localField: "notifyTo",
        foreignField: "_id",
        as: "participantsDetails",
      },
    },
  ]).sort({ _id: -1 });
};

// const notificatifyMe = async (request) => {
//   let event = await Event.findById(request.params.id);
//   if (!event) {
//     throw new appError(httpStatus.CONFLICT, request.t("event.EVENT_NOT_FOUND"));
//   }

//   if (!event.notifyTo.includes(request.user.id)) {
//     event = await Event.findByIdAndUpdate(
//       request.params.id,
//       {
//         $push: {
//           notifyTo: request.user.id,
//         },
//       },
//       { new: true }
//     );
//   }
//   return event;
// };

const notificatifyMe = async (request) => {
  let event = await Event.findById(request.params.id);
  if (!event) {
    throw new appError(httpStatus.CONFLICT, request.t("event.EVENT_NOT_FOUND"));
  }

  if (!event.notifyTo.includes(request.user.id)) {
    event = await Event.findByIdAndUpdate(
      request.params.id,
      {
        $push: { notifyTo: request.user.id },
      },
      { new: true }
    );
    await sendNotifications(event.notifyTo, event);
  }
  return event;
};

const sendNotifications = async (userIds, event) => {
  for (const userId of userIds) {
    const user = await User.findById(userId);
    if (user) {
      const eventDate = {
        from: event.date.from,
        to: event.date.to,
      };

      const meetingLink = event.meetingLink; // Make sure this field exists in your event object
      const duration = {
        from: event.duration[0].from, // Assuming duration is an array and you're taking the first item
        to: event.duration[0].to,
      };

      const notificationToUser = new Notification({
        userId: userId,
        eventId: event._id,
        message: `You have a new notification regarding the event.`,
        profileImage: user.profileImage,
        eventDate: eventDate,
        meetingLink: meetingLink,
        duration: duration,
      });

      await notificationToUser.save();
    }
  }
};


async function getAttendedEvents(request) {
  const { page = 1, limit = 10 } = request.query;
  const userObjectId = mongoose.Types.ObjectId(request.user.id);
  const skip = (page - 1) * limit;

  return await Event.aggregate([
    {
      $match: {
        teachers: userObjectId,
        userId: { $ne: userObjectId },
      },
    },
    {
      $lookup: {
        from: "users",
        localField: "teachers",
        foreignField: "_id",
        as: "teacherDetails",
      },
    },

    {
      $skip: skip,
    },
    {
      $limit: limit,
    },
  ]);
}

const subscribeToEvent = async (eventId, userId, userName) => {
  const event = await Event.findById(eventId);

  if (!event) {
    throw new appError(httpStatus.NOT_FOUND, "Event not found");
  }

  if (!event.subscribers.some(sub => sub.userId.toString() === userId.toString())) {
    event.subscribers.push({ userId, name: userName });
    await event.save();
  }

  await Subscription.create({
    userId,
    eventId,
    name: userName
  });

  return { event, subscription: { userId, eventId, name: userName } };
};

const getSubscribersByEventId = async (eventId) => {
  console.log(`Fetching event with ID: ${eventId}`);

  const event = await Event.findById(eventId).populate({
    path: 'participants.userId',
    select: 'name',
  });

  if (!event) {
    console.log(`Event not found for ID: ${eventId}`);
    throw new appError(httpStatus.NOT_FOUND, 'Event not found');
  }

  console.log(`Event found:`, event);
  console.log(`Participants:`, event.participants);

  const subscribers = event.participants.map(participant => ({
    userId: participant.userId._id,
    name: participant.userId.name
  }));

  console.log(`Subscribers list:`, subscribers);

  return subscribers;
};

const getNearEventService = async (longitude, latitude, maxDistance) => {
  try {
    // Find nearby events based on geospatial coordinates
    let nearByEvents = await Event.find({
      location: {
        $nearSphere: {
          $geometry: {
            type: "Point",
            coordinates: [longitude, latitude]
          },
          $maxDistance: maxDistance, // distance in meters
        },
      },
    });

    return nearByEvents;
  } catch (error) {
    throw new Error(`Error fetching nearby events: ${error.message}`);
  }
};
module.exports = {
  getHorizontalEvents,
  createEvent,
  editEvent,
  deleteEvent,
  getEvent,
  getEvents,
  getMyEvents,
  getNotification,
  notificatifyMe,
  getParticepents,
  getAttendedEvents,
  subscribeToEvent,
  getSubscribersByEventId,
  getNearEventService
};
