const router = require("express").Router();
const multer = require("multer");
const createResponse = require("../../common/utils/createResponse");
const httpStatus = require("../../common/utils/status.json");

// Configure multer for file uploads
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
});

// Custom middleware to log form data
const logFormData = (req, res, next) => {
  console.log('=== Form Data Debug ===');
  console.log('Body:', req.body);
  console.log('Files:', req.files);
  next();
};

// Define the upload fields for different routes
const profileUpload = upload.fields([
  { name: 'profileImage', maxCount: 1 },
  { name: 'teacherIdCard', maxCount: 1 }
]);

const fileUpload = upload.fields([
  { name: 'file', maxCount: 1 }
]);

const teacherUpload = upload.fields([
  { name: 'teacherIdCard', maxCount: 1 }
]);

const {
  userLoginV,
  updateLocationV,
  onBoardUserV,
  teachersListingV,
  updateSocialMediaLinksV,
} = require("./userValidation");

const {
  userLoginController,
  updateLocationController,
  onBoardUserController,
  addFiles,
  addTeacherRole,
  getAllUsers,
  getAllTeachers,
  actionOnTeacherAccount,
  verifyOtpController,
  getTeachersRequest,
  updateSocialMediaLinks,
  generateTokenController,
  locationSharing,
  getNearbyVisible,
  getSocialMediaController,
  searchUsers,
  getUser // Import getUser from userController
} = require("./userController");

// Remove this line as we're already importing searchUsers from userController
// const { searchUsers } = require("./userService");

const { ROLES } = require("../../common/utils/constants");
const auth = require("../../middleware/authentication");
const methodNotAllowed = require("../../middleware/methodNotAllowed");
const validate = require("../../middleware/validate");
const { uploadToS3 } = require("../../common/utils/uploadToS3");



// User profile routes
router.route("/")
  .get(auth([ROLES.USER, ROLES.ADMIN, ROLES.TEACHER]), getUser)
  .all(methodNotAllowed);

router
  .route("/login")
  .post(validate(userLoginV), userLoginController)
  .all(methodNotAllowed);

router.route("/verify").post(verifyOtpController).all(methodNotAllowed);

router
  .route("/onBoard")
  .post(
    [
      auth(ROLES.ALL),
      profileUpload,  // Process form data first
      logFormData,    // Then log the processed data
      validate(onBoardUserV)  // Then validate the processed data
    ],
    onBoardUserController
  )
  .all(methodNotAllowed);

router
  .route("/location")
  .put([auth(ROLES.ALL), validate(updateLocationV)], updateLocationController)
  .all(methodNotAllowed);

router
  .route("/upload")
  .post(auth(ROLES.ALL), fileUpload, addFiles)
  .all(methodNotAllowed);

router
  .route("/refreshToken")
  .post(generateTokenController)
  .all(methodNotAllowed);

router
  .route("/teacher")
  .post([auth(ROLES.ALL), teacherUpload], addTeacherRole)
  .all(methodNotAllowed);

router.route("/all").get(auth(ROLES.ALL), getAllUsers).all(methodNotAllowed);

router
  .route("/teachers")
  .get(auth(ROLES.ALL), validate(teachersListingV), getAllTeachers)
  .all(methodNotAllowed);

router
  .route("/action-teacher")
  .post(auth(ROLES.ADMIN), actionOnTeacherAccount)
  .all(methodNotAllowed);

router
  .route("/getTeachersRequest")
  .get(auth(ROLES.ADMIN), getTeachersRequest)
  .all(methodNotAllowed);

router
  .route("/getAllTeachers")
  .get(auth(ROLES.ALL), getAllTeachers)
  .all(methodNotAllowed);

router
  .route("/socialMedia")
  .patch(
    auth(ROLES.ALL),
    validate(updateSocialMediaLinksV),
    updateSocialMediaLinks
  )
  .all(methodNotAllowed);

router
  .route("/locationSharing")
  .patch(auth(ROLES.ALL), locationSharing)
  .all(methodNotAllowed);

router.route("/socialLinks/:userId")
  .get(getSocialMediaController)
  .all(methodNotAllowed);

router.route("/nearUser")
  .post(getNearbyVisible)
  .all(methodNotAllowed);

// router
//   .route("/search-user")
//   .get(async (req, res) => {
//     try {
//       const { userName } = req.query;
      
//       if (!userName && userName !== '') {
//         return createResponse(res, httpStatus.BAD_REQUEST, "Username parameter is required");
//       }

//       const users = await searchUsers(userName);
//       return createResponse(res, httpStatus.OK, "Users found", {
//         message: users.length > 0 ? "Users found" : "No users found",
//         data: users
//       });

//     } catch (error) {
//       console.error("Search user error:", error);
//       return createResponse(
//         res, 
//         error.status || httpStatus.INTERNAL_SERVER_ERROR,
//         error.message || "Error searching users"
//       );
//     }
//   })
//   .all(methodNotAllowed);

module.exports = router;