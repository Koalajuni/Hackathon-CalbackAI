const functions = require("firebase-functions");
const admin = require("firebase-admin");
//  const auth = require("firebase-auth");

const serviceAccount = require(
    "./calback-fdeeb-firebase-adminsdk-4tqbw-81efde4f35.json"
);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});


// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
exports.createToken = functions.https.onRequest(
    async (request, response) => {
      const user = request.body;
      let newId = "0";
      let uid = "";
      const updateParams = {
        email: user.email,
      };

      if (user.userType == "kakao") {
        uid = `kakaoUserhymhymhym${user.uid}`;

        try {
          //  if account exists, updates
          await admin.auth().updateUser(uid, updateParams);
        } catch (e) {
          //  if account doesn't exist
          updateParams["uid"] = uid;
          await admin.auth().createUser(updateParams);
          newId = "1";
        }
      } else if (user.userType == "open") {
        uid = user.uid;
        try {
          updateParams["uid"] = uid;
          updateParams["password"] = user.password;
          await admin.auth().createUser(updateParams);
          newId = "1";
          const token = await admin.auth().createCustomToken(uid);
          response.send({"token": token, "new": newId});
        } catch (e) {
          console.log(e);
          response.send({"token": e, "new": -1});
        }
      }
    });
