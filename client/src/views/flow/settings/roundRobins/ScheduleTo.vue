<template>
  <v-container class="pa-0" id="schedule-to-container">
    <v-row>
      <v-col class="pt-0">
        <v-toolbar flat>
          <v-toolbar-title>
            Schedule To
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                icon
                color="primary"
                v-if="userCanAdd"
                @click="[addUser = !addUser, selectedUser = {}, getUsers()]"
                :size="$vuetify.breakpoint.smAndDown ? 'large' : 'default'"
                :prepend-icon="addUser ? 'remove' : 'add'"
            ></a-btn>

          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addUser" class="square-card text-left pa-5">
          <v-autocomplete v-model="selectedUser"
                          :items="users"
                          label="Select a User..."
                          :loading="usersLoading"
                          item-text="fullName"
                          item-value="userId"
                          return-object
                          autocomplete="off"
                          attach>
          </v-autocomplete>
          <v-autocomplete v-model="newUserCompanyTimezoneId"
                          :items="companyTimezones"
                          label="Time Zone"
                          v-if="roundRobin.remote"
                          item-text="timezone"
                          item-value="id"
                          attach
          ></v-autocomplete>
          <a-btn
              color="primary"
              class="mr-3 mt-5"
              @click="addUserToRoundRobin(selectedUser)"
              :disabled="!selectedUser.id"
              text="Add"
          ></a-btn>

        </v-card>
        <v-divider v-if="addUser"></v-divider>
        <v-card-title class="pt-0">
          <a-text-field
              v-model="search"
              prepend-inner-icon="search"
              label="Search"
              single-line
              hide-details
          ></a-text-field>
        </v-card-title>
        <v-divider></v-divider>
        <v-data-table id="schedule-to-table"
                      :headers="filteredHeaders"
                      :items="filteredUsers"
                      :fixed-header="true"
                      :items-per-page="-1"
                      disable-sort
                      single-expand
                      :expanded.sync="expanded"
                      :search="search"
                      :loading="dataLoading"
                      class="elevation-0 table-striped"
        >
          <template #no-data>
            <span class="default-text-color">No available users</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available users</span>
          </template>

          <template #item.timezone="{ item, index }" class="text-left timezone-column" v-if="roundRobin.remote">
            <span v-if="!item.edit">{{ item.timezone || '--' }}</span>
            <v-autocomplete v-if="item.edit"
                            v-model="item.companyTimezoneId"
                            :items="companyTimezones"
                            label="Time Zone"
                            style="width: 200px;"
                            item-text="timezone"
                            item-value="id"
                            hide-details
                            attach
            ></v-autocomplete>
            <a-btn
                class="d-inline-block"
                size="x-small"
                variant="text"
                @click="item.edit = !item.edit"
                :prepend-icon="!item.edit ? 'edit' : 'close'"
            ></a-btn>

            <a-btn
                class="d-inline-block"
                size="x-small"
                variant="text"
                v-if="item.edit"
                @click="saveUserTimezone(item)"
                prepend-icon="save"
            ></a-btn>

          </template>
          <template #item.prescribedAllocation="{item}" class="text-left">
            <v-tooltip top>
              <template v-slot:activator="{ on }">
                    <span v-on="on">
                      {{ item.prescribedAllocation | percent(1) }}
                    </span>
              </template>
              <span>{{ getAllocationValue(item.prescribedAllocation) }}</span>
            </v-tooltip>
          </template>
          <template #item.manuallySetAllocation="{item}" class="text-left">
            <input type="checkbox" v-if="item.manualAllocationWhole || item.manualAllocationWhole === 0" checked
                   disabled readonly>
            <input type="checkbox" v-else disabled readonly>
            <a-text-field
                          type="number"
                          solo
                          single-line
                          dense
                          hide-details
                          :disabled="!userCanEdit"
                          :readonly="!userCanEdit"
                          @input="[item.dirty = true, valuesUpdated = true, getTotalManualAllocation()]"
                          class="ml-2 allocation-input d-inline-block"
                          v-model.number="item.manualAllocationWhole"></a-text-field>
            <span class="ml-2">%</span>
          </template>
          <template #item.targetLeadAllocation="{item}" class="text-left">
            <v-tooltip top v-if="item.targetLeadAllocation || item.targetLeadAllocation === 0">
              <template v-slot:activator="{ on }">
                    <span v-on="on">
                      {{ item.targetLeadAllocation | percent(1) }}
                    </span>
              </template>
              <span>{{ getAllocationValue(item.targetLeadAllocation) }}</span>
            </v-tooltip>
            <span v-else>--</span>
          </template>
          <template #item.icons="{item}" class="text-right">
            <a-btn
                v-if="userCanEdit"
                icon
                color="primary"
                @click="userToDelete = item"
                prepend-icon="delete"
                :size="$vuetify.breakpoint.smAndDown ? 'large' : 'small'"
            ></a-btn>
          </template>


          <template v-slot:body.append="{headers}">
            <tr>
              <td v-for="(header,i) in headers" :key="i" class="font-weight-bold">

                <div v-if="header.value === 'manuallySetAllocation'">
                  Total Manual: {{ totalManualAllocation }}%
                  <div v-if="totalManualAllocation > 100" class="error-text">
                    * ERROR: Total Cannot Exceed 100
                  </div>
                </div>

                <div v-if="is7oaksAdmin && header.value === 'prescribedAllocation'">
                  {{ totalPrescribedAllocation }}
                </div>

                <div v-if="is7oaksAdmin && header.value === 'targetLeadAllocation'">
                  {{ totalTargetLeadAllocation }}
                </div>

                <div v-if="header.value === 'icons'">
                  <a-btn
                      @click="saveAllocationChanges"
                      color="primary"
                      icon
                      :disabled="!userCanEdit || totalManualAllocation > 100 || !valuesUpdated"
                      prepend-icon="save"
                  ></a-btn>

                </div>

              </td>
            </tr>
          </template>

        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!userToDelete" @confirm="deleteUserFromRoundRobin"
                        @close-dialog="userToDelete = null">
      Are you sure you want to delete this user: <strong>{{ userToDeleteName }}</strong>?
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>


