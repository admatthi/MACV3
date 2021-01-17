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
        "token": "d-9D0Wl39EXyiy08zc_NIW:APA91bEdGsIfzcEcGt71rH4sdQVT82HVcq9KKvAEqWQwsziAwpxhDQpagM8FRUM0DbmtSGSKfGrYlmJ0O0GRuqdiC3Chm3bQothDGfmQZCGY8vf0NNsvTRoxcV9mZt-BuJ_3K9KGPR6G"
    };
    const options = {
        content_available: true,
        priority: "high",

    }
    let response= admin.messaging().sendToDevice(message.token,payload,options)

    return null;
});