<template xmlns="http://www.w3.org/1999/html">
  <v-container>
    <v-dialog
        v-model="showNewMessageDialog"
        @click:outside="exitDialogue"
        width="803">
    <v-card class="pa-6">
      <v-card-title
          class="albatross-header-4-new pa-0"
          primary-title
      >
        Compose new SMS Message
      </v-card-title>
      <span class="sub-message-span">You will be assigned to the conversation automatically, unless chosen otherwise</span>
      <br>
      <div class="flex-display" v-if="isInbox">
        <label class="mt-5 mr-2">To:</label>
        <v-autocomplete
          v-model="selectedProjectId"
          :items="availableProjects"
          :search-input.sync="projectQuery"
          attach
          item-text="firstName"
          item-value="id"
          :disabled="selectedUserIds.length > 0"
          label="Enter project ID"
          class="team-select pa-0 mt-4"
        ><template #item="{item}">
          <span>
            {{item.projectName}}
          </span>
        </template>
        </v-autocomplete>
      </div>

      <div class="select-user-div mb-5">
        <label v-if="!isInbox" class="mt-5 mr-2">To:</label>
        <v-autocomplete
          v-model="selectedUserIds"
          :items="availableUsers"
          multiple
          :disabled="selectedProjectId != null && isInbox"
          item-text="name"
          item-value="userId"
          label="Select users"
          class="pa-0 mt-4 select-users"
          :class="isInbox ? 'ml-7' : ''"
          clearable
        ><template #item="{item}">
          <span>
            {{item.name}}
          </span>
        </template>
        <template
          slot="selection"
          slot-scope="{ item, index }"
        >
          <v-chip small v-if="selectedUserIds.length < 2">
            <span>{{ item.name }}</span>
          </v-chip>
          <span
            v-if="index === 1 && selectedUserIds.length >= 2"
          >{{ selectedUserIds.length }} selected</span>
        </template>
        </v-autocomplete>
        <router-link  class="open-conversation-link pt-5 pl-5"
                      :class="selectedUserIds.length > 1 ? 'disabled-open-conversation' : ''"
                      v-if="selectedUserIds.length > 0"
                      :to="`/user/${this.selectedUserIds}/details`"
                      target="_blank">
          Open conversations<v-icon>mdi-open-in-new</v-icon>
        </router-link>
      </div>

      <div class="flex-display justify-end">
        <v-textarea class="py-2 message-text-area" hide-details
                    placeholder="Enter message here"
                    auto-grow
                    outlined
                    rows="4"
                    v-model="message">
        </v-textarea>
        <v-btn icon color="primary" class="white--text mx-2 mt-1 templateButton">
          <v-tooltip bottom small>
            <template v-slot:activator="{on, attrs}">
              <v-icon @click="" v-bind="attrs" v-on="on">
                article
              </v-icon>
            </template>
            <span class="albatross-body-3">Templates</span>
          </v-tooltip>
        </v-btn>

        <v-menu top left offset-y activator=".templateButton" :close-on-content-click="false">
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
                        @change="[message = selectedTemplate.message]">

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

        <v-file-input
          dense
          hide-input
          multiple
          label="Upload file"
          @change="uploadTextAttachment"
          @click:clear="[uploadedFiles = []]"
        />
      </div>

      <v-card-actions class="pt-1 pb-0 px-0">
        <span v-if="uploadedFiles.length > 0">Attached {{attachmentsText}}</span>
        <v-spacer/>
        <v-btn
          class="text-capitalize"
          @click="[assignAndSend = false, sendMessage()]"
          text color="primary"
        >
          Send and don't assign
        </v-btn>

        <v-btn
          color="primary"
          class="text-capitalize white--text"
          :disabled="!selectedProjectId && !selectedUserIds"
          @click="[assignAndSend = true, sendMessage()]">
          Send
        </v-btn>
      </v-card-actions>
    </v-card>
    </v-dialog>
  </v-container>
</template>

<script>
import { AppMutations } from '@/stores/AppStore'
import {getRequest, getRequestWithParams, putRequest, getSnackbar, handleHidingGlobalLoader, postRequest} from '@/helpers/helpers'

