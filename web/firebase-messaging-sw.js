importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyBygExI8d7eUKruIsLChdq6ui9KNQDKozk",
  authDomain: "pet-hero-423816.firebaseapp.com",
  projectId: "pet-hero-423816",
  storageBucket: "pet-hero-423816.firebasestorage.app",
  messagingSenderId: "721852722464",
  appId: "1:721852722464:web:d709be9380727fdec0bb45",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification ? payload.notification.title : 'Notificação';
  const notificationOptions = {
    body: payload.notification ? payload.notification.body : '',
    icon: '/icons/Icon-192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
