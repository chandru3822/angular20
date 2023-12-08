<template>
  <CollapsableRightPanel
      :view-options="[{icon: 'mdi-forum-outline', visible: showSmsTab}, {icon: 'mdi-text-long', visible: true}, {icon: 'mdi-folder-outline', visible: true}]"
      :selected-option="selectedOption"
      :showHeaderSecondLine = "selectedOption === 0"
      @selectView="selectView($event)"
      :allowSidebarCollapse = !!allowSidebarCollapse
      @collapseClicked="$emit('collapseCallback')"
  >
    <template v-slot:title>
      <v-tooltip bottom small v-if="showSmsTab && $route.path.includes('inboxConversation')">
        <template v-slot:activator="{on, attrs}">
          <a v-if="!isSidebarCollapsed && messageProperties.projectName"
             v-bind="attrs" v-on="on"
             class="d-inline-block clickable conversation-name-link"
             :href="`/project/${projectId}/status`">
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
      <div v-if="showSmsTab && selectedOption === 0" style="display: inline-flex">
        <v-chip v-if="messageProperties.projectName" class="customer-chip" style="margin-left: 4px;" small>
          <span >Customer</span>
        </v-chip>
        <v-chip v-else class="internal-chip" style="margin-left: 4px;" small>
          <span >Internal</span>
        </v-chip>
      </div>
    </template>
    <template v-slot:header-actions>
      <div v-if="showSmsTab && selectedOption === 0 && userCanViewSms && !isSidebarCollapsed">
        <v-tooltip bottom small>
          <template v-slot:activator="{on, attrs}">
            <v-btn icon color="primary" @click="openHistoryDrilldown" v-bind="attrs" v-on="on">
              <v-icon>mdi-history</v-icon>
            </v-btn>
          </template>
          <span class="albatross-body-3">History</span></v-tooltip>
      </div>
      <div v-else-if="selectedOption === 2 && !isSidebarCollapsed" style="width: 168px;" class="mr-2">

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


          <v-btn :color="toggleFocused === 0 ? 'primary' : 'white'"
                 id="focused-toggle"
                 :class="{'white--text': toggleFocused === 0, 'primary--text' : toggleFocused === 1}"
                 class="text-capitalize my-4 fix-toggle-opacity body-medium"
                 style="width: 50% !important;"
          >
            Focused
          </v-btn>
          <v-btn :color="toggleFocused === 1 ? 'primary' : 'white'"
                 id="focused-toggle"
                 :class="{'white--text': toggleFocused === 1, 'primary--text' : toggleFocused === 0}"
                 class="text-capitalize  fix-toggle-opacity body-medium"
                 style="width: 50% !important;"
          >
            All
          </v-btn>
        </v-btn-toggle>
      </div>
      <div v-else-if="selectedOption === 1 && !isSidebarCollapsed" style="width: 168px;" class="mr-2" @click="startReadNotesTimer('Clicked in the notes tab')">

        <v-btn-toggle
            v-model="toggleTimelineView"
            mandatory
            borderless
            color="primary"
            class="d-inline-block one-hunned body-medium"
            style="opacity: 1 !important;"
        >
          <v-btn :color="toggleTimelineView === 0 ? 'primary' : 'white'"
                 :class="{'white--text': toggleTimelineView === 0, 'primary--text' : toggleTimelineView === 1}"
                 class="text-capitalize my-4 fix-toggle-opacity body-medium"
                 style="width: 50% !important;"
                 @click="selectNotesActivityView"
          >
            Timeline
          </v-btn>
          <v-btn :color="toggleTimelineView === 1 ? 'primary' : 'white'"
                 :class="{'white--text': toggleTimelineView === 1, 'primary--text' : toggleTimelineView === 0}"
                 class="text-capitalize  fix-toggle-opacity body-medium"
                 style="width: 50% !important;"
                 @click="selectNotesActivityView"
          >
            Topic
          </v-btn>
        </v-btn-toggle>
      </div>
    </template>
    <template v-if="collapseBtnIcon" v-slot:collapse-btn-icon><v-icon>{{collapseBtnIcon}}</v-icon></template>
    <template v-slot:header-second-line>
      <TeamAssignmentChips
          v-if="showSmsTab && selectedOption === 0 && userCanViewSms"
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
      v-if="showSmsTab && selectedOption === 0"
      :primaryId="projectId"
      :userIdIn="userId"
      :user-assigned="userAssigned"
      :teams-associated-to-user="teamsAssociatedToUser"
    />

    <ActivitySection :contact-id="contactId" :user-id="userId"
                     :timeline-view="toggleTimelineView === 0"
                     :object-type-id="objectTypeId" :project-id="projectId"
                     :org-id="orgId" v-show="selectedOption === 1"
                     @scrollToTop="scrollToTop"

    />
    <AttachmentsFolderList v-if="selectedOption === 2"
                           :contact-id="contactId"
                           :user-id="userId"
                           :object-type-id="objectTypeId"
                           :org-id="orgId"
                           :force-show-upload-btn="forceShowUploadBtn"
                           :activity-tab="true"
                           :focused="toggleFocused === 0"
                           :project-id="projectId"
                           :reload-on-key-change="true"
                           :project-process-step-id="projectProcessStepId"
                           @scrollToTop="scrollToTop"
    />
    <v-dialog v-model="showHistoryDialog" max-width="800px">
                <OwnershipHistoryDrilldown
                    class="overflow-y-hidden"
                    :conversation-history="this.conversationHistory"
                    @historyDialogClosed="showHistoryDialog = false"
                ></OwnershipHistoryDrilldown>
    </v-dialog>
  </CollapsableRightPanel>
