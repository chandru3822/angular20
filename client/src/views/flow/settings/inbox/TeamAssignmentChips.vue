<template xmlns="http://www.w3.org/1999/html">
  <v-chip-group column class="team-chips">
    <span v-for="(team, index) in smsTeamOwners" class="d-flex flex-wrap">
        <v-chip v-if="team.users.length === 0"
                label
                :close="teamNamesAssociatedToUser.includes(team.teamName) && userCanView"
                close-icon="mdi-close"
                @click:close="closeTeam(team)"
                class="chip"
                :class="{
                  'unassigned-team-chip': teamNamesAssociatedToUser.includes(team.teamName),
                  'other-team-chip': !teamNamesAssociatedToUser.includes(team.teamName),  'selected': (selectedProjectId === projectId ||
                                                                                                        selectedUserId === userId) && showSelectedStyles}"
        >
          <span >{{team.teamName}} - Unassigned</span>
        </v-chip>
        <v-chip v-else v-for="(user, index) in team.users"
                label
                :close="(user.userId === loggedInUserId && userCanView) || (teamNamesAssociatedToUser.includes(team.teamName) && userCanManage)"
                close-icon="mdi-close"
                @click:close="close(user)"
                :ripple="false"
                class="chip"
                :class="{'assigned-team-chip': teamNamesAssociatedToUser.includes(team.teamName),
                 'other-team-chip': !teamNamesAssociatedToUser.includes(team.teamName), 'selected': (selectedProjectId === projectId ||
                                                                                                        selectedUserId === userId) && showSelectedStyles}">
          <span>{{team.teamName}} - {{user.name}}</span>
        </v-chip>
      </span>

      <v-chip v-if="(conversation && conversation.showAssignToMeButton) || showAssignToMeButton && !reloading && !readOnly"
              label
              class="white--text text-capitalize clickable"
              :ripple="false"
              :class="unassignedTeamExits ? 'unassigned-join-button' : 'assigned-join-button'"
              @click.native.stop="$emit('joinConversation')">
        <span>Join</span>
      </v-chip>
      <span v-if="readOnly">This user is either no longer active or the user’s position cannot receive SMS from Albatross</span>
      <v-dialog v-model="showRemoveDialog" max-width="709px">
        <v-card class="pt-6 pl-6">
          <v-card-title class="albatross-header-4-new pa-0">What would you like to do?</v-card-title>
          <v-radio-group v-model="removeOption">
            <v-radio :key="0" :value="0" class="albatross-body-1 remove-dialog-option mb-4">
              <template v-slot:label><div class="default-text-color"> Remove <strong>&nbsp;{{userToRemove.name}}&nbsp;</strong> from the conversation</div></template></v-radio>
            <v-radio :key="1" :value="1" class="albatross-body-1 remove-dialog-option mb-0" color="grey darken-4" :mesaages="[`This will also remove other ${teamToRemove.teamName} team members on the conversation`]">
              <template v-slot:label><div class="default-text-color">Remove <strong>&nbsp;{{userToRemove.name}}&nbsp;</strong> and <strong>&nbsp;{{teamToRemove.teamName}}&nbsp;</strong> team from the conversation</div></template>
            </v-radio>
            <span class="albatross-body-3 remove-dialog-option-info px-8 pt-n4">This will also remove other {{teamToRemove.teamName}} team members on the conversation</span>
          </v-radio-group>
          <v-card-actions class="pb-4">
            <v-spacer/>
            <a-btn
              class="text-capitalize"
              variant="text"
              color="primary"
              @click="showRemoveDialog=false"
              text="CANCEL"
            />
            <a-btn
              class="text-capitalize white--text"
              depressed
              color="primary"
              @click="confirmChoice"
              text="CONFIRM"
            />
          </v-card-actions>
        </v-card>
      </v-dialog>
      <v-dialog v-model="showRemoveLastTeamDialog" max-width="600px">
        <v-card class="pt-6">
          <v-card-title
              class="albatross-header-4-new pt-0"
              primary-title>
            Remove Team
          </v-card-title>
          <v-card-text class="default-text-color albatross-body-1 px-6">
           <div>Because no other team is on the conversation, this action will remove the team and close the conversation.</div>
            <div>Are you sure you want to remove {{teamToRemove.teamName}} team and close conversation?</div>
          </v-card-text>
          <v-card-actions class="pb-4">
            <v-spacer/>
            <a-btn
              class="text-capitalize"
              variant="text"
              color="primary"
              @click="showRemoveLastTeamDialog=false"
              text="CANCEL"
            />
            <a-btn
              class="text-capitalize white--text"
              color="primary"
              @click="removeTeam(teamToRemove.id)">Remove and Close</a-btn>
          </v-card-actions>
        </v-card>
      </v-dialog>
      <v-dialog v-model="showRemoveTeamDialog" max-width="509px">
        <v-card>
          <v-card-title
              class="albatross-header-4-new"
              primary-title>
            Remove Team
          </v-card-title>
          <v-card-text class="albatross-body-1 pb-2 default-text-color">
            <div>This action will remove the team from the conversation. </div>
            <div>Are you sure you want to remove <b>{{teamToRemove.teamName}}</b> team?</div>
          </v-card-text>
          <v-card-actions>
            <v-spacer></v-spacer>
            <a-btn
                variant="text"
                color="primary"
                @click="showRemoveTeamDialog=false"
                class="text-capitalize mr-2 mb-2"
                text="Cancel"
            />
            <a-btn
                color="primary"
                class="white--text elevation-2 text-capitalize mb-2"
                @click="removeTeam(teamToRemove.id)"
                text="REMOVE"
            />
          </v-card-actions>
        </v-card>

      </v-dialog>
      <v-menu offset-y :close-on-content-click="false" v-model="teamsMenuOpen" v-if="userCanView && !readOnly">
        <template v-slot:activator="{on: menu, attrs}">
          <v-tooltip top small>
            <template v-slot:activator="{on: tooltip, attrs}">
              <a-btn
                variant="text"
                icon
                v-bind="attrs"
                :activation-handler="{...tooltip, ...menu}"
                size="small"
                class="align-self-baseline"
                prepend-icon="mdi-plus"
              />
            </template>
            <span class="albatross-body-3">Add Member</span>
          </v-tooltip>
        </template>
        <AddTeamDropdown :sms-team-owners="smsTeamOwners" :project-id="projectId" :owner-user-id="userId" @closeTeamAdded="teamAdded()"></AddTeamDropdown>
      </v-menu>
  </v-chip-group>
