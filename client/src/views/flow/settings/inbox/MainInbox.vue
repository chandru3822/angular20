<template>
  <ThreeColumnLayout
    id="main-inbox-container"
    :header-hidden="true"
    :right-hidden="!$route.params.projectId"
    :left-hidden="true"
    :auto-overflow-left="true"
    :show-right-collapse-btn="false"
    @closeRight="$router.push({path: `/inbox`})"
  >
    <template v-slot:main-column>
      <ConfirmAssignmentDialog :show-join-conversation-dialog.sync="showAssignToMeDialog"
                               :teams-associated-to-user="teamsAssociatedToUser"
                               @joinConversation="joinConversation" />
      <v-toolbar prominent elevation="4" color="#F5F6F7" class="py-4 sticky-toolbar">
        <v-toolbar-items class="px-2 pt-0 d-flex flex-column col-12">
          <v-text-field
            prepend-inner-icon="search"
            text
            label="Search by project or owner"
            v-model="searchQuery"
            @input="searchProjects"
            class="albatross-body-2 mb-n4"
            clearable
          />
          <v-row class="px-2 toolbar-row-2">
            <v-checkbox
              v-model="showUnreadOnly"
              @change="reloadProjects"
              label="Show unread only"
              class="read-filter albatross-body-2 align-self-end pr-6 flex-shrink-0 default-text-color"
              :class="{'small-width': viewWidth===1264 && this.$route.path.includes('inboxConversation')}"
            >
            </v-checkbox>
            <v-chip label color="primary--text" class="sort-chip align-self-center albatross-body-2 mr-6 flex-shrink-0"
                    @click="sortOldToNew = !sortOldToNew">
              {{ sortOldToNew ? 'Oldest to Newest' : 'Newest to Oldest' }}
            </v-chip>
            <v-autocomplete v-model="selectedTeamFilters"
                            :items="teamFilterOptions"
                            item-text="teamName"
                            item-value="id"
                            prepend-icon="group"
                            class="filter-control albatross-body-2 align-self-end flex-shrink-1"
                            placeholder="Teams"
                            :menu-props="{offsetY:true}"
                            multiple
                            clearable
                            @input="teamSelectionChanged"
                            v-if="teamFilterOptions.length > 1">
              <v-list-item
                slot="prepend-item"
                ripple
                @click="toggleSelectAllTeams()"
              >
                <v-list-item-action>
                  <v-icon>{{ teamsIcon }}</v-icon>
                </v-list-item-action>
                <v-list-item-title>Select All</v-list-item-title>
              </v-list-item>
              <v-divider
                slot="prepend-item"
                class="mt-2"
              ></v-divider>
              <template
                slot="selection"
                slot-scope="{ item, index }"
              >
                <v-chip small
                        v-if="index <= teamFilterChipLimit && selectedTeamFilters && selectedTeamFilters.length <= teamFilterChipLimit">
                  <span>{{ item.teamName }}</span>
                </v-chip>
                <span
                  v-if="index === 0 && selectedTeamFilters && selectedTeamFilters.length > teamFilterChipLimit"
                  class="primary--text text-caption"
                >{{ selectedTeamFilters.length }} selected</span>
              </template>
            </v-autocomplete>
            <v-autocomplete v-model="selectedOwnerFilters"
                            :items="ownerFilterOptions"
                            item-text="name"
                            item-value="userId"
                            prepend-icon="person"
                            class="filter-control albatross-body-2 align-self-end flex-shrink-1"
                            placeholder="Owners"
                            :menu-props="{offsetY:true}"
                            @input="reloadProjects"
                            multiple
                            clearable>
              <v-list-item
                slot="prepend-item"
                ripple
                @click="toggleSelectAllOwners()"
              >
                <v-list-item-action>
                  <v-icon>{{ ownersIcon }}</v-icon>
                </v-list-item-action>
                <v-list-item-title>Select All</v-list-item-title>
              </v-list-item>
              <v-divider
                slot="prepend-item"
                class="mt-2"
              ></v-divider>
              <template
                slot="selection"
                slot-scope="{ item, index }"
              >
                <v-chip small
                        v-if="index <= ownerFilterChipLimit && selectedOwnerFilters && selectedOwnerFilters.length <= ownerFilterChipLimit">
                  <span>{{ item.userName }}</span>
                </v-chip>
                <span
                  v-if="index === 0 && selectedOwnerFilters && selectedOwnerFilters.length > ownerFilterChipLimit"
                  class="primary--text text-caption"
                >{{ selectedOwnerFilters.length }} selected</span>
              </template>
            </v-autocomplete>
            <v-spacer></v-spacer>
          </v-row>
        </v-toolbar-items>
      </v-toolbar>
      <v-data-table
        :items="projectsFiltered"
        :options.sync="options"
        disable-sort
        :mobile-breakpoint="0"
        :footer-props="footerProps"
        :server-items-length="totalProjects"
        hide-default-header
        class="elevation-1"
        id="inbox-message-list"
      >
        <template #no-data>
          <div class="default-text-color">No available conversations</div>
        </template>

        <template #no-results class="default-text-color">
          <div class="default-text-color">No available conversations</div>
        </template>

        <template #item="{ item, index }">
          <v-col class="inbox-row pa-6 clickable"
                 :class="{'selected': $route.params.projectId == item.projectId}"
                 @click="$router.push({path: `/inbox/inboxConversation/${item.projectId}`}); clearNotification(item.projectId)">
            <v-row class="justify-space-between flex-nowrap mx-0 pa-0">
              <v-col cols="11" class="pa-0">
                <div class="d-flex align-baseline"
                     :class="{'notif-div': (hasNotification(item.projectId))}">
                  <div>
                    <v-badge
                      dot
                      color="#F35858"
                      class="notif-badge"
                      v-if="hasNotification(item.projectId)"
                    >
                    </v-badge>
                    <b>{{ item.projectName }}</b>
                  </div>
                  <span v-if="item.messageHistory.length > 0"
                        class="albatross-body-2 px-2">{{ getTime(item.messageHistory[0].lastMessageSent)
                    }}</span>
                  <span class="albatross-body-2 px-1 grey--text text--darken-2">{{ item.state }}</span>
                </div>
                <div v-if="item.messageHistory.length > 0" class="text-ellipses">{{ item.messageHistory[0].message }}
                </div>
              </v-col>
            </v-row>
            <TeamAssignmentChips
              :sms-team-owners="item.smsTeamOwners"
              :team-names-associated-to-user="teamNamesAssociatedToUser"
              :reloading="reloadInProgress"
              :show-assign-to-me-button="false"
              :project-id="item.projectId"
              :project="item"
              show-selected-styles
              @updateOwner="fetchProjects"
              @joinConversation="[assignToMeProject = item, joinConversation()]"
            />
          </v-col>
        </template>
      </v-data-table>
    </template>
    <template v-slot:collapse-button>
      <v-btn class="d-inline-block align-self-center" small text color="primary"
             @click="$router.push({path: `/inbox`})">
        <v-icon>close</v-icon>
      </v-btn>
    </template>
  </ThreeColumnLayout>
