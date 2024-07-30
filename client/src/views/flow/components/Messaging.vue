<template>
  <div class="height-one-hunned">
    <v-row
      id="project-tabs"
      class="message-container"
      justify="center"
      no-gutters
    >
      <div v-if="messageList.length <= 0" class="pt-4">No messages to show</div>
      <!-- MESSAGING TAB -->
      <template>
        <beautiful-chat
          class="chat-container"
          :participants="participants"
          :onMessageWasSent="onMessageWasSent"
          :messageList="messageList"
          :newMessagesCount="newMessagesCount"
          :isOpen="true"
          :close="closeChat"
          :open="openChat"
          :showEmoji="true"
          :showFile="true"
          :showEdition="false"
          :showDeletion="false"
          :showCloseButton="false"
          :showLauncher="false"
          :showHeader="false"
          :colors="colors"
          :alwaysScrollToBottom="true"
          :messageStyling="messageStyling"
        />
      </template>
      <template #user-avatar="{ message, user }">
        <div
          class="message-avatar"
          v-if="message.type === 'text' && user && user.name"
        >
          {{ user.name.toUpperCase()[0] }}
        </div>
      </template>
    </v-row>

    <v-menu
      top
      left
      offset-y
      :close-on-content-click="false"
      v-model="showTemplateDialog"
    >
      <template #activator="{ on: menu }">
        <v-tooltip bottom small>
          <template #activator="{ on: tooltip, attrs }">
            <a-btn
                v-if="!hideTemplateBtn"
              icon
              color="primary"
              v-bind="attrs"
              :activation-handler="{ ...tooltip, ...menu }"
              class="templateButton"
              html-style="display: none"
              small
              prepend-icon="article"
            ></a-btn>
          </template>
          <span class="albatross-body-3">Templates</span>
        </v-tooltip>
      </template>
      <v-card class="template-dialog" width="295px">
        <v-card-title>
          <span class="albatross-header-4-new">Add Template</span>
        </v-card-title>
        <v-card-text>
          <a-select
            label="Template"
            custom-classes="template-selector pt-1"
            v-model="selectedTemplate"
            :items="selectableTemplates"
            item-title="title"
            item-value="id"
            return-object
            @change="sendTemplateMessage"
          >
            <template #item="{ item }">
              <!-- HTML that describes how select should render items when the select is open -->
              <div class="ellipse">
                <h4 class="template-title">{{ item.title }}<br /></h4>
                <span class="template-message">{{ item.message }}</span>
              </div>
            </template>
          </a-select>
        </v-card-text>
      </v-card>
    </v-menu>
  </div>
</template>

<script setup>
import moment from 'moment'
import debounce from 'lodash.debounce'

import { getRequest, postRequest, putRequest } from '@/helpers/helpers'
import { useNotificationStore } from '@/stores/NotificationStore.js'
import {
  computed,
  getCurrentInstance,
  onMounted,
  ref,
  toRefs,
  watch
} from 'vue'
import { useUserStore } from '@/stores/UserStore.js'
import { useRoute } from 'vue-router/composables'
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()
const route = useRoute()
const userStore = useUserStore()
const notificationStore = useNotificationStore()
const vueInstance = getCurrentInstance().proxy
const filters = vueInstance.$filters

const props = defineProps({
  userAssigned: Boolean,
  userIdIn: Number,
  teamsAssociatedToUser: Array,
  hideTemplateBtn: {
    type: Boolean,
    default: false
  }
})
const { userAssigned, userIdIn, teamsAssociatedToUser } = toRefs(props)

onMounted(() => {
  if (projectId.value) {
    fetchProjectData()
  } else if (userId.value) {
    fetchUserData()
  }
  toggleChatBox()
})

