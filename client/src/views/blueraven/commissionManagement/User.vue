<template>
  <v-container class="pa-0" id="closer-container">
    <v-toolbar flat color="transparent" :min-height="120">
      <v-toolbar-title>
        {{closer.name}}
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <v-card flat color="transparent" class="text-right mt-3">
          <strong>User ID: </strong>{{closer.userId}}<br/>
          <strong>Position: </strong>{{closer.position}}<br/>
          <strong>Office: </strong>{{closer.orgName}}<br/>
          <strong>Position Effective Date: </strong>{{closer.positionStartDate | formatDate('date')}}
        </v-card>
      </v-toolbar-items>
    </v-toolbar>
    <v-divider></v-divider>
    <v-row>
      <v-col>
        <v-toolbar flat>
          <v-toolbar-title>
            Commission Plans
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                variant="text"
                color="primary"
                v-if="userCanAdd"
                @click="[planErrorObj = {}, addNewCommissionPlan = !addNewCommissionPlan, newCommissionPlan = {}, getCommissionPlans()]"
                :prepend-icon="addNewCommissionPlan ? 'remove' : 'add'"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addNewCommissionPlan" class="square-card text-left pa-5">
          <a-autocomplete v-model="newCommissionPlan.id"
                          :items="commissionPlans"
                          label="Select a Plan to Add"
                          item-title="name"
                          item-value="id"
                          autocomplete="off"
                          attach
          />
          <DatetimePickerInput
              v-model="newCommissionPlan.startDate"
              :timezone="timezone"
              :type="'date'"
              :format="'MMMM DD, YYYY'"
              label="Start Date"
              @input="checkDates(newCommissionPlan.startDate, newCommissionPlan.endDate, closer.plans, planErrorObj)"
          />
          <DatetimePickerInput
              v-model="newCommissionPlan.endDate"
              :timezone="timezone"
              :type="'date'"
              :format="'MMMM DD, YYYY'"
              label="End Date"
              @input="checkDates(newCommissionPlan.startDate, newCommissionPlan.endDate, closer.plans, planErrorObj)"
          />
          <div v-if="planErrorObj.dateError" class="error--text mb-2">
            * Error: {{planErrorObj.dateErrorMsg}}
          </div>
          <div class="mb-2" v-if="planErrorObj.showNote">
            {{planErrorObj.noteMsg}}
          </div>
          <div>
            <a-btn
                color="primary"
                class="mr-3"
                @click="[addNewCommissionPlan = false, savePlan(newCommissionPlan, 2, true)]"
                :disabled="planErrorObj.dateError || !newCommissionPlan.id || !newCommissionPlan.startDate"
                text="Save"
            ></a-btn>
            <a-btn
                color="primary"
                variant="text"
                @click="addNewCommissionPlan = !addNewCommissionPlan"
                text="Cancel"
            ></a-btn>
          </div>
        </v-card>
        <v-divider v-if="addNewCommissionPlan"></v-divider>
        <v-data-table
            :headers="planHeaders"
            :items="closer.plans"
            :fixed-header="true"
            :items-per-page="-1"
            disable-sort
            single-expand
            :expanded.sync="expanded"
            :loading="dataLoading"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            <span class="default-text-color">No available plans</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available plans</span>
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4 text-left" :class="{'shaded-row': selectedIndex % 2}">
              <DatetimePickerInput
                  v-model="item.endDate"
                  :timezone="timezone"
                  :type="'date'"
                  :format="'MMMM DD, YYYY'"
                  :readonly="closer.plans.indexOf(item) !== 0"
                  label="New End Date"
              />
              <label>Note:</label>
              <a-textarea variant="filled" class="mt-4"
                          v-model="item.note">
              </a-textarea>
              <a-btn
                  color="primary"
                  :disabled="!item.endDate && !item.note"
                  @click="[expanded = [], savePlan(item, 2)]"
                  text="Save"
              ></a-btn>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.name}}</td>
              <td class="text-left">{{item.description}}</td>
              <td class="text-left">{{item.startDate | formatDate('date')}}</td>
              <td class="text-left">{{item.endDate | formatDate('date')}}</td>
              <td class="text-left">
                <pre class="app-pre-wrapper">
                  {{item.note}}
                </pre>
              </td>
              <td>
                <a-btn
                    size="small"
                    variant="text"
                    color="primary"
                    @click="[expanded = [item], selectedIndex = index]"
                    v-if="!expanded.includes(item) && userCanEdit"
                    prepend-icon="edit"
                ></a-btn>
                <a-btn
                    size="small"
                    variant="text"
                    color="primary"
                    @click="[expanded = [], selectedIndex = index]"
                    v-if="expanded.includes(item)"
                    text="Cancel"
                ></a-btn>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <v-row>
      <v-col>
        <v-toolbar flat>
          <v-toolbar-title>
            Override Plans Assigned To
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                variant="text"
                color="primary"
                v-if="userCanAdd"
                @click="[overrideErrorObj = {}, addNewOverridePlan = !addNewOverridePlan, newOverridePlan = {}, getOverridePlans()]"
                :prepend-icon="addNewOverridePlan ? 'remove' : 'add'"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addNewOverridePlan" class="square-card text-left pa-5">
          <a-autocomplete v-model="newOverridePlan.id"
                          :items="overridePlans"
                          label="Select a Plan to Add This User"
                          item-title="name"
                          item-value="id"
                          autocomplete="off"
                          attach
          />
          <DatetimePickerInput
              v-model="newOverridePlan.startDate"
              :timezone="timezone"
              :type="'date'"
              :format="'MMMM DD, YYYY'"
              label="Start Date"
              @input="checkDates(newOverridePlan.startDate, newOverridePlan.endDate, closer.overrides, overrideErrorObj)"
          />
          <DatetimePickerInput
              v-model="newOverridePlan.endDate"
              :timezone="timezone"
              :type="'date'"
              :format="'MMMM DD, YYYY'"
              label="End Date"
              @input="checkDates(newOverridePlan.startDate, newOverridePlan.endDate, closer.overrides, overrideErrorObj)"
          />
          <div v-if="overrideErrorObj.dateError" class="error--text mb-2">
            * Error: {{overrideErrorObj.dateErrorMsg}}
          </div>
          <div class="mb-2" v-if="overrideErrorObj.showNote">
            {{overrideErrorObj.noteMsg}}
          </div>
          <a-btn
              color="primary"
              class="mr-3"
              @click="[addNewOverridePlan = false, savePlan(newOverridePlan, 1, true)]"
              :disabled="overrideErrorObj.dateError || !newOverridePlan.id || !newOverridePlan.startDate"
              text="Save"
          ></a-btn>
          <a-btn
              color="primary"
              variant="text"
              @click="addNewOverridePlan = !addNewOverridePlan"
              text="Cancel"
          ></a-btn>
        </v-card>
        <v-divider v-if="addNewOverridePlan"></v-divider>
        <v-data-table
            :headers="overrideHeaders"
            :items="closer.overrides"
            :fixed-header="true"
            :items-per-page="-1"
            disable-sort
            :expanded.sync="overrideExpanded"
            single-expand
            :loading="dataLoading"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            <span class="default-text-color">No available overrides</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available overrides</span>
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4 text-left" :class="{'shaded-row': selectedIndex % 2}">
              <DatetimePickerInput
                  v-model="item.endDate"
                  :timezone="timezone"
                  :type="'date'"
                  :readonly="closer.overrides.indexOf(item) !== 0"
                  :format="'MMMM DD, YYYY'"
                  label="New End Date"
                  @input="checkDates(item.startDate, item.endDate, closer.overrides, item, item.id)"
              />
              <label>Note:</label>
              <a-textarea variant="filled" class="mt-4"
                          v-model="item.note">
              </a-textarea>
              <div v-if="item.dateError" class="error--text mb-2">
                * Error: {{item.dateErrorMsg}}
              </div>
              <div class="mb-2" v-if="item.showNote">
                {{item.noteMsg}}
              </div>
              <a-btn
                  color="primary"
                  :disabled="(!item.endDate && !item.note) || item.dateError "
                  @click="[overrideExpanded = [], savePlan(item, 1)]"
                  text="Save"
              ></a-btn>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.planName}}</td>
              <td class="text-left">{{item.planDescription}}</td>
              <td class="text-left">{{item.startDate | formatDate('date')}}</td>
              <td class="text-left">{{item.endDate | formatDate('date')}}</td>
              <td class="text-left">
                <pre class="app-pre-wrapper">
                  {{item.note}}
                </pre>
              </td>
              <td>
                <a-btn
                    size="small"
                    variant="text"
                    color="primary"
                    @click="[overrideExpanded = [item], overrideSelectedIndex = index]"
                    v-if="!overrideExpanded.includes(item) && userCanEdit"
                    prepend-icon="edit"
                ></a-btn>
                <a-btn
                    size="small"
                    variant="text"
                    color="primary"
                    @click="[overrideExpanded = [], overrideSelectedIndex = index]"
                    v-if="overrideExpanded.includes(item)"
                    text="Cancel"
                ></a-btn>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <v-row>
      <v-col>
        <v-toolbar flat>
          <v-toolbar-title>
            Receiving Override Plans
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                variant="text"
                color="primary"
                v-if="userCanAdd"
                @click="[addNewReceivingPlan = !addNewReceivingPlan, cloneOverridePlan = {}, getOverridePlans()]"
                :prepend-icon="addNewReceivingPlan ? 'remove' : 'mdi-content-copy'"
            ></a-btn>
            <a-btn
                variant="text"
                color="primary"
                @click="addOverridePlan()"
                v-if="userCanAdd"
                prepend-icon="add"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addNewReceivingPlan" class="square-card text-left pa-5">
          <a-autocomplete v-model="cloneOverridePlan"
                          :items="overridePlans"
                          label="Select a Plan to Clone"
                          item-title="name"
                          item-value="id"
                          return-object
                          autocomplete="off"
                          attach
          />
          <v-card flat v-if="cloneOverridePlan && cloneOverridePlan.id">
            <v-card-title>Receiving Users</v-card-title>
            <div v-for="ru in cloneOverridePlan.receivingUsers">
              <input type="checkbox" class="mr-2" v-model="ru.selected">
              {{ru.name}}
            </div>
          </v-card>
          <v-card flat v-if="cloneOverridePlan && cloneOverridePlan.id">
            <v-card-title>Assigned Users</v-card-title>
            <div v-for="ru in cloneOverridePlan.assignedusers">
              <input type="checkbox" class="mr-2" v-model="ru.selected">
              {{ru.name}}
            </div>
          </v-card>
          <a-btn
              color="primary"
              class="mr-3"
              @click="clonePlan()"
              :disabled="!cloneOverridePlan.id"
              text="Clone"
          ></a-btn>
        </v-card>
        <v-data-table
            :headers="receivingHeaders"
            :items="closer.receiving"
            :fixed-header="true"
            :items-per-page="-1"
            disable-sort
            :expanded.sync="receivingExpanded"
            single-expand
            :loading="dataLoading"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            <span class="default-text-color">No available plans</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available plans</span>
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4 text-left" :class="{'shaded-row': receivingSelectedIndex % 2}">
              <label>Note:</label>
              <a-textarea variant="filled" class="mt-4"
                          v-model="item.note">
              </a-textarea>
              <a-btn
                  color="primary"
                  :disabled="!item.endDate && !item.note"
                  @click="[addNewReceivingPlan = false, savePlan(item, 3)]"
                  text="Save"
              ></a-btn>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.name}}</td>
              <td class="text-left">{{item.statusType}}</td>
              <td class="text-left">{{item.m1Allocation}}</td>
              <td class="text-left">{{item.m2Allocation}}</td>
              <td class="text-left">{{item.redLineM1Allocation}}</td>
              <td class="text-left">{{item.redLineM2Allocation}}</td>
              <td class="text-left">
                <pre class="app-pre-wrapper">
                  {{item.note}}
                </pre>
              </td>
              <td>
                <a-btn
                    size="small"
                    variant="text"
                    color="primary"
                    @click="[receivingExpanded = [item], receivingSelectedIndex = index]"
                    v-if="!receivingExpanded.includes(item) && userCanEdit"
                    prepend-icon="edit"
                ></a-btn>
                <a-btn
                    size="small"
                    variant="text"
                    color="primary"
                    @click="[receivingExpanded = [], receivingSelectedIndex = index]"
                    v-if="receivingExpanded.includes(item)"
                    text="Cancel"
                ></a-btn>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>

  </v-container>