export default {
  name: "NewMessageDialog",
  props: {
    showNewMessageDialog: Boolean,
    ownerUserId: Number,
    isInbox: Boolean
  },
  data () {
    return {
      selectedProjectId: null,
      availableProjects: [],
      availableUsers: [],
      uploadedFiles: [],
      message: '',
      templateTeams: [],
      selectedTemplate: '',
      selectableTemplates: [],
      selectedUserIds: [],
      projectQuery: null,
      teamsAssociatedToUser: [],
      attachmentUrl: '',
      sendTextUrl: '',
      lastSentUrl: '',
      createNotificationUrl: '',
      inboxUrl: '',
      addTeamUrl: '',
      assignAndSend: false
    }
  },
  created() {
    this.getUsers();
    this.fetchTeamsForUser()
  },
  computed: {
    attachmentsText() {
      if (this.uploadedFiles.length == 1) {
        return this.uploadedFiles[0][0].name
      }
      else if (this.uploadedFiles.length > 1) {
        return this.uploadedFiles.length + ' files'
      }
    }
  },
  watch: {
    projectQuery (val) {
      if(!val) {
        return
      }
      this.selectedUserIds = []
      if (val.length > 3) {
        this.getProjectDebounced(val)
      }
    }
  },
  methods: {
    exitDialogue(){
      this.$emit('update:showNewMessageDialog', false)
    },
    getProjectDebounced(val) {
      clearTimeout(this._searchTimerId)
      this._searchTimerId = setTimeout(() => {
        this.getProjects(val)
      }, 500) /* 500ms throttle */
    },
    sendMessage() {
      if (this.selectedProjectId) {
        this.attachmentUrl = `/project/${this.selectedProjectId}/attachment`
        this.sendTextUrl = `/communication/sendTextsForProject/${this.selectedProjectId}`
        this.lastSentUrl = `/messaging/setLastSent/project/` + this.selectedProjectId
        this.createNotificationUrl = `/messaging/createNotification/project/${this.selectedProjectId}`
        this.inboxUrl = `/inbox/inboxConversation/project/${this.selectedProjectId}`
        this.addTeamUrl = `/messaging/addTeam/project/${this.selectedProjectId}`
        if (this.assignAndSend) {
          this.sendMessageAndAssign();
        }
        else {
          if (this.onMessageWasSent()) {
            this.snackbar = getSnackbar('SUCCESS', 'Message sent')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          }
        }
      }
      else {
        // Send the message for each selected User
        for (let currentUserId of this.selectedUserIds) {
          this.attachmentUrl =  `/user/` + currentUserId + `/attachment`
          this.sendTextUrl = `/communication/sendTextsForUser/` + currentUserId
          this.lastSentUrl = `/messaging/setLastSent/user/` + currentUserId
          this.createNotificationUrl = `/messaging/createNotification/user/` + currentUserId
          this.inboxUrl = `/inbox/inboxConversation/user/` + currentUserId
          this.addTeamUrl = `/messaging/addTeam/user/` + currentUserId
          if (this.assignAndSend) {
            this.sendMessageAndAssign();
          }
          else {
            if (this.onMessageWasSent()) {
              this.snackbar = getSnackbar('SUCCESS', 'Message sent')
              this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            }
          }
        }
      }
      this.exitDialogue()
    },
    async onMessageWasSent() {
      if (this.message && this.message.length > 1599) {
        let textOverflowLength = message.data.text.length - 1599;
        this.snackbar = getSnackbar('ERROR', 'Message exceeds the 1600 character limit by ' + textOverflowLength + ' characters. ')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        return
      }

      // called when the user sends a message
      let params
      let smsTeamId = this.teamsAssociatedToUser ? this.teamsAssociatedToUser[0].id : null

      try {
        if (this.uploadedFiles && this.uploadedFiles.length > 0) {
          for (let currFile of this.uploadedFiles){
            let mediaUrls = []
            let formData = new FormData()
            formData.append('file', currFile[0])
            formData.append('attachmentTypeId', 3)

            if (this.selectedUserIds.length > 0) {
              formData.append('displayName', currFile[0].name.substr(0, currFile[0].name.lastIndexOf('.')))
            }

            const resp = await postRequest(this.attachmentUrl, formData)
            const { status } = resp

            if (status === 200) {
              mediaUrls.push(resp.data.url)
            }

            params = {
              userIDs: null,
              message: currFile[0].name,
              mediaURLs: mediaUrls,
              smsTeamId: smsTeamId
            }

            await postRequest(this.sendTextUrl, params)
          }
        }

        if (this.message) {
          params = {
            userIDs: null,
            message: this.message,
            smsTeamId: smsTeamId
          }
          await postRequest(this.sendTextUrl, params)
        }

        await putRequest(this.lastSentUrl)
        await postRequest(this.createNotificationUrl)

        this.message = '';
        this.uploadedFiles = [];
        this.selectedUserIds = [];
        this.selectedProjectId = null

        return true;
      } catch (e) {
        console.error('*** ERROR ***', e)
        let message = e?.message ? 'Error Sending Message: ' + e.message :
          e?.data?.message ? 'Error Sending Message: ' + e.data.message : 'Error Sending Message'
        this.snackbar = getSnackbar('ERROR', message)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        return false;
      }
    },
    sendMessageAndAssign: async function () {
      let smsTeamId = this.teamsAssociatedToUser ? this.teamsAssociatedToUser[0].id : null

      let params = {
        id: smsTeamId,
        users: [{
          smsTeamId: smsTeamId,
          userId: this.$store.state.user.details.id
        }]
      }

      await postRequest(this.addTeamUrl, params)

      if (await this.onMessageWasSent()) {
        this.snackbar = getSnackbar('SUCCESS', 'Message sent and conversation assigned')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        await this.$router.push({ path: this.inboxUrl })
      }
    },
    async getProjects(val) {
      if (val == null) {
        this.selectedProjectId = null
        this.availableProjects = []
        return;
      }

      try {
        const {data} = await getRequestWithParams(`/messaging/availableProjects`, {
          params: {
            query: val,
          }
        })
        this.availableProjects = data
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving projects')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getUsers() {
      try {
        const { data } = await getRequest(`/messaging/availableUsers/`)
        this.availableUsers = data

        let currentUserValues = this.availableUsers.filter(value => value.userId && value.userId === this.ownerUserId)
        if (currentUserValues.length > 0) {
          this.selectedUserIds = [this.ownerUserId]
        }
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving users and positions')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async fetchTeamsForUser() {
      try {
        this.conversationIsLoading = true
        const { data, status } = await getRequest(`/smsTeam/getTeamsForUser/`)
        this.$store.commit(AppMutations.SET_LOADING, false)
        this.teamsAssociatedToUser = data
        for (let team of this.teamsAssociatedToUser){
          this.templateTeams.push(team.id);
        }
        handleHidingGlobalLoader(this, status)
        await this.getSmsTeamTemplates();
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching SMS Teams')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.conversationIsLoading = false
      }
    },
    async getSmsTeamTemplates() {
      try {
        this.selectedTemplate = ''
        if (this.teamsAssociatedToUser.length < 1) {
          return
        }

        const { data } = await getRequest(`/messaging/templates/` + this.templateTeams)
        this.selectableTemplates = data
      } catch (e) {
        console.log('ccc')
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving templates')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    uploadTextAttachment: async function (file) {
      try {
        if (!file){
          return
        }

        this.uploadedFiles.push(file);
      } catch(e) {
        this.$store.commit(AppMutations.SET_LOADING, false)
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Uploading File')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
  }
}
</script>

<style lang="scss" scoped>
.select-user-div {
  display: inline-flex;
  width: 100%;
}

.select-users {
  max-width: 50%;
}

.team-select {
  max-width: 50%;
}

.open-conversation-link {
  text-decoration: none;
  color: var(--v-primary-base);
  max-width: 100%;
}

.sub-message-span {
  font-size: 12px;
}

.template-dialog {
  max-width: 500px;
}

.disabled-open-conversation {
  opacity: 0.5;
  pointer-events: none;
}

.message-text-area {
  width: 85%;
}

</style>