const participants = ref([])
// the list of the messages to show, can be paginated and adjusted dynamically
const messageList = ref([])
const newMessagesCount = ref(0)
// to determine whether the chat window should be open or closed
const isChatOpen = ref(false)
// specifies the color scheme for the component
const colors = ref({
  header: {
    bg: '#4e8cff',
    text: '#ffffff'
  },
  launcher: {
    bg: '#4e8cff'
  },
  messageList: {
    bg: '#ffffff'
  },
  sentMessage: {
    bg: 'var(--v-primary-lighten9)',
    text: 'var(--v-neutrals-base)'
  },
  receivedMessage: {
    bg: 'var(--v-grey-lighten3)',
    text: 'rgba(0,0,0,0.87)'
  },
  userInput: {
    bg: 'var(--v-grey-lighten4)',
    text: 'rgba(0,0,0,0.87)',
    button: '#1F3C73'
  }
})

// when set to true always scrolls the chat to the bottom when new events are in (new message, user starts typing...)
const alwaysScrollToBottom = ref(true)
const messageStyling = ref(false)
const selectedUserId = ref(-1)
const contactId = ref(null)
const id = ref(null)
const showTemplateDialog = ref(false)
const sendingMessage = ref(false)
const selectedTemplate = ref('')
const selectableTemplates = ref([])
const templateTeams = ref([])

const currentUserFullName = computed(() => {
  return userStore.details.fullName
})

const smsOwnershipEvents = computed(() => {
  return notificationStore.getEventsByTopic('sms_ownership').length
})

const projectId = computed(() => {
  return parseInt(route.params.projectId)
})

const userId = computed(() => {
  return userIdIn.value ? userIdIn.value : parseInt(route.params.userId)
})

watch([projectId, userId], async () => {
  if (projectId.value) {
    await fetchProjectData()
  }
})

watch(teamsAssociatedToUser, async (value, oldValue, onCleanup) => {
  templateTeams.value = []
  if (teamsAssociatedToUser.value.length > 0) {
    for (let team of teamsAssociatedToUser.value) {
      templateTeams.value.push(team.id)
    }
  }
  await getTemplates()
})

watch(
  userAssigned,
  debounce(() => {
    toggleChatBox()
  }, 500)
)

watch(
  smsOwnershipEvents,
  debounce(async () => {
    await fetchSmsData()
  }, 800)
)

const toggleChatBox = () => {
  const chatBox = document.querySelector('.sc-user-input')
  if (chatBox) {
    // Hide the chat box if the User is not an owner
    if (!userAssigned.value) {
      chatBox.classList.add('hide-chat')
    } else {
      chatBox.classList.remove('hide-chat')
      // Used to keep cursor in chat box when a refresh happens from an ownership change event
      chatBox.focus()
    }
  }
}
const sendMessage = (text) => {
  if (text.length > 0) {
    newMessagesCount.value = isChatOpen.value
      ? newMessagesCount.value
      : newMessagesCount.value + 1
    onMessageWasSent({ author: 'me', type: 'text', data: { text } })
  }
}

