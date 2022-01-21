<template>
  <div class="height-one-hunned">
    <v-toolbar color="white" class="elevation-0">
      <v-toolbar-title>
        Project Communication
      </v-toolbar-title>
    </v-toolbar>

    <v-row id="project-tabs" class="message-container" justify="center" no-gutters>
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
            :showEmoji="false"
            :showFile="true"
            :showEdition="false"
            :showDeletion="false"
            :showCloseButton="false"
            :showLauncher="false"
            :showHeader="false"
            :colors="colors"
            :alwaysScrollToBottom="true"
            :messageStyling="messageStyling"/>
      </template>
      <template v-slot:user-avatar="{ message, user }">
        <div class="message-avatar" v-if="message.type === 'text' && user && user.name">
          {{ user.name.toUpperCase()[0] }}
        </div>
      </template>
    </v-row>


  </div>
</template>

<script>
import {getRequest, getSnackbar, postRequest} from '@/helpers/helpers'
import {AppMutations} from "@/stores/AppStore"
import moment from 'moment'
export default {
  name: 'Messaging',
  props: {},
  created() {
    this.fetchContact()
    this.fetchSmsData()
  },

  data() {
    return {
      snackbar: {},
      currentUserFullName: this.$store.state.user.details.fullName,
      projectId: parseInt(this.$route.params.projectId),
      participants: [],
      messageList: [], // the list of the messages to show, can be paginated and adjusted dynamically
      newMessagesCount: 0,
      isChatOpen: false, // to determine whether the chat window should be open or closed
      colors: {
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
          bg: '#4e8cff',
          text: '#ffffff'
        },
        receivedMessage: {
          bg: '#eaeaea',
          text: '#222222'
        },
        userInput: {
          bg: '#f4f7f9',
          text: '#565867'
        }
      }, // specifies the color scheme for the component
      alwaysScrollToBottom: true, // when set to true always scrolls the chat to the bottom when new events are in (new message, user starts typing...)
      messageStyling: true,
      selectedUserId: -1
    }
  },
  methods: {
    sendMessage(text) {
      if (text.length > 0) {
        this.newMessagesCount = this.isChatOpen ? this.newMessagesCount : this.newMessagesCount + 1
        this.onMessageWasSent({author: 'me', type: 'text', data: {text}})
      }
    },
    async onMessageWasSent(message) {
      // called when the user sends a message
      let params;
      try {
        if (message.type === 'file') {
          let mediaUrls = []
          let formData = new FormData()
          formData.append('file', message.data.file)
          formData.append('attachmentTypeId', 3)

          const resp = await postRequest(`/project/${this.projectId}/attachment`, formData)
          const {status} = resp

          if (status === 200) {
            mediaUrls.push(resp.data.url)
          }

          params = {
            userIDs: [this.contactId],
            message: message.data.file.name,
            mediaURLs: mediaUrls
          }
        } else {
          params = {
            userIDs: [this.contactId],
            message: message.data.text
          }
        }

        await postRequest(`/communication/sendTextsForProject`, params)

        //dont add to the ui unless the message goes thru successfully
        message.data.meta = this.currentUserFullName + ' ' + moment().format('M/D/YYYY h:mm a')
        this.messageList = [...this.messageList, message]
        this.newMessagesCount = this.isChatOpen ? this.newMessagesCount : this.newMessagesCount + 1
      } catch (e) {
        console.error('*** ERROR ***', e)
        let message = e?.message ? 'Error Sending Message: ' + e.message : 'Error Sending Message'
        this.snackbar = getSnackbar('ERROR', message)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    openChat() {
      // called when the user clicks on the fab button to open the chat
      this.isChatOpen = true
      this.newMessagesCount = 0
    },
    closeChat() {
      // called when the user clicks on the button to close the chat
      this.isChatOpen = false
    },
    async fetchContact() {
      try {
        const {data} = await getRequest(`/contact/project/${this.projectId}`)
        this.contactId = data.id;
        let user = [{
          id: this.id,
          name: data.fullName,
          phone: data.phone
        }]

        this.participants = user
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching SMS users')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async fetchSmsData() {
      try {
        let messages = []
        const {data} = await getRequest(`/sms/messages/${this.projectId}`, null, [])

        data.forEach(u => {
          let msgFrom = '';
          if (u.fromPhone != null && u.fromPhone !== '+18014480212') {
            msgFrom = u.contactId;
          } else {
            msgFrom = 'me';
          }

          let msg;
          if (u.mediaUrls.length > 0) {
            msg = {
              type: 'file',
              author: msgFrom,
              data: {
                file: {
                  name: u.message,
                  url: u.mediaUrls[0],
                  meta: u.full_name ? u.full_name + ' ' + this.$filters.formatDate(u.created, 'timestamp') : this.$filters.formatDate(u.created, 'timestamp')
                }
              }
            }
          } else {
            msg = {
              type: 'text',
              author: msgFrom,
              data: {
                text: u.message,
                meta: u.full_name ? u.full_name + ' ' + this.$filters.formatDate(u.created, 'timestamp') : this.$filters.formatDate(u.created, 'timestamp')
              }
            }
          }

          messages.push(msg);
        })

        this.messageList = messages
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching messages')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    }
  }
}
</script>

<style lang="scss">
.message-container {
  min-height: 400px;
  height: calc(100% - 65px);
  margin-top: 5px;
}

.sc-message-list {
  padding-left: 10px !important;
  padding-right: 10px !important;
  height: 100% !important;
}

.sc-message--content.sent .sc-message--meta {
  text-align: right;
}

.sc-message--content.received .sc-message--meta {
  text-align: left;
}

.sc-message--meta, .sc-message--text-content {
  margin-bottom: 5px !important;
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
  width: calc(100% - 100px);
}

.sc-user-input {
  border-bottom-left-radius: 0 !important;
  border-bottom-right-radius: 0 !important;
}

.sc-user-input--text {
  border-bottom-left-radius: 0 !important;
}

.chat-container {
  width:100%;
  height: 100%;
}

.sc-message{
  width:100%;
}

.sc-message--avatar{
  display: none;
}
</style>