</template>

<script setup>
import {getSnackbar, getRequest, putRequest} from "@/helpers/helpers";
import AddTeamDropdown from "@/views/flow/settings/inbox/AddTeamDropdown";

import {ref, computed, onMounted, getCurrentInstance, watch, defineProps} from "vue";
import {useUserStore} from "@/stores/UserStore.js";
import {useRouter, useRoute} from "vue-router/composables"
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar
const route = useRoute()
const router = useRouter()
const vuetify = vueInstance.$vuetify
const userStore = useUserStore()

const props = defineProps({
  smsTeamOwners: Array,
  teamNamesAssociatedToUser: Array,
  projectId: Number,
  conversation: Object,
  showSelectedStyles: Boolean,
  showAssignToMeButton: Boolean,
  reloading: Boolean,
  userId: Number
})

const showRemoveDialog = ref(false)
const showRemoveLastTeamDialog = ref(false)
const showRemoveTeamDialog = ref(false)
const userToRemove = ref('')
const teamToRemove = ref({})
const removeOption = ref(0)
const teamsMenuOpen = ref(false)
const unassignedTeamMenuOpen = ref(false)
const readOnly = ref(false)

const emit = defineEmits(['updateOwner'])

const selectedProjectId = computed(() => {
  return parseInt(route.params.projectId)
})

const selectedUserId = computed(() => {
  return parseInt(route.params.userId)
})
const loggedInUserId = computed(() => {
  return userStore.details.id
})
const userCanView = computed(() => {
  return userStore.userHasFeatureAccessLevel('SMS_INBOX', 'VIEW')
})
const userCanManage = computed(() => {
  return userStore.userHasFeatureAccessLevel('SMS_INBOX', 'MANAGE')
})


onMounted(() => {

  if (props.userId) {
    getSmsAccess()
  }
})