const onMessageWasSent = async (message) => {
  if (message.data.text && message.data.text.length > 1599) {
    const textOverflowLength = message.data.text.length - 1599
    appStore.showSnack(
      'ERROR',
      'Message exceeds the 1600 character limit by ' +
        textOverflowLength +
        ' characters. '
    )
    sendingMessage.value = false
  } else if (!sendingMessage.value) {
    sendingMessage.value = true
    // called when the user sends a message
    let params
    const userIds = projectId.value ? [contactId.value] : [userId.value]
    const attachmentUrl = projectId.value
      ? `/project/${projectId.value}/attachment`
      : `/user/${userId.value}/attachment`
    const sendTextUrl = projectId.value
      ? `/communication/sendTextsForProject/${projectId.value}`
      : `/communication/sendTextsForUser/${userId.value}`
    const lastSentUrl = projectId.value
      ? `/messaging/setLastSent/project/` + projectId.value
      : `/messaging/setLastSent/user/` + userId.value
    const createNotificationUrl = projectId.value
      ? `/messaging/createNotification/project/${projectId.value}`
      : `/messaging/createNotification/user/${userId.value}`

    try {
      if (message.type === 'file') {
        let mediaUrls = []
        let formData = new FormData()
        formData.append('file', message.data.file)
        formData.append('attachmentTypeId', 3)

        if (!projectId.value) {
          formData.append(
            'displayName',
            message.data.file.name.substr(
              0,
              message.data.file.name.lastIndexOf('.')
            )
          )
        }

        const resp = await postRequest(attachmentUrl, formData)
        const { status } = resp

        if (status === 200) {
          mediaUrls.push(resp.data.url)
        }

        params = {
          userIDs: userIds,
          message: message.data.file.name,
          mediaURLs: mediaUrls,
          smsTeamId: teamsAssociatedToUser.value[0].id
        }
        await postRequest(sendTextUrl, params)
      }

      if (message.data.text) {
        params = {
          userIDs: userIds,
          message: message.data.text,
          smsTeamId: teamsAssociatedToUser.value[0].id
        }
        await postRequest(sendTextUrl, params)
      }

      await putRequest(lastSentUrl)
      await postRequest(createNotificationUrl)

      //dont add to the ui unless the message goes thru successfully
      message.data.meta =
        currentUserFullName.value + ' ' + moment().format('M/D/YYYY h:mm a')
      messageList.value = [...messageList.value, message]
      newMessagesCount.value = isChatOpen.value
        ? newMessagesCount.value
        : newMessagesCount.value + 1
    } catch (e) {
      console.error('*** ERROR ***', e)
      const message = e?.message
        ? 'Error Sending Message: ' + e.message
        : e?.data?.message
        ? 'Error Sending Message: ' + e.data.message
        : 'Error Sending Message'
      appStore.showSnack('ERROR', message)

      const textInput = document.querySelector('.sc-user-input--text')
      // This line fails, but accomplishes what I want - stops the plugin from clearing the message box
      // when there's an error sending a message
      textInput.innerHTML = message.data.text
    } finally {
      sendingMessage.value = false
    }
  }
}

const openChat = () => {
  // called when the user clicks on the fab button to open the chat
  isChatOpen.value = true
  newMessagesCount.value = 0
}

