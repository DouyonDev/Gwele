// service-worker.js

// Gestion de l'installation du Service Worker
self.addEventListener('install', function(event) {
    console.log('Service Worker installé');
    // Optionnel: pré-cache des fichiers pour l'utilisation hors ligne
});

// Gestion de l'activation du Service Worker
self.addEventListener('activate', function(event) {
    console.log('Service Worker activé');
    // Optionnel: nettoyage du cache ou autres tâches lors de l'activation
});

// Gestion des notifications push
self.addEventListener('push', function(event) {
    const options = {
        body: event.data ? event.data.text() : 'Vous avez une nouvelle notification!',
        icon: '/images/icons/icon-192x192.png', // Chemin vers l'icône de notification
        badge: '/images/icons/badge-72x72.png' // Chemin vers le badge de notification
    };

    event.waitUntil(
        self.registration.showNotification('Titre de la notification', options)
    );
});

// Gestion du clic sur une notification
self.addEventListener('notificationclick', function(event) {
    event.notification.close(); // Fermer la notification

    event.waitUntil(
        clients.openWindow('https://votre-url-de-redirection.com') // Ouvre une nouvelle fenêtre ou un nouvel onglet
    );
});
