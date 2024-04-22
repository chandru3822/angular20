<template>
  <CollapsableRightPanel
      :view-options="[{icon: 'mdi-forum-outline', visible: showSmsTab}, {icon: 'mdi-text-long', visible: true}, {icon: 'mdi-folder-outline', visible: true}]"
      :selected-option="viewId"
      :showHeaderSecondLine = "viewId === 0"
      @selectView="selectView($event)"
      :allowSidebarCollapse = !!allowSidebarCollapse
      @collapseClicked="$emit('collapseCallback')"
  >
    <template v-slot:title>
      <v-tooltip bottom small v-if="showSmsTab && route.path.includes('inboxConversation')">
        <template v-slot:activator="{on, attrs}">
          <a v-if="!isSidebarCollapsed && messageProperties.projectName"
             v-bind="attrs" v-on="on"
             class="d-inline-block clickable conversation-name-link"
             :href="`/project/${projectId}/${defaultProjectPage}`">
            {{ messageProperties.projectName }}
            <v-chip class="customer-chip" style="margin-left: 4px;" small>
              <span >Customer</span>
            </v-chip>
          </a>

          <a v-else
             v-bind="attrs" v-on="on"
             class="d-inline-block clickable conversation-name-link"
             :href="`/user/${userId}/details`">
            {{ messageProperties.fullName }}
            <v-chip class="internal-chip" style="margin-left: 4px;" small>
              <span >Internal</span>
            </v-chip>
          </a>
        </template>
        <span v-if="messageProperties.projectName" class="albatross-body-3">Go to project</span>
        <span v-else class="albatross-body-3">Go to user</span>
      </v-tooltip>
      <span v-else>{{ sidebarTitle }}</span>
      <div v-if="showSmsTab && viewId === 0 && !route.path.includes('inbox')" style="display: inline-flex">
        <v-chip v-if="messageProperties.projectName" class="customer-chip" style="margin-left: 4px;" small>
          <span >Customer</span>
        </v-chip>
        <v-chip v-else class="internal-chip" style="margin-left: 4px;" small>
          <span >Internal</span>
        </v-chip>
      </div>
    </template>
    <template v-slot:header-actions>
      <div v-if="showSmsTab && viewId === 0 && userCanViewSms && !isSidebarCollapsed">
        <v-tooltip bottom small>
          <template v-slot:activator="{on, attrs}">
            <a-btn
                icon
                color="primary"
                @click="openHistoryDrilldown"
                v-bind="attrs"
                :activation-handler="on"
                prepend-icon="mdi-history"
            ></a-btn>
          </template>
          <span class="albatross-body-3">History</span></v-tooltip>
      </div>
      <div v-else-if="viewId === 2 && !isSidebarCollapsed" style="width: 168px;" class="mr-2">

        <v-btn-toggle
            v-model="toggleFocused"
            mandatory
            borderless
            color="primary"
            class="d-inline-block one-hunned body-medium"
            style="opacity: 1 !important;"
            id="focused-toggle"
            v-if="!isMobile"
        >


          <a-btn
              :color="toggleFocused === 0 ? 'primary' : 'white'"
              id="focused-toggle"
              :class="{'white--text': toggleFocused === 0, 'primary--text' : toggleFocused === 1}"
              class="text-capitalize my-4 fix-toggle-opacity body-medium"
              html-style="width: 50% !important;"
              text="Focused"
          ></a-btn>
          <a-btn
              :color="toggleFocused === 1 ? 'primary' : 'white'"
              id="focused-toggle"
              :class="{'white--text': toggleFocused === 1, 'primary--text' : toggleFocused === 0}"
              class="text-capitalize fix-toggle-opacity body-medium"
              html-style="width: 50% !important;"
              text="All"
          ></a-btn>
        </v-btn-toggle>
      </div>
      <div v-else-if="viewId === 1 && !isSidebarCollapsed" style="width: 168px;" class="mr-2">

        <v-btn-toggle
            v-model="toggleTimelineView"
            mandatory
            borderless
            color="primary"
            class="d-inline-block one-hunned body-medium"
            style="opacity: 1 !important;"
        >
          <a-btn
              :color="toggleTimelineView === 0 ? 'primary' : 'white'"
              :class="{'white--text': toggleTimelineView === 0, 'primary--text' : toggleTimelineView === 1}"
              class="text-capitalize my-4 fix-toggle-opacity body-medium"
              html-style="width: 50% !important;"
              @click="selectNotesActivityView"
              text="Timeline"
          ></a-btn>
          <a-btn
              :color="toggleTimelineView === 1 ? 'primary' : 'white'"
              :class="{'white--text': toggleTimelineView === 1, 'primary--text' : toggleTimelineView === 0}"
              class="text-capitalize fix-toggle-opacity body-medium"
              html-style="width: 50% !important;"
              @click="selectNotesActivityView"
              text="Topic"
          ></a-btn>
        </v-btn-toggle>
      </div>
    </template>
    <template v-if="collapseBtnIcon" v-slot:collapse-btn-icon><v-icon>{{collapseBtnIcon}}</v-icon></template>
    <template v-slot:header-second-line>
      <TeamAssignmentChips
          v-if="showSmsTab && viewId === 0 && userCanViewSms"
          :sms-team-owners="messageProperties.smsTeamOwners"
          :team-names-associated-to-user="teamNamesAssociatedToUser"
          :reloading="conversationIsLoading"
          :show-assign-to-me-button="!userAssigned && userHasTeam"
          :project-id="projectId"
          :user-id="userId"
          class="px-6 pb-1 mt-n1"
          @updateOwner="loadConversation"
          @joinConversation="startJoinConversation"
      />
    </template>
    <Messaging
        v-if="showSmsTab && viewId === 0 && !conversationIsLoading"
        :primaryId="projectId"
        :userIdIn="userId"
        :user-assigned="userAssigned"
        :teams-associated-to-user="teamsAssociatedToUser"
    />

    <ActivitySection :contact-id="contactId" :user-id="userId"
                     :timeline-view="toggleTimelineView === 0"
                     :object-type-id="objectTypeId" :project-id="projectId"
                     :org-id="orgId" v-show="viewId === 1"
                     @scrollToTop="scrollToTop"

    />
    <AttachmentsFolderList v-if="viewId === 2"
                           :contact-id="contactId"
                           :user-id="userId"
                           :object-type-id="objectTypeId"
                           :org-id="orgId"
                           :force-show-upload-btn="forceShowUploadBtn"
                           :activity-tab="true"
                           :focused="toggleFocused === 0"
                           :hide-empty-folder-status="hideEmptyFolderStatus"
                           :project-id="projectId"
                           :reload-on-key-change="true"
                           :project-process-step-id="projectProcessStepId"
                           @scrollToTop="scrollToTop"
                           @toggleEmptyFolders="hideEmptyFolderStatus = !hideEmptyFolderStatus"
    />
    <v-dialog v-model="showHistoryDialog" max-width="800px">
      <OwnershipHistoryDrilldown
          class="overflow-y-hidden"
          :conversation-history="conversationHistory"
          @historyDialogClosed="showHistoryDialog = false"
      ></OwnershipHistoryDrilldown>
    </v-dialog>
  </CollapsableRightPanel>