</template>

<script setup>

import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
import moment from 'moment'
import {handleHidingGlobalLoader, getRequest, postRequest, } from '@/helpers/helpers'
import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'
import { useBrsStore } from '@/stores/BrsStore.js'
import { storeToRefs } from 'pinia'

const brsStore = useBrsStore()
const { commissionPositionId } = storeToRefs(brsStore)
const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

onMounted(() => {
  getCloserDetails()
})

watch(commissionPositionId, async() => {
  //if they change the position (setter vs closer) have to go back to main page
  await router.push('/commissionManagement/users')
})

const planErrorObj = ref({})
const overrideErrorObj = ref({})
const dataLoading = ref(true)
const overrideSelectedIndex = ref(null)
const positionId = ref(brsStore.commissionPositionId)
const selectedIndex = ref(null)
const receivingSelectedIndex = ref(null)
const commissionPlans = ref([])
const overridePlans = ref([])
const newCommissionPlan = ref({})
const newOverridePlan = ref({})
const cloneOverridePlan = ref({})
const addNewCommissionPlan = ref(false)
const addNewOverridePlan = ref(false)
const addNewReceivingPlan = ref(false)
const userId = ref(route.params.id)
const expanded = ref([])
const overrideExpanded = ref([])
const receivingExpanded = ref([])
const overrideHeaders = ref([
  {text: 'Plan Name', value: 'name', show: true},
  {text: 'Description', value: 'Position', show: true},
  {text: 'Start Date', value: 'startDate', show: true},
  {text: 'End Date', value: 'endDate', show: true},
  {text: 'Notes', value: 'note', show: true},
  {text: '', value: 'icons', show: true},
])
const planHeaders = ref([
  {text: 'Plan Name', value: 'name', show: true},
  {text: 'Description', value: 'description', show: true},
  {text: 'Start Date', value: 'startDate', show: true},
  {text: 'End Date', value: 'endDate', show: true},
  {text: 'Notes', value: 'note', show: true},
  {text: '', value: 'icons', show: true},
])
const receivingHeaders = ref([
  {text: 'Plan Name', value: 'name', show: true},
  {text: 'Status', value: 'statusType', show: true},
  {text: 'M1 Allocation', value: 'm1Allocation', show: true},
  {text: 'M2 Allocation', value: 'm2Allocation', show: true},
  {text: 'Red Line M1 Allocation', value: 'redLineM1Allocation', show: true},
  {text: 'Red Line M1 Allocation', value: 'redLineM2Allocation', show: true},
  {text: 'Notes', value: 'note', show: true},
  {text: '', value: 'icons', show: true},
])
const closer = ref({})

