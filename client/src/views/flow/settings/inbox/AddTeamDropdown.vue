<template>
  <v-card width="300px" min-height="270px" class="pa-6 d-flex flex-column">
    <div class="albatross-header-4-new">Add Member</div>
    <v-select v-model="teamToSave"
              :items="selectableTeams"
              item-text="teamName"
              label="Team"
              class="user-filter-select"
              @change="getSelectableUsers"
              menu-props="offset-y"
              return-object
    > <template #item="{item}">
                  <span>
                    {{item.teamName}}
                  </span>
    </template>
    </v-select>
    <v-autocomplete v-model="ownersToSave"
                    :disabled="!teamToSave || selectableUsers.length == 0"
                    :items="selectableUsers"
                    multiple
                    item-text="name"
                    label="Select Owners"
                    height="35px"
                    class="user-filter-select"
                    return-object
                    menu-props="offset-y"
    >
      <template
        slot="selection"
        slot-scope="{ item, index }"
      >
        <v-chip small v-if="index === 0 && ownersToSave && ownersToSave.length < 2">
          <span>{{ item.name }}</span>
        </v-chip>
        <span
          v-if="index === 1 && ownersToSave && ownersToSave.length >= 2"
          class="primary--text caption"
        >{{ ownersToSave.length }} selected</span>
      </template>
    </v-autocomplete>


    <v-card-actions>
      <v-spacer></v-spacer>
      <AlbatrossButton variant="text" color="primary" @click="cancel()"
        text="CANCEL"
      />
      <AlbatrossButton :disabled="!teamToSave || !ownersToSave"
                       :loading="teamSaving"
             color="primary" class="white--text" @click="addTeamDetails()"
             text="SAVE"
      />
    </v-card-actions>
  </v-card>
</template>

<script setup>
import {getRequest, postRequest} from "@/helpers/helpers";
import { useUserStore } from '@/stores/UserStorePinia.js'

import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";
import {ref, onMounted, getCurrentInstance, computed, defineProps} from "vue";
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
  smsTeamOwners:[],
  defaultTeamId: Number,
  projectId: Number,
  ownerUserId: Number
})

const emit = defineEmits(['closeTeamAdded'])
const teamToSave = ref('')
const selectableTeams = ref([])
const existingTeams = ref({})
const teamSaving = ref(false)
const ownersToSave = ref([])
const selectableUsers = ref([])

onMounted(async () => {
  await getTeams()
  if(props.defaultTeamId) {
    teamToSave.value = selectableTeams.value.find(team => props.defaultTeamId === team.id)
    getSelectableUsers()
  }
})
const userCanView = computed(() => {
  return userStore.userHasFeatureAccessLevel('SMS_INBOX', 'VIEW')
})
const userCanManage = computed(() => {
  return userStore.userHasFeatureAccessLevel('SMS_INBOX', 'MANAGE')
})
const userId = computed(() => {
  return userStore.details.id
})

const getTeams = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/smsTeam/users`)
    selectableTeams.value = data.sort((a,b)=>{
      if(a.teamName < b.teamName) {
        return -1
      }
      if(a.teamName > b.teamName) {
        return 1
      }
      return 0
    })
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.loading = false
    snackbar('ERROR', 'Error retrieving teams')

  }
}
const addTeamDetails = async () => {
  teamSaving.value = true
  try {
    let params = {
      id: teamToSave.value.id,
      users: ownersToSave.value
    }
    if (props.projectId) {
      await postRequest(`/messaging/addTeam/project/${props.projectId}`, params)
    }
    else if (props.ownerUserId) {
      await postRequest(`/messaging/addTeam/user/${props.ownerUserId}`, params)
    }

    const snackbarText = (!ownersToSave.value || ownersToSave.value.length === 0 ) ? 'Team added':
        (isTeamAlreadyAdded(teamToSave.value) ? 'Conversation assigned' : `Conversation assigned and ${teamToSave.value.teamName} team added`)
    snackbar('SUCCESS', snackbarText)
    teamToSave.value = '';
    selectableUsers.value = []
    ownersToSave.value = []
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error adding team')
  } finally {
    teamSaving.value = false
  }

  emit('closeTeamAdded')
}
const cancel = () => {
  teamToSave.value = ''
  ownersToSave.value = []
  emit('closeTeamAdded')
}
const isTeamAlreadyAdded = (team) => {
  let teamAlreadyAdded = false
     props.smsTeamOwners.forEach(owner => {
       if (owner.id === team.id) {
         teamAlreadyAdded = true
         return true
       }
     })
   return teamAlreadyAdded
}
const getSelectableUsers = () => {
  let teamAlreadyAdded = false;
  selectableUsers.value = [];
  ownersToSave.value = [];
  props.smsTeamOwners.forEach(owner => {
    // If this is the team being added has already been added
    if (owner.id === teamToSave.value.id) {
      teamAlreadyAdded = true;
      teamToSave.value.users.forEach(u => {
        if (!owner.users.filter(u2 => u2.userId === u.userId).length > 0) {
          selectableUsers.value.push(u);
        }
      })
    }
  })
  // If the team hasn't been added, all users can be selected
  if (!teamAlreadyAdded) {
    selectableUsers.value = teamToSave.value.users;
  }

  // If User only has View permission, they can only add themselves
  if (userCanView.value && !userCanManage.value) {
    selectableUsers.value = selectableUsers.value.filter(u => u.userId === userId.value)
  }

  selectableUsers.value.sort((a,b)=>{
    if(a.name < b.name) {
      return -1
    }
    if(a.name > b.name) {
      return 1
    }
    return 0
  })
}

</script>

<style scoped>

</style>
