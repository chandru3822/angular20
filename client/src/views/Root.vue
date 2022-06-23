<template>
  <router-view />
</template>
<script>
import store from '@/store'
import constants from '@/helpers/constants'
import { NotificationActions } from '@/plugins/notifications/NotificationStore'
import { UserActions } from '@/stores/UserStore'

export default {
  data() {
    return {
      evtSource: undefined
    }
  },
  mounted() {
    this.setupNotificationStream()
  },
  beforeDestroy() {
    this.evtSource?.close()
  },
  methods: {
    setupNotificationStream() {
      const setup = () => {
        const url = `${constants.VUE_APP_BASE_API}/api/v1/flow/notifications/stream?access_token=${store.state.user.jwt}`
        const topics = ['sms_ownership', 'sms_reply']
        this.evtSource = new EventSource(url, { withCredentials: true })
        topics.forEach(topic => {
          this.evtSource.addEventListener(topic, function(e) {
            const data = JSON.parse(e?.data)
            store.dispatch(NotificationActions.HANDLE_STREAM_EVENT, data)
          })
        })

        //catchall
        window?.addEventListener('beforeunload', (e) => {
          this.evtSource?.close()
        })

        const logoutUnsubscriber = store.subscribeAction((action, state) => {
          if (action.type === UserActions.LOGOUT) {
            this.evtSource?.close()
            logoutUnsubscriber()
          }
        })
      }

      if (store.state.user.jwt) {
        setup()
      } else {
        const loginUnsubcriber = store.subscribeAction((action, state) => {
          //logging in for the first time wait until we have a user
          if (action.type === UserActions.LOGIN_SUCCESS) {
            setup()
            loginUnsubcriber()
          }
        })
      }
    }
  }
}
</script>