const userCanAdd = computed(() => {
  return userStore.userHasFeatureAccessLevel('COMMISSIONS', 'ADD')
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('COMMISSIONS', 'EDIT')
})
const timezone = computed(() => {
  return userStore.timezone.value
})


const getCloserDetails = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/commissionManagement/closerDetails/${userId.value}`, 'blueraven')
    closer.value = data ? data[0] : []
    dataLoading.value = false
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Loading User Details')

    appStore.loading = false
  }
}
const getCommissionPlans = async () => {
  if(addNewCommissionPlan.value) {
    appStore.loading = true
    try {
      const {data, status} = await getRequest(`/commissionManagement/plans/${positionId.value}`, 'blueraven')
      commissionPlans.value = data
      handleHidingGlobalLoader( status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Loading Commission Plans')

      appStore.loading = false
    }
  }
}
const getOverridePlans = async () => {
  if(addNewOverridePlan.value || addNewReceivingPlan.value) {
    appStore.loading = true
    try {
      const {data, status} = await getRequest(`/commissionManagement/overrides/plans/${positionId.value}/active`, 'blueraven')
      overridePlans.value = data
      handleHidingGlobalLoader( status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Loading Override Plans')

      appStore.loading = false
    }
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
const savePlan = async (item, type, isNew) => {
  let params = {
    userId: userId.value,
    startDate: item.startDate,
    endDate: item.endDate,
    note: item.note,
    m1Allocation: item.m1Allocation,
    m2Allocation: item.m2Allocation
  }
  let url = ''
  //override == 1, commission = 2, receiving === 3
  if(type === 1) {
    if(isNew) {
      url = `/commissionManagement/overrides/${item.id}/assignedUsers`
    } else {
      url = `/commissionManagement/overrides/${item.id}/updateUser`
    }
  } else if(type === 2) {
    if(isNew) {
      url = `/commissionManagement/${item.id}/users/${positionId.value}`
    } else {
      url = `/commissionManagement/${item.id}/updateUser`
    }
  } else {
    url = `/commissionManagement/overrides/${item.id}/receivingUser`
  }
  try {
    const {data, status} = await postRequest(url, params, 'blueraven')
    //reset fields as needed
    if(type === 1) {
      overrideExpanded.value = []
      addNewOverridePlan.value = false
      newOverridePlan.value = {}
      if(isNew) {
        closer.value.overrides = data
      }
    } else if (type === 2) {
      expanded.value = []
      newCommissionPlan.value = {}
      addNewCommissionPlan.value = false
      if(isNew) {
        closer.value.plans = data
      }
    } else {
      receivingExpanded.value = []
      addNewReceivingPlan.value = false
    }
    appStore.showSnack('SUCCESS', 'Saved Successfully')

    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    let errorMsg = e?.msg ?? 'Error Saving Plan'
    appStore.showSnack('ERROR', errorMsg)

    appStore.loading = false
  }
}
const clonePlan = async () => {
  let params = {
    receivingUsers: cloneOverridePlan.value.receivingUsers.filter(r => r.selected).map(r => r.userId),
    assignedUsers: cloneOverridePlan.value.assignedUsers.filter(r => r.selected).map(r => r.userId),
    positionId: cloneOverridePlan.value.positionId,
    userId: userId.value,
    backdateApprovalCreds: null,
  }
  try {
    const {data, status} = await postRequest(`/commissionManagement/overrides/${cloneOverridePlan.value.id}/clone`, params, 'blueraven')
    handleHidingGlobalLoader( status)
    await router.push({name: 'override', params: {id: data.id}})
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Saving Plan to User')

    appStore.loading = false
  }
}
const addOverridePlan = async() => {
  try {
    const {data} = await postRequest(`/commissionManagement/overrides`, {}, 'blueraven')
    addReceivingUserToOverridePlan(data.id)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Creating New Plan')

    appStore.loading = false
  }
}
const addReceivingUserToOverridePlan = async(overridePlanId) => {
  let params = {
    userId: userId.value,
    m1Allocation: 0,
    m2Allocation: 0,
    redLineM1Allocation: 0,
    redLineM2Allocation: 0
  }
  try {
    const {status} = await postRequest(`/commissionManagement/overrides/${overridePlanId}/receivingUsers`, params, 'blueraven')
    handleHidingGlobalLoader( status)
    await router.push({name: 'override', params: {id: overridePlanId}})
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Adding User to Plan')

    appStore.loading = false
  }
}
</script>

<style lang="scss" scoped>
.v-data-table {
  border-radius: 0;
}
</style>

