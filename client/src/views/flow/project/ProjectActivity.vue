<template>
  <v-row id="project-activity-container" class="flex-column flex-nowrap" no-gutters>
<!--      <v-toolbar color="transparent" class="elevation-0" id="right-sidebar-title">-->
<!--        <v-toolbar-title v-show="!isCollapsed">{{ sidebarTitle }}</v-toolbar-title>-->
<!--        <v-spacer v-if="!$store.state.project.rightSideSplit"></v-spacer>-->
<!--        <v-toolbar-items>-->
<!--          <div>-->
<!--            <v-btn small text class="mt-1" @click="collapseSide()">-->
<!--              <v-icon>mdi-menu</v-icon>-->
<!--            </v-btn>-->
<!--          </div>-->
<!--        </v-toolbar-items>-->
<!--      </v-toolbar>-->
    <div class="project-activity-header-container" :class="{'pt-n2':selectedOption === 0}">
      <div class="albatross-header-3 pt-0 d-flex align-center project-activity-header"
           :class="{'title-collapse': $store.state.project.rightSideSplit,
                    'title-no-collapse': !$store.state.project.rightSideSplit}">
        <v-tooltip bottom small v-if="$route.path.includes('inboxConversation')"><template v-slot:activator="{on, attrs}">
        <div v-if="!$store.state.project.rightSideSplit"
             v-bind="attrs" v-on="on"
             class="d-inline-block clickable"
             @click="clickRightSideTitle">{{projectMessageProperties.projectName}}</div>
        </template>
          <span class="albatross-body-3">Go to project</span>
        </v-tooltip>
        <div v-else-if="!$store.state.project.rightSideSplit"
             class="d-inline-block"
             >{{sidebarTitle}}</div>
        <v-spacer v-if="!$store.state.project.rightSideSplit"></v-spacer>
        <div v-if="selectedOption === 0 && !$store.state.project.rightSideSplit">
          <v-tooltip bottom small>
            <template v-slot:activator="{on, attrs}">
          <v-btn icon @click="openHistoryDrilldown" v-bind="attrs" v-on="on"><v-icon>mdi-history</v-icon></v-btn>
            </template><span class="albatross-body-3">History</span></v-tooltip>
          <v-dialog v-model="showHistoryDialog" max-width="800px">
            <OwnershipHistoryDrilldown
                class="overflow-y-hidden"
                :project-history="this.projectHistory"
                @historyDialogClosed="showHistoryDialog = false"
            ></OwnershipHistoryDrilldown>
          </v-dialog>

        </div>
        <v-btn v-if="$route.path.indexOf('inbox') > 0" class="d-inline-block align-self-center" small text @click="closeRight()">
          <v-icon>close</v-icon>
        </v-btn>
        <v-btn v-else class="d-inline-block" small text @click="collapseSide()">
          <v-icon>mdi-menu</v-icon>
        </v-btn>
      </div>
    <span v-if="selectedOption === 0 && !$store.state.project.rightSideSplit" class="pl-6 albatross-body-3 mt-n2">Members</span>
    <TeamAssignmentChips v-if="selectedOption === 0 && !$store.state.project.rightSideSplit"
                         :sms-team-owners="projectMessageProperties.smsTeamOwners"
                         :team-names-associated-to-user="teamNamesAssociatedToUser"
                         :reloading="projectIsLoading"
                         :show-assign-to-me-button="!userAssigned && userHasTeam"
                         :project-id="projectId"
                         class="px-6 pb-1 mt-n1"
                         @updateOwner="loadProject"
                         @joinConversation="startJoinConversation"
    />

<!--      i show this line regardless of selected tab so that the mb-3 sticks around. otherwise need to add it to the element above for only options 0 & 1-->
      <div class="sidebar-subtitle mb-3" v-if="!$store.state.project.rightSideSplit">{{sidebarSubTitle}}</div>
    </div>