</template>

<script setup>

import ActivitySection from '@/views/flow/components/ActivitySection'
import Messaging from '@/views/flow/components/Messaging'
import AttachmentsFolderList from '@/views/flow/components/AttachmentsFolderList'

import {getProjectPath, getRequest, handleHidingGlobalLoader, postRequest} from '@/helpers/helpers'
import TeamAssignmentChips from '@/views/flow/settings/inbox/TeamAssignmentChips'
import OwnershipHistoryDrilldown from '@/views/flow/settings/inbox/OwnershipHistoryDrilldown'
import AddTeamDropdown from '@/views/flow/settings/inbox/AddTeamDropdown'
import ConfirmAssignmentDialog from '@/views/flow/settings/inbox/ConfirmAssignmentDialog'
import debounce from 'lodash.debounce'
import CollapsableRightPanel from "@/layouts/CollapsableRightPanel.vue";
import { useProjectStore } from '@/stores/ProjectStore.js'
import { useNotificationStore } from '@/stores/NotificationStore.js'

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'
import {storeToRefs} from "pinia";

const appStore = useAppStore()
const notificationStore = useNotificationStore()
const projectStore = useProjectStore()
const { selectedTab } = storeToRefs(projectStore)

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const vuetify = vueInstance.$vuetify

const props = defineProps({
  showSmsTab: {
    type: Boolean,
    default: true
  },
  contactId: Number,
  userIdIn: Number,
  orgId: Number,
  forceShowUploadBtn: Boolean,
  allowSidebarCollapse: {
    type: Boolean,
    default: true
  },
  showNotes: Boolean,
  collapseBtnIcon: String
})
const { showSmsTab, contactId, userIdIn, orgId, forceShowUploadBtn, allowSidebarCollapse, showNotes, collapseBtnIcon } = toRefs(props)

