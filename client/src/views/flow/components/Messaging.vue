<template>
  <div class="height-one-hunned">
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
          :showEmoji="true"
          :showFile="true"
          :showEdition="false"
          :showDeletion="false"
          :showCloseButton="false"
          :showLauncher="false"
          :showHeader="false"
          :colors="colors"
          :alwaysScrollToBottom="true"
          :messageStyling="messageStyling" />
      </template>
      <template v-slot:user-avatar="{ message, user }">
        <div class="message-avatar" v-if="message.type === 'text' && user && user.name">
          {{ user.name.toUpperCase()[0] }}
        </div>
      </template>
    </v-row>

    <v-btn icon color="primary" class="templateButton " style="display: none" small>
      <v-tooltip bottom small>
        <template v-slot:activator="{on, attrs}">
          <v-icon @click="" v-bind="attrs" v-on="on">
            article
          </v-icon>
        </template>
        <span class="albatross-body-3">Templates</span>
      </v-tooltip>
    </v-btn>

    <v-menu top left offset-y activator=".templateButton" :close-on-content-click="false" v-model="showTemplateDialog">
      <v-card class="template-dialog" width="295px">
        <v-card-title>
          <span class="albatross-header-4-new">Add Template</span>
        </v-card-title>
        <v-card-text>
          <v-select label="Template"
                    class="template-selector pt-1"
                    v-model="selectedTemplate"
                    :items="selectableTemplates"
                    item-text="title"
                    item-value="id"
                    return-object
                    @change="sendTemplateMessage">

            <template slot="item" slot-scope="data">
              <!-- HTML that describes how select should render items when the select is open -->
              <div class="ellipse">
                <h4 class="template-title">{{ data.item.title }}<br /></h4>
                <span class="template-message">{{ data.item.message }}</span>
              </div>
            </template>
          </v-select>
        </v-card-text>
      </v-card>
    </v-menu>
  </div>
</template>

<script>
import debounce from 'lodash.debounce'
import { getRequest, getSnackbar, postRequest, putRequest } from '@/helpers/helpers'
import { AppMutations } from '@/stores/AppStore'
import moment from 'moment'

