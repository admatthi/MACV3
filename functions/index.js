const functions = require('firebase-functions');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
var schedule = require('node-schedule');
const db = admin.firestore();

exports.scheduledFunction = functions.pubsub.schedule('every 30 minutes').onRun(async (context) => {
    console.log('This will be run every 30 minutes!');


    const querySnapshot = await db.collectionGroup('profile').get();
    querySnapshot.forEach((doc) => {
        console.log(doc.id, ' => ', doc.data());
        var data = doc.data();
        const payload = {
            "data": {
                "story_id": "story_12345"
            }
        };
        var token = data.token;
        var message ={
            "token": "fu0hSGxbH0JQi9ylSSWGje:APA91bELIqHpQougtaVQQlRpgOo7AvLQ9w72Ph8ZfRz8rrUBWQP6sFCJCyBZN5nEt42uDbmbxY3_2MLkmg0v_Dg5oaItSzn31vhh8gnGCdjy1sLQYOsNRB6ZdE1jrhEWOxo8A9fQY0uh",
            "data": {
                "updateApi": "activity"
            }
        };
        const options = {
            content_available: true,
            priority: "high"
        }
        let response= admin.messaging().sendToDevice(token,payload,options)
        console.log(response);
    });
    return null;
});