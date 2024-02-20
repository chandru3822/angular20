const {
  VITE_VAPID_KEY,
  VITE_FIREBASE_API_KEY,
  VITE_FIREBASE_PROJECT_ID,
  VITE_FIREBASE_APP_ID,
  VITE_FIREBASE_MESSAGING_SENDER_ID
} = import.meta.env
import { ref } from 'vue'
import { initializeApp } from 'firebase/app'
import { deleteToken, getMessaging, getToken } from 'firebase/messaging'
import { deleteRequest, postRequest } from '@/helpers/helpers'

// See: https://firebase.google.com/docs/web/learn-more#config-object
const firebaseConfig = {
  apiKey: VITE_FIREBASE_API_KEY,
  projectId: VITE_FIREBASE_PROJECT_ID,
  appId: VITE_FIREBASE_APP_ID,
  authDomain: `${VITE_FIREBASE_PROJECT_ID}.firebaseapp.com`,
  messagingSenderId: VITE_FIREBASE_MESSAGING_SENDER_ID
}


function getFirebaseApp(){
  try {
    // Initialize Firebase
    if (firebaseConfig.apiKey && firebaseConfig.projectId){
      return initializeApp(firebaseConfig)
    }
    return undefined
  }catch (e){
    log.error(e)
    return undefined
  }
}

function getFirebaseMessaging(app){
  try {
    if (app){
      return getMessaging(app)
    }
    return undefined
  }catch (e){
    return undefined
  }
}

export function useFirebase() {

  const app = getFirebaseApp()

  // Initialize Firebase Cloud Messaging and get a reference to the service
  const messaging = getFirebaseMessaging(app)

  const registered = ref(false)

  const getNotificationToken = async function () {
    try {
      const sw = await navigator.serviceWorker.register(
        import.meta.env.MODE === 'production' ? '/firebase-messaging-sw.js' : '/dev-sw.js?dev-sw',
        { type: import.meta.env.MODE === 'production' ? 'classic' : 'module' }
      )
      const token = await getToken(messaging, {
        serviceWorkerRegistration: sw,
        vapidKey: VITE_VAPID_KEY })
      if (token) {
        await postRequest('/user/token', { token })
        registered.value = true
      }
      return token
    } catch (e) {
      registered.value = false
      console.error(e)
    }
    return null
  }

  const removeNotificationToken = async function () {
    const notificationToken = await getNotificationToken()
    if (!notificationToken) {
      return
    }
    await deleteRequest(`/user/token?id=${notificationToken}`)
    await deleteToken(messaging)
    registered.value = false
    return true
  }

  const init = async function () {
    const granted = Notification.permission === 'granted'

    if (granted) {
      const token = await getNotificationToken()
      if (token) {
        registered.value = granted
      }
    }
  }

  if (app && messaging){
    init()
    return { registered, removeNotificationToken, getNotificationToken }
  }

  return {
    registered,
    removeNotificationToken: ()=> console.error('notifications not configured properly'),
    getNotificationToken: ()=> console.error('notifications not configured properly'),
  }

}
