import NotificationStore from './NotificationStore'

const NOTIFICATION_MODULE = 'notifications'

export const NotificationPlugin = {
  install(Vue, { store }) {
    // dynamically register notifications store
    if (!store.hasModule(NOTIFICATION_MODULE)) {
      store.registerModule(NOTIFICATION_MODULE, NotificationStore)
    }
  }
}
