<script setup>
/*
*@name MessagingDialog
*@author jess
*@date 6/5/24
*
*@description
* props
*   value: Boolean
*   userIdIn: Number
*
*
*/

import Messaging from "@/views/flow/components/Messaging.vue";
import ConfirmationDialog from "@/components/ConfirmationDialog.vue";
import {getRequest, handleHidingGlobalLoader} from "@/helpers/helpers.js";
import {onMounted, ref, toRefs} from "vue";
import {useAppStore} from "@/stores/AppStore.js";

const props = defineProps({
  value:Boolean,
  userId: Number,
  userIdIn: Number
})
const {userId, userIdIn} = toRefs(props)
const emit = defineEmits(['close'])

const userAssigned = ref(false)
const messageProperties = ref({})
const teamsAssociatedToUser = ref([])
const teamNamesAssociatedToUser = ref([])
const conversationIsLoading = ref(false)

const appStore = useAppStore()

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
        // userHasTeam.value = true
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
          '/messaging/user/' + userId.value
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

onMounted(() => {
  fetchTeamsForUser()
})
</script>

<template>
  <ConfirmationDialog :open-dialog="value" hide-title hide-confirm @close-dialog="emit('close')">
    <Messaging :user-id-in="userIdIn" :teams-associated-to-user="teamsAssociatedToUser" :user-assigned="userAssigned"/>
    <template v-slot:no>Close</template>
  </ConfirmationDialog>
</template>

<style scoped lang="scss">

</style>