</template>

<script>
import { AppMutations } from '@/stores/AppStore'
import Vue2Filters from 'vue2-filters'
import { getRequest, getSnackbar, handleHidingGlobalLoader, postRequest } from '@/helpers/helpers'
import constants from '@/helpers/constants'
import moment from 'moment'
import ThreeColumnLayout from '@/views/ThreeColumnLayout'
import TeamAssignmentChips from '@/views/flow/settings/inbox/TeamAssignmentChips'
import ConfirmAssignmentDialog from '@/views/flow/settings/inbox/ConfirmAssignmentDialog'
import { NotificationActions } from '@/plugins/notifications/NotificationStore'
import debounce from 'lodash.debounce'

export default {
  name: 'Inbox',
  components: {
    TeamAssignmentChips,
    ThreeColumnLayout,
    ConfirmAssignmentDialog
  },
  mixins: [Vue2Filters.mixin],
  constants,
  data() {
    return {
      userCanViewAll: this.$store.getters.userHasFeatureAccessLevel('SMS_INBOX', 'VIEW_ALL'),
      snackbar: {},
      projects: [],
      options: {
        itemsPerPage: 25
      },
      footerProps: {
        'items-per-page-options': [25, 50, 100],
        'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
      },
      searchQuery: '',
      constants,
      userId: this.$store.state.user.details.id,
      sortOldToNew: true,
      ownerFilterOptions: [],
      selectedOwnerFilters: [],
      teamFilterOptions: [],
      selectedTeamFilters: [],
      showUnreadOnly: false,
      showAssignToMeDialog: false,
      assignToMeProject: [],
      teamsAssociatedToUser: [],
      teamNamesAssociatedToUser: [],
      evtSource: '',
      thingsLoading: 0,
      viewWidth: window.innerWidth,
      selectableTeams: [],
      reloadInProgress: false,
      totalProjects: 0,
      initialLoad: true
    }
  },
  computed: {
    smsOwnershipEvents() {
      return this.$store.getters.getEventsByTopic('sms_ownership').length
    },
    smsNotification() {
      return this.$store.getters.getNotificationsByTopic('sms_reply')
    },
    projectsFiltered() {
      let projectList = this.projects
      return projectList.sort((a, b) => {
        return this.sortOldToNew ?
          (a.messageHistory.length > 0 ? new Date(a.messageHistory[0].lastMessageSent) : 0) - (b.messageHistory.length > 0 ? new Date(b.messageHistory[0].lastMessageSent) : 0) :
          (b.messageHistory.length > 0 ? new Date(b.messageHistory[0].lastMessageSent) : 0) - (a.messageHistory.length > 0 ? new Date(a.messageHistory[0].lastMessageSent) : 0)
      })
    },
    allTeamsSelected() {
      return this.selectedTeamFilters.length === this.teamFilterOptions.length
    },
    allOwnersSelected() {
      return this.selectedOwnerFilters.length === this.ownerFilterOptions.length
    },
    teamsIcon() {
      if (this.selectedTeamFilters.length === this.teamFilterOptions.length) {
        return 'check_box'
      }
      if (this.selectedTeamFilters.length > 0) {
        return 'indeterminate_check_box'
      }
      return 'check_box_outline_blank'
    },
    ownersIcon() {
      if (this.selectedOwnerFilters.length === this.ownerFilterOptions.length) {
        return 'check_box'
      }
      if (this.selectedOwnerFilters.length > 0) {
        return 'indeterminate_check_box'
      }
      return 'check_box_outline_blank'
    },
    teamFilterChipLimit() {
      if (this.viewWidth < 1264) {
        //smaller screen
        if (this.$route.path.includes('inboxConversation')) {
          //right panel open
          return 0
        }
        //right panel closed
        return 2
      }
      //larger screen
      if (this.$route.path.includes('inboxConversation')) {
        //right panel open
        return 1
      }
      //right panel closed
      return 3
    },
    ownerFilterChipLimit() {
      if (this.viewWidth < 1264) {
        //smaller screen
        if (this.$route.path.includes('inboxConversation')) {
          //right panel open
          return 0
        }
        //right panel closed
        return 3
      }
      //larger screen
      if (this.$route.path.includes('inboxConversation')) {
        //right panel open
        return 2
      }
      //right panel closed
      if (this.teamFilterOptions.length > 1) {
        //teams filter is showing
        return 4
      }
      //teams filter not showing
      return 6
    }
  },
  methods: {
    showLoading(isLoading) {
      if (isLoading) {
        if (this.thingsLoading == 0) {
          this.$store.commit(AppMutations.SET_LOADING, true)
        }
        this.thingsLoading++
      } else {
        this.thingsLoading--
        if (this.thingsLoading == 0) {
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    async fetchProjects() {
      try {
        this.showLoading(true)
        const { page, itemsPerPage } = this.options
        let filterData = {
          ownerUserIds: this.selectedOwnerFilters,
          smsTeamIds: this.selectedTeamFilters,
          notifProjectIds: this.showUnreadOnly ? (this.smsNotification?.length > 0 ? this.smsNotification?.map(n => n.metadata?.projectId) : [-1]) : []
        }

        const { data } = await postRequest(`/messaging/projects?size=${itemsPerPage}&page=${page - 1}&query=${this.searchQuery}`,
          filterData
        )

        if (data) {
          this.projects = data.content
          this.totalProjects = data?.totalElements || 0
          this.projects?.forEach(p => {
            p.showAssignToMeButton = this.teamsAssociatedToUser.length > 0
            p.smsTeamOwners.forEach(team => {
              team.users.forEach(owner => {
                if (owner.userId === this.userId) {
                  p.showAssignToMeButton = false
                }
              })
            })
          })
        }
        handleHidingGlobalLoader(this, status)
        this.showLoading(false)
        this.initialLoad = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching projects')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.showLoading(false)
      }
    },
    async reloadProjects() {
      try {
        this.showLoading(true)
        const { page, itemsPerPage } = this.options

        let filterData = {
          ownerUserIds: this.selectedOwnerFilters,
          smsTeamIds: this.selectedTeamFilters,
          notifProjectIds: this.showUnreadOnly ? (this.smsNotification?.length > 0 ? this.smsNotification?.map(n => n.metadata?.projectId) : [-1]) : []
        }

        const { data } = await postRequest(`/messaging/projects?size=${itemsPerPage}&page=${page - 1}&query=${this.searchQuery}`,
          filterData
        )

        if (data) {
          this.projects = data.content
          this.totalProjects = data?.totalElements || 0
          this.projects?.forEach(p => {
            p.showAssignToMeButton = this.teamsAssociatedToUser.length > 0
            p.smsTeamOwners.forEach(team => {
              team.users.forEach(owner => {
                if (owner.userId === this.userId) {
                  p.showAssignToMeButton = false
                }
              })
            })
          })
        }
        const projectIds = this.projects?.map(p => p.projectId)

        let projectId = parseInt(this.$route.params.projectId) || null
        // If the Project opened in the right panel no longer is available, close the right panel
        if (this.$route.path.includes('inboxConversation') && projectId != null && projectId !== 0 && !projectIds.includes(projectId)) {
          await this.$router.push({ path: `/inbox` })
        }
        handleHidingGlobalLoader(this, status)
        this.showLoading(false)
        this.reloadInProgress = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching projects')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.showLoading(false)
        this.reloadInProgress = false
      }
    },
    getTime(lastMessageSent) {
      const now = moment()
      const lastMessage = moment(lastMessageSent)

      // get the difference between the moments
      const diff = now.diff(lastMessage)
      const diffDuration = moment.duration(diff)

      if (diffDuration.years() > 0) {
        return moment(lastMessageSent).format('M/D/YYYY h:mm a')
      } else if (diffDuration.days() > 0 || diffDuration.hours() > 12) {
        return moment(lastMessageSent).format('M/D h:mm a')
      } else {
        return moment(lastMessageSent).fromNow()
      }
    },
    async joinConversation(selectedTeam) {
      try {
        if (this.teamsAssociatedToUser && this.teamsAssociatedToUser.length === 1) {
          selectedTeam = this.teamsAssociatedToUser[0]

        }
        // If the User has multiple teams available, have them select a team to join with first
        else if (this.teamsAssociatedToUser.length > 1 && !selectedTeam) {
          this.showAssignToMeDialog = true
          return
        }
        this.showLoading(true)
        await postRequest(`/messaging/addTeam/${this.assignToMeProject.projectId}`, selectedTeam)
        this.snackbar = getSnackbar('SUCCESS', 'Successfully joined conversation')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        if (!this.$route.path.includes('inboxConversation')) {
          //avoids redundant navigation console error
          this.$router.push({ path: `/inbox/inboxConversation/${this.assignToMeProject.projectId}` })
        }
        this.showLoading(false)
        this.showAssignToMeDialog = false
        await this.fetchProjects()
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error joining conversation')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.showLoading(false)
      }
    },
    async fetchTeamsForUser() {
      this.showLoading(true)
      try {
        const { data } = await getRequest(`/smsTeam/getTeamsForUser/`)
        this.showLoading(false)
        if (data && Array.isArray(data)) {
          this.teamsAssociatedToUser = data
          this.teamNamesAssociatedToUser = data?.map(team => team.teamName)
        }
        await this.getAvailableTeams()
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching SMS Teams')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.showLoading(false)
      }
    },
    hasNotification(projectId) {
      return this.smsNotification?.filter(n => n.metadata?.projectId === projectId)?.length > 0
    },
    clearNotification(projectId) {
      const notificationIds = this.smsNotification
        ?.filter(n => n.metadata.projectId === projectId)
        ?.map(notif => notif.id)

      this.$store.dispatch(NotificationActions.MARK_AS_READ, notificationIds)
    },
    toggleSelectAllTeams() {
      if (this.allTeamsSelected) {
        this.selectedTeamFilters = []
      } else {
        this.selectedTeamFilters = this.teamFilterOptions?.map(t => t.id)
      }
      this.reloadProjects()
    },
    toggleSelectAllOwners() {
      if (this.allOwnersSelected) {
        this.selectedOwnerFilters = []
      } else {
        this.selectedOwnerFilters = this.ownerFilterOptions?.map(o => o.userId)
      }
      this.reloadProjects()
    },
    onResize() {
      this.viewWidth = window.innerWidth
    },
    async getAvailableTeams() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const { data, status } = await getRequest(`/smsTeam/users`)
        this.selectableTeams = data
        this.selectableTeams.forEach(team => {
          if (this.teamNamesAssociatedToUser.includes(team.teamName)) {
            if (!this.teamAlreadyAddedToFilter(team)) {
              this.teamFilterOptions.push(team)
            }

            if (!this.selectedTeamFilters.includes(team.id)) {
              this.selectedTeamFilters.push(team.id)
            }

            team.users.forEach(owner => {
              if (!this.ownerAlreadyAddedToFilter(owner)) {
                this.ownerFilterOptions.push(owner)

                if (owner.userId === this.userId) {
                  this.selectedOwnerFilters.push(owner.userId)
                }
              }
            })
          } else if (this.userCanViewAll) {
            if (!this.teamAlreadyAddedToFilter(team)) {
              this.teamFilterOptions.push(team)
            }

            team.users.forEach(owner => {
              if (!this.ownerAlreadyAddedToFilter(owner)) {
                this.ownerFilterOptions.push(owner)
              }
            })
          }
        })

        this.ownerFilterOptions.push({ name: 'Unassigned', userName: 'Unassigned', id: -1, userId: -1 })

        this.teamFilterOptions.sort((a,b)=>{
          if(a.teamName < b.teamName) {
            return -1
          }
          if(a.teamName > b.teamName) {
            return 1
          }
          return 0
        })

        this.ownerFilterOptions.sort((a,b)=>{
          if(a.name < b.name) {
            return -1
          }
          if(a.name > b.name) {
            return 1
          }
          return 0
        })

        if (!this.selectedOwnerFilters.includes(-1)) {
          this.selectedOwnerFilters.push(-1)
        }
        handleHidingGlobalLoader(this, status)
        this.$store.commit(AppMutations.SET_LOADING, false)
        await this.fetchProjects()
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.$store.commit(AppMutations.SET_LOADING, false)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving teams')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    ownerAlreadyAddedToFilter(ownerToAdd) {
      let alreadyAdded = false
      this.ownerFilterOptions.forEach(o => {
        if (o.userId === ownerToAdd.userId) {
          alreadyAdded = true
        }
      })
      return alreadyAdded
    },
    teamAlreadyAddedToFilter(teamToAdd) {
      let alreadyAdded = false
      this.teamFilterOptions.forEach(t => {
        if (t.id === teamToAdd.id) {
          alreadyAdded = true
        }
      })
      return alreadyAdded
    },
    teamSelectionChanged() {
      this.options.page = 1
      this.reloadProjects()
    },
    searchProjects: debounce(function() {
      //don't allow searchQuery to be null - causes issues
      this.searchQuery = this.searchQuery || ''
      this.reloadProjects()
    }, 500)
  },
  watch: {
    smsOwnershipEvents: debounce(function() {
      this.fetchTeamsForUser()
      this.reloadProjects()
    }, 500),
    options: {
      handler() {
        if (!this.initialLoad) {
          this.reloadProjects()
        }
      }
    }
  },
  created() {
    this.fetchTeamsForUser()
    window.addEventListener('resize', this.onResize)
  }
}
</script>

<style lang="scss">
#inbox-message-list .v-data-table__wrapper table,
#inbox-message-list .v-data-table__wrapper tbody{
  width: 100% !important;
  max-width: 100% !important;
  display: block;
}
</style>

<style scoped lang="scss">
.sticky-toolbar {
  position: sticky;
  top: 0;
  z-index: 1; //just to get it in front of the rest of the section
  @media (max-width: 1264px) {
    height: max-content !important;
  }
}

.toolbar-row-2 {
  display: flex;
  flex-wrap: nowrap;
  position: relative;
  bottom: 1rem;

  @media (max-width: 1264px) {
    flex-wrap: wrap;
    bottom: 0;
  }
}

.read-filter.small-width {
  @media (max-width: 1264px) {
    position: relative;
    top: 0.75rem;
  }
}

.inbox-row {
  min-height: 94px;
  width: 100%;
  border-bottom: 1px solid var(--v-grey-lighten1);
  background-color: white;
}

.selected {
  background-color: var(--v-primary-lighten9);
}

a {
  text-decoration: none;
}

.notif-badge {
  margin-right: 10px;
  margin-bottom: 5px;
}

.notif-div {
  margin-left: 2px;
}

.filter-control {
  margin-right: 24px;
  bottom: -8px;

  @media (max-width: 1264px) {
    max-width: 45%;
  }
}

.sort-chip {
  background: #FFFFFF !important;
  font-weight: 500;
}

.team-select {
  max-width: 300px;
  margin-left: 10px;
}

.text-ellipses {
  width: 100%;
  display: block;
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
}

.assigned-join-button {
  background-color: #C0C0C0;
  color: #1F3C73 !important;
}

.unassigned-join-button {
  background-color: #1F3C73 !important;
}

</style>
