import debounce from 'lodash.debounce'
import { getRequest, postRequest } from '@/helpers/helpers'

export const NotificationActions = {
  FETCH_NOTIFICATIONS: 'notifications::fetch',
  MARK_AS_READ: 'notifications::markAsRead',
  HANDLE_STREAM_EVENT: 'notifications::handleStreamEvent',
  PROCESS_PROJECT_MSG: 'notifications::processProjectMsg'
}

export default {
  state: () => ({
    // data from the /notifications endpoint
    notifications: [],

    // data from /notifications/stream endpoint
    messages: []
  }),
  getters: {
    getAllNotifications: (state) => state.notifications,
    getNotificationsByTopic: (state) => (topic) => {
      return state.notifications?.filter(n => n.topic === topic) ?? []
    },
    getEventsByTopic: (state) => (topic) => {
      return state.messages?.filter(n => n.topic === topic) ?? []
    }
  },
  actions: {
    _debouncedFetchNotifications: debounce(({ dispatch }) => {
      dispatch(NotificationActions.FETCH_NOTIFICATIONS)
    }, 500),
    [NotificationActions.PROCESS_PROJECT_MSG]: async ({ state, commit }, projectId) => {
      try {
        if (!projectId) {
          return
        }

        const newState = state.messages?.filter(n => n.projectId !== projectId)
        commit('setMessages', newState)

      } catch (e) {
        console.error('*** ERROR ***', e)
      }
    },
    [NotificationActions.FETCH_NOTIFICATIONS]: async ({ commit }) => {
      try {
        const { data } = await getRequest(`/notifications/`)
        commit('setNotifications', data ?? [])
      } catch (e) {
        console.error('*** ERROR ***', e)
      }
    },
    [NotificationActions.MARK_AS_READ]: async ({ state, commit }, notificationIds) => {
      try {

        if (!notificationIds?.length) {
          return
        }

        const newState = state.notifications?.filter(n => !notificationIds.includes(n.id))
        commit('setNotifications', newState)

        await postRequest(`/notifications/markNotificationAsRead/`, { notificationIds })

      } catch (e) {
        console.error('*** ERROR ***', e)
      }
    },
    [NotificationActions.HANDLE_STREAM_EVENT]: async ({ dispatch, commit }, message) => {
      if (message?.topic) {
        commit('addMessage', message)

        //only trigger a notification refresh on this topic
        if (message?.topic === 'sms_reply'){
          dispatch('_debouncedFetchNotifications')
        }
      }
    }
  },
  mutations: {
    setNotifications(state, notifications) {
      state.notifications = notifications
    },
    setMessages(state, messages) {
      state.messages = messages
    },
    addMessage(state, message) {
      state.messages.push(message)
    }
  }
}
