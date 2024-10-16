if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('/firebase-messaging-sw.js')
        .then(function(registration) {
            console.log('Service Worker enregistré avec succès :', registration.scope);

            // Demander la permission pour les notifications
            Notification.requestPermission().then(function(permission) {
                if (permission === 'granted') {
                    console.log('Permission accordée pour les notifications.');
                } else {
                    console.log('Permission refusée pour les notifications.');
                }
            });
        })
        .catch(function(err) {
            console.log('Échec de l\'enregistrement du Service Worker :', err);
        });
}
