<template>
  <v-row id="project-activity-container" class="flex-column flex-nowrap" no-gutters>
    <div class="project-activity-header-container" :class="{'pt-n2':selectedOption === 0}">
      <div class="albatross-header-3 pt-0 d-flex align-center project-activity-header"
           :class="{'title-collapse': isSidebarCollapsed,
                    'title-no-collapse': !isSidebarCollapsed,
                    'ml-2': isSidebarCollapsed && $route.path.indexOf('project') < 0,
                    'mt-0': $route.path.indexOf('project') < 0}">
        <v-tooltip bottom small v-if="showSmsTab && $route.path.includes('inboxConversation')">
          <template v-slot:activator="{on, attrs}">
            <a v-if="!isSidebarCollapsed"
               v-bind="attrs" v-on="on"
               class="d-inline-block clickable project-name-link"
              :href="`/project/${projectId}/details`">
              {{ projectMessageProperties.projectName }}
            </a>
          </template>
          <span class="albatross-body-3">Go to project</span>
        </v-tooltip>
        <div v-else-if="!isSidebarCollapsed" >
          {{sidebarTitle}}
        </div>
        <v-spacer v-if="!isSidebarCollapsed"></v-spacer>
        <div v-if="showSmsTab && selectedOption === 0 && userCanViewSms && !isSidebarCollapsed">
          <v-tooltip bottom small>
            <template v-slot:activator="{on, attrs}">
              <v-btn icon color="primary" @click="openHistoryDrilldown" v-bind="attrs" v-on="on">
                <v-icon>mdi-history</v-icon>
              </v-btn>
            </template>
            <span class="albatross-body-3">History</span></v-tooltip>
          <v-dialog v-model="showHistoryDialog" max-width="800px">
            <OwnershipHistoryDrilldown
              class="overflow-y-hidden"
              :project-history="this.projectHistory"
              @historyDialogClosed="showHistoryDialog = false"
            ></OwnershipHistoryDrilldown>
          </v-dialog>

        </div>
        <div v-else-if="selectedOption === 2 && !isSidebarCollapsed">
          <v-btn-toggle
              v-model="toggleFocused"
              mandatory
              borderless
              color="primary"
              class="d-inline-block pa-0">
            <v-btn :color="toggleFocused === 0 ? 'primary' : 'white'"
                   :class="{'white--text': toggleFocused === 0, 'primary--text' : toggleFocused === 1}"
                   class="text-capitalize"
                   width="50%"
            >
              Focused
            </v-btn>
            <v-btn :color="toggleFocused === 1 ? 'primary' : 'white'"
                   :class="{'white--text': toggleFocused === 1, 'primary--text' : toggleFocused === 0}"
                   class="text-capitalize"
                   width="50%"
            >
              All
            </v-btn>
          </v-btn-toggle>
        </div>
        <slot name="collapse-button">
        <v-btn class="d-inline-block align-self-center" :class="{'title-collapsed': $store.state.project.rightSideSplit}" small text color="primary" @click="collapseSide()">
          <v-icon>mdi-menu</v-icon>
        </v-btn>
        </slot>
      </div>
      <span v-if="showSmsTab && selectedOption === 0 && !isSidebarCollapsed && userCanViewSms" class="pl-6 albatross-body-3 mt-n2">Members</span>
      <TeamAssignmentChips
        v-if="showSmsTab && selectedOption === 0 && !isSidebarCollapsed && userCanViewSms"
        :sms-team-owners="projectMessageProperties.smsTeamOwners"
        :team-names-associated-to-user="teamNamesAssociatedToUser"
        :reloading="projectIsLoading"
        :show-assign-to-me-button="!userAssigned && userHasTeam"
        :project-id="projectId"
        class="px-6 pb-1 mt-n1"
        @updateOwner="loadProject"
        @joinConversation="startJoinConversation"
      />

      <!-- i show this line regardless of selected tab so that the mb-3 sticks around. otherwise need to add it to the element above for only options 0 & 1-->
      <div class="mb-3" v-if="!isSidebarCollapsed"></div>
    </div>
    <v-divider v-if="selectedOption === 0 && !isSidebarCollapsed"></v-divider>
    <div class="project-activity-inner-container">
      <div v-show="!isSidebarCollapsed" class="height-one-hunned">
        <Messaging v-if="showSmsTab && selectedOption === 0" :primaryId="projectId" :user-assigned="userAssigned" />
        <ProjectNotes :contact-id="contactId" :user-id="userId"
                      :object-type-id="objectTypeId" :project-id="projectId"
                      :org-id="orgId" v-else-if="selectedOption === 1"></ProjectNotes>
        <div v-else-if="selectedOption === 2">
          <AttachmentsFolderList :contact-id="contactId"
                               :user-id="userId"
                               :object-type-id="objectTypeId"
                               :org-id="orgId"
                               :force-show-upload-btn="forceShowUploadBtn"
                               :activity-tab="true"
                               :focused="toggleFocused === 0"
                               :project-id="projectId"
                               :project-process-step-id="projectProcessStepId" />
        </div>
      </div>
    </div>
    <div class="footer-container"
         :style="{'width': isSidebarCollapsed ? '72px' : '100%',
                    }">
      <v-row
        :value="selectedOption"
        :style="{'flex-direction': isSidebarCollapsed ? 'column' : 'row',
                      'width': isSidebarCollapsed ? 'calc(100% - 45px)' : '100%'}"
        class="section-footer ma-0" :class="{'px-4': !isSidebarCollapsed}"
      >
        <v-col cols="4" class="px-0">
          <v-btn v-if="showSmsTab" text  :color="selectedOption === 0 ? 'white' : 'primary'" block elevation="0" @click="selectView(0)" :dark="selectedOption === 0"
                 :class="{'section-selected': selectedOption===0}">
            <v-icon>mdi-forum-outline</v-icon>
          </v-btn>
        </v-col>
        <v-col cols="4" class="px-0">
          <v-btn text :color="selectedOption === 1 ? 'white' : 'primary'" block elevation="0" @click="selectView(1)" :dark="selectedOption === 1"
                 :class="{'section-selected': selectedOption===1}">
            <v-icon>mdi-text-long</v-icon>
          </v-btn>
        </v-col>
        <v-col cols="4" class="px-0">
          <v-btn text :color="selectedOption === 2 ? 'white' : 'primary'" block elevation="0" @click="selectView(2)" :dark="selectedOption === 2"
                 :class="{'section-selected': selectedOption===2}">
            <v-icon>mdi-folder-outline</v-icon>
          </v-btn>
        </v-col>
      </v-row>
    </div>
    <ConfirmAssignmentDialog
      :show-join-conversation-dialog.sync="showJoinConversationDialog"
      :teams-associated-to-user="teamsAssociatedToUser"
      @joinConversation="joinConversation" />
  </v-row>
