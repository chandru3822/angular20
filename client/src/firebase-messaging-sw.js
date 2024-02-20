// Give the service worker access to Firebase Messaging.
import { initializeApp } from 'firebase/app'
import { getMessaging } from "firebase/messaging/sw"

const VITE_FIREBASE_API_KEY = import.meta.env.VITE_FIREBASE_API_KEY
const VITE_FIREBASE_PROJECT_ID = import.meta.env.VITE_FIREBASE_PROJECT_ID
const VITE_FIREBASE_APP_ID = import.meta.env.VITE_FIREBASE_APP_ID
const VITE_FIREBASE_MESSAGING_SENDER_ID = import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID

// See: https://firebase.google.com/docs/web/learn-more#config-object
const firebaseConfig = {
  apiKey: VITE_FIREBASE_API_KEY,
  projectId: VITE_FIREBASE_PROJECT_ID,
  appId: VITE_FIREBASE_APP_ID,
  authDomain: `${VITE_FIREBASE_PROJECT_ID}.firebaseapp.com`,
  messagingSenderId: VITE_FIREBASE_MESSAGING_SENDER_ID
}

const app = initializeApp(firebaseConfig)
const messaging = getMessaging(app)

// Retrieve an instance of Firebase Messaging so that it can handle background
// messages.
// onBackgroundMessage(messaging, (payload)=>{
//   console.log({payload})
// })

//   // Customize notification here
//   const notificationTitle = 'Background Message Title'
//   const notificationOptions = {
//     body: 'Background Message body.',
//     icon: '/firebase-logo.png'
//   }
//
//   self.registration.showNotification(notificationTitle, notificationOptions)

self.skipWaiting()
