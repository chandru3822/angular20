<template>
  <router-view/>
</template>
<script setup>
import constants from '@/helpers/constants'
import {NotificationActions} from '@/plugins/notifications/NotificationStore'
import {UserActions} from '@/stores/UserStore'
import {getCurrentInstance, onBeforeUnmount, onMounted, ref} from 'vue'

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const evtSource = ref(undefined)

onMounted(() => {
  setupNotificationStream()
})

onBeforeUnmount(() => {
  cleanupNotificationStream()
})


const setupNotificationStream = () => {
  const setup = () => {
    const url = `${constants.VUE_APP_BASE_API}/api/v1/flow/notifications/stream?access_token=${store.state.user.jwt}`
    const topics = ['sms_ownership', 'sms_reply', 'project_tag', 'revoke_access', 'theme_update', 'announcement']
    evtSource.value = new EventSource(url, {withCredentials: true})
    topics.forEach(topic => {
      evtSource.value.addEventListener(topic, function (e) {
        const data = JSON.parse(e?.data)
        store.dispatch(NotificationActions.HANDLE_STREAM_EVENT, data)
      })
    })

    //catchall
    window?.addEventListener('beforeunload', (e) => {
      evtSource.value?.close()
    })

    const logoutUnsubscriber = store.subscribeAction((action, state) => {
      if (action.type === UserActions.LOGOUT) {
        evtSource.value?.close()
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

const cleanupNotificationStream = () => {
  evtSource.value?.close()
}
</script>