const emit = defineEmits(['closeRight'])

const isMobile = computed(() => {
  return vuetify.breakpoint.smAndDown
})
const defaultProjectPage = ref(getProjectPath().pathSuffix)
const userHasTeam = ref(false)
const userAssigned = ref(false)
const showJoinConversationDialog = ref(false)
const teamsAssociatedToUser = ref([])
const teamNamesAssociatedToUser = ref([])
const selectableTeams = ref([])
const messageProperties = ref({})
const showHistoryDialog = ref(false)
const teamsMenuOpen = ref(false)
const myOwner = ref([])
const conversationHistory = ref([])
const conversationIsLoading = ref(true)
const toggleFocused = ref(isMobile.value ? 1 : 0)
const toggleFocusedXs = ref(0)
const hideEmptyFolderStatus = ref(false)

const toggleTimelineView = ref(projectStore.notesActivityView)

const userCanViewSms = computed(() => {
  return userStore.userHasFeatureAccessLevel('SMS_INBOX', 'VIEW')
})

const projectProcessStepId = computed(() => {
  return parseInt(route.params.processStepId) || null
})
const projectProcessStepEventId = computed(() => {
  return parseInt(route.params.ppsEventId) || null
})
const viewId = computed(() => {
  return (null == selectedTab.value || (selectedTab.value === 0 && !showSmsTab.value)) ? 1 : selectedTab.value
})
const currentUserId = computed(() => {
  return userStore.details.id
})
const userId = computed(() => {
  return userIdIn.value ? userIdIn.value : parseInt(route.params.userId) || null
})
const objectTypeId = computed(() => {
  //not needed for other types
  return userId.value ? 3 : contactId.value ? 2 : orgId.value ? 5 : null
})
const sidebarTitle = computed(() => {
  switch (viewId.value) {
    case 0:
      if (userCanViewSms.value) {
        if (projectId.value) {
          return route.path.includes('inboxConversation') ? messageProperties.value.projectName : 'Communication'
        }
        else {
          return route.path.includes('inboxConversation') ? messageProperties.value.fullName : 'Communication'
        }
      } else {
        if (projectId.value) {
          return route.path.includes('inboxConversation') ? messageProperties.value.projectName : 'Communication (Read-only)'
        }
        else {
          return route.path.includes('inboxConversation') ? messageProperties.value.fullName : 'Communication (Read-only)'
        }
      }

    case 1:
      return orgId.value || userId.value || contactId.value || projectId.value ? 'Notes & Activities' : null
    case 2:
      return orgId.value || userId.value || contactId.value || projectId.value ? 'Documents' : null
  }
})
const isSidebarCollapsed = computed(() => {
  return allowSidebarCollapse.value && projectStore.rightSideSplit
})
const smsOwnershipEvents = computed(() => {
  return notificationStore.getEventsByTopic('sms_ownership').length
})

const projectId = computed(() => {
  return parseInt(route.params.projectId)
})


