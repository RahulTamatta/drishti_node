const router = require("express").Router();
const multer = require("multer");

// Configure multer for file uploads
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 } // 5MB limit
});

// Define the upload fields
const userUpload = upload.fields([{ name: "profilePic" }]);
const teacherUpload = upload.fields([{ name: "teacherIdCard", maxCount: 1 }]);

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
  getUser,
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
  getSocialMediaController
} = require("./userController");

const { ROLES } = require("../../common/utils/constants");
const auth = require("../../middleware/authentication");
const methodNotAllowed = require("../../middleware/methodNotAllowed");
const validate = require("../../middleware/validate");
const { uploadToS3 } = require("../../common/utils/uploadToS3");

router.route("/").get(auth(ROLES.ALL), getUser).all(methodNotAllowed);

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
      validate(onBoardUserV),
    ],
    upload.single('profileImage'),
    onBoardUserController
  )
  .all(methodNotAllowed);

router
  .route("/location")
  .put([auth(ROLES.ALL), validate(updateLocationV)], updateLocationController)
  .all(methodNotAllowed);

router
  .route("/upload")
  .post(auth(ROLES.ALL), userUpload, addFiles)
  .all(methodNotAllowed);

router
  .route("/refreshToken")
  .post(generateTokenController)
  .all(methodNotAllowed);

router
  .route("/teacher")
  .post(auth(ROLES.ALL), teacherUpload, addTeacherRole)
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

module.exports = router;