<v-divider v-if="selectedOption === 0 && !$store.state.project.rightSideSplit"></v-divider>
      <div class="project-activity-inner-container">
        <div v-show="!$store.state.project.rightSideSplit" class="height-one-hunned">
          <Messaging v-if="selectedOption === 0" :primaryId="projectId" :user-assigned="userAssigned"/>
          <ProjectNotes v-else-if="selectedOption === 1"></ProjectNotes>
          <AttachmentsDropdown v-else :projectId="projectId" :project-process-step-id="projectProcessStepId"/>
        </div>
      </div>
      <div class="footer-container"
           :style="{'width': $store.state.project.rightSideSplit ? '72px' : '100%',
                    }">
        <v-row
          :value="selectedOption"
          color="primaryButton"
          :style="{'flex-direction': $store.state.project.rightSideSplit ? 'column' : 'row',
                      'width': $store.state.project.rightSideSplit ? 'calc(100% - 45px)' : '100%'}"
          class="section-footer ma-0" :class="{'px-4': !$store.state.project.rightSideSplit}"
        >
          <v-col cols="4" class="px-0">
            <v-btn text block elevation="0" @click="selectView(0)" :dark="selectedOption === 0"
                   :class="{'section-selected': selectedOption===0}">
              <v-icon>mdi-forum-outline</v-icon>
            </v-btn>
          </v-col>
          <v-col cols="4" class="px-0">
            <v-btn text block elevation="0" @click="selectView(1)" :dark="selectedOption === 1"
                   :class="{'section-selected': selectedOption===1}">
              <v-icon>mdi-text-long</v-icon>
            </v-btn>
          </v-col>
          <v-col cols="4" class="px-0">
            <v-btn text block elevation="0" @click="selectView(2)" :dark="selectedOption === 2"
                   :class="{'section-selected': selectedOption===2}">
              <v-icon>mdi-folder-outline</v-icon>
            </v-btn>
          </v-col>
        </v-row>
      </div>
    <ConfirmAssignmentDialog :show-join-conversation-dialog.sync="showJoinConversationDialog"
                             :teams-associated-to-user="teamsAssociatedToUser"
                             @joinConversation="joinConversation"
    ></ConfirmAssignmentDialog>
  </v-row>
</template>

<script>

import SpinnerInline from '@/components/SpinnerInline'
import ProjectNotes from '@/views/flow/project/ProjectNotes'
import Messaging from '@/views/flow/components/Messaging'
import AttachmentsDropdown from "@/views/flow/components/AttachmentsDropdown";
import {ProjectMutations} from '@/stores/ProjectStore'
import {AppMutations} from "@/stores/AppStore";
import {getRequest, getSnackbar, postRequest, putRequest} from "@/helpers/helpers";
import TeamAssignmentChips from "@/views/flow/settings/inbox/TeamAssignmentChips";
import OwnershipHistoryDrilldown from "@/views/flow/settings/inbox/OwnershipHistoryDrilldown";
import AddTeamDropdown from "@/views/flow/settings/inbox/AddTeamDropdown";
import ConfirmDeleteDialog from "@/ConfirmDeleteDialog";
import ConfirmAssignmentDialog from "@/views/flow/settings/inbox/ConfirmAssignmentDialog";
import constants from "@/helpers/constants";