onMounted(() => {
  const projectActivityParam = parseInt(route.query.activityView | '-1')
  if(projectActivityParam >= 0){
    selectView(projectActivityParam)
  }
  handlePageLoad()
})

watch(projectId, async() => {
  if(viewId.value === 0) {
    await fetchTeamsForUser()
  }
})
watch(() =>route.query.activityView, async() => {
  const projectActivityParam = parseInt(route.query.activityView | '-1')
  if(projectActivityParam >= 0){
    selectView(projectActivityParam)
  }
})
// watch(viewId, async() => {
//   // selectedOption.value = viewId.value
//   return (route.params.viewId ? parseInt(route.params.viewId) :
//       (showSmsTab.value && route.path.indexOf('inbox') > 0) ? 0 :
//           (null == selectedTab.value || (selectedTab.value === 0 && !showSmsTab.value)) ? 1 : selectedTab.value
// })
watch(smsOwnershipEvents, debounce(async function() {
  await fetchTeamsForUser()
}, 800))
watch(viewId, async() => {
  handlePageLoad()
})
watch(userId, async() => {
  // selectedOption.value = route.path.indexOf('inbox') > 0 ? 0 : (null == userStore.selectedTab ? 1 : userStore.selectedTab)
  if(viewId.value === 0) {
    await fetchTeamsForUser()
  }
})

const handlePageLoad = ()  => {
  //dont load the sms stuff if they aren't on the sms tab
  if (userCanViewSms.value && viewId.value === 0) {
    handleSmsLoad()
  }
}
const handleSmsLoad = ()  => {
  //i dont think we should show the global spinner when the side section is loading
  // appStore.loading = true
  fetchTeamsForUser()
  getAvailableTeams()
  // appStore.loading = false
}
const closeRight = ()  => {
  emit('closeRight')
}
const collapseSide = ()  => {
  projectStore.rightSideSplit = !projectStore.rightSideSplit
}
const selectView = (viewOption) => {
  selectedTab.value = viewOption
}
const selectNotesActivityView = () => {
  if(toggleTimelineView.value === 0){
    projectStore.notesActivityView = 1
  } else {
    projectStore.notesActivityView = 0
  }
  scrollToTop()
}
const scrollToTop = () => {
  document.querySelector('div.conversation-activity-inner-container').scroll({top:0})
}
const startJoinConversation = ()  => {
  if (teamsAssociatedToUser.value?.length === 1) {
    const selectedSmsTeam = teamsAssociatedToUser.value[0]
    joinConversation(selectedSmsTeam)
  } else {
    // If the User has multiple teams available, have them select a team to join with first
    showJoinConversationDialog.value = true
  }
}
const openMenu = () => {
  projectStore.leftSideSplit = false;
}
const joinConversation = async(selectedTeam) => {
  try {
    if (projectId.value) {
      await postRequest(`/messaging/addTeam/project/${projectId.value}`, selectedTeam)
    }
    else if (userId.value) {
      await postRequest(`/messaging/addTeam/user/${userId.value}`, selectedTeam)
    }

    appStore.showSnack('SUCCESS', 'Successfully joined conversation')

    await loadConversation()

  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error joining conversation')

    appStore.loading = false
  }
}
const fetchTeamsForUser = async() => {
  if(showSmsTab.value) {
    try {
      conversationIsLoading.value = true
      const { data, status } = await getRequest(`/smsTeam/getTeamsForUser`, null, [])
      // appStore.loading = false
      teamsAssociatedToUser.value = data ?? []

      if (data != null && data.length > 0) {
        userHasTeam.value = true
        teamNamesAssociatedToUser.value = teamsAssociatedToUser.value.map(team => team.teamName)
      }
      // handleHidingGlobalLoader( status)
      await loadConversation()
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error fetching SMS Teams')

      conversationIsLoading.value = false
    }
  }
}
const loadConversation = async() => {
  userAssigned.value = false
  if (projectId.value) {
    try {
      const { data, status } = await getRequest('/messaging/project/' + projectId.value)
      messageProperties.value = data
      messageProperties.value.smsTeamOwners?.forEach(team => {
        if (teamNamesAssociatedToUser.value.includes(team.teamName)) {
          team.users?.forEach(owner => {
            if (owner.userId === currentUserId.value) {
              userAssigned.value = true
              myOwner.value.push(owner)
            }
          })
        }
      })
      // handleHidingGlobalLoader( status)
      conversationIsLoading.value = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error fetching project messaging details')

      conversationIsLoading.value = false
    }
  }
  else if (userId.value) {
    try {
      const { data, status } = await getRequest('/messaging/user/' + userId.value)
      messageProperties.value = data
      messageProperties.value.smsTeamOwners?.forEach(team => {
        if (teamNamesAssociatedToUser.value.includes(team.teamName)) {
          team.users?.forEach(owner => {
            if (owner.userId === currentUserId.value) {
              userAssigned.value = true
              myOwner.value.push(owner)
            }
          })
        }
      })
      handleHidingGlobalLoader( status)
      conversationIsLoading.value = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error fetching user messaging details')

      conversationIsLoading.value = false
    }
  }
}
const getAvailableTeams = async() => {
  // appStore.loading = true
  try {
    const { data, status } = await getRequest(`/smsTeam/users`)
    if (data) {
      selectableTeams.value = data
    }
    // handleHidingGlobalLoader( status)
    // appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    // appStore.loading = false
    appStore.showSnack('ERROR', 'Error retrieving teams')

  }
}
const openHistoryDrilldown = async() => {
  try {
    let historyUrl = ''
    if (projectId.value) {
      historyUrl = `/messaging/history/project/${projectId.value}`
    }
    else {
      historyUrl = `/messaging/history/user/${userId.value}`
    }
    const { data } = await getRequest(historyUrl)
    conversationHistory.value = data
    showHistoryDialog.value = true
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error fetching history')

  }
}
</script>

