if( 'undefined' === typeof window) {
    importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js');
    importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging-compat.js');



if (!firebase.apps.length) {
    firebase.initializeApp({
        apiKey: "AIzaSyDSq2o1nRu3ao4VSeKYIz3sfm9mrHfZWEk",
        authDomain: "gwele-33e7f.firebaseapp.com",
        projectId: "gwele-33e7f",
        storageBucket: "gwele-33e7f.appspot.com",
        messagingSenderId: "55776588459",
        appId: "1:55776588459:web:433c30b37ab55187533dee",
        measurementId: "G-Y8R1PJ52FZ"
    });
}


const messaging = firebase.messaging();

//messaging.usePublicVapidKey('BJrdGqugU_00AC1_Tq3Jv_ki4Rkk9Mv0ZZ1n9CGoFX2tHP5KgCab3sTOVMG5DHBdG-8VmqAJvlSY04WPG1kT7co');

messaging.onBackgroundMessage(function(payload) {
    console.log('Message en arrière-plan reçu ', payload);
    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
        // icon: '/firebase-logo.png'  // Vérifiez que le fichier existe
    };

    self.registration.showNotification(notificationTitle, notificationOptions);
});}