const teamAdded = () => {
  teamsMenuOpen.value = false
  unassignedTeamMenuOpen.value = false
  emit('updateOwner')
}
const close =  (user) => {
  userToRemove.value = user
  teamToRemove.value = getTeamToRemoveBySmsTeamId(user.smsTeamId)
  showRemoveDialog.value = true
}
const closeTeam =  (team) => {
  teamToRemove.value = team
  if(props.smsTeamOwners.length === 1){
    showRemoveLastTeamDialog.value = true
  } else {
    showRemoveTeamDialog.value = true
  }
  }
const getTeamToRemoveBySmsTeamId = (smsTeamId)=> {
 return props.smsTeamOwners.find(team => team.id === smsTeamId)
}
const confirmChoice = ()=> {
  switch (removeOption.value){
    case 0: removeUser()
         break
    case 1: removeTeam(teamToRemove.value.id)
        break
  }
  removeOption.value  = 0
  showRemoveDialog.value  = false
}
const removeTeam = async (teamId) => {
  showRemoveTeamDialog.value = false
  showRemoveLastTeamDialog.value = false
  try {
    let removeTeamUrl = ''
    if (props.projectId) {
      removeTeamUrl = `/messaging/removeTeam/project/`+ props.projectId + '/' + teamId
    }
    else if (props.userId) {
      removeTeamUrl = `/messaging/removeTeam/user/`+ props.userId + '/' + teamId
    }

    await putRequest(removeTeamUrl)
    // If the project/user is currently opened on the right panel, navigate back to main inbox to close it
    if (route.path.includes('inboxConversation') && (route.path.includes(props.projectId) || route.path.includes(props.userId))) {
      await router.push({path: `/inbox`})
    }
    snackbar('SUCCESS', 'Team removed')
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error removing team')
  }

  emit('updateOwner')
}
const removeUser = async () => {
  try {
    if (props.projectId) {
      const bodyData = {
        projectId: props.projectId,
        smsTeamId: userToRemove.value.smsTeamId,
        userId: userToRemove.value.userId,
        name: userToRemove.value.name,
        archived: userToRemove.value.archived
      }
      await putRequest(`/messaging/removeOwner/project/`+ props.projectId, bodyData)
    }
    else if (props.userId) {
      const bodyData = {
        ownerUserId: props.userId,
        smsTeamId: userToRemove.value.smsTeamId,
        userId: userToRemove.value.userId,
        name: userToRemove.value.name,
        archived: userToRemove.value.archived
      }
      await putRequest(`/messaging/removeOwner/user/`+ props.userId, bodyData)
    }
    snackbar('SUCCESS', 'Unassigned')
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error removing team')
  }

  emit('updateOwner')
}
const unassignedTeamExits = () => {
  let unassignedExists = false;
  props.smsTeamOwners.forEach(team => {
    if (team.users.length === 0 && props.teamNamesAssociatedToUser.includes(team.teamName)) {
      unassignedExists = true;
    }
  });

  return unassignedExists;
}
const getSmsAccess = async () => {
  try {
    const { data, status } = await getRequest(`/user/smsAccess/${props.userId}`)
    readOnly.value = !data
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving SMS Access')
    appStore.loading = false
  }
}

</script>

<style lang="scss" scoped>

.unassigned-join-button {
  background-color: var(--v-primary-base) !important;
}
.assigned-join-button {
  background-color: var(--v-grey-lighten1);
  color: var(--v-primary-base) !important;
}

.chip:hover {
  cursor: default;
}
.chip::before {
  color: transparent;
  cursor: default;
}

.unassigned-team-chip {
  background-color: var(--v-error-lighten4) !important;
  color: var(--v-error-base) !important;
  cursor: default;

  &.selected {
    border: solid 0.5px;
  }
}

.other-team-chip {
  background: var(--v-grey-lighten3) !important;
  cursor: default;

  &.selected {
    border: solid 0.5px;
  }
}

.assigned-team-chip {
  background: var(--v-primary-lighten9) !important;
  //color: white !important;
  cursor: default;
  &.selected {
    background: white !important;
    border: solid 0.5px;
  }
}

.remove-dialog-option-info {
  color: var(--v-grey-darken1);
}
</style>
