<template>
  <v-container class="pa-0" id="schedule-by-container">
    <v-row>
      <v-col class="pt-0">
        <v-toolbar flat>
          <v-toolbar-title>
            Schedule By
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn icon :large="$vuetify.breakpoint.smAndDown" color="primary" v-if="userCanAdd"
                   @click="[addScheduler = !addScheduler, selectedScheduler = {}, getSchedulers()]">
              <v-icon v-if="addScheduler">remove</v-icon>
              <v-icon v-else>add</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addScheduler" class="square-card text-left pa-5">
          <v-autocomplete v-model="selectedScheduler"
                          :items="schedulers"
                          label="Select a User..."
                          :loading="schedulersLoading"
                          item-text="fullName"
                          item-value="userId"
                          return-object
                          autocomplete="off"
                          attach>
          </v-autocomplete>
          <v-btn color="primary" class="mr-3 white--text" @click="addUserToRoundRobin(selectedScheduler)"
                 :disabled="!selectedScheduler.id">
            Add
          </v-btn>

        </v-card>
        <v-divider v-if="addScheduler"></v-divider>
        <v-card-title class="pt-0">
          <v-text-field
              v-model="schedulerSearch"
              prepend-inner-icon="search"
              label="Search"
              single-line
              hide-details
          ></v-text-field>
        </v-card-title>
        <v-divider></v-divider>
        <v-data-table id="round-robin-schedule-by-table"
                      :headers="schedulerHeaders"
                      :items="filteredSchedulers"
                      :fixed-header="true"
                      :items-per-page="-1"
                      disable-sort
                      :search="schedulerSearch"
                      :loading="schedulersLoading"
                      class="elevation-0 table-striped"
        >
          <template #no-data>
            <span class="default-text-color">No available users</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available users</span>
          </template>

          <template #item="{ item, index }">
            <tr>
              <td class="text-left name-col">{{ item.fullName }}</td>
              <td :class="{'text-right': $vuetify.breakpoint.smAndDown}">
                <v-btn v-if="userCanEdit" icon color="primary" :large="$vuetify.breakpoint.smAndDown"
                       @click="userToDelete = item">
                  <v-icon>delete</v-icon>
                </v-btn>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!userToDelete" @confirm="deleteUserFromRoundRobin"
                        @close-dialog="userToDelete = null">
      Are you sure you want to remove this user: <strong>{{ userToDeleteName }}</strong>?
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>
import {AppMutations} from '@/stores/AppStore'
import {handleHidingGlobalLoader, getRequest, deleteRequest, postRequest, getSnackbar} from '@/helpers/helpers'
import ConfirmationDialog from "@/components/ConfirmationDialog";
import {useUserStore} from '@/stores/UserStorePinia.js'
import {getCurrentInstance, computed, ref, onMounted} from 'vue'
import {useRoute} from "vue-router/composables";

const route = useRoute()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const userStore = useUserStore()


const scheduleByUsers = ref([])
const dataLoading = ref(true)
const selectedScheduler = ref({})
const schedulers = ref([])
const schedulersLoading = ref(false)
const addScheduler = ref(false)
const schedulerSearch = ref('')
const userToDelete = ref(null)
const schedulerHeaders = ref([
  {text: 'Name', value: 'fullName', show: true},
  {text: '', value: 'icons', show: true},
])

const roundRobinId = computed(() => {
  return route.params.id
})
const userCanAdd = computed(() => {
  return userStore.userHasFeatureAccessLevel('ROUND_ROBIN', 'ADD')
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('ROUND_ROBIN', 'EDIT')
})
const userCanDelete = computed(() => {
  return userStore.userHasFeatureAccessLevel('ROUND_ROBIN', 'DELETE')
})
const userToDeleteName = computed(() => {
  return userToDelete.value ? userToDelete.value.fullName : ''
})
const filteredSchedulers = computed(() => {
  return scheduleByUsers?.value.filter(pczu => {
    return !pczu.archived
  })
})

onMounted(() => {
  getScheduleByUsers()
})

const getScheduleByUsers = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await getRequest(`/roundRobin/${roundRobinId.value}/scheduleBy`)
    scheduleByUsers.value = data
    dataLoading.value = false
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    getSnackbar('ERROR', 'Error Retrieving Data')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const deleteUserFromRoundRobin = async () => {
  const user = userToDelete.value
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await deleteRequest(`/roundRobin/user/${user.id}`)
    user.archived = true
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    getSnackbar('ERROR', 'Error Removing User')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const addUserToRoundRobin = async (selected) => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    let params = {
      roundRobinId: roundRobinId.value,
      userId: selected.id,
    }
    const {data, status} = await postRequest(`/roundRobin/saveScheduleByUser`, params)
    scheduleByUsers.value.push(data)
    addScheduler.value = false
    selectedScheduler.value = {}
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    getSnackbar('ERROR', 'Error Adding User')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const getSchedulers = async () => {
  if (addScheduler.value) {
    schedulersLoading.value = true
    try {
      const {data} = await getRequest(`/roundRobin/${roundRobinId.value}/schedulers`)
      schedulers.value = data
      schedulersLoading.value = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      getSnackbar('ERROR', 'Error Loading Users')
    }
  }
}
</script>
<style scoped lang="scss">
@media (max-width: 770px) {
  .name-col {
    width: 100%;
  }
}
</style>
<style lang="scss">
#schedule-by-container .v-data-table__wrapper {
  max-height: calc(100vh - 410px);
  min-height: 300px;
}

@media (max-width: 770px) {
  #round-robin-schedule-by-table {
    padding-bottom: 12px;

    div.v-data-footer {
      display: inline-block;
      width: 100%;
      padding-bottom: 12px;

      div.v-data-footer__select {
        justify-content: center;
      }

      div.v-data-footer__pagination {

      }

      div.v-data-footer__icons-before {
        display: inline;
        margin-left: calc(50% - 36px);
      }

      div.v-data-footer__icons-after {
        display: inline;
      }

    }
  }
}
</style>
