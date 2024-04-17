<template>
  <ThreeColumnLayout
    id="main-inbox-container"
    :header-hidden="true"
    :right-hidden="!route.params.projectId && !route.params.userId"
    :left-hidden="true"
    :half-n-half="true"
    :auto-overflow-left="true"
    :show-right-collapse-btn="false"
    @closeRight="router.push({path: `/inbox`})"
  >
    <template v-slot:main-column>
      <ConfirmAssignmentDialog :show-join-conversation-dialog.sync="showAssignToMeDialog"
                               :teams-associated-to-user="teamsAssociatedToUser"
                               @joinConversation="joinConversation" />
      <v-toolbar prominent elevation="4" color="grey lighten-4" class="pb-4 sticky-toolbar">
        <v-toolbar-items class="px-2 pt-0 d-flex flex-column col-12">
          <v-tabs class="inbox-tabs pa-0" background-color="grey lighten-4">
            <v-tab :class="inboxNotificationCount > 0 ? 'inbox-tab-with-badge' : ''" text @click="showInbox = true; reloadConversations()">
              New
              <v-badge
                class="inbox-badge"
                color="#D03331"
                :content="inboxNotificationCount"
                v-if="inboxNotificationCount > 0"
              ></v-badge>
            </v-tab>
            <v-tab text @click="showInbox = false; reloadConversations()">
              Sent
              <v-badge
                class="inbox-badge"
                color="#D03331"
                :content="sentNotificationCount"
                v-if="sentNotificationCount > 0"
              ></v-badge>
            </v-tab>
            <v-spacer></v-spacer>
            <a-btn v-if="teamsAssociatedToUser.length > 0" color="primary"
                  class="justify-end new-message-button mt-3"
                  @click="showNewMessageDialog = true"
                  prepend-icon="add"
                  text="New Message"
            />
          </v-tabs>
          <v-row class="px-2 pt-2 toolbar-row-2 mt-4">
            <a-text-field
              prepend-inner-icon="search"
              label="Search by project or owner"
              v-model="searchQuery"
              @input="searchConversations"
              :class="teamFilterOptions.length > 0 ? 'conversation-search' : 'conversation-search-no-teams'"
              class="albatross-body-2 mb-n4 mt-2 pr-6"
              clearable
            />
            <a-select v-model="messageTypeFilter"
                      :items="messageTypes"
                      single-line
                      @change="reloadConversations"
                      custom-classes="message-type-selector albatross-body-2 mb-n4 pr-6 mt-2"
                      prepend-icon="filter_alt"
            >
              <template v-slot:prepend>
                <v-icon>filter_alt</v-icon>
              </template>
              <template v-slot:selection="{ item, index }">
                <span class="d-flex" style="width: 100%;">
                  {{ item }}
                </span>
              </template>
            </a-select>
            <v-chip label color="primary--text" class="sort-chip align-self-center albatross-body-2 mr-6 flex-shrink-0"
                    @click="sortOldToNew = !sortOldToNew">
              {{ sortOldToNew ? 'Oldest to Newest' : 'Newest to Oldest' }}
            </v-chip>
          </v-row>
          <v-row class="toolbar-row-2 mt-6 mb-6">
            <v-checkbox
              v-model="showUnreadOnly"
              @change="reloadConversations"
              label="Show unread only"
              class="read-filter albatross-body-2 align-self-end flex-shrink-0 default-text-color pr-6 pl-1"
              :class="{'small-width': viewWidth===1264 && route.path.includes('inboxConversation')}"
            >
            </v-checkbox>
            <a-autocomplete v-model="selectedTeamFilters"
                            :items="teamFilterOptions"
                            item-title="teamName"
                            item-value="id"
                            prepend-icon="group"
                            class="filter-control albatross-body-2 align-self-end flex-shrink-1  mr-6"
                            placeholder="Teams"
                            :menu-props="{offsetY:true}"
                            multiple
                            clearable
                            @input="teamSelectionChanged"
                            v-if="teamFilterOptions.length > 1">
              <template  v-slot:prepend-item>
                <v-list-item
                  ripple
                  @click="toggleSelectAllTeams()"
                >
                  <v-list-item-action>
                    <v-icon>{{ teamsIcon }}</v-icon>
                  </v-list-item-action>
                  <v-list-item-title>Select All</v-list-item-title>
                </v-list-item>
                <v-divider
                  class="mt-2"
                ></v-divider>
              </template>
              <template  v-slot:selection="{item, index}">
                <v-chip small
                        v-if="index <= teamFilterChipLimit && selectedTeamFilters && selectedTeamFilters.length <= teamFilterChipLimit">
                  <span>{{ item.teamName }}</span>
                </v-chip>
                <span
                  v-if="index === 0 && selectedTeamFilters && selectedTeamFilters.length > teamFilterChipLimit"
                  class="primary--text text-caption"
                >{{ selectedTeamFilters.length }} selected</span>
              </template>
            </a-autocomplete>
            <a-autocomplete v-model="selectedOwnerFilters"
                            :items="ownerFilterOptions"
                            item-title="name"
                            item-value="userId"
                            prepend-icon="person"
                            class="filter-control albatross-body-2 align-self-end flex-shrink-1"
                            placeholder="Owners"
                            :menu-props="{offsetY:true}"
                            @input="reloadConversations"
                            multiple
                            clearable>
              <template  v-slot:prepend-item>
                <v-list-item
                  ripple
                  @click="toggleSelectAllOwners()"
                >
                  <v-list-item-action>
                    <v-icon>{{ ownersIcon }}</v-icon>
                  </v-list-item-action>
                  <v-list-item-title>Select All</v-list-item-title>
                </v-list-item>
                <v-divider
                  class="mt-2"
                ></v-divider>
              </template>
              <template  v-slot:selection="{item, index}">
                <v-chip small
                        v-if="index <= ownerFilterChipLimit && selectedOwnerFilters && selectedOwnerFilters.length <= ownerFilterChipLimit">
                  <span>{{ item.userName }}</span>
                </v-chip>
                <span
                  v-if="index === 0 && selectedOwnerFilters && selectedOwnerFilters.length > ownerFilterChipLimit"
                  class="primary--text text-caption"
                >{{ selectedOwnerFilters.length }} selected</span>
              </template>
            </a-autocomplete>
            <v-spacer></v-spacer>
          </v-row>
        </v-toolbar-items>
      </v-toolbar>
      <v-data-table
        :items="conversationsFiltered"
        :options.sync="options"
        disable-sort
        ref="pageable-table"
        :page.sync="page"
        :mobile-breakpoint="0"
        :footer-props="footerProps"
        :server-items-length="totalConversations"
        fixed-header
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
                 :class="{'selected': (item.projectId && route.params.projectId == item.projectId) || (item.userId && route.params.userId == item.userId)}"
                 @click="openConversation(item)">
            <v-row class="justify-space-between flex-nowrap mx-0 pa-0">
              <v-col cols="11" class="pa-0">
                <div class="d-flex align-baseline"
                     :class="{'notif-div': (getNotificationCount(item) > 0)}">
                  <div>
                    <v-badge
                      color="#D03331"
                      class="notif-badge"
                      :content="getNotificationCount(item)"
                      v-if="getNotificationCount(item) > 0"
                    >
                    </v-badge>
                    <b>{{ item.projectName ? item.projectName : item.fullName }}</b>
                  </div>
                  <span v-if="item.messageHistory.length > 0"
                        class="albatross-body-2 px-2">{{ getTime(item.messageHistory[0].lastMessageSent)
                    }}</span>
                  <span class="albatross-body-2 px-1 grey--text text--darken-2" v-if="item.projectName">{{ item.state }}</span>
                  <v-chip class="customer-chip ml-1" small  v-if="item.projectId">
                    <span >Customer</span>
                  </v-chip>
                  <v-chip class="internal-chip" small v-else>
                    <span >Internal</span>
                  </v-chip>
                </div>
                <div v-if="item.messageHistory.length > 0" class="text-ellipses mt-1">{{ item.messageHistory[0].message }}
                </div>
              </v-col>
            </v-row>
            <TeamAssignmentChips
              :sms-team-owners="item.smsTeamOwners"
              :team-names-associated-to-user="teamNamesAssociatedToUser"
              :reloading="reloadInProgress"
              :show-assign-to-me-button="false"
              :project-id="item.projectId"
              :user-id="item.userId"
              :conversation="item"
              show-selected-styles
              @updateOwner="fetchConversations"
              @joinConversation="[assignToMe = item, joinConversation()]"
            />
          </v-col>
        </template>
      </v-data-table>
      <NewMessageDialog :show-new-message-dialog.sync="showNewMessageDialog" :is-inbox="true" class="pa-0"/>
    </template>
    <template v-slot:collapse-button>
      <a-btn class="d-inline-block align-self-center" size="small" variant="text" color="primary"
                       @click="router.push({path: `/inbox`})"
                       prepend-icon="close"
      />
    </template>
    <template v-slot:right-column>
      <ProjectActivity v-if="!thingsLoading" collapseBtnIcon="close" :allowSidebarCollapse="false" @collapseCallback="closeConversation"></ProjectActivity>
    </template>
  </ThreeColumnLayout>