import {
  handleHidingGlobalLoader,
  getRequest,
  putRequest,
  postRequest,
  getSnackbar,
  getRequestWithParams
} from '@/helpers/helpers'
import sumBy from "lodash.sumby"
import ConfirmationDialog from "@/components/ConfirmationDialog";
import {mapStores} from 'pinia'
import {getCurrentInstance, computed, ref, onMounted} from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute} from "vue-router/composables"
import { useAppStore } from '@/stores/AppStorePinia.js'
const appStore = useAppStore()

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar
const userStore = useUserStore()
const route = useRoute()

const scheduleToUsers = ref([])
const dataLoading = ref(true)
const selectedUser = ref({})
const users = ref([])
const usersLoading = ref(false)
const valuesUpdated = ref(false)
const addUser = ref(false)
const search = ref('')
const expanded = ref([])
const newUserCompanyTimezoneId = ref(null)
const selectedIndex = ref(null)
const totalManualAllocation = ref(null)
const totalTargetLeadAllocation = ref(null)
const totalPrescribedAllocation = ref(null)
const roundRobin = ref({})
const userHeaders = ref([])
const companyTimezones = ref([])
const userToDelete = ref(null)


onMounted(async() => {
  //had to add this to determine if zone is remote or not
  getScheduleToUsers()
  await getRoundRobinDetails()
  userHeaders.value = [
    {text: 'Name', value: 'fullName', show: true},
    {text: 'Timezone', value: 'timezone', show: roundRobin.value.remote, width: 250},
    {text: 'Prescribed Allocation', value: 'prescribedAllocation', show: true},
    {text: 'Manually Set Allocation', value: 'manuallySetAllocation', width: '175px', show: true},
    {text: 'Adjusted Allocation', value: 'targetLeadAllocation', show: true},
    {text: '', value: 'icons', show: true, align: 'end'},
  ]
  if (roundRobin.value?.remote) {
    await getCompanyTimezones()
  }
})

