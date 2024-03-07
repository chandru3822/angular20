const {
  VITE_VAPID_KEY,
  VITE_FIREBASE_API_KEY,
  VITE_FIREBASE_PROJECT_ID,
  VITE_FIREBASE_APP_ID,
  VITE_FIREBASE_MESSAGING_SENDER_ID
} = import.meta.env
import { ref } from 'vue'
import { initializeApp } from 'firebase/app'
import { deleteToken, getMessaging, getToken, onMessage } from 'firebase/messaging'
import { deleteRequest, postRequest } from '@/helpers/helpers'

// See: https://firebase.google.com/docs/web/learn-more#config-object
const firebaseConfig = {
  apiKey: VITE_FIREBASE_API_KEY,
  projectId: VITE_FIREBASE_PROJECT_ID,
  appId: VITE_FIREBASE_APP_ID,
  authDomain: `${VITE_FIREBASE_PROJECT_ID}.firebaseapp.com`,
  messagingSenderId: VITE_FIREBASE_MESSAGING_SENDER_ID
}

const STORAGE_KEY = 'firebase/token'

function getFirebaseApp() {
  try {
    // Initialize Firebase
    if (firebaseConfig.apiKey && firebaseConfig.projectId) {
      return initializeApp(firebaseConfig)
    }
    return undefined
  } catch (e) {
    log.error(e)
    return undefined
  }
}

function getFirebaseMessaging(app) {
  try {
    if (app) {
      return getMessaging(app)
    }
    return undefined
  } catch (e) {
    return undefined
  }
}

function getItem() {
  const storedToken = localStorage.getItem(STORAGE_KEY)
  if (!storedToken) {
    return undefined
  }

  const parsed = JSON.parse(storedToken)
  if (parsed?.expires) {
    if (new Date() > new Date(parsed.expires)) {
      localStorage.removeItem(STORAGE_KEY)
      return undefined
    }
  }

  return parsed?.value
}

//default ttl = 60 days
function saveItem(item, ttl = 1000 * 60 * 60 * 24 * 60) {
  const saved = JSON.stringify({
    value: item,
    expires: new Date().getTime() + ttl
  })
  localStorage.setItem(STORAGE_KEY, saved)
}

const registered = ref(false)
const message = ref()

const app = getFirebaseApp()

// Initialize Firebase Cloud Messaging and get a reference to the service
const messaging = getFirebaseMessaging(app)

export function useFirebase() {
  const getNotificationToken = async function () {
    try {
      const isProduction = import.meta.env.MODE === 'production'
      const sw = await navigator.serviceWorker.register(
        isProduction ? '/firebase-messaging-sw.js' : '/dev-sw.js?dev-sw',
        { type: isProduction ? 'classic' : 'module' }
      )

      const storedToken = getItem()

      const token = await getToken(messaging, {
        serviceWorkerRegistration: sw,
        vapidKey: VITE_VAPID_KEY
      })

      if (!storedToken || storedToken !== token) {
        await postRequest('/user/token', { token })
        saveItem(token)
      }

      registered.value = true
      return token
    } catch (e) {
      registered.value = false
      console.error(e)
    }
    return null
  }

  const removeNotificationToken = async function () {
    const notificationToken = getItem()
    if (!notificationToken) {
      return
    }
    await Promise.allSettled([
      deleteRequest(`/user/token?id=${notificationToken}`),
      deleteToken(messaging)
    ])

    localStorage.removeItem(STORAGE_KEY)

    registered.value = false
    return true
  }

  const init = async function () {
    const granted = Notification.permission === 'granted'

    if (granted) {
      const token = await getNotificationToken()
      if (token) {
        registered.value = granted

        //todo: handle deregistration
        onMessage(messaging, payload=>{
          message.value = payload
        })
      }
    }
  }

  if (app && messaging) {
    return { init, registered, removeNotificationToken, getNotificationToken, message }
  }

  return {
    registered,
    message,
    init: () => console.error('notifications not configured properly'),
    removeNotificationToken: () =>
      console.error('notifications not configured properly'),
    getNotificationToken: () =>
      console.error('notifications not configured properly')
  }
}
