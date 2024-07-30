<script setup>
/*
*@name MessagingDialog
*@author jess
*@date 6/5/24
*
*@description
* props
*   currentUserId: Number,
    userIdToMessage: Number, -- dialog displays when this prop has a value
    title: String,
*
*
*/

import Messaging from "@/views/flow/components/Messaging.vue";
import ConfirmationDialog from "@/components/ConfirmationDialog.vue";
import {getRequest, handleHidingGlobalLoader, postRequest} from "@/helpers/helpers.js";
import {onMounted, ref, toRefs, watch} from "vue";
import {useAppStore} from "@/stores/AppStore.js";
import TeamAssignmentChips from "@/views/flow/settings/inbox/TeamAssignmentChips.vue";

const props = defineProps({
  currentUserId: Number,
  userIdToMessage: Number,
  title: String
})
const {currentUserId, userIdToMessage, adjustVertical} = toRefs(props)
const emit = defineEmits(['close'])

const userAssigned = ref(false)
const messageProperties = ref({})
const teamsAssociatedToUser = ref([])
const teamNamesAssociatedToUser = ref([])
const conversationIsLoading = ref(false)
const userHasTeam = ref(false)
const minimized = ref(false)


const appStore = useAppStore()

watch(userIdToMessage, () => {
  if(userIdToMessage.value) {
    fetchTeamsForUser()
    minimized.value = false
  }
  else {
    resetAllRefs()
  }
})

const resetAllRefs = () => {
  userAssigned.value = false
  messageProperties.value = {}
  teamsAssociatedToUser.value = []
  teamNamesAssociatedToUser.value = []
  conversationIsLoading.value = false
  userHasTeam.value = false
}

const fetchTeamsForUser = async () => {
    try {
      conversationIsLoading.value = true
      const { data, status } = await getRequest(
          `/smsTeam/getTeamsForUser`,
          null,
          []
      )
      teamsAssociatedToUser.value = data ?? []

      if (data != null && data.length > 0) {
        userHasTeam.value = true
        teamNamesAssociatedToUser.value = teamsAssociatedToUser.value.map(
            (team) => team.teamName
        )
      }
      // handleHidingGlobalLoader( status)
      await loadConversation()
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error fetching SMS Teams')

      conversationIsLoading.value = false
    }
}

const loadConversation = async () => {
  userAssigned.value = false
    try {
      const { data, status } = await getRequest(
          '/messaging/user/' + userIdToMessage.value
      )
      messageProperties.value = data
      messageProperties.value.smsTeamOwners?.forEach((team) => {
        if (teamNamesAssociatedToUser.value.includes(team.teamName)) {
          team.users?.forEach((owner) => {
            if (owner.userId === currentUserId.value) {
              userAssigned.value = true
            }
          })
        }
      })
      handleHidingGlobalLoader(status)
      conversationIsLoading.value = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error fetching user messaging details')

      conversationIsLoading.value = false
    }
}

const startJoinConversation = () => {
  if (teamsAssociatedToUser.value?.length === 1) {
    const selectedSmsTeam = teamsAssociatedToUser.value[0]
    joinConversation(selectedSmsTeam)
  } else {
    // If the User has multiple teams available, have them select a team to join with first
    showJoinConversationDialog.value = true
  }
}

const joinConversation = async (selectedTeam) => {
  try {
    if (currentUserId.value) {
      await postRequest(`/messaging/addTeam/user/${userIdToMessage.value}`, selectedTeam)
    }
    appStore.showSnack('SUCCESS', 'Successfully joined conversation')
    await loadConversation()

  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error joining conversation')
    appStore.loading = false
  }
}

const getContentClass = () => {
    return 'messaging-dialog'
  }


const minimize = () => {
  minimized.value = !minimized.value
}
</script>

<template>
  <v-dialog :value="userIdToMessage"  @click:outside="emit('close')" custom-classes="px-0" width="500" hide-overlay :content-class="getContentClass()">
    <div v-if="userIdToMessage"  id="schedule-resource-message-dialog" :class="{'joined': userAssigned, 'minimized': minimized}"><!--the v-if is to make sure the messages reset when you close the dialog-->
      <div class="d-flex flex-column one-hunned px-0 sticky-header srmd-header" :class="{'srmd-header-dense': messageProperties.smsTeamOwners?.length <= 0 || minimized}">
        <div class="d-flex px-4 py-2 align-start">
          <v-tooltip right>
            <template v-slot:activator="{on, attrs}">
        <a class="title-medium text-decoration-none" v-bind="attrs" v-on="on" target="_blank" :href="`/user/${userIdToMessage}/details`">{{title}}
          <v-icon small color="primary"> mdi-open-in-new</v-icon>
        </a>
            </template>
            Open user in new tab
          </v-tooltip>
          <v-spacer/>
          <a-btn :prepend-icon="minimized ? 'mdi-chevron-up' : 'mdi-minus'" variant="text" icon @click="minimize"/>
          <a-btn prepend-icon="mdi-close" variant="text" icon @click="emit('close')"/>
        </div>
        <div v-if="messageProperties.smsTeamOwners?.length > 0" class="one-hunned">
      <TeamAssignmentChips
          v-if="!minimized"
          :sms-team-owners="messageProperties.smsTeamOwners"
          :team-names-associated-to-user="teamNamesAssociatedToUser"
          :reloading="conversationIsLoading"
          :show-assign-to-me-button="!userAssigned && userHasTeam"
          :user-id="userIdToMessage"
          mini-dialog
          :conversation="messageProperties"
          class="px-6 pb-1 mt-n1"
          @updateOwner="loadConversation"
          @joinConversation="startJoinConversation"
      />
        </div>

      </div>
    <Messaging v-if="!minimized" :user-id-in="userIdToMessage" :teams-associated-to-user="teamsAssociatedToUser" :user-assigned="userAssigned" hide-template-btn/>
    </div>
  </v-dialog>
</template>

<style scoped lang="scss">
.sticky-header {
  position: sticky;
  top: 0;
  background: white;
  z-index: 1;
}

#schedule-resource-message-dialog {
  background-color: white;
  max-height: 500px !important;
  overflow-y:hidden
}

#schedule-resource-message-dialog > div.srmd-header {
  height: 100px;
  border-bottom: var(--v-grey-lighten2) solid 1px;

  &.srmd-header-dense {
    min-height: unset;
    height: 64px;
  }
}

@media (min-width: 960px) {

  ::v-deep .messaging-dialog {
    position: absolute;
    bottom: -22px;
    left:0;

  }
}

</style>
<style lang="scss">
#app > div.v-dialog__content.v-dialog__content--active > div{
  max-height:500px;
}

#schedule-resource-message-dialog > div.height-one-hunned > #project-tabs > div > div > div.sc-message-list {
  min-height: 300px;
  max-height: 400px;
}
#schedule-resource-message-dialog.joined > div.height-one-hunned > #project-tabs > div > div > div.sc-message-list {
  min-height: 350px;
  max-height:350px;
}

#schedule-resource-message-dialog.minimized > div.srmd-header[data-v-b6bbbd73] {
  height: 52px !important;
  max-height: 52px !important;
}
</style>
