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
        <a-autocomplete
          v-model="selectedProjectIds"
          :items="sortedProjects"
          :search-input.sync="projectQuery"
          multiple
          cache-items
          clearable
          item-title="firstName"
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
          <template  v-slot:selection="{item, index}">
            <v-chip small v-if="selectedProjectIds.length < 3">
              <span>{{ item.projectName }}</span>
            </v-chip>
            <span
              v-if="index === 1 && selectedProjectIds.length >= 3"
            >{{ selectedProjectIds.length }} selected&nbsp;&nbsp;</span>
          </template>
        </a-autocomplete>
      </div>

      <div class="select-user-div">
        <label v-if="!isInbox" class="mt-5 mr-2">To:</label>
        <a-autocomplete
          v-model="selectedUserIds"
          :items="sortedUsers"
          multiple
          :disabled="selectedProjectIds.length > 0 && isInbox"
          item-title="name"
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
        <template  v-slot:selection="{item, index}">
          <v-chip small v-if="selectedUserIds.length < 2">
            <span>{{ item.name }}</span>
          </v-chip>
          <span
            v-if="index === 1 && selectedUserIds.length >= 2"
          >{{ selectedUserIds.length }} selected</span>
        </template>
        </a-autocomplete>
        <router-link  class="pt-5 pl-5"
                      :class="selectedUserIds.length > 1 ? 'disabled-open-conversation' : 'open-conversation-link'"
                      v-if="selectedUserIds.length > 0"
                      :to="`/user/${selectedUserIds}/details`"
                      target="_blank">
          Open conversation<v-icon small>mdi-open-in-new</v-icon>
        </router-link>
      </div>

      <div class="flex-display">
        <a-textarea class="message-text-area" hide-details
                    placeholder="Enter message here"
                    auto-grow
                    variant="outlined"
                    rows="4"
                    v-model="message">
        </a-textarea>
        <a-btn
          variant="text"
          icon
          color="primary"
          class="white--text templateButton template-button-height"
        >
          <v-tooltip bottom small>
            <template v-slot:activator="{on, attrs}">
              <v-icon class="pr-2" @click="" v-bind="attrs" v-on="on">
                article
              </v-icon>
            </template>
            <span class="albatross-body-3">Templates</span>
          </v-tooltip>
        </a-btn>

        <v-menu v-model="menuOpen" top left offset-y activator=".templateButton" :close-on-content-click="false">
          <v-card class="template-dialog" width="295px">
            <v-card-title>
              <span class="albatross-header-4-new">Add Template</span>
            </v-card-title>
            <v-card-text>
              <a-select label="Template"
                        class="template-selector pt-1"
                        v-model="selectedTemplate"
                        :items="selectableTemplates"
                        item-title="title"
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
              </a-select>
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
          <a-btn
              color="primary"
              :disabled="(selectedProjectIds.length == 0 && selectedUserIds.length == 0) || (message.length == 0 && uploadedFiles.length == 0)"
              @click="[assignAndSend = false, sendMessage()]"
              class="send-button"
              variant="text"
              text="Send and don't assign"
          ></a-btn>

          <a-btn
              color="primary"
              class="send-button"
              :disabled="(selectedProjectIds.length == 0 && selectedUserIds.length == 0) || (message.length == 0 && uploadedFiles.length == 0)"
              @click="[assignAndSend = true, sendMessage()]"
              text="Send"
          ></a-btn>
        </v-card-actions>
      </div>
    </v-card>
    </v-dialog>
  </v-container>
</template>

<script setup>
import {getRequest, getRequestWithParams, putRequest, handleHidingGlobalLoader, postRequest} from '@/helpers/helpers'

import {ref, computed, onMounted, getCurrentInstance, watch} from "vue";
import {useUserStore} from "@/stores/UserStore.js";
import {useRouter, useRoute} from "vue-router/composables"
import { useAppStore } from '@/stores/AppStore.js'
const appStore = useAppStore()

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
 const route = useRoute()
const router = useRouter()
const vuetify = vueInstance.$vuetify

const userStore = useUserStore()
const emit = defineEmits(['update:showNewMessageDialog'])

const props = defineProps({
  showNewMessageDialog: Boolean,
  ownerUserId: Number,
  isInbox: Boolean
})

