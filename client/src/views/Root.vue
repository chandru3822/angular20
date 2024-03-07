<template>
  <router-view/>
</template>
<script setup>
import constants from '@/helpers/constants'
import {NotificationActions} from '@/plugins/notifications/NotificationStore'
import {getCurrentInstance, onBeforeUnmount, onMounted, ref} from 'vue'
import { useUserStore } from '@/stores/UserStorePinia.js'

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const userStore = useUserStore()

const evtSource = ref(undefined)

onMounted(() => {
  setupNotificationStream()
})

onBeforeUnmount(() => {
  cleanupNotificationStream()
})


const setupNotificationStream = () => {
  const setup = () => {
    const url = `${constants.VUE_APP_BASE_API}/api/v1/flow/notifications/stream?access_token=${userStore.jwt}`
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

    const logoutUnsubscriber = userStore.$onAction(({name}) => {
      if (name === 'logout') {
        evtSource.value?.close()
        logoutUnsubscriber()
      }
    })
  }

  if (userStore.jwt) {
    setup()
  } else {
    const loginUnsubscriber = userStore.$onAction(({name}) => {
      console.log(name)
      if (name === 'login') {
        setup()
        loginUnsubscriber()
      }
    })
  }
}

const cleanupNotificationStream = () => {
  evtSource.value?.close()
}
</script>