<style lang="scss" scoped>

@media (max-width: 960px) {
  .mobile-hamburger-menu {
    padding-left: 32px;
    padding-right: 24px;
  }

  .mobile-contact-header{
    padding-top: 14px;
    padding-right: 36px;
  }

  .mobile-content-padding{
    padding-top: 16px;
    padding-left: 16px;
  }
}

#conversation-activity-container {
  height: 100%;
  width: 100%;
  position: relative;
}

.conversation-activity-inner-container {
  max-height: 100%;
  overflow: auto;
  flex-grow: 4;
}

.conversation-activity-header {
  height: 41px;
}

.conversation-activity-content {
  min-height: 800px;
  overflow-y: scroll;
  width: 100%;
}

.footer-container {
  width: 100%;
  align-self: center;
  height: fit-content;
  min-height: 65px;
  background-color: white;
}

.section-footer {
  display: flex;
  align-items: center;
}

.section-selected {
  background-color: var(--v-primary-base) !important;
}

.section-not-selected {
  background-color: white;
}

.title-collapse {
  padding-left: 10px;
  margin-top: 12px;
}

.title-no-collapse {
  padding-left: 24px;
  padding-top: 4px;
  display: flex !important;
  justify-content: space-between;
  margin-right: 11px;
}

.conversation-name-link {
  text-decoration: none;
}

.v-btn-toggle .v-btn {
  border: 1px solid var(--v-primary-base) !important;
  height: 30px !important;
  width: 168px !important;

  &:not(:last-child) {
    border-right: none !important;
  }
}

.toggle-btn {
  width: 50% !important;
}

//not sure why/when this broke but we were always showing a scrollbar this makes it show only when needed
.scrollable-area {
  height: calc(100% - 5px);
}
</style>

<style lang="scss">
#right-sidebar-title .v-toolbar__content {
  display: flex;
  align-items: flex-start;
}

#conversation-activity-container .fix-toggle-opacity:before {
  background-color: unset !important;
}

.internal-chip {
  background-color: #C8E6C9 !important;
  height: 22px;
}

.customer-chip {
  background-color: #FECDD2 !important;
  height: 22px;
}
</style>