const selectedProjectIds = ref([])
const availableProjects = ref([])
const availableUsers = ref([])
const uploadedFiles = ref([])
const message = ref('')
const templateTeams = ref([])
const selectedTemplate = ref(null)
const selectableTemplates = ref([])
const selectedUserIds = ref([])
const projectQuery = ref(null)
const teamsAssociatedToUser = ref([])
const attachmentUrl = ref('')
const sendTextUrl = ref('')
const lastSentUrl = ref('')
const createNotificationUrl = ref('')
const inboxUrl = ref('')
const addTeamUrl = ref('')
const assignAndSend = ref(false)
const menuOpen = ref(false)
const messageSuccess = ref(false)
const conversationIsLoading = ref(false)

onMounted(() => {
  getUsers();
  fetchTeamsForUser();
})
const attachmentsText = computed(() => {
  if (uploadedFiles.value.length == 1) {
    return uploadedFiles.value[0][0].name
  }
  else if (uploadedFiles.value.length > 1) {
    return uploadedFiles.value.length + ' files'
  }
})
const sortedProjects = computed(() => {
  const selectedProjects = availableProjects.value.filter(project => selectedProjectIds.value.includes(project.id));
  const unselectedProjects = availableProjects.value.filter(project => !selectedProjectIds.value.includes(project.id));
  return selectedProjects.concat(unselectedProjects);
})
const sortedUsers = computed(() => {
  const selectedUsers = availableUsers.value.filter(user => selectedUserIds.value.includes(user.userId));
  const unselectedUsers = availableUsers.value.filter(user => !selectedUserIds.value.includes(user.userId));
  return selectedUsers.concat(unselectedUsers);
})

