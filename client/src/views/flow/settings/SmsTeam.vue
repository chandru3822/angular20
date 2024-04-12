<template>
  <v-container id="hierarchy-container">
    <ConfirmationDialog
        :open-dialog="showDeleteDialog"
        hide-title
        @close-dialog="clearDeleteItem"
        @confirm="deleteItem"
    >
      <template v-slot:title class="albatross-body-1">
        Confirm
      </template>
      <span>Are you sure you want to remove <b>{{itemToDelete.name || itemToDelete.teamName}}</b>?</span> <br/>
      <span v-if="deleteType == DeleteTypeEnum.TEAM">Please ensure this team has resolved associated conversations.</span>
    </ConfirmationDialog>
    <v-row class="fill-height" align="center" justify="start">
      <v-col class="shrink" cols="12">
        <v-toolbar flat>
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">SMS Teams</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
              variant="text"
              color="primary"
              @click="[addTeam = !addTeam, newType = {}]"
              v-if="userStore.userHasFeatureAccessLevel('SMS_INBOX', 'ADD')"
              :hide-text-on-mobile="constants.IS_MOBILE"
              :prepend-icon="constants.IS_MOBILE ? 'add' : ''"
              :text="addTeam ? 'CANCEL' : 'ADD NEW'"
            />
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="addTeam" class="text-left pa-5 mb-3 mt-2" flat >
          <h3>Add Team</h3>
          <a-text-field  v-model="newTeam.teamName"
                        label="Team Name" />

          <a-btn
            :disabled="!newTeam.teamName"
            color="primary" class="mr-2"
            @click="saveTeam(newTeam, true)"
            text="SAVE"
          />
          <a-btn variant="text" color="primary" @click="[addTeam = !addTeam, newTeam = {}]" text="CANCEL"/>
        </v-card>
        <v-data-table
          :headers="headers"
          :items="filterTeams"
          :fixed-header="true"
          :items-per-page="-1"
          single-expand
          :mobile-breakpoint="0"
          :expanded.sync="expanded"
          hide-default-footer
          class="elevation-1"
        >
          <template #no-data>
            <span class="default-text-color">NO DATA HERE!</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No parameters exist for this function</span>
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': filterTeams.indexOf(item) % 2}">
              <a-text-field  v-model="item.teamName" label="Team Name" class="px-4"/>
              <v-checkbox dense v-model="item.checked" :value="item.isDefault" :disabled="item.isDefault" class="albatross-body-2 mt-0 px-4" label="Make Default for incoming unprompted customer and internal messages" />
              <a-btn :disabled="item.teamName.length < 1" color="primary" class="mr-2" @click="saveTeam(item, false)" text="SAVE"/>
              <div class="mb-2">
                <v-toolbar flat dense color="transparent" class="wqt-header-bar">
                  <v-toolbar-title class="albatross-header-4"><b>Positions</b></v-toolbar-title>
                  <v-spacer></v-spacer>
                  <a-btn variant="text" color="primary" @click="addPosition = !addPosition" prepend-icon="add"/>
                </v-toolbar>
                <v-card flat v-if="addPosition" color="transparent" class="px-4">
                  <a-select
                    v-model="positionId"
                    :items="selectablePositions"
                    label="Positions"
                    item-title="position"
                    item-value="id"
                  ></a-select>

                  <a-btn color="primary" :disabled="!positionId" @click="addPositionToTeam" text="SAVE" class="mb-6"/>
                  <a-btn variant="text" color="primary" @click="[addPosition = !addPosition, positionId = null]" class="mb-6" text="CANCEL"/>
                </v-card>

                <v-data-table
                  :headers="positionHeaders"
                  :items="filterPositions"
                  :fixed-header="true"
                  :items-per-page="-1"
                  hide-default-footer
                  :mobile-breakpoint="0"
                  class="elevation-1 org-type-table"
                  disable-sort
                  height="15%"
                >
                  <template #no-data>
                    <span class="default-text-color">No positions assigned</span>
                  </template>

                  <template #no-results>
                    <span class="default-text-color">No positions assigned</span>
                  </template>

                  <template #item="{ item }">
                    <tr class="text-left" :class="{'shaded-row': expandedItem.positions.indexOf(item) % 2}">
                      <td class="text-left">{{ item.name }}</td>
                      <td class="text-right">
                        <a-btn size="small" variant="text" color="primary" @click="startDelete(DeleteTypeEnum.POSITION, item)" prepend-icon="delete"/>
                      </td>
                    </tr>
                  </template>

                </v-data-table>
              </div>

              <div id="team-container">
                <v-toolbar dense flat color="transparent" class="wqt-header-bar">
                  <v-toolbar-title class="albatross-header-4"><b>Users</b></v-toolbar-title>
                  <v-spacer></v-spacer>
                  <a-btn variant="text" color="primary" @click="addUser = !addUser" prepend-icon="add"/>
                </v-toolbar>
                <v-card flat v-if="addUser" color="transparent" class="px-4 mb-6">
                  <a-autocomplete
                    v-model="userId"
                    :items="users"
                    label="Users"
                    item-title="fullName"
                    item-value="id"
                    attach
                  ></a-autocomplete>

                  <a-btn color="primary" :disabled="!userId" @click="addUserToTeam" text="SAVE"/>
                  <a-btn variant="text" color="primary" @click="[addUser = !addUser, userId = null]" text="CANCEL"/>
                </v-card>
                <v-data-table
                  :headers="userHeaders"
                  :items="filterUsers"
                  :fixed-header="true"
                  :items-per-page="-1"
                  hide-default-footer
                  :mobile-breakpoint="0"
                  disable-sort
                  class="elevation-1 org-type-table"
                >
                  <template #no-data>
                    <span class="default-text-color">No users assigned</span>
                  </template>

                  <template #no-results>
                    <span class="default-text-color">No users assigned</span>
                  </template>

                  <template #item="{ item }">
                    <tr class="text-left" :class="{'shaded-row': expandedItem.users.indexOf(item) % 2}">
                      <td class="text-left">{{ item.name }}</td>
                      <td class="text-right">
                        <a-btn size="small" variant="text" color="primary" @click="startDelete(DeleteTypeEnum.USER, item)" prepend-icon="delete"/>
                      </td>
                    </tr>
                  </template>

                </v-data-table>
              </div>

              <div id="org-container">
                <v-toolbar color="transparent" dense flat class="wqt-header-bar">
                  <v-toolbar-title class="albatross-header-4"><b>Organizations</b></v-toolbar-title>
                  <v-spacer></v-spacer>
                  <a-btn variant="text" color="primary" @click="addOrg = !addOrg" prepend-icon="add"/>
                </v-toolbar>
                <v-card flat v-if="addOrg" color="transparent" class="px-4 mb-6">
                  <a-autocomplete
                    v-model="orgId"
                    :items="orgs"
                    label="Organizations"
                    item-title="orgName"
                    item-value="id"
                    attach
                  ></a-autocomplete>

                  <a-btn color="primary" :disabled="!orgId" @click="addOrgToTeam" text="SAVE"/>
                  <a-btn variant="text" color="primary" @click="[addOrg = !addOrg, orgId = null]" text="CANCEL"/>
                </v-card>
                <v-data-table
                  :headers="orgHeaders"
                  :items="filterOrgs"
                  :fixed-header="true"
                  :items-per-page="-1"
                  hide-default-footer
                  :mobile-breakpoint="0"
                  disable-sort
                  class="elevation-1 org-type-table"
                >
                  <template #no-data>
                    <span class="default-text-color">No organizations assigned</span>
                  </template>

                  <template #no-results>
                    <span class="default-text-color">No organizations assigned</span>
                  </template>

                  <template #item="{ item }">
                    <tr class="text-left" :class="{'shaded-row': expandedItem.orgs.indexOf(item) % 2}">
                      <td class="text-left">{{ item.name }}</td>
                      <td class="text-right">
                        <a-btn size="small" variant="text" color="primary"
                                         @click="startDelete(DeleteTypeEnum.ORG, item)" prepend-icon="delete"/>
                      </td>
                    </tr>
                  </template>

                </v-data-table>
              </div>
              <div class="mb-2">
                <v-toolbar flat dense color="transparent" class="wqt-header-bar">
                  <v-toolbar-title class="albatross-header-4"><b>Unassigned SMS Notification</b></v-toolbar-title>
                  <v-spacer></v-spacer>
                </v-toolbar>
                <div class="pl-4">
                  <span v-if="item.unassignedNotificationUsers.length === 0" class="error-red">No one in this team is configured to receive notifications regarding team’s unassigned messages</span>
                  <span v-else v-for="(us, idx) in item.unassignedNotificationUsers">
                    <span v-if="idx !== 0">, </span>
                    <span >{{ us.fullName }}</span>
                  </span>
                </div>
              </div>
            </td>
          </template>

          <template #item="{ item }">
            <tr :class="{'shaded-row': filterTeams.indexOf(item) % 2}">
              <td class="text-left align-baseline">
                <span>{{ item.teamName }}</span>
                <span v-if="item.positions.length === 0 && item.users.length === 0 && item.orgs.length === 0" class="pl-4 error-red"><v-icon color="error" class="pr-1">error</v-icon>This team has no members</span>
              </td>
              <td class="pl-6"><v-icon v-if="item.isDefault">mdi-check</v-icon></td>
              <td class="text-right">
                <a-btn size="small" variant="text" color="primary"
                                 v-if="!expanded.includes(item) && userStore.userHasFeatureAccessLevel('SMS_INBOX', 'EDIT')"
                                 @click="expanded = [item]; expandedItem = item;" prepend-icon="edit"/>
                <a-btn
                  v-if="!expanded.includes(item) && userStore.userHasFeatureAccessLevel('SMS_INBOX', 'DELETE')"
                  :disabled="item.isDefault" size="small" variant="text" color="primary"
                  @click="startDelete(DeleteTypeEnum.TEAM, item)" prepend-icon="delete"/>
                <a-btn size="small" variant="text" color="primary"
                                 v-if="expanded.includes(item)" @click="expanded = []" text="CANCEL"/>
              </td>

            </tr>
          </template>

        </v-data-table>
      </v-col>

    </v-row>
  </v-container>
