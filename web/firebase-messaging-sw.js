/* Firebase background service worker for browser push notifications. */
importScripts('https://www.gstatic.com/firebasejs/10.12.5/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.5/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyAo2lCna2h3rAaDYNLDN4DIwnpyrgn4p0I',
  authDomain: 'rose-perfume.firebaseapp.com',
  projectId: 'rose-perfume',
  storageBucket: 'rose-perfume.firebasestorage.app',
  messagingSenderId: '216929737421',
  appId: '1:216929737421:web:7f1b44bc938bdf7954e784',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const notification = payload.notification || {};
  return self.registration.showNotification(notification.title || 'روز برفيوم', {
    body: notification.body || '',
    icon: '/icons/Icon-192.png',
    data: payload.data || {},
  });
});
