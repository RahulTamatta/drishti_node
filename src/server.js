const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const mongoose = require('mongoose');
const logger = require('../src/common/config/logger');
const morgan = require('../src/common/config/morgan');
const i18next = require('./middleware/i18Next');
const i18nextMiddleware = require('i18next-http-middleware');
const config = require('./common/config/config');
const cluster = require('cluster');
const os = require('os');
const sendSms = require('../src/common/utils/messageService');
const cron = require('node-cron');
const { sendEventReminders } = require('./modules/notification/notificationController'); // Adjust the path if needed
const Notification = require('./models/notification.js'); // Adjust the path as needed


const app = express();
cron.schedule('* * * * * *', async () => { // Runs every second
  const now = new Date();
  // Convert current time to Indian time (Asia/Kolkata)
  const indianTime = new Date(now.toLocaleString("en-US", { timeZone: "Asia/Kolkata" }));
  const formattedIndianTime = new Date(indianTime.toISOString().split('.')[0] + ".000Z");
  
  //   console.log(`\n[${now.toISOString()}] Cron job called...`);
  //   console.log("Indian Time (ISO):", formattedIndianTime);

  try {
    //   console.log(`[${now.toISOString()}] Fetching pending notifications...`);
    const notifications = await Notification.find({
      scheduledAt: { $lte: Date }, // Query using ISO formatted Indian time
      status: "pending"
    });

    //   console.log(`[${now.toISOString()}] Found ${notifications.length} pending notifications.`);

    if (notifications.length === 0) {
      //   console.log(`[${now.toISOString()}] No notifications to send at this moment.`);
      return;
    }

    for (const notification of notifications) {
      //   console.log(`[${now.toISOString()}] Processing notification: ${notification._id} (${notification.title})`);
      
      try {
        await new Promise((resolve) => setTimeout(resolve, 500)); // Simulate delay for sending
        notification.status = "completed";
        await notification.save();
        //   console.log(`[${now.toISOString()}] Notification ${notification._id} marked as completed.`);
      } catch (sendError) {
        // //   console.error(`[${now.toISOString()}] Error sending notification ${notification._id}:`, sendError);
      }
    }
  } catch (error) {
    // //   console.error(`[${now.toISOString()}] Error during cron job execution:`, error);
  }

  // //   console.log(`[${now.toISOString()}] Cron job execution finished.\n`);
});


// const PORT =  3000;

// app.listen(PORT, () => {
//   //   console.log(`Server running on port ${PORT}`);
// });

; // Import the cron job to start it

// if (cluster.isMaster) {
//   const numCPUs = os.cpus().length;

//   for (let i = 0; i < numCPUs; i++) {
//     cluster.fork();
//   }

//   cluster.on("exit", (worker, code, signal) => {
//     //   console.log(`Worker ${worker.process.pid} died`);
//     cluster.fork();
//   });
// } else {
if (process.env.NODE_ENV !== "test") {
  app.use(morgan.successHandler);
  app.use(morgan.errorHandler);
}

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(i18nextMiddleware.handle(i18next));

require("./route")(app);
// sendSms();
// Error Handling Middleware
app.use((err, req, res, next) => {
  // //   console.error(err);
  // logger.error(err);
  res.status(500).send("Internal Server Error");
});

// if (process.env.NODE_ENV !== "PRODUCTION") {
//   dotenv.config({ path: `${__dirname}/../.env.local` });
// }

mongoose.set("strictQuery", true);
mongoose.set("debug", true);

let server;

mongoose
  .connect(config.mongoose.url)
  .then(() => {
    logger.info("Connected to MongoDB");
    server = app.listen(config.port, () => {
      logger.info(`Listening to port ${config.port}`);
    });
  })
  .catch((error) => {
    logger.error(error.message);
  });

const unexpectedErrorHandler = (error) => {
  //   console.error("Unexpected Error:", error.message);
  //   console.error(error.stack);
  logger.error(error);

  // Additional logging for OAuth2 errors
  if (error.name === "TokenError") {
    //   console.error("OAuth2 Token Error:", error.message);
    //   console.error("OAuth2 Token Error Description:", error.description);
    //   console.error("OAuth2 Token Error Code:", error.code);
  }

  exitHandler();
};

const exitHandler = () => {
  if (server) {
    server.close(() => {
      logger.info("Server closed");
      mongoose.connection.close(false, () => {
        logger.info("MongoDB connection closed");
        process.exit(1);
      });
    });
  } else {
    mongoose.connection.close(false, () => {
      logger.info("MongoDB connection closed");
      process.exit(1);
    });
  }
};

process.on("uncaughtException", unexpectedErrorHandler);
process.on("unhandledRejection", (reason, promise) => {
  //   console.error("Unhandled Rejection at:", promise, "reason:", reason);
  // Additional logging or handling can be added here
});

process.on("SIGTERM", () => {
  logger.info("SIGTERM received");
  if (server) {
    server.close();
  }
});
// }
