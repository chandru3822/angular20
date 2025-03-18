<template>
  <div>
    <v-row>
      <v-col>
        <v-toolbar flat>
          <v-toolbar-title>
            Users Assigned to Plan
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
              variant="text"
              color="primary"
              @click="[addUser = !addUser, newUser = {}, userHistory = []]"
              v-if="canAdd"
              :prepend-icon="addUser ? 'remove' : 'add'"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addUser" class="square-card text-left px-5 pb-5">
          <v-row>
            <v-col cols="12" md="6">
              <a-autocomplete v-model="newUser.userId"
                              :items="usersToAdd"
                              :loading="usersLoading"
                              prepend-icon="search"
                              cache-items
                              :search-input.sync="userSearch"
                              label="Search for a user..."
                              item-title="name"
                              item-value="userId"
                              autocomplete="off"
                              @input="getUserHistory(newUser.userId)"
                              attach
              >
                <template v-slot:item="{ props, item }">
                  {{ item.name }} - {{ item.position }}
                </template>
              </a-autocomplete>
              <DatetimePickerInput
                v-model="newUser.startDate"
                :timezone="timezone"
                :type="'date'"
                :format="'MMMM DD, YYYY'"
                label="Start Date"
                :readonly="!newUser.userId || errorLoadingUserHistory"
                @input="checkDates(newUser.startDate, newUser.endDate, userHistory, newUser)"
              />
              <DatetimePickerInput
                v-model="newUser.endDate"
                :timezone="timezone"
                :type="'date'"
                :format="'MMMM DD, YYYY'"
                label="End Date"
                :readonly="!newUser.userId || errorLoadingUserHistory"
                @input="checkDates(newUser.startDate, newUser.endDate, userHistory, newUser)"
              />
            </v-col>
            <v-col cols="12" md="6">
              <v-data-table
                :headers="historyHeaders"
                :items="userHistory"
                :fixed-header="true"
                :items-per-page="-1"
                disable-sort
                hide-default-footer
                class="elevation-1"
                v-if="userHistory.length > 0"
              >
              </v-data-table>
              <div v-if="errorLoadingUserHistory" class="error--text">
                We had a problem loading this user's plan history. Cannot add this user until their history can be
                checked.
              </div>
            </v-col>
          </v-row>

          <div v-if="newUser.dateError" class="error--text mb-2">
            * Error: {{ newUser.dateErrorMsg }}
          </div>
          <div class="mb-2" v-else-if="newUser.showNote">
            {{ newUser.noteMsg }}
          </div>
          <a-btn
            color="primary"
            class="mr-3"
            @click="addUserToPlan()"
            :disabled="newUser.dateError || !newUser.userId || !newUser.startDate || errorLoadingUserHistory"
            text="Add"
          ></a-btn>
        </v-card>
        <v-divider v-if="addUser"></v-divider>
        <v-data-table
          :headers="headers"
          :items="filteredCommissionUsers"
          :fixed-header="true"
          :items-per-page="-1"
          disable-sort
          :loading="dataLoading"
          single-expand
          :expanded.sync="assignedUserExpanded"
          hide-default-footer
          class="elevation-1"
        >
          <template #no-data>
            No available users
          </template>

          <template #no-results>
            No available users
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4 text-left">
              <v-row>
                <v-col cols="12" md="6">
                  <DatetimePickerInput
                    v-model="item.endDate"
                    :timezone="timezone"
                    :type="'date'"
                    :format="'MMMM DD, YYYY'"
                    label="End Date"
                    :readonly="errorLoadingUserHistory"
                    @input="checkDates(item.startDate, item.endDate, userHistory, item, commission.id)"
                  />
                </v-col>
                <v-col cols="12" md="6">
                  <v-data-table
                    :headers="historyHeaders"
                    :items="userHistory"
                    item-key="userPlanId"
                    :fixed-header="true"
                    :items-per-page="-1"
                    hide-default-footer
                    class="elevation-1"
                    v-if="userHistory.length > 0"
                  >
                  </v-data-table>
                  <div v-if="errorLoadingUserHistory" class="error--text">
                    We had a problem loading this user's plan history. Cannot add this user until their history can be
                    checked.
                  </div>
                </v-col>
              </v-row>
              <div v-if="item.dateError" class="error--text mb-2">
                * Error: {{ item.dateErrorMsg }}
              </div>
              <div class="mb-2" v-else-if="item.showNote">
                {{ item.noteMsg }}
              </div>
              <a-btn
                color="primary"
                class="mr-3"
                @click="updateAssignedUser(item)"
                :disabled="item.dateError || !item.userId || !item.startDate || errorLoadingUserHistory"
                text="Save"
              ></a-btn>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{ item.name }}</td>
              <td class="text-left">{{ item.position }}</td>
              <td class="text-left">{{ item.employeeId }}</td>
              <td class="text-left">{{ item.startDate }}</td>
              <td class="text-left">{{ item.endDate }}</td>
              <td>
                <a-btn
                  v-if="commission.statusType === 'PENDING' && !assignedUserExpanded.includes(item)"
                  size="small"
                  variant="text"
                  color="primary"
                  prepend-icon="edit"
                  @click="[assignedUserExpanded = [item], getUserHistory(item.userId)]"
                ></a-btn>
                <a-btn
                  size="small"
                  variant="text"
                  color="primary"
                  @click="assignedUserExpanded = []"
                  v-if="assignedUserExpanded.includes(item)"
                  text="Cancel"
                ></a-btn>
                <a-btn
                  v-if="commission.statusType === 'PENDING' && canDelete"
                  size="small"
                  variant="text"
                  color="primary"
                  @click="userToDelete=item"
                  prepend-icon="delete"
                ></a-btn>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!userToDelete" @confirm="deleteUserFromPlan" @close-dialog="userToDelete=null">
      Are you sure you want to delete <strong>{{ userToDeleteName }}</strong>?
    </ConfirmationDialog>
  </div>
