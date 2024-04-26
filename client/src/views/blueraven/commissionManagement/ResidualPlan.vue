<template>
  <v-container class="pa-0" id="residualPlan-container">
    <v-toolbar flat color="transparent">
      <v-toolbar-title>
        <span v-if="planId">{{residualPlan.name}}</span>
        <span v-else>New Residual Plan</span>
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <div class="commission-button-container">
          <a-btn
              color="primary"
              class="mr-2"
              :disabled="!residualPlan.name"
              @click="savePlan()"
              text="Save"
          ></a-btn>
          <a-btn
              color="success"
              class="mr-2"
              v-if="userStore.userHasFeatureAccessLevel('COMMISSIONS', 'ADMIN') && planId && residualPlan.statusType === 'PENDING'"
              :disabled="errorMessages.length > 0"
              @click="approvePlan()"
          > Approve </a-btn>
        </div>
      </v-toolbar-items>
    </v-toolbar>
    <v-divider v-if="errorMessages.length > 0"></v-divider>
    <v-row v-if="errorMessages.length > 0">
      <v-col cols="12">
        <v-list v-for="(em, index) in errorMessages" :key="index" class="pa-0" color="transparent">
          <v-list-item>
            <v-list-item-content class="text-left error--text">
              {{em}}
            </v-list-item-content>
          </v-list-item>
        </v-list>
      </v-col>
    </v-row>
    <v-divider></v-divider>
    <v-form ref="residualPlanForm">
      <v-container>
        <v-row>
          <v-col cols="12" sm="6">
            <v-card flat class="pa-3" color="transparent">
              <a-text-field
                            label="Name"
                            v-model="residualPlan.name"></a-text-field>
              <a-text-field
                            label="Description"
                            v-model="residualPlan.description"></a-text-field>
              <a-text-field label="Total"
                            readonly disabled
                            prepend-icon="mdi-currency-usd"
                            v-model.number="residualPlan.total"></a-text-field>
              <a-text-field v-if="residualPlan.residualDurationMonths"
                            label="Residual Lifetime (Months)"
                            readonly disabled
                            v-model="residualPlan.residualDurationMonths"></a-text-field>
            </v-card>
          </v-col>
          <v-col cols="12" sm="6">
            <v-card class="pa-3" v-if="planId">
              <a-text-field
                            label="Status"
                            disabled
                            v-model="residualPlan.statusType"></a-text-field>
              <a-text-field
                            disabled
                            label="Created By"
                            v-model="residualPlan.createdName"></a-text-field>
              <a-text-field
                            disabled
                            label="Approved"
                            v-if="residualPlan.approvedDate"
                            v-model="residualPlan.approvedDate"></a-text-field>
              <a-text-field
                            disabled
                            v-if="residualPlan.approvedName"
                            label="Approved By"
                            v-model="residualPlan.approvedName"></a-text-field>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
    </v-form>
    <v-row v-if="planId">
      <v-col>
        <v-toolbar flat>
          <v-toolbar-title>
            Levels
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                variant="text"
                color="primary"
                v-if="residualPlan.statusType === 'PENDING'"
                @click="[selectedLevel = {}, addLevel = !addLevel]"
                :prepend-icon="addLevel ? 'remove' : 'add'"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-data-table
            :headers="levelHeaders"
            :items="residualPlan.residualPlanAllocations"
            :fixed-header="true"
            hide-default-footer
            disable-sort
            :loading="dataLoading"
            single-expand
            :expanded.sync="levelExpanded"
            class="elevation-1"
        >
          <template #no-data>
            No available levels
          </template>

          <template #no-results>
            No available levels
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.min}}</td>
              <td class="text-left">{{item.max}}</td>
              <td class="text-left">{{item.allocation}} {{residualPlan.isSystemSize ? 'kW' : ''}}</td>
              <td class="text-left">{{item.fdcCount}} {{residualPlan.isSystemSize && item.fdcCount ? 'kW' : ''}}</td>
              <td class="text-left">
                <span v-if="item.partialAllocation !== null">{{ item.partialAllocation | percent(0)}}</span>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <v-row v-if="planId">
      <v-col>
        <v-toolbar flat>
          <v-toolbar-title>
            Source Adjustment
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                variant="text"
                color="primary"
                v-if="residualPlan.statusType === 'PENDING'"
                @click="[selectedSource = {}, addSource = !addSource, getSources()]"
                :prepend-icon="addSource ? 'remove' : 'add'"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addSource" class="square-card text-left pa-5">
          <v-form ref="sourceForm">
            <a-select attach v-model="selectedSource.id"
                      :items="sources"
                      label="Select a Source..."
                      item-title="sourceName"
                      item-value="id"
                      autocomplete="off">
            </a-select>
            <a-text-field variant="text"
                          type="number"
                          label="Amount"
                          :rules="amountRules"
                          v-model.number="selectedSource.amount"></a-text-field>
            <a-btn
                color="primary"
                class="mr-3"
                @click="validateSource()"
                text="Add"
            ></a-btn>
          </v-form>
        </v-card>
        <v-divider v-if="addSource"></v-divider>
        <v-data-table
            :headers="sourceHeaders"
            :items="residualPlan.sources"
            :fixed-header="true"
            :items-per-page="-1"
            disable-sort
            :loading="dataLoading"
            single-expand
            :expanded.sync="sourceExpanded"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            <span class="default-text-color">No available sources</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available sources</span>
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4 text-left">
              <a-text-field variant="text" type="number"
                            label="Amount"
                            :rules="amountRules"
                            v-model.number="item.amount"></a-text-field>
              <a-btn
                  :disabled="!item.amount || item.amount <= 0 || item.amount > 5"
                  @click="[sourceExpanded = [], updateSource(item)]"
                  color="primary"
                  text="Save"
              ></a-btn>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.sourceName}}</td>
              <td class="text-left">{{item.amount}}</td>
              <td class="text-right">
                <a-btn
                    size="small"
                    variant="text"
                    color="primary"
                    @click="sourceExpanded = [item]"
                    v-if="residualPlan.statusType === 'PENDING' && !sourceExpanded.includes(item)"
                    prepend-icon="edit"
                ></a-btn>
                <a-btn
                    size="small"
                    variant="text"
                    color="primary"
                    @click="sourceExpanded = []"
                    v-if="sourceExpanded.includes(item)"
                    text="Cancel"
                ></a-btn>
                <a-btn
                    v-if="residualPlan.statusType === 'PENDING'"
                    size="small"
                    variant="text"
                    color="primary"
                    @click="sourceToDelete=item"
                    prepend-icon="delete"
                ></a-btn>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!sourceToDelete" @confirm="deleteSource" @close-dialog="sourceToDelete=null">
      Are you sure you want to delete this source: <strong>{{ sourceToDeleteName }}</strong>??
    </ConfirmationDialog>
    <v-row v-if="planId">
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
                              attach
              >
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
          </v-row>

          <div v-if="newUser.dateError" class="error--text mb-2">
            * Error: {{newUser.dateErrorMsg}}
          </div>
          <div class="mb-2" v-else-if="newUser.showNote">
            {{newUser.noteMsg}}
          </div>
          <a-btn
              color="primary"
              class="mr-3"
              @click="addUserToPlan()"
              :disabled="newUser.dateError || !newUser.userId || !newUser.startDate || errorLoadingUserHistory"
              text="Add"
          ></a-btn>
        </v-card>
        <v-card color="white" class="square-card px-5 pt-1 pb-4">
          <a-text-field
              prepend-inner-icon="search"
              hide-details
              clearable
              label="Search users..."
              v-model="search"
          ></a-text-field>
        </v-card>
        <v-divider></v-divider>
        <v-data-table
            :headers="headers"
            :items="filteredResidualPlanUsers"
            :fixed-header="true"
            :options.sync="options"
            :search="search"
            :footer-props="footerProps"
            disable-sort
            :loading="dataLoading"
            single-expand
            :expanded.sync="assignedUserExpanded"
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
                      @input="checkDates(item.startDate, item.endDate, userHistory, item, residualPlan.id)"
                  />
                </v-col>
                <v-col cols="12" md="6">
                  <v-data-table
                      :headers="historyHeaders"
                      :items="userHistory"
                      :fixed-header="true"
                      :items-per-page="-1"
                      hide-default-footer
                      class="elevation-1"
                      v-if="userHistory.length > 0"
                  >
                  </v-data-table>
                  <div v-if="errorLoadingUserHistory" class="error--text">
                    We had a problem loading this user's plan history. Cannot add this user until their history can be checked.
                  </div>
                </v-col>
              </v-row>
              <div v-if="item.dateError" class="error--text mb-2">
                * Error: {{item.dateErrorMsg}}
              </div>
              <div class="mb-2" v-else-if="item.showNote">
                {{item.noteMsg}}
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
              <td class="text-left">{{item.name}}</td>
              <td class="text-left">{{item.employeeId}}</td>
              <td class="text-left">{{item.startDate}}</td>
              <td class="text-left">{{item.endDate}}</td>
              <td>

                <a-btn
                    size="small"
                    variant="text"
                    color="primary"
                    @click="[assignedUserExpanded = [item], getUserHistory(item.userId)]"
                    v-if="residualPlan.statusType === 'PENDING' && !assignedUserExpanded.includes(item)"
                    prepend-icon="edit"
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
                    size="small"
                    variant="text"
                    color="primary"
                    @click="userToDelete = item"
                    v-if="residualPlan.statusType === 'PENDING'"
                    prepend-icon="delete"
                ></a-btn>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!userToDelete" @confirm="deleteUserFromPlan" @close-dialog="userToDelete = null">
      Are you sure you want to delete <strong>{{ userToDeleteName }}</strong>?
    </ConfirmationDialog>
    <ConfirmationDialog :open-dialog="!!levelToDelete" @confirm="deleteLevel" @close-dialog="levelToDelete = null">
      Are you sure you want to delete this level: <strong>{{ levelToDeleteName }}</strong>?
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>