</template>

<script>

import ActivitySection from '@/views/flow/components/ActivitySection'
import Messaging from '@/views/flow/components/Messaging'
import AttachmentsFolderList from '@/views/flow/components/AttachmentsFolderList'
import { ProjectMutations } from '@/stores/ProjectStore'
import { AppMutations } from '@/stores/AppStore'
import {getRequest, getSnackbar, handleHidingGlobalLoader, postRequest} from '@/helpers/helpers'
import TeamAssignmentChips from '@/views/flow/settings/inbox/TeamAssignmentChips'
import OwnershipHistoryDrilldown from '@/views/flow/settings/inbox/OwnershipHistoryDrilldown'
import AddTeamDropdown from '@/views/flow/settings/inbox/AddTeamDropdown'
import ConfirmAssignmentDialog from '@/views/flow/settings/inbox/ConfirmAssignmentDialog'
import debounce from 'lodash.debounce'
import CollapsableRightPanel from "@/layouts/CollapsableRightPanel.vue";

export default {
  name: 'ProjectActivity',
  components: {
    CollapsableRightPanel,
    ConfirmAssignmentDialog,
    AddTeamDropdown,
    OwnershipHistoryDrilldown,
    TeamAssignmentChips,
    AttachmentsFolderList,
    ActivitySection,
    Messaging
  },
  props: {
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
    collapseBtnIcon: String
  },
  watch: {
    // whenever userImage changes, this function will run
    '$route.params.projectId': function() {
      this.projectId = parseInt(this.$route.params.projectId) || null
      this.selectedOption = this.$route.path.indexOf('inbox') > 0 ? 0 : (null == this.$store.state.project.selectedTab ? 1 : this.$store.state.project.selectedTab)
      if(this.selectedOption === 0) {
        this.fetchTeamsForUser()
      }
    },
    '$route.params.userId': function() {
      this.userId = parseInt(this.$route.params.userId) || null
      this.selectedOption = this.$route.path.indexOf('inbox') > 0 ? 0 : (null == this.$store.state.user.selectedTab ? 1 : this.$store.state.user.selectedTab)
      if(this.selectedOption === 0) {
        this.fetchTeamsForUser()
      }
    },
    '$route.params.viewId': function() {
      this.selectedOption = parseInt(this.$route.params.viewId)
    },
    smsOwnershipEvents: debounce(function() {
      this.fetchTeamsForUser()
    }, 800),
    selectedOption: function() {
      console.log('option changed to:', this.selectedOption)
      this.handlePageLoad()
    }
  },
  data() {
    return {
      userCanViewSms: this.$store.getters.userHasFeatureAccessLevel('SMS_INBOX', 'VIEW'),
      projectId: parseInt(this.$route.params.projectId) || null,
      userId: this.userIdIn ? this.userIdIn : parseInt(this.$route.params.userId) || null,
      projectProcessStepId: parseInt(this.$route.params.processStepId) || null,
      projectProcessStepEventId: parseInt(this.$route.params.ppsEventId) || null,
      selectedOption: this.$route.params.viewId ? parseInt(this.$route.params.viewId) :  this.showSmsTab && this.$route.path.indexOf('inbox') > 0 ? 0 : (null == this.$store.state.project.selectedTab || (this.$store.state.project.selectedTab === 0 && !this.showSmsTab)) ? 1 : this.$store.state.project.selectedTab,
      userHasTeam: false,
      userAssigned: false,
      showJoinConversationDialog: false,
      teamsAssociatedToUser: [],
      teamNamesAssociatedToUser: [],
      selectableTeams: [],
      messageProperties: {},
      currentUserId: this.$store.state.user.details.id,
      showHistoryDialog: false,
      teamsMenuOpen: false,
      myOwner: [],
      conversationHistory: [],
      conversationIsLoading: true,
      toggleFocused: this.isMobile ? 1 : 0,
      toggleFocusedXs: 0,
      toggleTimelineView: this.$store.state.project.notesActivityView,
    }
  },
  created() {
    this.handlePageLoad()
  },
  computed: {
    objectTypeId() {
      //not needed for other types
      return this.userId ? 3 : this.contactId ? 2 : this.orgId ? 5 : null
    },
    sidebarTitle() {
      switch (this.selectedOption) {
        case 0:
          if (this.userCanViewSms) {
            if (this.projectId) {
              return this.$route.path.includes('inboxConversation') ? this.messageProperties.projectName : 'Communication'
            }
            else {
              return this.$route.path.includes('inboxConversation') ? this.messageProperties.fullName : 'Communication'
            }
          } else {
            if (this.projectId) {
              return this.$route.path.includes('inboxConversation') ? this.messageProperties.projectName : 'Communication (Read-only)'
            }
            else {
              return this.$route.path.includes('inboxConversation') ? this.messageProperties.fullName : 'Communication (Read-only)'
            }
          }

        case 1:
          return this.orgId || this.userId || this.contactId || this.projectId ? 'Notes & Activities' : null
        case 2:
          return this.orgId || this.userId || this.contactId || this.projectId ? 'Documents' : null
      }
    },
    isSidebarCollapsed() {
      return this.allowSidebarCollapse && this.$store.state.project.rightSideSplit
    },
    smsOwnershipEvents() {
      return this.$store.getters.getEventsByTopic('sms_ownership').length
    },
    isMobile(){
      return this.$vuetify.breakpoint.smAndDown
    }
  },
  methods: {
    handlePageLoad() {
      //dont load the sms stuff if they aren't on the sms tab
      if (this.userCanViewSms && this.selectedOption === 0) {
        this.handleSmsLoad()
      }
    },
    handleSmsLoad() {
        //i dont think we should show the global spinner when the side section is loading
      // this.$store.commit(AppMutations.SET_LOADING, true)
      this.fetchTeamsForUser()
      this.getAvailableTeams()
      // this.$store.commit(AppMutations.SET_LOADING, false)
    },
    closeRight() {
      this.$emit('closeRight')
    },
    collapseSide() {
      this.$store.commit(ProjectMutations.RIGHT_SIDE_COLLAPSE)
    },
    selectView: function(viewOption) {
      this.$store.commit(ProjectMutations.SET_SELECTED_TAB, viewOption)
      this.selectedOption = viewOption
    },
    selectNotesActivityView(){
      if(this.toggleTimelineView === 0){
        this.$store.commit(ProjectMutations.SET_NOTES_ACTIVITY_VIEW, 1)
      } else {
        this.$store.commit(ProjectMutations.SET_NOTES_ACTIVITY_VIEW, 0)
      }
      this.scrollToTop()
    },
    scrollToTop(){
      document.querySelector('div.conversation-activity-inner-container').scroll({top:0})
    },
    startJoinConversation() {
      if (this.teamsAssociatedToUser?.length === 1) {
        const selectedSmsTeam = this.teamsAssociatedToUser[0]
        this.joinConversation(selectedSmsTeam)
      } else {
        // If the User has multiple teams available, have them select a team to join with first
        this.showJoinConversationDialog = true
      }
    },
    openMenu(){
      this.$store.state.project.leftSideSplit = false;
    },
    async joinConversation(selectedTeam) {
      try {
        if (this.projectId) {
          await postRequest(`/messaging/addTeam/project/${this.projectId}`, selectedTeam)
        }
        else if (this.userId) {
          await postRequest(`/messaging/addTeam/user/${this.userId}`, selectedTeam)
        }

        this.snackbar = getSnackbar('SUCCESS', 'Successfully joined conversation')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        await this.loadConversation()

      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error joining conversation')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async fetchTeamsForUser() {
      if(this.showSmsTab) {
        try {
          this.conversationIsLoading = true
          const { data, status } = await getRequest(`/smsTeam/getTeamsForUser/`, null, [])
          // this.$store.commit(AppMutations.SET_LOADING, false)
          this.teamsAssociatedToUser = data ?? []

          if (data != null && data.length > 0) {
            this.userHasTeam = true
            this.teamNamesAssociatedToUser = this.teamsAssociatedToUser.map(team => team.teamName)
          }
          // handleHidingGlobalLoader(this, status)
          await this.loadConversation()
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error fetching SMS Teams')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.conversationIsLoading = false
        }
      }
    },
    async loadConversation() {
      this.userAssigned = false
      if (this.projectId) {
        try {
          const { data, status } = await getRequest('/messaging/project/' + this.projectId)
          this.messageProperties = data
          this.messageProperties.smsTeamOwners?.forEach(team => {
            if (this.teamNamesAssociatedToUser.includes(team.teamName)) {
              team.users?.forEach(owner => {
                if (owner.userId === this.currentUserId) {
                  this.userAssigned = true
                  this.myOwner.push(owner)
                }
              })
            }
          })
          // handleHidingGlobalLoader(this, status)
          this.conversationIsLoading = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error fetching project messaging details')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.conversationIsLoading = false
        }
      }
      else if (this.userId) {
        try {
          const { data, status } = await getRequest('/messaging/user/' + this.userId)
          this.messageProperties = data
          this.messageProperties.smsTeamOwners?.forEach(team => {
            if (this.teamNamesAssociatedToUser.includes(team.teamName)) {
              team.users?.forEach(owner => {
                if (owner.userId === this.currentUserId) {
                  this.userAssigned = true
                  this.myOwner.push(owner)
                }
              })
            }
          })
          handleHidingGlobalLoader(this, status)
          this.conversationIsLoading = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error fetching user messaging details')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.conversationIsLoading = false
        }
      }
    },
    async getAvailableTeams() {
      // this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const { data, status } = await getRequest(`/smsTeam/users`)
        if (data) {
          this.selectableTeams = data
        }
        // handleHidingGlobalLoader(this, status)
        // this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        // this.$store.commit(AppMutations.SET_LOADING, false)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving teams')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async openHistoryDrilldown() {
      try {
        let historyUrl = ''
        if (this.projectId) {
          historyUrl = `/messaging/history/project/${this.projectId}`
        }
        else {
          historyUrl = `/messaging/history/user/${this.userId}`
        }
        const { data } = await getRequest(historyUrl)
        this.conversationHistory = data
        this.showHistoryDialog = true
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching history')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
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