</template>

<script setup>

import {
  handleHidingGlobalLoader,
  putRequest,
  getSnackbar,
  getRequest,
  postRequest,
  deleteRequest
} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ConfirmationDialog from "@/components/ConfirmationDialog";

import {getCurrentInstance, onMounted, ref, computed, watch} from "vue";

import { useUserStore } from '@/stores/UserStore.js'
import {useRoute} from "vue-router/composables"
import { useAppStore } from '@/stores/AppStore.js'
const appStore = useAppStore()

const vueInstance = getCurrentInstance().proxy
const snackbar = vueInstance.$snackbar
const vuetify = vueInstance.$vuetify
const store = vueInstance.$store
const userStore = useUserStore()
const route = useRoute()

const DeleteTypeEnum = ref(Object.freeze({
  TEAM: 'deleteTeam',
  POSITION:'deletePosition',
  USER:'deleteUser',
  ORG: 'deleteOrg'
}))

const teams = ref([])
const newTeam = ref({})
const addTeam = ref(false)
const userSearch = ref('')
const orgSearch = ref('')
const levels = ref([])
const parentId = ref(userStore.details.parentCompanyId)
const headers = ref([
  { text: 'Team Name', value: 'teamName', show: true },
  {text: 'Default', value: 'isDefault', show: true },
  { text: null, value: 'icons', show: true, sortable: false }
])
const expanded = ref([])
const expandedItem = ref([])
const showDeleteDialog = ref(false)
const showDeleteUserDialog = ref(false)
const positionHeaders = ref([
  {text: 'Current Positions', value: 'name', show: true},
  {text: null, value: 'icons', show: true}
])
const userHeaders = ref([
  {text: 'Current Users', value: 'fullName', show: true},
  {text: null, value: 'icons', show: true}
])
const orgHeaders = ref([
  {text: 'Current Organizations', value: 'orgName', show: true},
  {text: null, value: 'icons', show: true}
])
const addUser = ref(false)
const addPosition = ref(false)
const addOrg = ref(false)
const users = ref([])
const positions = ref([])
const orgs = ref([])
const positionId = ref('')
const userId = ref('')
const orgId = ref('')
const itemToDelete = ref('')
const deleteType = ref('')