import moment from 'moment'
import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
import {handleHidingGlobalLoader, getRequest, deleteRequest, putRequest, postRequest,  getRequestWithParams} from '@/helpers/helpers'
import ConfirmationDialog from "@/components/ConfirmationDialog";
import constants from "@/helpers/constants";
import debounce from 'lodash.debounce'
import { storeToRefs } from 'pinia'

import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'
import { useBrsStore } from '@/stores/BrsStore.js'

const brsStore = useBrsStore()
const { commissionPositionId } = storeToRefs(brsStore)
const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const cloneDialog = ref(false)
const addUser = ref(false)
const newUser = ref({})
const usersToAdd = ref([])
const userSearch = ref(null)
const userHistory = ref([])
const usersLoading = ref(false)
const levelExpanded = ref([])
const footerProps = ref({
  'items-per-page-options': [10, 50, 100, 1000, 3000],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const options = ref({itemsPerPage: 100})
const levelHeaders = ref([
  {text: 'Lifetime FDC Lower', value: 'min', show: true},
  {text: 'Lifetime FDC Upper', value: 'max', show: true},
  {text: 'Target FDC', value: 'allocation', show: true},
  {text: 'Partial Target', value: 'fdcCount', show: true},
  {text: 'Partial Target %', value: 'partial', show: true},
])
const addLevel = ref(false)
const selectedLevel = ref({})
const cloneStartDate = ref(null)
const dataLoading = ref(true)
const inactivateConfirm = ref(false)
const deleteConfirm = ref(false)
const errorLoadingUserHistory = ref(false)
const assignedUserExpanded = ref([])
const search = ref('')
const headers = ref([
  {text: 'Name', value: 'name', show: true},
  {text: 'Employee ID', value: 'employeeId', show: true},
  {text: 'Start Date', value: 'startDate', show: true},
  {text: 'End Date', value: 'endDate', show: true},
  {text: '', value: 'icons', show: true},
])
const historyHeaders = ref([
  {text: 'Name', value: 'name', show: true},
  {text: 'Start Date', value: 'startDate', show: true},
  {text: 'End Date', value: 'endDate', show: true},
])
const errorMessages = ref([])
const cloneDateError = ref(false)
const residualPlan = ref({users: [],})
const sourceHeaders = ref([
  {text: 'Source', value: 'source', show: true},
  {text: 'Amount', value: 'amount', show: true},
  {text: '', value: 'icons', show: true},
])
const sourceExpanded = ref([])
const addSource = ref(false)
const selectedSource = ref({})
const sourceToDelete = ref(null)
const sourceForm = ref(null)
const amountRules = ref([
  v => !!v || "This field is required",
  v => ( v && v >= 0 ) || "Amount must be greater than 0",
  v => ( v && v <= 5 ) || "Amount can not be above 5",
  ])
const sources = ref([])
const levelToDelete = ref(null)
const userToDelete = ref(null)

onMounted(() => {
  if(planId.value) {
    getResidualPlanDetails()
  } else {
    dataLoading.value = false
  }
})

watch(commissionPositionId, async() => {
  //if they change the position (setter vs closer) have to go back to main page
  await router.push('/commissionManagement/residualPlans')
})

const planId = computed(() => {
  return route.params.id
})
const timezone = computed(() => {
  return userStore.timezone.value
})
const levelToDeleteName = computed(() => {
  return levelToDelete.value ? levelToDelete.value.name : ''
})
const userToDeleteName = computed(() => {
  return userToDelete.value ? userToDelete.value.name : ''
})
const sourceToDeleteName = computed(() => {
  return sourceToDelete.value ? sourceToDelete.value.sourceName : ''
})
const filteredResidualPlanUsers = computed(() => {
  return residualPlan.value?.users?.filter(cu => { return !cu.archived})
})

watch(planId, () => {
  getResidualPlanDetails()
})
watch(userSearch, (val) => {
  if(!val) {
    newUser.value.userId = null
    usersToAdd.value = []
    return
  }
  usersToAdd.value = []
  getUsersToAddDebounced(val)
})


const validateSource = () => {
  if(sourceForm.value.validate()) {
    addSourceToPlan()
  }
}

const getResidualPlanDetails = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/commissionManagement/residuals/plan/${planId.value}`, 'blueraven')
    residualPlan.value = data
    if([2,3].includes(residualPlan.value.residualPlanStatusId)) {
      residualPlan.value.approved = true
    }
    checkErrorMessages()
    dataLoading.value = false
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Loading Residual Plan Details')

    appStore.loading = false
  }
}
const validateStartDates = () => {
  //this is used when cloning users
  cloneDateError.value = false
  residualPlan.value?.users?.forEach(u => {
    if(u.selected && u.startDate >= cloneStartDate.value) {
      cloneDateError.value = true
    }
  })

  if(!cloneDateError) {
    clonePlan(residualPlan.value.users, cloneStartDate.value)
    cloneDialog.value = false;
  }
}
const checkDates = (startDate, endDate, plans, item, existingId) => {
  //item = where to track the error
  item.dateError = false

  if(startDate > endDate) {
    item.dateError = true
    item.dateErrorMsg = 'End Date cannot be before Start Date'
  } else {
    let overlap = []
    let hasActivePlan = false
    plans.forEach(p => {
      if(dateRangeOverlap(startDate, endDate, p, existingId)) {
        overlap.push(p)
      }
      // if any plan doesn't have an end date, then there is an active plan
      if(!p.endDate) {
        hasActivePlan = true
      }
    })
    if(overlap.length > 0) {
      item.dateError = true
      item.dateErrorMsg = 'Plans Cannot Overlap'
    } else if(!existingId && startDate && hasActivePlan) {
      item.showNote = true
      item.noteMsg = `The Current plan's end date will be set to ${moment(startDate).subtract(1, 'd').format('MM/DD/YYYY')}.`
    }
  }
}
const dateRangeOverlap = (start, end, plan, existingId) => {
  //this will not allow them to go back in time to add plans before existing plans which seems to be ok
  if(plan.id === existingId) {
    // ignore overlap check for self on existing record
    return false
  } else {
    //this is used when adding a new plan
    return start <= plan.startDate || start <= plan.endDate
  }
}
const checkErrorMessages =  () => {
  errorMessages.value = []
}
const planHasActiveUsers =  () => {
  let hasActive = false
  residualPlan.value?.users?.forEach(u => {
    if(u.endDate === null || u.endDate > new Date()){
      hasActive = true
    }
  })
  return hasActive
}
const savePlan = async () => {
  appStore.loading = true
  try {
    let params = {
      id: residualPlan.value.id,
      name: residualPlan.value.name,
      description: residualPlan.value.description
    }
    const {data, status} = await postRequest(`/commissionManagement/residuals/plan`, params, 'blueraven')
    if(!planId.value) {
      //need to reload some stuff if this was a new plan
      router.push({name: 'residualPlan', params: {id: data.id}})
    }
    checkErrorMessages()
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Saving Residual Plan')

    appStore.loading = false
  }
}
const approvePlan = async () => {
  appStore.loading = true
  try {
    const {data, status} = await postRequest(`/commissionManagement/residuals/plan/${planId.value}/approve`, {}, 'blueraven')
    appStore.showSnack('SUCCESS', 'Residual Plan Approved')
    residualPlan.value = data
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Approving Residual Plan')

    appStore.loading = false
  }
}
const updateAssignedUser = async(item) => {
  appStore.loading = true
  try {
    const {status} = await postRequest(`/commissionManagement/residuals/${planId.value}/updateUser`, item, 'blueraven')
    assignedUserExpanded.value = []
    userHistory.value = []
    appStore.showSnack('SUCCESS', 'Assigned User Updated')

    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Updating Assigned User')

    appStore.loading = false
  }
}
const getUsersToAddDebounced = debounce((val) => {
  getUsersToAdd(val)
}, 500)
const getUsersToAdd = async(query) => {
  if(addUser.value) {
    usersLoading.value = true
    try {
      let params = {
        query,
        planId: planId.value
      }
      const {data} = await getRequestWithParams(`/commissionManagement/residuals/_search`, {params}, 'blueraven')
      usersToAdd.value = data
      usersLoading.value = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Retrieving Residual Plan Users')

      appStore.loading = false
    }
  }
}
const addUserToPlan = async() => {
  appStore.loading = true
  try {
    let params = {
      userId: newUser.value.userId,
      startDate: newUser.value.startDate,
      endDate: newUser.value.endDate,
      approvalCreds: null
    }
    const {data, status} = await postRequest(`/commissionManagement/residuals/${planId.value}/users`, params, 'blueraven')
    residualPlan.value.users = data
    appStore.showSnack('SUCCESS', 'Residual Plan User Added')

    addUser.value = false
    newUser.value = {}
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Adding Residual Plan User')

    appStore.loading = false
  }
}
const deleteUserFromPlan = async() => {
  const residualPlanUser = userToDelete.value
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`/commissionManagement/residuals/${planId.value}/residualPlanUser/${residualPlanUser.id}`, 'blueraven')
    appStore.showSnack('SUCCESS', 'Residual Plan User Deleted')

    residualPlanUser.archived = true
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Deleting Residual Plan User')

    appStore.loading = false
  }
}
const getUserHistory = async(userId) => {
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
    const {data, status} = await getRequest(`/commissionManagement/residuals/residualPlanUser/${userId}/history`, 'blueraven')
    userHistory.value = data
    handleHidingGlobalLoader( status)
  } catch (e) {
    errorLoadingUserHistory.value = true
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving User History')

    appStore.loading = false
  }
}
const addLevelToPlan = async() => {
  try {
    let params = {
      ...selectedLevel.value
    }
    const {data} = await postRequest(`/commissionManagement/residuals/plan/${planId.value}/allocation`, params, 'blueraven')
    residualPlan.value.residualPlanAllocations.push(data)
    selectedLevel.value = {}
    addLevel.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Adding Level')

    appStore.loading = false
  }
}
const deleteLevel = async () => {
  const residualPlanAllocationId = levelToDelete.value.id
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`/commissionManagement/residuals/plan/${planId.value}/allocation/${residualPlanAllocationId}`, 'blueraven')
    appStore.showSnack('SUCCESS', 'Level Deleted')

    residualPlan.value.residualPlanAllocations = residualPlan.value.residualPlanAllocations.filter(rpa => {
      return rpa.id !== residualPlanAllocationId
    })
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Deleting Level')

    appStore.loading = false
  }
}
const updateLevel = async(item) => {
  appStore.loading = true
  try {
    const {status} = await putRequest(`/commissionManagement/residuals/plan/${planId.value}/allocation`, item, 'blueraven')
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Saving Level')
    appStore.loading = false
  }
}
const getSources = async() => {
  if(addSource.value) {
    try {
      const {data} = await getRequest(`/commissionManagement/residuals/${this.planId}/availableSources`, 'blueraven')
      sources.value = data
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Retrieving Sources')
      appStore.loading = false
    }
  }
}
const updateSource = async(item) => {
  appStore.loading = true
  try {
    const {data, status} = await putRequest(`/commissionManagement/residuals/${this.planId}/source`, item, 'blueraven')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Saving Source')
    appStore.loading = false
  }
}
const addSourceToPlan = async() => {
  try {
    let params = {
      sourceId: selectedSource.value.id,
      amount: selectedSource.value.amount,
    }
    const {data} = await postRequest(`/commissionManagement/residuals/${this.planId}/source`, params, 'blueraven')
    residualPlan.value.sources.push(data)
    selectedSource.value = {}
    addSource.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Adding Source')
    appStore.loading = false
  }
}
const deleteSource = async () => {
  const id = sourceToDelete.value.id
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`/commissionManagement/residuals/${planId.value}/source/${id}`, 'blueraven')
    appStore.showSnack('SUCCESS', 'Source Deleted')
    residualPlan.value.sources = residualPlan.value.sources.filter(s => {
      return s.id !== id
    })
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Deleting Source')
    appStore.loading = false
  }
}
</script>

<style lang="scss" scoped>
.v-data-table {
  border-radius: 0;
}
</style>