</template>

<script setup>
import {getRequest, handleHidingGlobalLoader, postRequest} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import moment from 'moment'
import ThreeColumnLayout from '@/views/ThreeColumnLayout'
import TeamAssignmentChips from '@/views/flow/settings/inbox/TeamAssignmentChips'
import ConfirmAssignmentDialog from '@/views/flow/settings/inbox/ConfirmAssignmentDialog'
import NewMessageDialog from "./NewMessageDialog";
import debounce from 'lodash.debounce'
import ProjectActivity from "@/views/flow/project/ProjectActivity.vue";


import {ref, computed, onMounted, getCurrentInstance, watch} from "vue";
import {useUserStore} from "@/stores/UserStore.js";
import { useNotificationStore } from '@/stores/NotificationStore.js'
import {useRouter, useRoute} from "vue-router/composables"
import { useAppStore } from '@/stores/AppStore.js'
const appStore = useAppStore()

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
 const route = useRoute()
const router = useRouter()
const vuetify = vueInstance.$vuetify
const userStore = useUserStore()
const notificationStore = useNotificationStore()

const conversations = ref([])
const options = ref({
  itemsPerPage: 25
})
const footerProps = ref({
  'items-per-page-options': [25, 50, 100],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const searchQuery = ref('')
const userId = ref(userStore.details.id)
const sortOldToNew = ref(false)
const ownerFilterOptions = ref([])
const selectedOwnerFilters = ref([])
const teamFilterOptions = ref([])
const selectedTeamFilters = ref([])
const showUnreadOnly = ref(false)
const showInbox = ref(true)
const pageableTable = ref(null)
const showAssignToMeDialog = ref(false)
const showNewMessageDialog = ref(false)
const assignToMe = ref([])
const teamsAssociatedToUser = ref([])
const teamNamesAssociatedToUser = ref([])
const evtSource = ref('')
const thingsLoading = ref(0)
const viewWidth = ref(window.innerWidth)
const selectableTeams = ref([])
const reloadInProgress = ref(false)
const totalConversations = ref(0)
const page = ref(1)
const initialLoad = ref(true)
const projectIdsForCurrentFilter = ref([])
const projectIdsInbox = ref([])
const projectIdsSent = ref([])
const userIdsForCurrentFilter = ref([])
const userIdsInbox = ref([])
const userIdsSent = ref([])
const messageTypeFilter = ref('All')
const messageTypes = ref(['All', 'Internal', 'Customer'])
const isSmsOwnershipEventsRunning = ref(false)

const userCanViewAll = computed(() => {
  return userStore.userHasFeatureAccessLevel('SMS_INBOX', 'VIEW_ALL')
})

const inboxNotificationCount = computed(() => {
  let count = 0;

  // Get Project notifications
  let notifProjectIds = smsNotification.value?.map(n => n.metadata?.projectId)
  notifProjectIds.forEach(npi => {
    if (projectIdsInbox.value && projectIdsInbox.value.includes(npi)) {
      count++;
    }
  })

  // Get User notifications
  let notifUserIds = smsNotification.value?.map(n => n.metadata?.userId)
  notifUserIds.forEach(nui => {
    if (userIdsInbox.value && userIdsInbox.value.includes(nui)) {
      count++;
    }
  })

  return count;
})
const sentNotificationCount = computed(() => {
  let count = 0;
  // Get Project notifications
  let notifProjectIds = smsNotification.value?.map(n => n.metadata?.projectId)
  notifProjectIds.forEach(npi => {
    if (projectIdsSent.value && projectIdsSent.value.includes(npi)) {
      count++;
    }
  })

  // Get User notifications
  let notifUserIds = smsNotification.value?.map(n => n.metadata?.userId)
  notifUserIds.forEach(nui => {
    if (userIdsSent.value && userIdsSent.value.includes(nui)) {
      count++;
    }
  })

  return count;
})
const smsOwnershipEvents = computed(() => {
  return notificationStore.getEventsByTopic('sms_ownership').length
})
const smsNotification = computed(() => {
  return notificationStore.getNotificationsByTopic('sms_reply')
})
const conversationsFiltered = computed(() => {
  let conversationList = conversations.value
  if (conversations.value) {
    return conversationList.sort((a, b) => {
      return sortOldToNew.value ?
        (a.messageHistory.length > 0 ? new Date(a.messageHistory[0].lastMessageSent) : 0) - (b.messageHistory.length > 0 ? new Date(b.messageHistory[0].lastMessageSent) : 0) :
        (b.messageHistory.length > 0 ? new Date(b.messageHistory[0].lastMessageSent) : 0) - (a.messageHistory.length > 0 ? new Date(a.messageHistory[0].lastMessageSent) : 0)
    })
  }
  else {
    return [];
  }

})
const allTeamsSelected = computed(() => {
  return selectedTeamFilters.value.length === teamFilterOptions.value.length
})
const allOwnersSelected = computed(() => {
  return selectedOwnerFilters.value.length === ownerFilterOptions.value.length
})
const teamsIcon = computed(() => {
  if (selectedTeamFilters.value.length === teamFilterOptions.value.length) {
    return 'check_box'
  }
  if (selectedTeamFilters.value.length > 0) {
    return 'indeterminate_check_box'
  }
  return 'check_box_outline_blank'
})
const ownersIcon = computed(() => {
  if (selectedOwnerFilters.value.length === ownerFilterOptions.value.length) {
    return 'check_box'
  }
  if (selectedOwnerFilters.value.length > 0) {
    return 'indeterminate_check_box'
  }
  return 'check_box_outline_blank'
})
const teamFilterChipLimit = computed(() => {
  if (viewWidth.value < 1264) {
    //smaller screen
    if (route.path.includes('inboxConversation')) {
      //right panel open
      return 0
    }
    //right panel closed
    return 2
  }
  //larger screen
  if (route.path.includes('inboxConversation')) {
    //right panel open
    return 1
  }
  //right panel closed
  return 3
})
const ownerFilterChipLimit = computed(() => {
  if (viewWidth.value < 1264) {
    //smaller screen
    if (route.path.includes('inboxConversation')) {
      //right panel open
      return 0
    }
    //right panel closed
    return 3
  }
  //larger screen
  if (route.path.includes('inboxConversation')) {
    //right panel open
    return 2
  }
  //right panel closed
  if (teamFilterOptions.value.length > 1) {
    //teams filter is showing
    return 4
  }
  //teams filter not showing
  return 6
})
const hasUnassignedNotifications = computed(() => {
  let hasNotifications = false
  teamsAssociatedToUser.value?.forEach(t => {
    if (t.receiveUnassignedNotifications) {
      hasNotifications = true;
    }
  })

  return hasNotifications;
})
const showLoading = (isLoading) => {
  if (isLoading) {
    if (thingsLoading.value == 0) {
      appStore.loading = true
    }
    thingsLoading.value++
  } else {
    thingsLoading.value--
    if (thingsLoading.value == 0) {
      appStore.loading = false
    }
  }
}
const fetchConversations = async () => {
  try {
    showLoading(true)
    const { page, itemsPerPage } = options.value
    let filterData = {
      ownerUserIds: selectedOwnerFilters.value,
      smsTeamIds: selectedTeamFilters.value,
      notifProjectIds: showUnreadOnly.value ? (smsNotification.value?.length > 0 ? smsNotification.value?.map(n => n.metadata?.projectId) : [-1]) : [],
      notifUserIds: showUnreadOnly.value ? (smsNotification.value?.length > 0 ? smsNotification.value?.map(n => n.metadata?.userId) : [-1]) : [],
      showProjects: (messageTypeFilter.value === 'Customer' || messageTypeFilter.value === 'All') ? true : false,
      showUsers: (messageTypeFilter.value === 'Internal' || messageTypeFilter.value === 'All') ? true : false,
      showInbox: showInbox.value
    }
    const { data } = await postRequest(`/messaging/conversations?size=${itemsPerPage}&page=${page - 1}&query=${searchQuery.value}`,
      filterData
    )

    if (data) {
      conversations.value = data.content
      if (conversations.value && conversations.value.length > 0) {
        projectIdsInbox.value = conversations.value[0].projectIdsInbox
        projectIdsSent.value = conversations.value[0].projectIdsSent
        projectIdsForCurrentFilter.value = conversations.value[0].projectIdsForFilter
        userIdsInbox.value = conversations.value[0].userIdsInbox
        userIdsSent.value = conversations.value[0].userIdsSent
        userIdsForCurrentFilter.value = conversations.value[0].userIdsForFilter
      }

      // If Projects are being displayed
      if (messageTypeFilter.value === 'Customer' || messageTypeFilter.value === 'All') {
        totalConversations.value = projectIdsForCurrentFilter.value?.length || 0
      }
      // If Users are being displayed
      if (messageTypeFilter.value === 'Internal' || messageTypeFilter.value === 'All') {
        totalConversations.value += userIdsForCurrentFilter.value?.length || 0
      }

      conversations.value?.forEach(p => {
        p.showAssignToMeButton = teamsAssociatedToUser.value.length > 0
        p.smsTeamOwners.forEach(team => {
          team.users.forEach(owner => {
            if (owner.userId === userId.value) {
              p.showAssignToMeButton = false
            }
          })
        })
      })
    }
    handleHidingGlobalLoader(status)
    showLoading(false)
    initialLoad.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error fetching conversations')
    showLoading(false)
  }
}
const reloadConversations = async () => {
  try {
    showLoading(true)
    const {page, itemsPerPage} = options.value

    let filterData = {
      ownerUserIds: selectedOwnerFilters.value,
      smsTeamIds: selectedTeamFilters.value,
      notifProjectIds: showUnreadOnly.value ? (smsNotification.value?.length > 0 ? smsNotification.value?.map(n => n.metadata?.projectId) : [-1]) : [],
      notifUserIds: showUnreadOnly.value ? (smsNotification.value?.length > 0 ? smsNotification.value?.map(n => n.metadata?.userId) : [-1]) : [],
      showProjects: (messageTypeFilter.value === 'Customer' || messageTypeFilter.value === 'All'),
      showUsers: (messageTypeFilter.value === 'Internal' || messageTypeFilter.value === 'All'),
      showInbox: showInbox.value
    }

    const { data } = await postRequest(`/messaging/conversations?size=${itemsPerPage}&page=${page - 1}&query=${searchQuery.value}`,
      filterData
    )

    if (data) {
      conversations.value = data.content
      if (conversations.value && conversations.value.length > 0) {
        projectIdsForCurrentFilter.value = conversations.value[0].projectIdsForFilter
        userIdsForCurrentFilter.value = conversations.value[0].userIdsForFilter
        // If New/Sent notification badges weren't loaded yet (No conversations under New), get values now
        if ((!projectIdsInbox.value || projectIdsInbox.value.length === 0) && (!projectIdsSent.value || projectIdsSent.value.length === 0)) {
          projectIdsInbox.value = conversations.value[0].projectIdsInbox
          projectIdsSent.value = conversations.value[0].projectIdsSent
        }

        if ((!userIdsInbox.value || userIdsInbox.value.length === 0) && (!userIdsSent.value || userIdsSent.value.length === 0)) {
          userIdsInbox.value = conversations.value[0].userIdsInbox
          userIdsSent.value = conversations.value[0].userIdsSent
        }
      }
      else {
        projectIdsForCurrentFilter.value = []
        userIdsForCurrentFilter.value = []
      }

      // If Projects are being displayed
      if (messageTypeFilter.value === 'Customer' || messageTypeFilter.value === 'All') {
        totalConversations.value = projectIdsForCurrentFilter.value?.length || 0
      }
      // If Users are being displayed
      if (messageTypeFilter.value === 'Internal' || messageTypeFilter.value === 'All') {
        totalConversations.value += userIdsForCurrentFilter.value?.length || 0
      }

      conversations.value?.forEach(p => {
        p.showAssignToMeButton = teamsAssociatedToUser.value.length > 0
        p.smsTeamOwners.forEach(team => {
          team.users.forEach(owner => {
            if (owner.userId === userId.value) {
              p.showAssignToMeButton = false
            }
          })
        })
      })
    }

    handleHidingGlobalLoader(status)
    showLoading(false)
    reloadInProgress.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error fetching conversations')

    showLoading(false)
    reloadInProgress.value = false
  }
}
const getTime = (lastMessageSent) => {
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
}
const joinConversation = async (selectedTeam) => {
  try {
    if (teamsAssociatedToUser.value && teamsAssociatedToUser.value.length === 1) {
      selectedTeam = teamsAssociatedToUser.value[0]
    }
    // If the User has multiple teams available, have them select a team to join with first
    else if (teamsAssociatedToUser.value.length > 1 && !selectedTeam) {
      showAssignToMeDialog.value = true
      return
    }
    showLoading(true)

    let addTeamUrl = assignToMe.value.projectId ? `/messaging/addTeam/project/${assignToMe.value.projectId}` : `/messaging/addTeam/user/${assignToMe.value.userId}`
    await postRequest(addTeamUrl, selectedTeam)
    appStore.showSnack('SUCCESS', 'Successfully joined conversation')

    if (!route.path.includes('inboxConversation')) {
      let inboxUrl = assignToMe.value.projectId ? `/inbox/inboxConversation/project/${assignToMe.value.projectId}` : `/inbox/inboxConversation/user/${assignToMe.value.userId}`
      //avoids redundant navigation console error
      router.push({ path: inboxUrl })
    }
    showLoading(false)
    showAssignToMeDialog.value = false
    await fetchConversations()
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error joining conversation')
    showLoading(false)
  }
}
const fetchTeamsForUser = async () => {
  showLoading(true)
  try {
    const { data } = await getRequest(`/smsTeam/getTeamsForUser`)
    showLoading(false)
    if (data && Array.isArray(data)) {
      teamsAssociatedToUser.value = data
      teamNamesAssociatedToUser.value = data?.map(team => team.teamName)
    }
    await getAvailableTeams()
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error fetching SMS Teams')

    showLoading(false)
  }
}
const projectNotificationCount = (projectId) => {
  return smsNotification.value?.filter(n => n.metadata?.projectId === projectId)?.length
}
const userNotificationCount = (userId) => {
  return smsNotification.value?.filter(n => n.metadata?.userId === userId)?.length
}
const getNotificationCount = (item) => {
  if (item.projectId) {
    return projectNotificationCount(item.projectId)
  }
  else if (item.userId) {
    return userNotificationCount(item.userId)
  }
}
const clearProjectNotification = (projectId) => {
  const notificationIds = smsNotification.value
    ?.filter(n => n.metadata.projectId === projectId)
    ?.map(notif => notif.id)

  notificationStore.markAsRead(notificationIds)
}
const clearUserNotification = (userId) => {
  const notificationIds = smsNotification.value
    ?.filter(n => n.metadata.userId === userId)
    ?.map(notif => notif.id)

  notificationStore.markAsRead(notificationIds)
}
const toggleSelectAllTeams = () => {
  if (allTeamsSelected.value) {
    selectedTeamFilters.value = []
  } else {
    selectedTeamFilters.value = teamFilterOptions.value?.map(t => t.id)
  }
  teamSelectionChanged()
}
const toggleSelectAllOwners = () => {
  if (allOwnersSelected.value) {
    selectedOwnerFilters.value = []
  } else {
    selectedOwnerFilters.value = ownerFilterOptions.value?.map(o => o.userId)
  }
  reloadConversations()
}
const onResize = () => {
  viewWidth.value = window.innerWidth
}
const getAvailableTeams = async () => {
  appStore.loading = true
  try {
    const { data, status } = await getRequest(`/smsTeam/users`)
    selectableTeams.value = data
    if (selectableTeams.value && selectableTeams.value.length > 0) {
      selectableTeams.value.forEach(team => {
        if (teamNamesAssociatedToUser.value.includes(team.teamName)) {
          if (!teamAlreadyAddedToFilter(team)) {
            teamFilterOptions.value.push(team)
          }

          if (selectedTeamFilters.value && !selectedTeamFilters.value.includes(team.id)) {
            selectedTeamFilters.value.push(team.id)
          }

          team.users.forEach(owner => {
            if (!ownerAlreadyAddedToFilter(owner)) {
              ownerFilterOptions.value.push(owner)

              if (owner.userId === userId.value) {
                selectedOwnerFilters.value.push(owner.userId)
              }
            }
          })
        } else if (userCanViewAll.value) {
          if (!teamAlreadyAddedToFilter(team)) {
            teamFilterOptions.value.push(team)
          }
        }
      })
    }

    ownerFilterOptions.value.push({ name: 'Unassigned', userName: 'Unassigned', id: -1, userId: -1 })
    teamFilterOptions.value.sort((a,b)=>{
      if(a.teamName < b.teamName) {
        return -1
      }
      if(a.teamName > b.teamName) {
        return 1
      }
      return 0
    })

    ownerFilterOptions.value.sort((a,b)=>{
      if(a.name < b.name) {
        return -1
      }
      if(a.name > b.name) {
        return 1
      }
      return 0
    })

    if (selectedOwnerFilters.value && !selectedOwnerFilters.value.includes(-1) && hasUnassignedNotifications.value) {
      selectedOwnerFilters.value.push(-1)
    }
    handleHidingGlobalLoader(status)
    appStore.loading = false
    await fetchConversations()
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.loading = false
    appStore.showSnack('ERROR', 'Error retrieving teams')
  }
}
const ownerAlreadyAddedToFilter = (ownerToAdd) => {
  let alreadyAdded = false
  ownerFilterOptions.value.forEach(o => {
    if (o.userId === ownerToAdd.userId) {
      alreadyAdded = true
    }
  })
  return alreadyAdded
}
const teamAlreadyAddedToFilter = (teamToAdd) => {
  let alreadyAdded = false
  teamFilterOptions.value.forEach(t => {
    if (t.id === teamToAdd.id) {
      alreadyAdded = true
    }
  })
  return alreadyAdded
}
const teamSelectionChanged = () => {
  ownerFilterOptions.value = []
  selectableTeams.value.forEach(team => {
    if (selectedTeamFilters.value.includes(team.id)) {
      team.users.forEach(owner => {
        if (!ownerAlreadyAddedToFilter(owner)) {
          ownerFilterOptions.value.push(owner)
        }
      })
    }
  })
  ownerFilterOptions.value.push({ name: 'Unassigned', userName: 'Unassigned', id: -1, userId: -1 })

  options.value.page = 1
  reloadConversations()
}
const openConversation = (item) => {
  if (item.projectId) {
    clearProjectNotification(item.projectId)
    router.push({path: `/inbox/inboxConversation/project/${item.projectId}`});
  }

  if (item.userId) {
    clearUserNotification(item.userId)
    router.push({path: `/inbox/inboxConversation/user/${item.userId}`});
  }
}
const closeConversation = () => {
  router.push({path: `/inbox`})
}
const searchConversations = debounce(() => {
  //don't allow searchQuery to be null - causes issues
  searchQuery.value = searchQuery.value || ''
  reloadConversations()
}, 500)

watch(smsOwnershipEvents, debounce(async function() {
  if (isSmsOwnershipEventsRunning.value) {
    // A previous execution is ongoing, ignore the current one
    return;
  }

  isSmsOwnershipEventsRunning.value = true;

  try {
    await fetchTeamsForUser();
    await reloadConversations();
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.loading = false
    appStore.showSnack('ERROR', 'Error reloading conversations')

  } finally {
    isSmsOwnershipEventsRunning.value = false;
  }
}, 1000))
watch(options, () => {
  if (!initialLoad.value) {
    reloadConversations()
  }
})
watch(page, () => {
  let table = pageableTable.value;
  let wrapper = table.$el.querySelector('div.v-data-table__wrapper');

  vuetify.goTo(table); // to table
  vuetify.goTo(table, {container: wrapper}); // to header
})
onMounted(() => {
  fetchTeamsForUser()
  window.addEventListener('resize', onResize.value)
})

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
  height: 170px !important;
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
  margin-right: 30px;
}

.inbox-badge {
  margin-top: 13px;
  margin-left: 10px;
}

.inbox-tab-with-badge {
  padding-right: 26px;
}

.notif-div {
  margin-left: 2px;
}

.filter-control {
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

.conversation-search {
  max-width: 536px !important;
}

conversation-search-no-teams {
  max-width: 429px !important;
}

.inbox-tabs {
  margin-left: -4px !important;
  top: -1px;
  height: 64px !important;
  z-index: 2;
  opacity: 0.95;
  .v-tab:hover {
    color: var(--v-primary-base);
  }
  max-width: 100vw;
}

::v-deep {
  .v-data-table__wrapper {
    height: calc(100vh - 275px);
    min-height: 300px;
  }
}

.message-type-selector {
  max-width: 160px;
}

.internal-chip {
  background-color: #C8E6C9 !important;
  height: 22px;
}

.customer-chip {
  background-color: #FECDD2 !important;
  height: 22px;
}

.new-message-button {
  text-transform: none;
}

.message-add-icon {
  height: 16px !important;
  width: 16px !important;
  margin-right: 4px;
}

</style>
