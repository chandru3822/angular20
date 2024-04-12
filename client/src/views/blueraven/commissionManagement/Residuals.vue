<template>
  <v-container class="pa-0" id="residuals-container">
    <v-dialog v-model="showModal" class="square-card">
      <ResidualDetailModal :data="modalData"
                           :title="modalTitle"
                           :type-id="modalTypeId"
                           :user-full-name="modalUserFullName"
                           @residualDetailModalClosed="showModal = false"
      ></ResidualDetailModal>
    </v-dialog>
    <v-divider></v-divider>
    <v-toolbar flat color="white">
      <v-toolbar-title>
        Residuals
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>

      </v-toolbar-items>
    </v-toolbar>
    <v-toolbar v-if="!payrollLoading && !additionalPayrollDataNeeded" :color="payrollStatus.color" class="mt-2">
      <v-toolbar-title class="app-title" :style="{'color': payrollStatus.textColor}">
        {{payrollStatus.message}}
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <div class="flex-display align-center" >
          <a-btn
              v-if="payrollStatus.action && userStore.userHasFeatureAccessLevel('COMMISSIONS', 'ADD')"
              :color="payrollStatus.actionColor"
              @click="submitForApproval(payrollStatus.action)"
              :text="payrollStatus.actionText"
          ></a-btn>
          <!-- currently only "Approve" has a secondary action which requires a dialog confirm. will have to update if that changes -->
          <v-dialog
              v-if="payrollStatus.secondaryAction && userStore.userHasFeatureAccessLevel('COMMISSIONS', 'ADMIN')"
              v-model="approveConfirm"
              width="500">
            <template v-slot:activator="{ on }">
              <a-btn
                  :activation-handler="on"
                  :color="payrollStatus.secondaryActionColor"
                  class="ml-3"
                  :text="payrollStatus.secondaryActionText"
              ></a-btn>
            </template>
            <v-card>
              <v-card-title
                  class="text-h5 grey lighten-2"
                  primary-title
              >
                Confirm
              </v-card-title>

              <v-card-text class="pt-3">
                Are you sure you want to approve this residual?

                <DatetimePickerInput
                    v-model="payDate"
                    :timezone="timezone"
                    :type="'date'"
                    :format="'MMMM DD, YYYY'"
                    label="Date Paid"
                />
              </v-card-text>


              <v-divider></v-divider>

              <v-card-actions>
                <v-spacer></v-spacer>
                <a-btn
                    @click="approveConfirm = false"
                    color="unset"
                    text="No"
                ></a-btn>
                <a-btn
                    color="primary"
                    :disabled="null == payDate"
                    @click="submitForApproval(payrollStatus.secondaryAction)"
                    text="Yes"
                ></a-btn>
              </v-card-actions>
            </v-card>
          </v-dialog>
        </div>
      </v-toolbar-items>
    </v-toolbar>
    <v-form ref="accountingForm">
      <v-container>
        <v-row>
          <v-col cols="12" sm="6">
            <v-card flat color="transparent" class="pa-3">
              <a-text-field  readonly disabled label="Payroll ID #" v-model="currentResidual.id"></a-text-field>
              <a-text-field
                            label="Description"
                            placeholder=" "
                            readonly
                            disabled
                            v-model="currentResidual.description"></a-text-field>

              <div class="text-left">
                <a-btn
                    color="primary"
                    v-if="userCanEdit"
                    @click="saveChangesToResidual()"
                    text="Save Changes"
                ></a-btn>
                <a-btn
                    color="primary"
                    class="ml-3"
                    @click="exportResiduals()"
                    text="Export"
                ></a-btn>
              </div>
            </v-card>
          </v-col>
          <v-col cols="12" sm="6">
            <v-card class="pa-3">
              <v-card-title>Project Override</v-card-title>
              <a-autocomplete v-model="projectId"
                              :items="projects"
                              :loading="projectsLoading"
                              :search-input.sync="projectSearch"
                              item-title="projectNameWithId"
                              label="Project..."
                              clearable
                              prepend-icon="search"
                              item-value="id"
                              autocomplete="off"
                              type="search"
                              @click:clear="projects = []"
                              attach>
              </a-autocomplete>
              <DatetimePickerInput
                  v-model="projectOverrideDate"
                  :timezone="timezone"
                  :readonly="!userCanEdit"
                  :disabled="!userCanEdit"
                  :type="'date'"
                  :format="'MMMM DD, YYYY'"
                  label="Override Date"
              />

              <div class="text-left">
                <a-btn
                    color="primary"
                    :disabled="!projectId || !projectOverrideDate"
                    @click="saveOverrideDate()"
                    text="Save"
                ></a-btn>
                <a-btn
                    class="ml-3"
                    variant="text"
                    color="primary"
                    @click="[projectId = null, projectSearch='', projects=[], projectOverrideDate = null]"
                    text="Reset"
                ></a-btn>
              </div>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
    </v-form>
    <v-row>
      <v-col class="pt-0">
        <v-card>
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
          <v-data-table
              :headers="headers"
              :items="residuals"
              :fixed-header="true"
              :search="search"
              :footer-props="footerProps"
              :mobile-breakpoint="0"
              :show-select="payrollStatus.showSelect"
              :loading="dataLoading"
              :items-per-page="25"
              class="elevation-1"
          >
            <template #no-data>
              No available residuals
            </template>

            <template #no-results>
              No available residuals
            </template>

            <template v-slot:header.data-table-select="{ on, props }">
              <v-checkbox color="primary" v-model="selectAll" @change="toggleSelectAll()"></v-checkbox>
            </template>

            <template #item="{ item, index }">
              <tr :class="{'shaded-row': index % 2}">
                <td v-if="payrollStatus.showSelect">
                  <v-checkbox color="primary" v-model="item.selected" @change="toggleSingleSelect(item)"></v-checkbox>
                </td>
                <td class="text-left">{{item.firstName}}</td>
                <td class="text-left">{{item.lastName}}</td>
                <td class="text-left">{{item.employeeId}}</td>
                <td class="text-left">{{item.regionName}}</td>
                <td class="text-left">{{item.officeName}}</td>
                <td class="text-left">{{item.officeState}}</td>
                <td class="text-left">{{item.userPositionName}}</td>
                <td class="text-left">{{item.userStatusType}}</td>
                <td class="text-left">{{item.hireDate}}</td>
                <td class="text-left">{{item.userFullName}}</td>
                <td class="text-left">{{item.residualPlanName}}</td>
                <td class="text-left">{{item.residualStartDate}}</td>
                <td class="text-left clickable">
                  <a @click="loadModalData(item, 1)">
                    {{item.lifetimeFdc}}
                  </a>
                </td>
                <td class="text-left">
                  <a @click="loadModalData(item, 2)">
                    {{item.qualifiedThisPeriodFdc}}
                  </a>
                </td>
                <td class="text-left">
                  <a @click="loadModalData(item, 3)">
                    {{item.fdsNotQualified}}
                  </a>
                </td>
                <td class="text-left">{{item.requiredFdcPerMonth}}</td>
                <td class="text-left">{{ item.residualEarned ? 'Yes' : 'No'}}</td>
                <td class="text-left">{{item.percentOfResidualEarned | percent(0)}}</td>
                <td class="text-left">{{item.potentialResidual | currency('$', 0)}}</td>
                <td class="text-left">{{item.earnedResidual | currency('$', 0)}}</td>
                <td class="text-left">
                  <a @click="loadModalData(item, 4)">
                    {{item.currentClawback | currency('$', 0)}}
                  </a>
                </td>
                <td class="text-left">{{item.existingClawback | currency('$', 0)}}</td>
                <td class="text-left">{{item.totalClawback | currency('$', 0)}}</td>
                <td class="text-left">
                  {{item.adjustmentOverride | currency('$', 0)}}

                  <v-dialog
                      v-if="userCanAdd"
                      v-model="item.dialog"
                      width="500">
                    <template v-slot:activator="{ on }">
                      <a-btn
                          size="x-small"
                          color="primary"
                          fab
                          class="ml-2"
                          :activation-handler="on"
                          @click="[delete item.adjustment, delete item.adjustmentNote]"
                          prepend-icon="add"
                      ></a-btn>
                    </template>
                    <v-card>
                      <v-card-title class="text-h5 grey lighten-2" primary-title>
                        Add Adjustment
                      </v-card-title>
                      <v-card-text class="pt-3">
                        <strong>Type: </strong>Commission
                        <a-text-field
                                      type="number"
                                      label="Adjustment Amount"
                                      prepend-icon="mdi-currency-usd"
                                      persistent-hint
                                      v-model.number="item.adjustment">
                        </a-text-field>
                        <a-textarea
                            label="Notes"
                            v-model="item.adjustmentNote"
                        ></a-textarea>
                      </v-card-text>
                      <v-divider></v-divider>
                      <v-card-actions>
                        <v-spacer></v-spacer>
                        <a-btn
                            @click="item.dialog = false"
                            color="unset"
                            text="Cancel"
                        ></a-btn>
                        <a-btn
                            color="primary"
                            :disabled="!item.adjustment || item.adjustment === 0 || !item.adjustmentNote"
                            @click="addAdjustment(item)"
                            text="Add"
                        ></a-btn>
                      </v-card-actions>
                    </v-card>
                  </v-dialog>
                </td>
                <td class="text-left">{{item.total | currency('$', 0)}}</td>
              </tr>
            </template>

            <template v-slot:body.append="{headers}">
              <tr>
                <td v-for="(header,i) in headers" :key="i" class="font-weight-bold">

                  <div v-if="header.value === 'adjustmentOverride'">
                    Total Pay:
                  </div>
                  <div v-if="header.value === 'total'">
                    {{ totalPay | currency('$', 2) }}
                  </div>

                </td>
              </tr>
            </template>
          </v-data-table>
        </v-card>
      </v-col>
    </v-row>

  </v-container>
