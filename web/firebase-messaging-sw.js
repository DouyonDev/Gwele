importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging.js');

firebase.initializeApp({
    apiKey: "AIzaSyDSq2o1nRu3ao4VSeKYIz3sfm9mrHfZWEk",
    authDomain: "gwele-33e7f.firebaseapp.com",
    projectId: "gwele-33e7f",
    storageBucket: "gwele-33e7f.appspot.com",
    messagingSenderId: "55776588459",
    measurementId: "G-Y8R1PJ52FZ"
});

const messaging = firebase.messaging();

// Gérer les notifications lorsque l'application est en arrière-plan
messaging.onBackgroundMessage(function(payload) {
    console.log('Received background message ', payload);
    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
        icon: '/firebase-logo.png'
    };

    self.registration.showNotification(notificationTitle, notificationOptions);
});
