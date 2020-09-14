<template>
  <div>
    <v-toolbar color="transparent" class="elevation-0">
      <v-toolbar-title>
        Messaging
      </v-toolbar-title>
    </v-toolbar>

    <v-row id="project-tabs" class="mb-2" justify="center" no-gutters>
        <!-- MESSAGING TAB -->
        <template>
            <beautiful-chat
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
                :colors="colors"
                :alwaysScrollToBottom="true"
                :messageStyling="messageStyling"/>
        </template>
        <template v-slot:user-avatar="{ message, user }">
            <div style="border-radius:50%; color: pink; font-size: 15px; line-height:25px; text-align:center;background: tomato; width: 25px !important; height: 25px !important; min-width: 30px;min-height: 30px;margin: 5px; font-weight:bold" v-if="message.type === 'text' && user && user.name">
                {{user.name.toUpperCase()[0]}}
            </div>
        </template>
    </v-row>

    <Snackbar :snackbar="snackbar"></Snackbar>
  </div>
</template>

<script>
import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
import Snackbar from '@/components/Snackbar.vue'
import $ from "jquery";

export default {
  name: 'Messaging',
  props: {
  },
  created () {
      this.fetchContact()
      this.fetchSmsData()
    },
  components: {
    Snackbar
  },
  data () {
    return {
      snackbar: {},
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
      sendMessage (text) {
          if (text.length > 0) {
              this.newMessagesCount = this.isChatOpen ? this.newMessagesCount : this.newMessagesCount + 1
              this.onMessageWasSent({ author: 'me', type: 'text', data: { text } })
          }
      },
      async onMessageWasSent (message) {
          // called when the user sends a message
          this.messageList = [ ...this.messageList, message ]
          this.newMessagesCount = this.isChatOpen ? this.newMessagesCount : this.newMessagesCount + 1

          let params;
          try {
              if (message.type == 'file') {
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
              }
              else {
                  params = {
                      userIDs: [this.contactId],
                      message: message.data.text
                  }
              }

              await postRequest(`/communication/sendTextsForProject`, params)
          } catch (e) {
              console.error('*** ERROR ***', e)
              this.snackbar = getSnackbar('ERROR', 'Error sending message')
          }
      },
      openChat () {
          // called when the user clicks on the fab button to open the chat
          this.isChatOpen = true
          this.newMessagesCount = 0
      },
      closeChat () {
          // called when the user clicks on the button to close the chat
          this.isChatOpen = false
      },
      async fetchContact() {
          try {
              const{data} = await getRequest(`/contact/project/${this.projectId}`)
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
          }
      },
      async fetchSmsData() {
          try {
            let messages = []
            const {data} = await getRequest(`/sms/messages/${this.projectId}`)

            data.forEach(u => {
                let msgFrom = '';
                if (u.fromPhone != null && u.fromPhone != '+18014480212') {
                    msgFrom = u.contactId;
                }
                else {
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
                                url: u.mediaUrls[0]
                            }
                        }
                    }
                }
                else {
                     msg = {
                        type: 'text',
                        author: msgFrom,
                        data: {text: u.message}
                    }
                }

                messages.push(msg);
            })

            this.messageList = messages
            $(".sc-user-input").css("text-align","left")
            $(".sc-user-input").parent().parent().css("right","250px")
            $(".sc-user-input").parent().parent().css("width","400px")
          } catch (e) {
              console.error('*** ERROR ***', e)
              this.snackbar = getSnackbar('ERROR', 'Error fetching messages')
          }
      }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">

</style>
<style lang="scss">

</style>