</template>

<script setup>
  import moment from 'moment'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'

  import {
    handleHidingGlobalLoader,
    getRequest,
    deleteRequest,
    putRequest,
    postRequestWithRequestParams,
    postRequest,
    getSnackbar,
    getRequestWithParams
  } from '@/helpers/helpers.js';
  import ConfirmationDialog from "@/components/ConfirmationDialog.vue";
  import { useBrsStore } from '@/stores/BrsStore.js'
  import {getCurrentInstance, computed, ref, onMounted, watch, toRefs} from 'vue'
  import {useUserStore} from '@/stores/UserStore.js'
  import {useAppStore} from '@/stores/AppStore.js'
  import {useRoute, useRouter} from "vue-router/composables"
  import debounce from "lodash.debounce"
  import { storeToRefs } from 'pinia'

  const route = useRoute()
  const router = useRouter()
  const userStore = useUserStore()
  const appStore = useAppStore()
  const brsStore = useBrsStore()
  const { commissionPositionId } = storeToRefs(brsStore)

  const vueInstance = getCurrentInstance().proxy
  const store = vueInstance.$store

  const props = defineProps({
    commission: Object,
    planId: Number,
    dataLoading: Boolean,
    canEdit: Boolean,
    canAdd: Boolean,
    canDelete: Boolean,
    isAdmin: Boolean
  })
  const { commission, planId } = toRefs(props)

  const addUser = ref(false)
  const newUser = ref({})
  const usersToAdd = ref([])
  const userSearch = ref('')
  const userHistory = ref([])
  const usersLoading = ref(false)
  const userToDelete = ref(null)
  const errorLoadingUserHistory = ref(false)
  const assignedUserExpanded = ref([])

  const historyHeaders = ref([
    {text: 'Name', value: 'name', show: true},
    {text: 'Start Date', value: 'startDate', show: true},
    {text: 'End Date', value: 'endDate', show: true},
  ])

  const headers = ref([
    {text: 'Name', value: 'name', show: true},
    {text: 'Position', value: 'Position', show: true},
    {text: 'Employee ID', value: 'employeeId', show: true},
    {text: 'Start Date', value: 'startDate', show: true},
    {text: 'End Date', value: 'endDate', show: true},
    {text: '', value: 'icons', show: true},
  ])

  const userToDeleteName = computed(() => {
    return userToDelete.value ? userToDelete.value.name : ''
  })
  const filteredCommissionUsers = computed(() => {
    return commission.value?.users?.filter(cu => {
      return !cu.archived
    })
  })
  const activeUsers = computed(() => {
    return commission.value?.users?.filter(u => {
      return u.endDate === null || u.endDate > new Date()
    })
  })
  const timezone = computed(() => {
    return userStore.timezone.value
  })


  watch(userSearch, (val) => {
    if (!val) {
      usersToAdd.value = []
      newUser.value.userId = null
      return
    }
    usersToAdd.value = []
    getUsersToAddDebounced(val)
  })

  onMounted(() => {

  })

  const updateAssignedUser = async (item) => {
    appStore.loading = true
    try {
      const {status} = await postRequest(`/commissionManagement/${planId.value}/updateUser`, item, 'blueraven')
      assignedUserExpanded.value = []
      userHistory.value = []
      appStore.showSnack('SUCCESS', 'Assigned User Updated')
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Updating Assigned User')
      appStore.loading = false
    }
  }
  const getUsersToAddDebounced = debounce((val) => {
    getUsersToAdd(val)
  }, 500)
  const getUsersToAdd = async (query) => {
    if (addUser.value) {
      usersLoading.value = true
      try {
        let positions = commission.value.positionId === 1 ? 'closers' : 'setters'
        let params = {
          positions,
          query,
          planId: planId.value
        }
        const {data} = await getRequestWithParams(`/commissionManagement/_search`, {params}, 'blueraven')
        usersToAdd.value = data
        usersLoading.value = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        appStore.showSnack('ERROR', 'Error Retrieving Commission Plan Users')
        appStore.loading = false
      }
    }
  }
  const addUserToPlan = async () => {
    appStore.loading = true
    try {
      let params = {
        userId: newUser.value.userId,
        startDate: newUser.value.startDate,
        endDate: newUser.value.endDate,
        approvalCreds: null
      }
      const {
        data,
        status
      } = await postRequestWithRequestParams(`/commissionManagement/${planId.value}/users/${commission.value.positionId}`, params, {addUserToPlan: true}, 'blueraven')
      commission.value.users = data
      appStore.showSnack('SUCCESS', 'Commission Plan User Added')
      addUser.value = false
      newUser.value = {}
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Adding Commission Plan User')
      appStore.loading = false
    }
  }
  const deleteUserFromPlan = async () => {
    const commissionPlanUser = userToDelete.value
    appStore.loading = true
    try {
      const {status} = await deleteRequest(`/commissionManagement/${planId.value}/commissionUser/${commissionPlanUser.id}`, 'blueraven')
      appStore.showSnack('SUCCESS', 'Commission Plan User Deleted')
      commissionPlanUser.archived = true
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Deleting Commission Plan User')
      appStore.loading = false
    }
  }
  const getUserHistory = async (userId) => {
    //reset the rest of the new user fields if they change users
    delete newUser.value.startDate
    delete newUser.value.endDate
    newUser.value.dateError = false
    newUser.value.dateErrorMsg = ''
    newUser.value.showNote = false
    newUser.value.noteMsg = ''
    errorLoadingUserHistory.value = false
    appStore.loading = true
    try {
      const {data, status} = await getRequest(`/commissionManagement/commissionUser/${userId}/history`, 'blueraven')
      userHistory.value = data
      handleHidingGlobalLoader(status)
    } catch (e) {
      errorLoadingUserHistory.value = true
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Retrieving User History')
      appStore.loading = false
    }
  }
  const checkDates = (startDate, endDate, plans, item, existingId) => {
    //item = where to track the error
    item.dateError = false

    if (startDate > endDate) {
      item.dateError = true
      item.dateErrorMsg = 'End Date cannot be before Start Date'
    } else {
      let overlap = []
      let hasActivePlan = false
      plans.forEach(p => {
        if (dateRangeOverlap(startDate, endDate, p, existingId)) {
          overlap.push(p)
        }
        // if any plan doesn't have an end date, then there is an active plan
        if (!p.endDate) {
          hasActivePlan = true
        }
      })
      if (overlap.length > 0) {
        item.dateError = true
        item.dateErrorMsg = 'Plans Cannot Overlap'
      } else if (!existingId && startDate && hasActivePlan) {
        item.showNote = true
        item.noteMsg = `The Current plan's end date will be set to ${moment(startDate).subtract(1, 'd').format('MM/DD/YYYY')}.`
      }
    }
  }
  const dateRangeOverlap = (start, end, plan, existingId) => {
    //this will not allow them to go back in time to add plans before existing plans which seems to be ok
    if (plan.id === existingId) {
      // ignore overlap check for self on existing record
      return false
    } else {
      //this is used when adding a new plan
      return start <= plan.startDate || start <= plan.endDate
    }
  }
</script>

<style lang="scss" scoped>
  .v-data-table {
    border-radius: 0;
  }
</style>
