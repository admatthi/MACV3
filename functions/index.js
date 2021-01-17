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

exports.scheduledFunction = functions.pubsub.schedule('every 1 minutes').onRun((context) => {
    console.log('This will be run every 1 minutes!');

    const payload = {
        notification: {
            title: "Alarm",
            body: "wake up",
        },
    };
    var message ={
        notification: {
            title: "Alarm",
            body:  "wake up"

        },
        "token": "cQuZ_waHbEM7lhD8ur2g8L:APA91bF4UfbYE6rqR1y7k37PoK1oQN2aiIrgZjoqK7zdZDm1URl81BdhE668ymu1Oh9kq31QC_HutGSFn3HnMEDNHGnUZy7wqCufFbFQRQteRgYXf-VmOr6LEj2MFOz1qKDe-Ek7Wp41"
    };
    const options = {
        content_available: true,
        priority: "high",
    }
    let response= admin.messaging().sendToDevice(message.token,payload,options)

    return null;
});