const closeChat = () => {
  // called when the user clicks on the button to close the chat
  isChatOpen.value = false
}
const fetchContact = async () => {
  try {
    const { data } = await getRequest(`/contact/project/${projectId.value}`)
    contactId.value = data.id
    participants.value = [
      {
        id: id.value,
        name: data.fullName,
        phone: data.phone
      }
    ]
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error fetching SMS users')
  }
}
const fetchSmsData = async () => {
  try {
    let fetchSmsDataUrl = ''
    if (projectId.value) {
      fetchSmsDataUrl = `/sms/messages/project/${projectId.value}`
    } else if (userId.value) {
      fetchSmsDataUrl = `/sms/messages/user/${userId.value}`
    } else {
      return
    }

    const { data = [] } = await getRequest(fetchSmsDataUrl, null, [])

    messageList.value = data.map((u) => {
      let msgFrom = 'me'
      if (
        u.fromPhone != null &&
        u.fromPhone !== '+18014480212' &&
        u.fromPhone !== '+18014480029'
      ) {
        msgFrom = u.contactId
      }

      if (u.mediaUrls.length > 0) {
        return {
          type: 'file',
          author: msgFrom,
          data: {
            file: {
              name: u.message,
              url: u.mediaUrls[0],
              meta: u.fullName
                ? u.fullName + ' ' + filters.formatDate(u.created, 'timestamp')
                : filters.formatDate(u.created, 'timestamp')
            }
          }
        }
      }
      return {
        type: 'text',
        author: msgFrom,
        data: {
          text: u.message,
          meta: u.fullName
            ? u.fullName + ' ' + filters.formatDate(u.created, 'timestamp')
            : filters.formatDate(u.created, 'timestamp')
        }
      }
    })

    // Replace the emoji icon with the Template button
    const emojiIcon = document.querySelector(
      '.sc-user-input--emoji-icon-wrapper'
    )
    const templateIcon = document.querySelector('.templateButton')
    if (templateIcon) {
      templateIcon.classList.add('template-button-display')
      if (emojiIcon != null) {
        emojiIcon.replaceWith(templateIcon)
      }
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error fetching messages')
  }
}
const getTemplates = async () => {
  try {
    selectedTemplate.value = ''
    if (!templateTeams.value || templateTeams.value.length < 1) {
      return
    }
    const { data } = await getRequest(
      `/messaging/templates/${templateTeams.value}`
    )
    selectableTemplates.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error retrieving templates')
  }
}
const sendTemplateMessage = async () => {
  const textInput = document.querySelector('.sc-user-input--text')
  textInput.innerHTML += selectedTemplate.value.message
  //clear out all the selections for the next time the template selector is opened
  selectedTemplate.value = undefined
  if (teamsAssociatedToUser.value?.length !== 1) {
    selectableTemplates.value = []
    templateTeams.value = []
  }
  showTemplateDialog.value = false
}
const fetchProjectData = async () => {
  await fetchContact()
  await fetchSmsData()
  templateTeams.value = []
  if (teamsAssociatedToUser.value?.length > 0) {
    for (let team of teamsAssociatedToUser.value) {
      templateTeams.value.push(team.id)
    }
  }
  // await getTemplates()
}
const fetchUserData = async () => {
  await fetchSmsData()
  templateTeams.value = []
  if (teamsAssociatedToUser.value?.length > 0) {
    for (let team of teamsAssociatedToUser.value) {
      templateTeams.value.push(team.id)
    }
  }
  // await getTemplates()
}
</script>

<style lang="scss">
.hide-chat {
  display: none !important;
}

a.chatLink {
  color: white;
}

.message-container {
  height: 90%;
  margin-top: 5px;
  @media (min-width: 960px) {
    min-height: 400px;
  }
}

.sc-message {
  padding-bottom: 1rem;
}

.sc-message-list {
  padding-left: 1.5rem !important;
  padding-right: 1.5rem !important;
  height: 100% !important;
}

.sc-message--content.sent .sc-message--meta {
  text-align: right;
}

.sc-message--content.received .sc-message--meta {
  text-align: left;
}

.sc-message--meta,
.sc-message--text-content {
  margin-bottom: 5px !important;
  font-family: 'Lato', sans-serif;
}

.sc-message--text-content {
  font-size: 0.875rem;
}

//this makes new lines show up when the user does shift + enter
.sc-message--text,
.sc-message--file-text {
  white-space: pre-wrap;
}

.sc-chat-window {
  position: unset !important;
  max-width: 100%;
  width: 100% !important;
  height: 100% !important;
  max-height: unset !important;
  text-align: left !important;
  border-radius: 0 !important;
  box-shadow: none !important;
}

.sc-user-input--text {
  width: 79%;
  font-family: 'Lato', sans-serif;
  font-size: 1rem;
  border-bottom-left-radius: 0 !important;
}

.sc-user-input--buttons {
  width: 21%;
  justify-content: space-between;
  align-items: center;
}

@media (max-width: 960px) {
  #project-tabs {
    height: 100%;
  }
}

#project-tabs
  > div
  > div
  > div:nth-child(2)
  > form
  > div.sc-user-input--buttons
  > div:nth-child(3)
  > div {
  left: 40% !important;
}
#project-tabs {
  div.sc-user-input--buttons > div.sc-user-input--button {
    padding-right: 8px;
  }
}

.sc-user-input {
  border-bottom-left-radius: 0 !important;
  border-bottom-right-radius: 0 !important;
  justify-content: space-between;
}

.chat-container {
  width: 100%;
  height: 100%;
}

.sc-message {
  width: 100%;

  a.chatLink {
    color: black;
  }
}

.sc-message--avatar {
  display: none;
}

.template-button-display {
  margin-bottom: 8px;
  background-color: transparent !important;
  display: inline-block !important;
}

.template-dialog {
  max-width: 500px;
}

.template-title {
  font-size: 14px;
}

.template-message {
  font-size: 12px;
  color: #808588;
}

.ellipse {
  white-space: nowrap;
  display: inline-block;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 450px;
}
</style>