const filterTeams = computed(() => {
  return teams.value.filter(tmp => !tmp.archived)
})
const selectablePositions = computed(() => {
  return positions.value?.filter(p => {
    return expandedItem.value?.positions?.find(po => po.positionId === p.positionId) == null
  })
})
const getTeams = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/smsTeam`)
    teams.value = data
    teams.value.map(team => team.checked = team.isDefault)
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Teams')

    appStore.loading = false
  }
}
const saveTeam = async (team, isNew) => {
  appStore.loading = true
  try {
    const confirmChangeDefault = (team.checked !== team.isDefault)
    if(confirmChangeDefault) {
      //if the edited team has been set as default, remove the isDefault state from the old default team
      const oldDefaultTeam = teams.value.filter(team => team.isDefault)[0]
      if (oldDefaultTeam) {
        oldDefaultTeam.isDefault = false
        const {removeData, removeStatus} = await putRequest(`/smsTeam`, oldDefaultTeam) //removes the default state from
      }
      team.isDefault = team.checked
    }
    const {data, status} = await putRequest(`/smsTeam`, team)
    if(isNew){
      teams.value.push(data)
      addTeam.value = false
      newTeam.value = {}
      snackbar('SUCCESS', 'Team Added')

    } else {
      expanded.value = []
      snackbar('SUCCESS', 'Team Updated')

    }
    handleHidingGlobalLoader(status)
    await getTeams();
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', isNew ? 'Error Adding Team' : 'Error Updating Team')

    appStore.loading = false
  }
}
const deleteTeam = async (team) => {
  try {
    const {data, status} = await putRequest(`/smsTeam/${team.id}/delete`)
    team.archived = true
    snackbar('SUCCESS', 'Team Deleted')
    showDeleteDialog.value = false

    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting Team')

    appStore.loading = false
    await getTeams()
  }
}
const getPositions = async () => {
  try {
    const {data, status} = await getRequest(`/position`)
    positions.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Positions')

    appStore.loading = false
  }
}
const filterPositions = computed(() => {
  return expandedItem.value?.positions?.filter(p => { return !p.archived})
})
const getUsers = async () => {
  try {
    const {data, status} = await getRequest(`/user/active`)
    users.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Users')

    appStore.loading = false
  }
}
const getOrgs = async () => {
  try {
    const {data, status} = await getRequest(`/org`)
    orgs.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Organizations')

    appStore.loading = false
  }
}
const filterOrgs = computed(() => {
  return expandedItem.value?.orgs?.filter(o => { return !o.archived})
})
const addPositionToTeam = async () => {
  appStore.loading = true
  try {
    const {data, status} = await postRequest(`/smsTeam/${expandedItem.value.id}/position/${positionId.value}`, {})
    expandedItem.value.positions.push(data)
    positionId.value = null
    addPosition.value = false
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error adding Position')

    appStore.loading = false
  }
}
const addUserToTeam = async () => {
  appStore.loading = true
  try {
    const {data, status} = await postRequest(`/smsTeam/${expandedItem.value.id}/user/${userId.value}`, {})
    expandedItem.value.users.push(data)
    userId.value = null
    addUser.value = false
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error adding User')

    appStore.loading = false
  }
}
const deleteUserFromTeam = async (user) => {
  appStore.loading = true
  try {
    const {data, status} = await deleteRequest(`/smsTeam/${expandedItem.value.id}/user/` + user.id)
    snackbar('SUCCESS', 'User removed')
    user.archived = true
    const userIndex = expandedItem.value.users.findIndex(u => u.id === user.id);
    expandedItem.value.users.splice(userIndex, 1)
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Unable to remove User')

    appStore.loading = false
  }
}
const deletePositionFromTeam = async (position) => {
  appStore.loading = true
  try {
    const {data, status} = await deleteRequest(`/smsTeam/${expandedItem.value.id}/position/` + position.positionId)
    position.archived = true
    const positionIndex = expandedItem.value.positions.findIndex(p => p.id === position.id);
    expandedItem.value.positions.splice(positionIndex, 1)
    snackbar('SUCCESS', 'Position removed')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Unable to removing Position')

    appStore.loading = false
  }
}
const addOrgToTeam = async () => {
  appStore.loading = true
  try {
    const {data, status} = await postRequest(`/smsTeam/${expandedItem.value.id}/org/${orgId.value}`, {})
    expandedItem.value.orgs.push(data)
    orgId.value = null
    addOrg.value = false
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error adding Organization')

    appStore.loading = false
  }
}
const deleteOrgFromTeam = async (org) => {
  appStore.loading = true
  try {
    const {data, status} = await deleteRequest(`/smsTeam/${expandedItem.value.id}/org/` + org.orgId)
    snackbar('SUCCESS', 'Organization removed')
    org.archived = true
    const orgIndex = expandedItem.value.orgs.findIndex(o => o.id === org.id);
    expandedItem.value.orgs.splice(orgIndex, 1)
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error removing Organization')
    appStore.loading = false
  }
}
const startDelete = (type, item) => {
  itemToDelete.value = item
  deleteType.value = type
  showDeleteDialog.value = true
}
const clearDeleteItem = ()  => {
  itemToDelete.value = ''
  deleteType.value = ''
  showDeleteDialog.value = false
}
const deleteItem = ()  => {
  switch (deleteType.value) {
    case DeleteTypeEnum.value.POSITION:
      deletePositionFromTeam(itemToDelete.value)
      break;
    case DeleteTypeEnum.value.USER:
      deleteUserFromTeam(itemToDelete.value)
      break;
    case DeleteTypeEnum.value.ORG:
      deleteOrgFromTeam(itemToDelete.value)
      break;
    case DeleteTypeEnum.value.TEAM:
      deleteTeam(itemToDelete.value)
      break;
  }
  clearDeleteItem()
}
const filterUsers = computed(() =>{
  return expandedItem.value?.users?.filter(p => { return !p.archived})
})

onMounted(async () => {
  getTeams()
  getPositions()
  getUsers()
  getOrgs()
})

</script>

<style lang="scss">
#team-container .v-data-table__wrapper {
  max-height: calc(100vh - 650px);
}

#hierarchy-container .v-data-table__wrapper {
  max-height: calc(100vh - 200px);
}
</style>

<style lang="scss" scoped>
.team-select {
  width: 450px;
}
.org-type-table {
  margin: 0 16px 30px 16px;

}

.edit-card {
  height: 113px;
}

.error-red {
  color: var(--v-error-base);
}
</style>
