import { defineStore } from 'pinia'
import { getRequest, postRequest } from '@/helpers/helpers.js'
import debounce from 'lodash.debounce'

const defaultState = {
  // data from the /notifications endpoint
  notifications: [],

  // data from /notifications/stream endpoint
  messages: []
}

export const useNotificationStore = defineStore('notification', {
  state: () => ({...defaultState}),
  getters: {
    getAllNotifications: (state) => state.notifications
  },
  actions: {
    setNotifications(notifications) {
      this.notifications = notifications
    },
    setMessages(messages) {
      this.messages = messages
    },
    addMessage(message) {
      this.messages.push(message)
    },
    getEventsByTopic(topic) {
      return this.messages?.filter(n => n.topic === topic) ?? []
    },
    getNotificationsByTopic(topic) {
      return this.notifications?.filter(n => n.topic === topic) ?? []
    },
    async processProjectMsg(projectId) {
      try {
        if (!projectId) {
          return
        }

        const newState = this.messages?.filter(n => n.projectId !== projectId)
        this.setMessages(newState)

      } catch (e) {
        console.error('*** ERROR ***', e)
      }
    },
    async processRevokeAccess(userId) {
      try {
        if (!userId) {
          return
        }

        const newState = this.messages?.filter(n => n.userId !== userId)
        this.setMessages(newState)

      } catch (e) {
        console.error('*** ERROR ***', e)
      }
    },
    async fetchNotifications() {
      try {
        const { data } = await getRequest(`/notifications/`)
        this.setNotifications(data ?? [])
      } catch (e) {
        console.error('*** ERROR ***', e)
      }
    },
    async markAsRead(notificationIds) {
      try {
        if (!notificationIds?.length) {
          return
        }

        const newState = this.notifications?.filter(n => !notificationIds.includes(n.id))
        this.setNotifications(newState)

        await postRequest(`/notifications/markNotificationAsRead/`, { notificationIds })
      } catch (e) {
        console.error('*** ERROR ***', e)
      }
    },
    async handleStreamEvent(message) {
      if (message?.topic) {
        this.addMessage(message)

        //only trigger a notification refresh on this topic
        if (message?.topic === 'sms_reply'){
          debounce(this.fetchNotifications, 500)
        }
      }
    }
  }
})