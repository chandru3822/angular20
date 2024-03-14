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
        <v-btn class="mr-4" type="submit" :disabled="!isValid"> submit </v-btn>
        <v-btn @click="clear">clear</v-btn>
      </v-row>
    </v-container>
  </v-form>
</template>
<script>
import { getRequest, postRequest } from '@/helpers/helpers'

export default {
  data() {
    return {
      filter: '',
      title: '',
      message: '',
      selected: [],
      users: []
    }
  },
  created() {
    Promise.allSettled([this.getPushNotificationUsers()])
  },
  computed: {
    isValid() {
      return (
        this.title?.trim()?.length > 0 &&
        this.message?.trim()?.length > 0 &&
        this.selected?.length > 0
      )
    }
  },
  methods: {
    clear() {
      this.$refs.form.reset()
    },
    async getPushNotificationUsers() {
      try {
        const { data = [] } = await getRequest('/user/notifications', null, [])
        this.users = [...data]
      } catch (e) {
        console.error(e)
      }
    },

    async sendPushNotifications() {
      try {
        if (this.title && this.message && this.selected.length > 0) {
          await postRequest('/push', {
            title: this.title,
            message: this.message,
            userIds: this.selected.map(u=>u.id)
          })
          this.clear()
        }
      } catch (e) {
        console.error(e)
      }
    }
  }
}
</script>
