if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('/firebase-messaging-sw.js')
        .then(function(registration) {
            console.log('Service Worker enregistré avec succès :', registration.scope);
        })
        .catch(function(err) {
            console.log('Échec de l\'enregistrement du Service Worker :', err);
        });
}
