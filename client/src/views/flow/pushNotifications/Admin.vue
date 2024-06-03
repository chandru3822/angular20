<template>
  <v-form ref="form" @submit.prevent="sendPushNotifications">
    <v-container>
      <v-card class="pa-4 mb-4" color="secondary" width="200" v-if="is7oaksAdmin">
        7 Oaks Only: <br>
        <a-btn class="mt-2" :loading="processingQueue"
               @click="processPushNotificationQueue()">Process Queue</a-btn>
      </v-card>
      <v-toolbar flat class="app-toolbar">
        <v-toolbar-title class="app-title">
          Test Push Notifications
        </v-toolbar-title>
      </v-toolbar>
      <v-row>
        <v-col>
          <v-combobox
            v-model="selected"
            :items="users"
            item-text="fullName"
            item-value="id"
            label="Users"
            multiple
            outlined
            dense
            clearable
            small-chips
            deletable-chips
          />
          <a-text-field
            label="Title"
            variant="solo"
            v-model="title"
            :disabled="!selected?.length"
          />
          <a-textarea
            :disabled="!selected?.length"
            variant="solo"
            no-resize
            name="input-7-4"
            label="Message"
            v-model="message"
          />
        </v-col>
      </v-row>
      <v-row>
        <a-btn
          class="mr-4"
          type="submit"
          :disabled="!isValid"
          color="unset"
          text="submit"
        ></a-btn>
        <a-btn @click="clear" color="unset" text="clear"></a-btn>
      </v-row>
    </v-container>
  </v-form>
</template>
<script setup>
import { getRequest, postRequest } from '@/helpers/helpers'
import { computed, ref, onMounted } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'

const userStore = useUserStore()

const title = ref('')
const message = ref('')
const selected = ref([])
const users = ref([])
const form = ref(null)
const processingQueue = ref(false)

const is7oaksAdmin = computed(() => {
  return userStore.isSystemAdmin
})

onMounted(() => {
  Promise.allSettled([getPushNotificationUsers()])
})
const isValid = computed(() => {
  return (
    title.value?.trim()?.length > 0 &&
    message.value?.trim()?.length > 0 &&
    selected.value?.length > 0
  )
})

const clear = () => {
  form.value.reset()
}
const getPushNotificationUsers = async () => {
  try {
    const { data = [] } = await getRequest('/user/notifications', null, [])
    users.value = [...data]
  } catch (e) {
    console.error(e)
  }
}

const processPushNotificationQueue = async () => {
  try {
    processingQueue.value = true
    await postRequest('/push/processQueue', {})
  } catch (e) {
    console.error(e)
  } finally {
    processingQueue.value = false
  }
}

const sendPushNotifications = async () => {
  try {
    if (title.value && message.value && selected.value?.length > 0) {
      await postRequest('/push', {
        title: title.value,
        message: message.value,
        userIds: selected.value?.map((u) => u.id)
      })
      clear()
    }
  } catch (e) {
    console.error(e)
  }
}
</script>