const roundRobinId = computed(() => {
  return route.params.id
})
const is7oaksAdmin = computed(() => {
  return userStore.isSystemAdmin
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
const filteredHeaders = computed(() => {
  return userHeaders.value.filter(header => header.show === true)
})
const filteredUsers = computed(() => {
  return scheduleToUsers.value?.filter(pczu => {
    return !pczu.archived
  })
})
const userToDeleteName = computed(() => {
  return userToDelete.value ? userToDelete.value.fullName : ''
})


const getAllocationValue = (value) => {
  //4 = leading '0.' + 2 more digits it being a % number (0.0132)
  let valueLength = value.toString().length - 4
  return valueLength <= 0 || value === 0 || value === null ? value : vueInstance.$filters.percent(value, valueLength)
}

const getCompanyTimezones = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequestWithParams(`/timezone`)
    companyTimezones.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Timezones')
    appStore.loading = false
  }
}

const getTotalManualAllocation = () => {
  totalManualAllocation.value = sumBy(scheduleToUsers.value, function (o) {
    return o.manualAllocationWhole ? o.manualAllocationWhole : 0
  })
}
const getOtherTotals = () => {
  totalPrescribedAllocation.value = sumBy(scheduleToUsers.value, function (o) {
    return o.prescribedAllocation
  })
  totalTargetLeadAllocation.value = sumBy(scheduleToUsers.value, function (o) {
    return o.targetLeadAllocation
  })
}
const getScheduleToUsers = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/roundRobin/${roundRobinId.value}/scheduleTo`)
    scheduleToUsers.value = data
    dataLoading.value = false
    getTotalManualAllocation()
    if (is7oaksAdmin.value) {
      getOtherTotals()
    }
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const saveAllocationChanges = async () => {
  appStore.loading = true
  try {
    let updatedRows = scheduleToUsers.value.filter(u => u.dirty)
    updatedRows.forEach(r => {
      r.manualAllocation = r.manualAllocationWhole ? r.manualAllocationWhole / 100 : null
    })
    if (updatedRows?.length > 0) {
      const {data} = await putRequest(`/roundRobin/${roundRobinId.value}/userAllocation`, updatedRows)
      scheduleToUsers.value = data
      getTotalManualAllocation()
      if (is7oaksAdmin.value) {
        getOtherTotals()
      }
    }
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Allocation Changes')
    appStore.loading = false
  }
}
const deleteUserFromRoundRobin = async () => {
  const user = userToDelete.value
  appStore.loading = true
  try {
    const {data, status} = await putRequest(`/roundRobin/${roundRobinId.value}/user/${user.roundRobinUserId}/delete`)
    scheduleToUsers.value = data
    getTotalManualAllocation()
    if (is7oaksAdmin.value) {
      getOtherTotals()
    }
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Removing User')
    appStore.loading = false
  }
}
const addUserToRoundRobin = async (selected) => {
  appStore.loading = true
  try {
    let params = {
      roundRobinId: roundRobinId.value,
      userId: selected.id,
      companyTimezoneId: newUserCompanyTimezoneId.value
    }
    const {data, status} = await postRequest(`/roundRobin/${roundRobinId.value}/saveScheduleToUser`, params)
    scheduleToUsers.value = data
    newUserCompanyTimezoneId.value = null
    getTotalManualAllocation()
    if (is7oaksAdmin.value) {
      getOtherTotals()
    }
    addUser.value = false
    selectedUser.value = {}
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Adding User')
    appStore.loading = false
  }
}
const getUsers = async () => {
  if (addUser.value) {
    usersLoading.value = true
    try {
      const {data} = await getRequest(`/roundRobin/${roundRobinId.value}/users`)
      users.value = data
      usersLoading.value = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Loading Users')
    }
  }
}
const getRoundRobinDetails = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/roundRobin/${roundRobinId.value}`)
    roundRobin.value = data
    dataLoading.value = false
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const saveUserTimezone = async (user) => {
  appStore.loading = true
  try {
    const {data, status} = await putRequest(`/roundRobin/user/${user.roundRobinUserId}`, user)
    user.timezone = data.timezone
    user.edit = false
    snackbar('SUCCESS', 'User Updated')
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Updating User')
    appStore.loading = false
  }
}
</script>

<style lang="scss">
#schedule-to-container .v-data-table__wrapper {
  height: calc(100vh - 510px);
  min-height: 400px;
}

@media (max-width: 770px) {
  #schedule-to-table {
    padding-bottom: 12px;

    div.v-data-table__wrapper {
      min-height: unset;
    }

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

<style lang="scss" scoped>
.allocation-input {
  width: 100px;
}

.timezone-column {
  display: flex;
  align-items: center;
}
</style>

