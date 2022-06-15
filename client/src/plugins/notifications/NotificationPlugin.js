import NotificationStore, { NotificationActions } from './NotificationStore'

const NOTIFICATION_MODULE = 'notifications'

export const NotificationPlugin = {
  install(Vue, url, { store, topics = ['sms_ownership', 'sms_reply'] }) {
    // dynamically register notifications store
    if (!store.hasModule(NOTIFICATION_MODULE)) {
      store.registerModule(NOTIFICATION_MODULE, NotificationStore)
    }

    const evtSource = new EventSource(url, { withCredentials: true })
    topics?.forEach(topic => {
      evtSource.addEventListener(topic, function(e) {
        const data = JSON.parse(e?.data)
        store.dispatch(NotificationActions.HANDLE_STREAM_EVENT, data)
      })
    })
  }
}
