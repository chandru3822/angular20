<template>
  <v-form ref="form" @submit.prevent="sendPushNotifications">
    <v-container>
      <v-toolbar flat class="app-toolbar">
        <v-toolbar-title class="app-title"
        >Test Push Notifications
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
          <v-text-field
              label="Title"
              solo
              v-model="title"
              :disabled="!selected?.length"
          />
          <v-textarea
              :disabled="!selected?.length"
              solo
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
        <a-btn
            @click=""
            color="unset"
            text="clear"
        ></a-btn>
      </v-row>
    </v-container>
  </v-form>
</template>
<script setup>
import { getRequest, postRequest } from '@/helpers/helpers'

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const filter = ref('')
const title = ref('')
const message = ref('')
const selected = ref([])
const users = ref([])
const form = ref(null)

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
const getPushNotificationUsers = async() => {
  try {
    const { data = [] } = await getRequest('/user/notifications', null, [])
    users.value = [...data]
  } catch (e) {
    console.error(e)
  }
}
const sendPushNotifications = async() => {
  try {
    if (title.value && message.value && selected.value?.length > 0) {
      await postRequest('/push', {
        title: title.value,
        message: message.value,
        userIds: selected.value?.map(u=>u.id)
      })
      clear()
    }
  } catch (e) {
    console.error(e)
  }
}
</script>