watch(projectQuery,(val) => {
  if(!val) {
    return
  }
  selectedUserIds.value = []
  if (val.length > 3) {
    getProjectDebounced(val)
  }
})
const handleTemplateSelection = () => {
  message.value += selectedTemplate.value.message
  menuOpen.value = false
  selectedTemplate.value = null
  vueInstance.$refs.templateSelect.reset();
}
const exitDialogue = () => {
  selectedProjectIds.value = []
  availableProjects.value = []
  uploadedFiles.value = []
  message.value = ''
  selectedUserIds.value = []
  projectQuery.value = null
  let currentUserValues = availableUsers.value.filter(value => value.userId && value.userId === props.ownerUserId)
  if (currentUserValues.length > 0) {
    selectedUserIds.value = [props.ownerUserId]
  }

  emit('update:showNewMessageDialog', false)
}
const getProjectDebounced = (val) => {
  clearTimeout(_searchTimerId.value)
  _searchTimerId.value = setTimeout(() => {
    getProjects(val)
  }, 500) /* 500ms throttle */
}
const sendMessage = async () => {
  appStore.loading = true
  if (selectedProjectIds.value.length > 0) {
    for (let selectedProjectId of selectedProjectIds.value) {
      attachmentUrl.value = `/project/` + selectedProjectId + `/attachment`
      sendTextUrl.value = `/communication/sendTextsForProject/` + selectedProjectId
      lastSentUrl.value = `/messaging/setLastSent/project/` + selectedProjectId
      createNotificationUrl.value = `/messaging/createNotification/project/` + selectedProjectId
      inboxUrl.value = `/inbox/inboxConversation/project/` + selectedProjectId
      addTeamUrl.value = `/messaging/addTeam/project/` + selectedProjectId
      if (assignAndSend.value) {
        await sendMessageAndAssign();
      }
      else {
        await onMessageWasSent();
      }
    }
  }
  else {
    // Send the message for each selected User
    for (let currentUserId of selectedUserIds.value) {
      attachment.value =  `/user/` + currentUserId + `/attachment`
      sendText.value = `/communication/sendTextsForUser/` + currentUserId
      lastSent.value = `/messaging/setLastSent/user/` + currentUserId
      createNotification.value = `/messaging/createNotification/user/` + currentUserId
      inbox.value = `/inbox/inboxConversation/user/` + currentUserId
      addTeam.value = `/messaging/addTeam/user/` + currentUserId
      if (assignAndSend.value) {
        await sendMessageAndAssign();
      }
      else {
        await onMessageWasSent()
      }

      if (!messageSuccess.value) {
        return;
      }
    }
  }

  if (messageSuccess.value) {
    exitDialogue()
    appStore.loading = false
    if (assignAndSend.value) {
      appStore.showSnack('SUCCESS', 'Message sent and conversation assigned')
      if (props.isInbox && !route.path.includes(inboxUrl.value)) {
        await router.push({ path: inboxUrl.value })
      }
    }
    else {
      appStore.showSnack('SUCCESS', 'Message sent')
      appStore.loading = false

    }
  }
}
const onMessageWasSent = async () => {
  if (message.value && message.value.length > 1599) {
    let textOverflowLength = message.value.length - 1599;
    appStore.showSnack('ERROR', 'Message exceeds the 1600 character limit by ' + textOverflowLength + ' characters. ')

    messageSuccess.value = false
    appStore.loading = false
    return;
  }

  // called when the user sends a message
  let params
  let smsTeamId = teamsAssociatedToUser.value.length > 0 ? teamsAssociatedToUser.value[0].id : null
  if (!smsTeamId) {
    appStore.showSnack('ERROR', 'Error: No SMS Team found')

    appStore.loading = false
    return
  }

  messageSuccess.value = true

  try {
    if (uploadedFiles.value && uploadedFiles.value.length > 0) {
      for (let currFile of uploadedFiles.value){
        let mediaUrls = []
        let formData = new FormData()
        formData.append('file', currFile[0])
        formData.append('attachmentTypeId', 3)

        if (selectedUserIds.value.length > 0) {
          formData.append('displayName', currFile[0].name.substr(0, currFile[0].name.lastIndexOf('.')))
        }

        const resp = await postRequest(attachmentUrl.value, formData)
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

        await postRequest(sendTextUrl.value, params)
      }
    }

    if (message.value) {
      params = {
        userIDs: null,
        message: message.value,
        smsTeamId: smsTeamId
      }
      await postRequest(sendTextUrl.value, params)
    }

    await putRequest(lastSentUrl.value)
    await postRequest(createNotificationUrl.value)
  } catch (e) {
    console.error('*** ERROR ***', e)
    messageSuccess.value = false
    let message = e?.message ? 'Error Sending Message: ' + e.message :
      e?.data?.message ? 'Error Sending Message: ' + e.data.message : 'Error Sending Message'
    appStore.showSnack('ERROR', message)

    appStore.loading = false
    return;
  }
}
const sendMessageAndAssign = async () => {
  let smsTeamId = teamsAssociatedToUser.value.length > 0 ? teamsAssociatedToUser.value[0].id : null
  if (!smsTeamId) {
    appStore.showSnack('ERROR', 'Error: No SMS Team found')

    appStore.loading = false
    return
  }

  let params = {
    id: smsTeamId,
    users: [{
      smsTeamId: smsTeamId,
      userId: userStore.details.id
    }]
  }

  await postRequest(addTeamUrl.value, params)

  await onMessageWasSent()
}
const getProjects = async (val) => {
  if (val == null) {
    selectedProjectIds.value = []
    availableProjects.value = []
    return;
  }

  try {
    const {data} = await getRequestWithParams(`/messaging/availableProjects`, {
      params: {
        query: val,
      }
    })
    availableProjects.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error retrieving projects')

  }
}
const getUsers = async () => {
  try {
    const { data } = await getRequest(`/messaging/availableUsers`)
    availableUsers.value = data

    if (availableUsers.value) {
      let currentUserValues = availableUsers.value.filter(value => value.userId && value.userId === props.ownerUserId)
      if (currentUserValues.length > 0) {
        selectedUserIds.value = [props.ownerUserId]
      }
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error retrieving users and positions')

  }
}
const fetchTeamsForUser = async () => {
  try {
    conversationIsLoading.value = true
    const { data, status } = await getRequest(`/smsTeam/getTeamsForUser`)
    appStore.loading = false
    teamsAssociatedToUser.value = data
    if (teamsAssociatedToUser.value && teamsAssociatedToUser.value.length > 0) {
      for (let team of teamsAssociatedToUser.value){
        templateTeams.value.push(team.id);
      }
    }
    handleHidingGlobalLoader(status)
    await getSmsTeamTemplates();
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error fetching SMS Teams')

    conversationIsLoading.value = false
  }
}
const getSmsTeamTemplates = async () => {
  try {
    selectedTemplate.value = null
    if (!teamsAssociatedToUser.value || teamsAssociatedToUser.value.length < 1) {
      return
    }

    const { data } = await getRequest(`/messaging/templates/` + templateTeams.value)
    selectableTemplates.value = data
  } catch (e) {
    // console.log('ccc')
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error retrieving templates')

  }
}
const uploadTextAttachment = async (file) => {
  try {
    if (!file){
      return
    }
    uploadedFiles.value.push(file);
  } catch(e) {
    appStore.loading = false
    logError(e)
    appStore.showSnack('ERROR', 'Error Uploading File')

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