</template>

<script setup>

import {handleHidingGlobalLoader, getRequest,  postRequest} from '@/helpers/helpers'
import ResidualDetailModal from '@/views/blueraven/commissionManagement/ResidualDetailModal'
import { saveAs } from 'file-saver'
import sumBy from "lodash.sumby";
import cloneDeep from 'lodash.clonedeep'
import constants from "@/helpers/constants";
import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import debounce from 'lodash.debounce'
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
const snackbar = vueInstance.$snackbar

onMounted(() => {
  getCurrentResidual()
  getResiduals()
})

const userCanAdd = computed(() => {
  return userStore.userHasFeatureAccessLevel('COMMISSIONS', 'ADD')
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('COMMISSIONS', 'EDIT')
})
const timezone = computed(() => {
  return userStore.timezone.value
})

const dataLoading = ref(true)
const search = ref('')
const currentResidual = ref({})
const payrollStatus = ref({})
const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 500, 1000],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const projects = ref([])
const projectId = ref(null)
const projectOverrideDate = ref(null)
const projectSearch = ref('')
const projectsLoading = ref(false)
const selectAll = ref(false)
const approveConfirm = ref(false)
const payDate = ref(null)
const additionalPayrollDataNeeded = ref(false)
const payrollLoading = ref(true)
const masterSelectedUserIds = ref([])
const showModal = ref(false)
const modalUserFullName = ref('')
const modalData = ref([])
const modalTitle = ref('')
const modalTypeId = ref(null)
const totalPay = ref(null)
const headers = ref([
  {text: 'User First Name', value: 'firstName', show: true},
  {text: 'User Last Name', value: 'lastName', show: true},
  {text: 'Employee ID', value: 'employeeId', show: true},
  {text: 'Region', value: 'regionName', show: true},
  {text: 'Org Name', value: 'officeName', show: true},
  {text: 'Org State', value: 'officeState', show: true},
  {text: 'User Position', value: 'userPositionName', show: true},
  {text: 'User Status', value: 'userStatusType', show: true},
  {text: 'Hire Date', value: 'hireDate', show: true},
  {text: 'Usable Name', value: 'userFullName', show: true},
  {text: 'Residual Plan', value: 'residualPlanName', show: true},
  {text: 'Residual Start Date', value: 'residualStartDate', show: true},
  {text: 'LTD Qualified FDC', value: 'lifetimeFdc', show: true},
  {text: 'Qualified FDC This Period', value: 'qualifiedThisPeriodFdc', show: true},
  {text: 'FDA Not Qualified This Period', value: 'fdsNotQualified', show: true},
  {text: 'Required FDS for Month', value: 'requiredFdcPerMonth', show: true},
  {text: 'Residual Earned', value: 'residualEarned', show: true},
  {text: '% of Residual Earned', value: 'percentOfResidualEarned', show: true},
  {text: 'Potential Residual', value: 'potentialResidual', show: true},
  {text: 'Earned Residual', value: 'earnedResidual', show: true},
  {text: 'Current Clawbacks', value: 'currentClawback', show: true},
  {text: 'Existing Clawbacks', value: 'existingClawback', show: true},
  {text: 'Total Clawbacks', value: 'totalClawbacks', show: true},
  {text: 'Adjustment/Override', value: 'adjustmentOverride', show: true},
  {text: 'Total', value: 'total', show: true},
])
const residuals = ref([])

