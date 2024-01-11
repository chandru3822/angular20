<template xmlns="http://www.w3.org/1999/html">
  <v-container>
    <v-dialog
        v-model="showNewMessageDialog"
        @click:outside="exitDialogue"
        width="803">
    <v-card class="px-6 pb-6 pt-3">
      <v-card-title class="pa-0 justify-space-between">
        <span class="title-large">Compose new SMS Message</span>
        <a class="close-modal-x pb-3" title="Close" @click="exitDialogue">×</a>
      </v-card-title>
      <span class="sub-message-span">You will be assigned to the conversation automatically, unless chosen otherwise</span>
      <br>
      <div class="flex-display" v-if="isInbox">
        <label class="mt-5 mr-2">To:</label>
        <v-autocomplete
          v-model="selectedProjectIds"
          :items="sortedProjects"
          :search-input.sync="projectQuery"
          multiple
          cache-items
          clearable
          item-text="firstName"
          item-value="id"
          :disabled="selectedUserIds.length > 0"
          label="Enter project ID"
          class="team-select pa-0 mt-4"
          hide-no-data
        >
          <template #item="{ item, attrs, on }">
            <v-list-item @click="on.click">
              <v-list-item-action>
                <v-checkbox
                  class="select-check"
                  :value="selectedProjectIds.includes(item.id)"
                  :disabled="true"
                  @click.stop
                ></v-checkbox>
              </v-list-item-action>
              <v-list-item-content>
                <v-list-item-title v-text="item.projectName"></v-list-item-title>
              </v-list-item-content>
            </v-list-item>
          </template>
          <template
            slot="selection"
            slot-scope="{ item, index }"
          >
            <v-chip small v-if="selectedProjectIds.length < 3">
              <span>{{ item.projectName }}</span>
            </v-chip>
            <span
              v-if="index === 1 && selectedProjectIds.length >= 3"
            >{{ selectedProjectIds.length }} selected&nbsp;&nbsp;</span>
          </template>
        </v-autocomplete>
      </div>

      <div class="select-user-div">
        <label v-if="!isInbox" class="mt-5 mr-2">To:</label>
        <v-autocomplete
          v-model="selectedUserIds"
          :items="sortedUsers"
          multiple
          :disabled="selectedProjectIds.length > 0 && isInbox"
          item-text="name"
          item-value="userId"
          :label="selectedUserIds.length > 0 ? '' : 'Select users'"
          class="pa-0 mt-4 select-users"
          :class="isInbox ? 'ml-7' : ''"
          clearable
        ><template #item="{ item, on, attrs }">
          <v-list-item @click="on.click">
            <v-list-item-action>
              <v-checkbox
                class="select-check"
                :input-value="selectedUserIds.includes(item.userId)"
                :disabled="true"
                @click.stop
              ></v-checkbox>
            </v-list-item-action>
            <v-list-item-content>
              <v-list-item-title v-text="item.name"></v-list-item-title>
            </v-list-item-content>
          </v-list-item>
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
        <router-link  class="pt-5 pl-5"
                      :class="selectedUserIds.length > 1 ? 'disabled-open-conversation' : 'open-conversation-link'"
                      v-if="selectedUserIds.length > 0"
                      :to="`/user/${this.selectedUserIds}/details`"
                      target="_blank">
          Open conversation<v-icon small>mdi-open-in-new</v-icon>
        </router-link>
      </div>

      <div class="flex-display">
        <v-textarea class="message-text-area" hide-details
                    placeholder="Enter message here"
                    auto-grow
                    outlined
                    rows="4"
                    v-model="message">
        </v-textarea>
        <v-btn icon color="primary" class="white--text templateButton template-button-height">
          <v-tooltip bottom small>
            <template v-slot:activator="{on, attrs}">
              <v-icon class="pr-2" @click="" v-bind="attrs" v-on="on">
                article
              </v-icon>
            </template>
            <span class="albatross-body-3">Templates</span>
          </v-tooltip>
        </v-btn>

        <v-menu v-model="menuOpen" top left offset-y activator=".templateButton" :close-on-content-click="false">
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
                        ref="templateSelect"
                        @change="handleTemplateSelection">

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
          class="ma-0 pt-1"
          @change="uploadTextAttachment"
          @click:clear="[uploadedFiles = []]"
        />
      </div>

      <div class="flex-display">
        <span v-if="uploadedFiles.length > 0">Attached {{attachmentsText}}</span>
        <v-spacer/>
        <v-card-actions class="pb-0 px-0 pt-6">
          <v-spacer/>
          <v-btn
            color="primary"
            :disabled="(selectedProjectIds.length == 0 && selectedUserIds.length == 0)
                          || (message.length == 0 && uploadedFiles.length == 0)"
            @click="[assignAndSend = false, sendMessage()]"
            class="send-button"
            text
          >
            Send and don't assign
          </v-btn>

          <v-btn
            color="primary"
            class="white--text send-button"
            :disabled="(selectedProjectIds.length == 0 && selectedUserIds.length == 0)
                          || (message.length == 0 && uploadedFiles.length == 0)"
            @click="[assignAndSend = true, sendMessage()]">
            Send
          </v-btn>
        </v-card-actions>
      </div>
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
      selectedProjectIds: [],
      availableProjects: [],
      availableUsers: [],
      uploadedFiles: [],
      message: '',
      templateTeams: [],
      selectedTemplate: null,
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
      assignAndSend: false,
      menuOpen: false,
      messageSuccess: false
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
    },
    sortedProjects() {
      const selectedProjects = this.availableProjects.filter(project => this.selectedProjectIds.includes(project.id));
      const unselectedProjects = this.availableProjects.filter(project => !this.selectedProjectIds.includes(project.id));
      return selectedProjects.concat(unselectedProjects);
    },
    sortedUsers() {
      const selectedUsers = this.availableUsers.filter(user => this.selectedUserIds.includes(user.userId));
      const unselectedUsers = this.availableUsers.filter(user => !this.selectedUserIds.includes(user.userId));
      return selectedUsers.concat(unselectedUsers);
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
    handleTemplateSelection() {
      this.message += this.selectedTemplate.message
      this.menuOpen = false
      this.selectedTemplate = null
      this.$refs.templateSelect.reset();
    },
    exitDialogue(){
      this.selectedProjectIds = []
      this.availableProjects = []
      this.uploadedFiles = []
      this.message = ''
      this.selectedUserIds = []
      this.projectQuery = null
      let currentUserValues = this.availableUsers.filter(value => value.userId && value.userId === this.ownerUserId)
      if (currentUserValues.length > 0) {
        this.selectedUserIds = [this.ownerUserId]
      }

      this.$emit('update:showNewMessageDialog', false)
    },
    getProjectDebounced(val) {
      clearTimeout(this._searchTimerId)
      this._searchTimerId = setTimeout(() => {
        this.getProjects(val)
      }, 500) /* 500ms throttle */
    },
    async sendMessage() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      if (this.selectedProjectIds.length > 0) {
        for (let selectedProjectId of this.selectedProjectIds) {
          this.attachmentUrl = `/project/` + selectedProjectId + `/attachment`
          this.sendTextUrl = `/communication/sendTextsForProject/` + selectedProjectId
          this.lastSentUrl = `/messaging/setLastSent/project/` + selectedProjectId
          this.createNotificationUrl = `/messaging/createNotification/project/` + selectedProjectId
          this.inboxUrl = `/inbox/inboxConversation/project/` + selectedProjectId
          this.addTeamUrl = `/messaging/addTeam/project/` + selectedProjectId
          if (this.assignAndSend) {
            await this.sendMessageAndAssign();
          }
          else {
            await this.onMessageWasSent();
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
            await this.sendMessageAndAssign();
          }
          else {
            await this.onMessageWasSent()
          }

          if (!this.messageSuccess) {
            return;
          }
        }
      }

      if (this.messageSuccess) {
        this.exitDialogue()
        this.$store.commit(AppMutations.SET_LOADING, false)
        if (this.assignAndSend) {
          this.snackbar = getSnackbar('SUCCESS', 'Message sent and conversation assigned')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          if (this.isInbox && !this.$route.path.includes(this.inboxUrl)) {
            await this.$router.push({ path: this.inboxUrl })
          }
        }
        else {
          this.snackbar = getSnackbar('SUCCESS', 'Message sent')
          this.$store.commit(AppMutations.SET_LOADING, false)
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      }
    },
    async onMessageWasSent() {
      if (this.message && this.message.length > 1599) {
        let textOverflowLength = this.message.length - 1599;
        this.snackbar = getSnackbar('ERROR', 'Message exceeds the 1600 character limit by ' + textOverflowLength + ' characters. ')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.messageSuccess = false
        this.$store.commit(AppMutations.SET_LOADING, false)
        return;
      }

      // called when the user sends a message
      let params
      let smsTeamId = this.teamsAssociatedToUser.length > 0 ? this.teamsAssociatedToUser[0].id : null
      if (!smsTeamId) {
        this.snackbar = getSnackbar('ERROR', 'Error: No SMS Team found')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
        return
      }

      this.messageSuccess = true

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
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.messageSuccess = false
        let message = e?.message ? 'Error Sending Message: ' + e.message :
          e?.data?.message ? 'Error Sending Message: ' + e.data.message : 'Error Sending Message'
        this.snackbar = getSnackbar('ERROR', message)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
        return;
      }
    },
    sendMessageAndAssign: async function () {
      let smsTeamId = this.teamsAssociatedToUser.length > 0 ? this.teamsAssociatedToUser[0].id : null
      if (!smsTeamId) {
        this.snackbar = getSnackbar('ERROR', 'Error: No SMS Team found')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
        return
      }

      let params = {
        id: smsTeamId,
        users: [{
          smsTeamId: smsTeamId,
          userId: this.$store.state.user.details.id
        }]
      }

      await postRequest(this.addTeamUrl, params)

      await this.onMessageWasSent()
    },
    async getProjects(val) {
      if (val == null) {
        this.selectedProjectIds = []
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

        if (this.availableUsers) {
          let currentUserValues = this.availableUsers.filter(value => value.userId && value.userId === this.ownerUserId)
          if (currentUserValues.length > 0) {
            this.selectedUserIds = [this.ownerUserId]
          }
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
        const { data, status } = await getRequest(`/smsTeam/getTeamsForUser`)
        this.$store.commit(AppMutations.SET_LOADING, false)
        this.teamsAssociatedToUser = data
        if (this.teamsAssociatedToUser && this.teamsAssociatedToUser.length > 0) {
          for (let team of this.teamsAssociatedToUser){
            this.templateTeams.push(team.id);
          }
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
        this.selectedTemplate = null
        if (!this.teamsAssociatedToUser || this.teamsAssociatedToUser.length < 1) {
          return
        }

        const { data } = await getRequest(`/messaging/templates/` + this.templateTeams)
        this.selectableTemplates = data
      } catch (e) {
        // console.log('ccc')
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
  max-width: 100%;
  text-decoration: none;
  color: lightgrey !important;
  pointer-events: none;

  .mdi-open-in-new {
    color: lightgrey !important;
  }

}

.message-text-area {
  width: 90%;
  margin-right: 5px;
}

.templateButton {
  margin-left: 10px;
  padding-left: 10px !important;
}

.mdi-open-in-new {
  color: var(--v-primary-base);
  height: 16px;
  width: 16px;
  margin-left: 8px;
}

.send-button {
  text-transform: none;
}

.close-modal-x {
  font-size: 30px;

  &:hover {
    font-weight: bolder;
  }
}

.select-check {
  color: var(--v-primary-base) !important;
}

.template-button-height {
  height: 36px !important;
  margin-top: 2px;
}

</style>