</template>

<script>

import SpinnerInline from '@/components/SpinnerInline'
import ProjectNotes from '@/views/flow/project/ProjectNotes'
import Messaging from '@/views/flow/components/Messaging'
import AttachmentsFolderList from '@/views/flow/components/AttachmentsFolderList'
import { ProjectMutations } from '@/stores/ProjectStore'
import { AppMutations } from '@/stores/AppStore'
import {getRequest, getSnackbar, handleHidingGlobalLoader, postRequest} from '@/helpers/helpers'
import TeamAssignmentChips from '@/views/flow/settings/inbox/TeamAssignmentChips'
import OwnershipHistoryDrilldown from '@/views/flow/settings/inbox/OwnershipHistoryDrilldown'
import AddTeamDropdown from '@/views/flow/settings/inbox/AddTeamDropdown'
import ConfirmDeleteDialog from '@/ConfirmDeleteDialog'
import ConfirmAssignmentDialog from '@/views/flow/settings/inbox/ConfirmAssignmentDialog'
import debounce from 'lodash.debounce'

export default {
  name: 'ProjectActivity',
  components: {
    ConfirmAssignmentDialog,
    ConfirmDeleteDialog,
    AddTeamDropdown,
    OwnershipHistoryDrilldown,
    TeamAssignmentChips,
    SpinnerInline,
    AttachmentsFolderList,
    ProjectNotes,
    Messaging
  },
  props: {
    showSmsTab: {
      type: Boolean,
      default: true
    },
    contactId: Number,
    userId: Number,
    orgId: Number,
    forceShowUploadBtn: Boolean,
    allowSidebarCollapse: {
      type: Boolean,
      default: true
    }
  },
  watch: {
    // whenever userImage changes, this function will run
    '$route.params.projectId': function() {
      this.projectId = parseInt(this.$route.params.projectId) || null
      this.fetchTeamsForUser()
      this.selectedOption = this.$route.path.indexOf('inbox') > 0 ? 0 : (null == this.$store.state.project.selectedTab ? 1 : this.$store.state.project.selectedTab)
    },
    smsOwnershipEvents: debounce(function() {
      this.fetchTeamsForUser()
    }, 500)
  },
  data() {
    return {
      //todo change this back after soft roll out is done @softRollOutChangeBack
      userCanViewSms: true,
      // userCanViewSms: this.$store.getters.userHasFeatureAccessLevel('SMS_INBOX', 'VIEW'),
      projectId: parseInt(this.$route.params.projectId) || null,
      projectProcessStepId: parseInt(this.$route.params.processStepId) || null,
      projectProcessStepEventId: parseInt(this.$route.params.ppsEventId) || null,
      selectedOption: this.showSmsTab && this.$route.path.indexOf('inbox') > 0 ? 0 : (null == this.$store.state.project.selectedTab || (this.$store.state.project.selectedTab === 0 && !this.showSmsTab)) ? 1 : this.$store.state.project.selectedTab,
      userHasTeam: false,
      userAssigned: false,
      showJoinConversationDialog: false,
      teamsAssociatedToUser: [],
      teamNamesAssociatedToUser: [],
      selectableTeams: [],
      projectMessageProperties: {},
      currentUserId: this.$store.state.user.details.id,
      showHistoryDialog: false,
      teamsMenuOpen: false,
      myOwner: [],
      projectHistory: [],
      projectIsLoading: true,
      toggleFocused: 1
    }
  },
  created() {
    if(this.userCanViewSms) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      this.fetchTeamsForUser()
      this.getAvailableTeams()
      this.$store.commit(AppMutations.SET_LOADING, false)
    }
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
            return this.$route.path.includes('inboxConversation') ? this.projectMessageProperties.projectName : 'Project Communication'
          } else {
            return this.$route.path.includes('inboxConversation') ? this.projectMessageProperties.projectName : 'Project Communication (Read-only)'
          }

        case 1:
          return this.orgId ? 'Organization Notes' : this.userId ? 'User Notes'
              : this.contactId ? 'Contact Notes' : this.projectId ? 'Project Notes' : null
        case 2:
          return this.orgId ? 'Organization Documents' : this.userId ? 'User Documents' : this.contactId ? 'Contact Documents'
              : this.projectId ? 'Project Documents' : null
      }
    },
    isSidebarCollapsed() {
      return this.allowSidebarCollapse && this.$store.state.project.rightSideSplit
    },
    smsOwnershipEvents() {
      return this.$store.getters.getEventsByTopic('sms_ownership').length
    }
  },
  methods: {
    closeRight() {
      this.$emit('closeRight')
    },
    collapseSide() {
      this.$store.commit(ProjectMutations.RIGHT_SIDE_COLLAPSE)
    },
    selectView: function(viewOption) {
      this.$store.commit(ProjectMutations.SET_SELECTED_TAB, viewOption)
      this.selectedOption = viewOption
      if (this.isSidebarCollapsed) {
        this.collapseSide()
        this.$emit('openRight')
      }
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
    async joinConversation(selectedTeam) {
      try {
        await postRequest(`/messaging/addTeam/${this.projectId}`, selectedTeam)
        this.snackbar = getSnackbar('SUCCESS', 'Successfully joined conversation')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        await this.loadProject()

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
          this.projectIsLoading = true
          const { data, status } = await getRequest(`/smsTeam/getTeamsForUser/`)
          this.$store.commit(AppMutations.SET_LOADING, false)
          this.teamsAssociatedToUser = data

          if (data != null && data.length > 0) {
            this.userHasTeam = true
            this.teamNamesAssociatedToUser = this.teamsAssociatedToUser.map(team => team.teamName)
          }
          handleHidingGlobalLoader(this, status)
          await this.loadProject()
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error fetching SMS Teams')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.projectIsLoading = false
        }
      }
    },
    async loadProject() {
      this.userAssigned = false
      try {
        const { data, status } = await getRequest('/messaging/projects/' + this.projectId)
        this.projectMessageProperties = data
        this.projectMessageProperties.smsTeamOwners?.forEach(team => {
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
        this.projectIsLoading = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching project messaging details')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.projectIsLoading = false
      }
    },
    async getAvailableTeams() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const { data, status } = await getRequest(`/smsTeam/users`)
        if (data) {
          this.selectableTeams = data
        }
        handleHidingGlobalLoader(this, status)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.$store.commit(AppMutations.SET_LOADING, false)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving teams')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async openHistoryDrilldown() {
      try {
        const { data } = await getRequest(`/messaging/history/${this.projectId}`)
        this.projectHistory = data
        this.showHistoryDialog = true
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching history')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    }
  }
}
</script>

<style lang="scss" scoped>
#project-activity-container {
  height: 100%;
  width: 100%;
  position: relative;
}

.project-activity-inner-container {
  overflow: auto;
  flex-grow: 4;
}

.project-activity-header {
  height: 41px;
}

.project-activity-content {
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

.project-name-link {
  text-decoration: none;
}

.v-btn-toggle .v-btn {
  border: 1px solid var(--v-primary-base) !important;
  height: 30px !important;
  width: 166px !important;

  &:not(:last-child) {
    border-right: none !important;
  }
}
</style>

<style lang="scss">
#right-sidebar-title .v-toolbar__content {
  display: flex;
  align-items: flex-start;
}
</style>