watch(projectSearch, (val) => {
  if(val === '') {
    projects.value = []
    projectId.value = null
    projectOverrideDate.value = null
  } else if (val != null && !val.includes(' - ')) {
    projects.value = []
    getProjectsDebounced(val)
  }
})

watch(commissionPositionId, () => {
  getCurrentResidual()
  getResiduals()
})

const toggleSelectAll = () => {
  residuals.value.forEach(ad => {
    ad.selected = selectAll.value
  })
  if(selectAll.value) {
    currentResidual.value.selectedUserIds = residuals.value.map(ad => ad.userId)
  } else {
    currentResidual.value.selectedUserIds = []
  }
}
const toggleSingleSelect =(item) => {
  if(item.selected) {
    currentResidual.value.selectedUserIds.push(item.userId)
  } else {
    currentResidual.value.selectedUserIds = currentResidual.value.selectedUserIds.filter(p => p !== item.userId)
  }
}
const getResiduals = async () => {
  appStore.loading = true
  try {
    let params = {}
    if(currentResidual.value?.status !== 'PENDING' && currentResidual.value?.status !== 'REJECTED') {
      params.selectedUserIds = currentResidual.value.selectedUserIds
    }

    const {data, status} = await getRequest(`/commissionManagement/residuals`, 'blueraven')
    residuals.value = data
    residuals.value.forEach(d => {
      d.selected = !!currentResidual.value.selectedUserIds?.includes(d.userId)
    })

    if(currentResidual.value?.selectedUserIds?.length === data.length) {
      selectAll.value = true
    }

    totalPay.value = sumBy(residuals.value,  function(o) { return o.selected ? o.total : 0 })

    residuals.value = data
    dataLoading.value = false
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Residuals')

    appStore.loading = false
  }
}
const addAdjustment = async (item) => {
  appStore.loading = true
  try {
    let params = {
      userId: item.userId,
      amount: item.adjustment,
      note: item.adjustmentNote
    }
    await postRequest(`/payroll/residual/${currentResidual.value.id}/adjustments`, params, 'blueraven')
    snackbar('SUCCESS', 'Adjustment Added')

    await getResiduals()
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Adding Adjustment')

    appStore.loading = false
  }
}
const getProjectsDebounced = debounce((val) => {
  getProjects(val)
}, 500)
const getProjects = async (search) => {
  try {
    const {data, status} = await getRequest(`/commissionManagement/residuals/projects?search=${search}`, 'blueraven')
    projects.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Data')

    appStore.loading = false
  }
}
const saveOverrideDate = async () => {
  try {
    let params = {
      overrideDate: projectOverrideDate.value,
      projectId: projectId.value
    }
    const {data, status} = await postRequest(`/commissionManagement/residuals/projectOverride`, params, 'blueraven')
    projectId.value = null
    projectSearch.value = null
    projects.value = []
    projectOverrideDate.value = null
  } catch (e) {
    console.error('*** ERROR ***', e)
    let msg = e?.data?.message || 'Error Loading Data'
    snackbar('ERROR', msg)

    appStore.loading = false
  }
}
const loadModalData = async (residualItem, typeId) => {
  //typeId: 1 = lifetime qualified,
  // 2 = qualified fds in period,
  // 3 = fds not qualified this period
  // 4 = current clawbacks/cancelled projects
  modalTypeId.value = typeId
  showModal.value = false
  modalData.value = []
  modalTitle.value = typeId === 1 ? 'Lifetime Qualified FDC' :
      typeId === 2 ? 'Qualified FDC in Period' :
          typeId === 3 ? 'FDA Not Qualified this Period'
              : 'Cancelled Projects'
  modalUserFullName.value = ''
  try {
    let url = typeId === 1 ? `/commissionManagement/residuals/qualifiedLifetime/${residualItem.userId}` :
        typeId === 2 ? `/commissionManagement/residuals/qualifiedPeriod/${residualItem.userId}` :
            typeId === 3 ? `/commissionManagement/residuals/notQualifiedPeriod/${residualItem.userId}`
                : `/commissionManagement/residuals/currentClawbacks/${residualItem.userId}`


    const {data, status} = await getRequest(url, 'blueraven')
    modalData.value = data
    modalUserFullName.value = residualItem.userFullName
    showModal.value = true
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Data')

    appStore.loading = false
  }
}
const getCurrentResidual = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/payroll/residual/current`, 'blueraven', [])
    currentResidual.value = data

    masterSelectedUserIds.value = cloneDeep(currentResidual.value.userIds)
    getStatusColor()
    payrollLoading.value = false
    additionalPayrollDataNeeded.value = null == currentResidual.value.description
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Current Payroll')

    appStore.loading = false
  }
}
const submitForApproval = async (action) => {
  //to avoid any unsaved changes prior to approval we are just saving changes prior to submitting
  const val = await saveChangesToResidual(true)
  //dont submit for approval if the save changes request failed
  if(val) {
    totalPay.value = sumBy(residuals.value,  function(o) { return o.selected ? o.total : 0 })
    let selectedIds = residuals.value.filter(ad => ad.selected).map(ad => ad.userId)
    let params = {
      payDate: payDate.value
    }
    if(payrollStatus.value.showSelect && (!selectedIds || selectedIds.length === 0)) {
      snackbar('WARNING', 'You must select at least one user.')

    } else {
      appStore.loading = true
      try {
        await postRequest(`/payroll/residual/${currentResidual.value.id}/${action}`, params, 'blueraven')
        snackbar('SUCCESS', 'Successfully Updated')

        //todo: reload residuals after approving
        await getCurrentResidual()
      } catch (e) {
        console.error('*** ERROR ***', e)
        snackbar('ERROR', 'Error Updating')

        appStore.loading = false
      }
    }
  }
}
const getStatusColor = () => {
  payrollStatus.value = {}
  switch(currentResidual.value.status) {
    case 'PENDING':
      payrollStatus.value.message = 'This payroll is pending.'
      payrollStatus.value.color = '#DCDCDC'
      payrollStatus.value.showSelect = true
      payrollStatus.value.action = 'submit'
      payrollStatus.value.actionText = 'Submit For Approval'
      payrollStatus.value.actionColor = 'primary'
      break
    case 'SUBMITTED':
      payrollStatus.value.message = 'This payroll has been Submitted.'
      payrollStatus.value.color = '#DCDCDC'
      payrollStatus.value.showSelect = false
      payrollStatus.value.action = 'reject'
      payrollStatus.value.actionText = 'Reject'
      payrollStatus.value.actionColor = 'error'
      payrollStatus.value.secondaryAction = 'approve'
      payrollStatus.value.secondaryActionText = 'Approve'
      payrollStatus.value.secondaryActionColor = 'green'
      break
    case 'REJECTED':
      payrollStatus.value.message = 'This payroll has been Rejected.'
      payrollStatus.value.color = 'error'
      payrollStatus.value.textColor = 'white'
      payrollStatus.value.showSelect = true
      payrollStatus.value.action = 'submit'
      payrollStatus.value.actionText = 'Submit For Approval'
      payrollStatus.value.actionColor = 'primary'
      break
    default:
      payrollStatus.value = {}
  }
}
const saveChangesToResidual = async (keepLoading) => {
  let params = {
    description: currentResidual.value.description,
    userIds: currentResidual.value.selectedUserIds
  }
  appStore.loading = true
  try {
    const {data} = await postRequest(`/payroll/residual/${currentResidual.value.id}`, params, 'blueraven')
    snackbar('SUCCESS', 'Successfully Updated')

    currentResidual.value = data
    additionalPayrollDataNeeded.value = null == currentResidual.value.description
    getStatusColor()
    getCurrentResidual()
    await getResiduals()

    if(!keepLoading) {
      appStore.loading = false
    }
    return true
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Updating')

    appStore.loading = false
    return false
  }
}
const exportResiduals = async () => {
  appStore.loading = true
  try {
    let filename = 'Residuals.csv';
    let csvData = 'User First Name,User Last Name,Employee ID,Region,Org Name,Org State,User Position,User Status,Hire Date,Usable Name,Residual Start Date,LTD Qualified FDC,Qualified FDC This Period,FDA Not Qualified This Period,Required FDS for Month,Residual Earned, % of Residual Earned,Potential Residual,Earned Residual,Current Clawback,Existing Clawback,Total Clawback,Adjustment/Override,Total';
    csvData += '\n';

    residuals.value.forEach(p => {
      csvData +=
          p.firstName + ',"' +
          p.lastName + '",' +
          p.employeeId + ',"' +
          p.regionName + '",' +
          "\"" + p.officeName + '\",' +
          p.officeState + ',' +
          p.userPositionName + ',"' +
          p.userStatusType + '",' +
          p.hireDate + ',' +
          p.userFullName + ',' +
          p.residualStartDate + ',' +
          p.lifetimeFdc + ',' +
          p.qualifiedThisPeriodFdc + ',' +
          p.fdsNotQualified + ',' +
          p.requiredFdcPerMonth + ',' +
          p.residualEarned + ',' +
          p.percentOfResidualEarned + ',"' +
          p.potentialResidual + '",' +
          p.earnedResidual + ',' +
          p.currentClawback + ',' +
          p.existingClawback + ',' +
          p.totalClawback + ',' +
          p.adjustmentOverride + ',' +
          p.total
      csvData += '\n';
    })

    let blob = new Blob([csvData], {
      type: 'text/csv;charset=utf-8'
    });

    saveAs(blob, filename);
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Exporting Residuals')

    appStore.loading = false
  }
}
</script>

<style lang="scss">
#residuals-container .v-data-table__wrapper {
  height: calc(100vh - 350px);
  min-height: 300px;
}
</style>

<style lang="scss" scoped>
.v-data-table {
  border-radius: 0;
}
</style>