export default {
  name: 'Messaging',
  created() {
    if (this.projectId) {
      this.fetchProjectData()
    }
    else if (this.userId) {
      this.fetchUserData()
    }
    this.fetchSmsData()
  },
  mounted() {
    this.toggleChatBox();
  },
  props: {
    userAssigned: Boolean,
    userIdIn: Number,
    teamsAssociatedToUser: Array
  },
  data() {
    return {
      snackbar: {},
      currentUserFullName: this.$store.state.user.details.fullName,
      projectId: parseInt(this.$route.params.projectId),
      userId: this.userIdIn ? this.userIdIn : parseInt(this.$route.params.userId) || null,
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
          bg: 'var(--v-primary-lighten3)',
          text: '#ffffff'
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
      }, // specifies the color scheme for the component
      icons: {
        emoji: {
          img: 'article'

        }
      },
      alwaysScrollToBottom: true, // when set to true always scrolls the chat to the bottom when new events are in (new message, user starts typing...)
      messageStyling: false,
      selectedUserId: -1,
      showTemplateDialog: false,
      selectedTemplate: '',
      selectableTemplates: [],
      templateTeams: []
    }
  },
  computed: {
    smsOwnershipEvents() {
      return this.$store.getters.getEventsByTopic('sms_ownership').length
    }
  },
  watch: {
    // whenever userImage changes, this function will run
    '$route.params.projectId': async function() {
      this.projectId = parseInt(this.$route.params.projectId) | null
      await this.fetchProjectData()
    },
    '$route.params.userId': async function() {
      this.userId = parseInt(this.$route.params.userId) | null
      await this.fetchUserData()
    },
    'teamsAssociatedToUser': async function() {
      this.templateTeams = []
      if (this.teamsAssociatedToUser.length > 0) {
        for (let team of this.teamsAssociatedToUser) {
          this.templateTeams.push(team.id);
        }
      }
      await this.getTemplates()
    },
    userAssigned: debounce(function() {
      this.toggleChatBox()
    }, 500),
    smsOwnershipEvents: debounce(async function() {
      await this.fetchSmsData()
    }, 800)
  },
  methods: {
    toggleChatBox() {
      let chatBox = document.querySelector('.sc-user-input')
      if (chatBox) {
        // Hide the chat box if the User is not an owner
        if (!this.userAssigned) {
          chatBox.classList.add('hide-chat')
        } else {
          chatBox.classList.remove('hide-chat')
          // Used to keep cursor in chat box when a refresh happens from an ownership change event
          chatBox.focus()
        }
      }
    },
    sendMessage(text) {
      if (text.length > 0) {
        this.newMessagesCount = this.isChatOpen ? this.newMessagesCount : this.newMessagesCount + 1
        this.onMessageWasSent({ author: 'me', type: 'text', data: { text } })
      }
    },
    async onMessageWasSent(message) {
      if (message.data.text && message.data.text.length > 1599) {
        let textOverflowLength = message.data.text.length - 1599;
        this.snackbar = getSnackbar('ERROR', 'Message exceeds the 1600 character limit by ' + textOverflowLength + ' characters. ')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        return
      }
      // called when the user sends a message
      let params
      let userIds = this.projectId ? [this.contactId] : [this.userId]
      let attachmentUrl = this.projectId ? `/project/${this.projectId}/attachment` : `/user/${this.userId}/attachment`
      let sendTextUrl = this.projectId ? `/communication/sendTextsForProject/${this.projectId}` : `/communication/sendTextsForUser/${this.userId}`
      let lastSentUrl = this.projectId ? `/messaging/setLastSent/project/` + this.projectId : `/messaging/setLastSent/user/` + this.userId
      let createNotificationUrl = this.projectId ? `/messaging/createNotification/project/${this.projectId}` : `/messaging/createNotification/user/${this.userId}`

      try {
        if (message.type === 'file') {
          let mediaUrls = []
          let formData = new FormData()
          formData.append('file', message.data.file)
          formData.append('attachmentTypeId', 3)

          if (!this.projectId) {
            formData.append('displayName', message.data.file.name.substr(0, message.data.file.name.lastIndexOf('.')))
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
            smsTeamId: this.teamsAssociatedToUser[0].id
          }
          await postRequest(sendTextUrl, params)
        }

        if (message.data.text) {
          params = {
            userIDs: userIds,
            message: message.data.text,
            smsTeamId: this.teamsAssociatedToUser[0].id
          }
          await postRequest(sendTextUrl, params)
        }

        await putRequest(lastSentUrl)
        await postRequest(createNotificationUrl)

        //dont add to the ui unless the message goes thru successfully
        message.data.meta = this.currentUserFullName + ' ' + moment().format('M/D/YYYY h:mm a')
        this.messageList = [...this.messageList, message]
        this.newMessagesCount = this.isChatOpen ? this.newMessagesCount : this.newMessagesCount + 1
      } catch (e) {
        console.error('*** ERROR ***', e)
        let message = e?.message ? 'Error Sending Message: ' + e.message :
          e?.data?.message ? 'Error Sending Message: ' + e.data.message : 'Error Sending Message'
        this.snackbar = getSnackbar('ERROR', message)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        let textInput = document.querySelector('.sc-user-input--text')
        // This line fails, but accomplishes what I want - stops the plugin from clearing the message box
        // when there's an error sending a message
        textInput.innerHTML = message.data.text
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
        const { data } = await getRequest(`/contact/project/${this.projectId}`)
        this.contactId = data.id
        this.participants = [{
          id: this.id,
          name: data.fullName,
          phone: data.phone
        }]
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching SMS users')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async fetchSmsData() {
      try {
        let fetchSmsDataUrl = ''
        if (this.projectId) {
          fetchSmsDataUrl = `/sms/messages/project/${this.projectId}`
        }
        else if (this.userId) {
          fetchSmsDataUrl = `/sms/messages/user/${this.userId}`
        }
        else {
          return;
        }

        const { data } = await getRequest(fetchSmsDataUrl, null, [])

        let messages = []
        data.forEach(u => {
          let msgFrom = 'me'
          if (u.fromPhone != null && u.fromPhone !== '+18014480212' && u.fromPhone !== '+18014480029') {
            msgFrom = u.contactId
          }

          let msg
          if (u.mediaUrls.length > 0) {
            msg = {
              type: 'file',
              author: msgFrom,
              data: {
                file: {
                  name: u.message,
                  url: u.mediaUrls[0],
                  meta: u.fullName ? u.fullName + ' ' + this.$filters.formatDate(u.created, 'timestamp') : this.$filters.formatDate(u.created, 'timestamp')
                }
              }
            }
          } else {
            msg = {
              type: 'text',
              author: msgFrom,
              data: {
                text: u.message,
                meta: u.fullName ? u.fullName + ' ' + this.$filters.formatDate(u.created, 'timestamp') : this.$filters.formatDate(u.created, 'timestamp')
              }
            }
          }

          messages.push(msg)
        })

        this.messageList = messages

        // Replace the emoji icon with the Template button
        let emojiIcon = document.querySelector('.sc-user-input--emoji-icon-wrapper')
        let templateIcon = document.querySelector('.templateButton')
        if (templateIcon) {
          templateIcon.classList.add('template-button-display')
          if (emojiIcon != null) {
            emojiIcon.replaceWith(templateIcon)
          }
        }
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching messages')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getTemplates() {
      try {
        this.selectedTemplate = ''
        if (!this.templateTeams || this.templateTeams.length < 1) {
          return
        }
        const { data } = await getRequest(`/messaging/templates/` + this.templateTeams)
        this.selectableTemplates = data
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving templates')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async sendTemplateMessage() {
      let textInput = document.querySelector('.sc-user-input--text')
      textInput.innerHTML += this.selectedTemplate.message
      //clear out all the selections for the next time the template selector is opened
      this.selectedTemplate = undefined
      if (this.teamsAssociatedToUser.length !== 1) {
        this.selectableTemplates = []
        this.templateTeams = []
      }
      this.showTemplateDialog = false
    },
    async fetchProjectData() {
      await this.fetchContact()
      await this.fetchSmsData()
      this.templateTeams = []
      if (this.teamsAssociatedToUser?.length > 0) {
        for (let team of this.teamsAssociatedToUser) {
          this.templateTeams.push(team.id);
        }
      }
      await this.getTemplates()
    },
    async fetchUserData() {
      await this.fetchSmsData()
      this.templateTeams = []
      if (this.teamsAssociatedToUser?.length > 0) {
        for (let team of this.teamsAssociatedToUser) {
          this.templateTeams.push(team.id);
        }
      }
      await this.getTemplates()
    }
  }
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

.sc-message--meta, .sc-message--text-content {
  margin-bottom: 5px !important;
  font-family: 'Lato', sans-serif;

}

.sc-message--text-content {
  font-size: 0.875rem;
}

//this makes new lines show up when the user does shift + enter
.sc-message--text, .sc-message--file-text { white-space: pre-wrap; }

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
  #project-tabs{
    height: 100%;
  }
}

#project-tabs > div > div > div:nth-child(2) > form > div.sc-user-input--buttons > div:nth-child(3) > div {
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