export default {
  name: 'ProjectActivity',
  components: {
    ConfirmAssignmentDialog,
    ConfirmDeleteDialog,
    AddTeamDropdown,
    OwnershipHistoryDrilldown,
    TeamAssignmentChips,
    SpinnerInline,
    AttachmentsDropdown,
    ProjectNotes,
    Messaging,
  },
  props: {},
  watch: {
    // whenever userImage changes, this function will run
    '$route.params.projectId': function () {
      this.projectId = parseInt(this.$route.params.projectId) | null
      this.fetchTeamsForUser()
      this.selectedOption= this.$route.path.indexOf('inbox') > 0 ? 0 : (null == this.$store.state.project.selectedTab ? 1 : this.$store.state.project.selectedTab)
    }
  },
  data() {
    return {
      userCanViewSms: this.$store.getters.userHasFeatureAccessLevel('SMS_INBOX', 'VIEW'),
      projectId: parseInt(this.$route.params.projectId) || null,
      projectProcessStepId: parseInt(this.$route.params.processStepId) || null,
      projectProcessStepEventId: parseInt(this.$route.params.ppsEventId) || null,
      selectedOption: this.$route.path.indexOf('inbox') > 0 ? 0 : (null == this.$store.state.project.selectedTab ? 1 : this.$store.state.project.selectedTab),
      userHasTeam: false,
      userAssigned: false,
      showJoinConversationDialog: false,
      teamsAssociatedToUser: [],
      teamNamesAssociatedToUser: [],
      selectableTeams: [],
      projectMessageProperties: {},
      userId: this.$store.state.user.details.id,
      showHistoryDialog: false,
      teamsMenuOpen: false,
      myOwner: [],
      projectHistory: [],
      projectIsLoading: true
    }
  },
  created() {
    this.$store.commit(AppMutations.SET_LOADING, true)
    this.fetchTeamsForUser();
    this.getAvailableTeams()
    this.$store.commit(AppMutations.SET_LOADING, false)
  },
  mounted() {
    this.evtSource = new EventSource(`${constants.VUE_APP_BASE_API}/api/v1/flow/notifications/stream?access_token=${this.$store.state.user.jwt}`)
    this.evtSource.addEventListener('sms_ownership', function(e) {
      const data = JSON.parse(e.data)
      if (data) {
        this.fetchTeamsForUser()
      }
    }.bind(this))
  },
  beforeDestroy() {
    if (this.evtSource){
      this.evtSource.close()
    }
  },
  computed: {
    sidebarTitle() {
      switch (this.selectedOption) {
        case 0:
          if (this.userCanViewSms) {
            return this.$route.path.includes("inboxConversation") ? this.projectMessageProperties.projectName : "Project Communication"
          }
          else {
            return this.$route.path.includes("inboxConversation") ? this.projectMessageProperties.projectName : "Project Communication (Read-only)"
          }

        case 1:
          return "Project Notes"
        case 2:
          return this.$route.params.ppsEventId ? 'Event Documents' : this.$route.params.processStepId ? 'Process Step Documents' : 'Project Documents'
      }
    },
    sidebarSubTitle() {
      switch (this.selectedOption) {
        case 0:
          return ''
        case 1:
          return ''
        case 2:
          return this.$route.params.ppsEventId ? 'Documents related to the selected event.' : this.$route.params.processStepId ? 'Documents related to the selected process step.' : 'Documents related to the selected project.'
      }
    },
    isSidebarCollapsed() {
      debugger
        return !this.$route.path.indexOf('inbox') && this.$store.state.project.rightSideSplit
    }
  },
  methods: {
    closeRight() {
      this.$emit('closeRight')
    },
    collapseSide() {
      this.$store.commit(ProjectMutations.RIGHT_SIDE_COLLAPSE)
    },
    clickRightSideTitle() {
      if(this.$route.path.includes("inboxConversation")){
        this.$router.push(`/project/${this.projectId}/details`)
      }
    },
    selectView: function (viewOption) {
      this.$store.commit(ProjectMutations.SET_SELECTED_TAB, viewOption)
      this.selectedOption = viewOption;
      if (this.$store.state.project.rightSideSplit) {
        this.collapseSide()
        this.$emit('openRight');
      }
    },
    startJoinConversation() {
      if (this.teamsAssociatedToUser && this.teamsAssociatedToUser.length === 1) {
        const selectedSmsTeam = this.teamsAssociatedToUser[0]
        this.joinConversation(selectedSmsTeam)
      }
      // If the User has multiple teams available, have them select a team to join with first
      else {
        this.showJoinConversationDialog = true;
      }
    },
    async joinConversation(selectedTeam) {
      try {
        const {data, status} = await postRequest(`/messaging/addTeam/${this.projectId}`, selectedTeam)
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
      try {
        this.projectIsLoading = true;
        const {data, status} = await getRequest(`/smsTeam/getTeamsForUser/`)
        this.$store.commit(AppMutations.SET_LOADING, false)
        this.teamsAssociatedToUser = data;

        if (data != null && data.length > 0) {
          this.userHasTeam = true
          this.teamsAssociatedToUser.forEach(team => {
            this.teamNamesAssociatedToUser.push(team.teamName)
          })
        }

        await this.loadProject();
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching SMS Teams')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.projectIsLoading = false;
      }
    },
    async loadProject() {
      this.userAssigned = false
      try {
        const {data, status} = await getRequest('/messaging/projects/'+this.projectId);
        this.projectMessageProperties = data
        this.projectMessageProperties.smsTeamOwners?.forEach(team => {
          if (this.teamNamesAssociatedToUser.includes(team.teamName)) {
            team.users?.forEach(owner => {
              if (owner.userId === this.userId) {
                this.userAssigned = true
                this.myOwner.push(owner)
              }
            })
          }
        })


        this.projectIsLoading = false;
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching project messaging details')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.projectIsLoading = false;
      }
    },
    async getAvailableTeams() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/smsTeam/users`)
        if (data) {
          this.selectableTeams = data
        }
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
        const {data} = await getRequest(`/messaging/history/${this.projectId}`)
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

.sidebar-subtitle {
  margin-left: 24px;
  font-size: 14px;
}

.section-footer {
  display: flex;
  align-items: center;
}

.section-selected {
  background-color: var(--v-primaryCustom-base) !important;
}

.section-not-selected {
  background-color: white;
}

.right-expander-button {
  margin-right: 10px;
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
</style>

<style lang="scss">
#right-sidebar-title .v-toolbar__content {
  display: flex;
  align-items: flex-start;
}
</style>
