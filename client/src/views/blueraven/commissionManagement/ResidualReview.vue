<template>
  <v-container class="pa-0">
    <v-dialog v-model="showModal" class="square-card">
      <ResidualDetailModal :data="modalData"
                           :title="modalTitle"
                           :type-id="modalTypeId"
                           :user-full-name="modalUserFullName"
                           @residualDetailModalClosed="showModal = false"
      ></ResidualDetailModal>
    </v-dialog>
    <v-row>
      <v-col>
        <v-toolbar flat :color="payrollStatus.color">
          <v-toolbar-title :style="{'color': payrollStatus.textColor}">
            {{ payrollStatus.message }}
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <div class="commission-button-container">

            </div>
          </v-toolbar-items>
        </v-toolbar>
      </v-col>
    </v-row>
    <v-row>
      <v-col cols="6">
        <table>
          <tr>
            <td class="text-left pr-3"><strong>Residual ID #</strong></td>
            <td class="text-left">{{residual.id}}</td>
          </tr>
          <tr>
            <td class="text-left pr-3"><strong>Residual Starting</strong></td>
            <td class="text-left">{{residual.periodStart | formatDate('date')}}</td>
          </tr>
          <tr>
            <td class="text-left pr-3"><strong>Residual Ending</strong></td>
            <td class="text-left">{{residual.periodEnd | formatDate('date')}}</td>
          </tr>
          <tr>
            <td class="text-left pr-3"><strong>Residual Grace Period</strong></td>
            <td class="text-left">{{residual.gracePeriodEnd | formatDate('date')}}</td>
          </tr>
          <tr>
            <td class="text-left pr-3"><strong>Description</strong></td>
            <td class="text-left">{{residual.description}}</td>
          </tr>
        </table>
      </v-col>
      <v-col cols="6" class="text-right">
        <a-btn
            color="primary"
            @click="exportResidualReview"
            text="Export"
        ></a-btn>
        <a-btn
            color="primary"
            @click="exportResidualReviewForNetSuite"
            class="ml-3"
            text="Export Netsuite"
        ></a-btn>
      </v-col>
    </v-row>
    <v-divider></v-divider>
    <v-row>
      <v-col>
        <v-data-table
            :headers="headers"
            :items="residualSnapshot"
            :fixed-header="true"
            disable-sort
            :loading="dataLoading"
            :items-per-page="25"
            :footer-props="footerProps"
            class="elevation-1"
        >
          <template #no-data>
            No available snapshot data
          </template>

          <template #no-results>
            No available snapshot data
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td v-if="payrollStatus.showSelect">
                <v-checkbox color="primary" v-model="item.selected" @change="toggleSingleSelect(item)"></v-checkbox>
              </td>
              <td class="text-left">{{item.userFirstName}}</td>
              <td class="text-left">{{item.userLastName}}</td>
              <td class="text-left">{{item.employeeId}}</td>
              <td class="text-left">{{item.regionName}}</td>
              <td class="text-left">{{item.officeName}}</td>
              <td class="text-left">{{item.officeState}}</td>
              <td class="text-left">{{item.userPositionName}}</td>
              <td class="text-left">{{item.userStatus}}</td>
              <td class="text-left">{{item.hireDate}}</td>
              <td class="text-left">{{item.userFullName}}</td>
              <td class="text-left">{{item.residualPlanName}}</td>
              <td class="text-left">{{item.residualStartDate}}</td>
              <td class="text-left clickable">
                <a @click="loadModalData(item, 1)">
                  {{item.lifetimeQualifiedFds}}
                </a>
              </td>
              <td class="text-left">
                <a @click="loadModalData(item, 2)">
                  {{item.qualifiedFdcInPeriod}}
                </a>
              </td>
              <td class="text-left">
                <a @click="loadModalData(item, 3)">
                  {{item.fdcNotQualifiedInPeriod}}
                </a>
              </td>
              <td class="text-left">{{item.requiredFdcPerMonth}}</td>
              <td class="text-left">{{item.residualEarned ? 'Yes' : 'No'}}</td>
              <td class="text-left">{{item.percentOfResidualEarned | percent(0)}}</td>
              <td class="text-left">{{item.potentialResidual | currency('$', 0)}}</td>
              <td class="text-left">{{item.earnedResidual | currency('$', 0)}}</td>
              <!--              <td class="text-left">{{item.currentClawback | currency('$', 0)}}</td>-->
              <td class="text-left">
                <a @click="loadModalData(item, 4)">
                  {{item.currentClawback | currency('$', 0)}}
                </a>
              </td>
              <td class="text-left">{{item.existingClawback | currency('$', 0)}}</td>
              <td class="text-left">{{item.totalClawback | currency('$', 0)}}</td>
              <td class="text-left">{{item.adjustmentOverride | currency('$', 0)}}</td>
              <td class="text-left">{{item.residualTotal | currency('$', 0)}}</td>
              <td class="text-left">{{item.paidInPeriod ? 'Yes' : 'No'}}</td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>

  </v-container>
</template>

<script setup>

import { saveAs } from 'file-saver'
import constants from "@/helpers/constants";
import moment from 'moment'
import {handleHidingGlobalLoader, getRequest, getRequestWithParams, } from '@/helpers/helpers'
import ResidualDetailModal from '@/views/blueraven/commissionManagement/ResidualDetailModal'
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
const snackbar = vueInstance.$snackbar

const residual = ref({})
const showModal = ref(false)
const modalUserFullName = ref('')
const modalData = ref([])
const modalTitle = ref('')
const modalTypeId = ref(null)
const dataLoading = ref(false)
const residualSnapshot = ref([])
const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 500],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const residualSummary = ref([])
const payrollStatus = ref({})
const residualId = ref(route.params.id)
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
  {text: 'Residual Name', value: 'residualPlanName', show: true},
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
  {text: 'Total Clawbacks', value: 'totalClawback', show: true},
  {text: 'Adjustment/Override', value: 'adjustmentOverride', show: true},
  {text: 'Total', value: 'total', show: true},
  {text: 'Paid In Period', value: 'paidInPeriod', show: true},
])
const NetsuiteStateEnum = [
  {id: 1, abbreviation: 'AL' },
  {id: 2, abbreviation: 'AK' },
  {id: 3, abbreviation: 'AZ' },
  {id: 4, abbreviation: 'AR' },
  {id: 5, abbreviation: 'CA' },
  {id: 6, abbreviation: 'CO' },
  {id: 7, abbreviation: 'CT' },
  {id: 8, abbreviation: 'DE' },
  {id: 9, abbreviation: 'FL' },
  {id: 10, abbreviation: 'GA' },
  {id: 11, abbreviation: 'HI' },
  {id: 12, abbreviation: 'ID' },
  {id: 13, abbreviation: 'IL' },
  {id: 14, abbreviation: 'IN' },
  {id: 15, abbreviation: 'IA' },
  {id: 16, abbreviation: 'KS' },
  {id: 17, abbreviation: 'KY' },
  {id: 18, abbreviation: 'LA' },
  {id: 19, abbreviation: 'ME' },
  {id: 20, abbreviation: 'MD' },
  {id: 21, abbreviation: 'MA' },
  {id: 22, abbreviation: 'MI' },
  {id: 23, abbreviation: 'MN' },
  {id: 24, abbreviation: 'MS' },
  {id: 25, abbreviation: 'MO' },
  {id: 26, abbreviation: 'MT' },
  {id: 27, abbreviation: 'NE' },
  {id: 28, abbreviation: 'NV' },
  {id: 29, abbreviation: 'NH' },
  {id: 30, abbreviation: 'NJ' },
  {id: 31, abbreviation: 'NM' },
  {id: 32, abbreviation: 'NY' },
  {id: 33, abbreviation: 'NC' },
  {id: 34, abbreviation: 'ND' },
  {id: 35, abbreviation: 'OH' },
  {id: 36, abbreviation: 'OK' },
  {id: 37, abbreviation: 'OR' },
  {id: 38, abbreviation: 'PA' },
  {id: 39, abbreviation: 'RI' },
  {id: 40, abbreviation: 'SC' },
  {id: 41, abbreviation: 'SD' },
  {id: 42, abbreviation: 'TN' },
  {id: 43, abbreviation: 'TX' },
  {id: 44, abbreviation: 'UT' },
  {id: 45, abbreviation: 'VT' },
  {id: 46, abbreviation: 'VA' },
  {id: 47, abbreviation: 'WA' },
  {id: 48, abbreviation: 'WV' },
  {id: 49, abbreviation: 'WI' },
  {id: 50, abbreviation: 'WY' }
]

onMounted(() => {
  getResidual()
  getResidualSnapshot()
})

watch(commissionPositionId, async() => {
  //if they change the position (setter vs closer) have to go back to main page
  await router.push('/commissionManagement/residualSearch')
})

const getResidual = async() => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/payroll/residual/${residualId.value}`, 'blueraven')
    residual.value = data
    populateStatusDetails()
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Residual Details')

    appStore.loading = false
  }
}
const getResidualSnapshot = async() => {
  appStore.loading = true
  dataLoading.value = true
  try {
    const {data, status} = await getRequest(`/payroll/residual/${residualId.value}/snapshot`, 'blueraven')
    dataLoading.value = false
    residualSnapshot.value = data

    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Residual Snapshot')

    appStore.loading = false
  }
}
const populateStatusDetails = () => {
  switch(residual.value.status) {
    case 'PENDING':
      payrollStatus.value.message = 'This payroll is pending.'
      payrollStatus.value.color = 'primary'
      payrollStatus.value.textColor = 'white'
      break
    case 'APPROVED':
      payrollStatus.value.message = 'This payroll has been Approved for Pay.'
      payrollStatus.value.color = 'success'
      payrollStatus.value.textColor = 'white'
      break
    case 'SUBMITTED':
      payrollStatus.value.message = 'This payroll has been Submitted for Approval.'
      payrollStatus.value.color = '#DCDCDC'
      break
    case 'REJECTED':
      payrollStatus.value.message = 'This payroll has been Rejected.'
      payrollStatus.value.color = 'error'
      payrollStatus.value.textColor = 'white'
      break
    default:
      payrollStatus.value = {}
  }
}
const exportResidualReview = async () => {
  appStore.loading = true
  try {
    let filename = 'Residual Review.csv'

    let csvData = 'User First Name,User Last Name,Employee ID,Region,Org Name,Org State,User Position,User Status,Hire Date,Usable Name,Residual Start Date,LTD Qualified FDC,Qualified FDC This Period,FDA Not Qualified This Period,Required FDS for Month,Residual Earned, % of Residual Earned,Potential Residual,Earned Residual,Clawback,Adjustment/Override,Total,Paid In Period';
    csvData += '\n';

    residualSnapshot.value.forEach(p => {
      csvData +=
          p.userFirstName + ',"' +
          p.userLastName + '",' +
          p.employeeId + ',"' +
          p.regionName + '",' +
          "\"" + p.officeName +  '\",' +
          p.officeState + ',' +
          p.userPositionName + ',"' +
          p.userStatus + '",' +
          p.hireDate + ',' +
          p.userFullName + ',' +
          p.residualStartDate + ',' +
          p.lifetimeQualifiedFds + ',' +
          p.qualifiedFdcInPeriod + ',' +
          p.fdcNotQualifiedInPeriod + ',' +
          p.requiredFdcPerMonth + ',' +
          p.residualEarned + ',' +
          p.percentOfResidualEarned + ',"' +
          p.potentialResidual + '",' +
          p.earnedResidual + ',' +
          p.clawback + ',' +
          p.adjustmentOverride + ',' +
          p.residualTotal + ',' +
          p.paidInPeriod
      csvData += '\n';
    })


    let blob = new Blob([csvData], {
      type: 'text/csv;charset=utf-8'
    });

    saveAs(blob, filename);
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Exporting Residual Review')

    appStore.loading = false
  }
}
const lastThursdayForMonth =(monthMoment) => {
  let month = monthMoment.month()
  monthMoment.endOf("month").startOf("isoweek").add(3, "days")
  if (monthMoment.month() !== month) {
    monthMoment.subtract(7, "days")
  }
  return monthMoment.format('M/DD/YYYY')
}
const exportResidualReviewForNetSuite = async () => {
  appStore.loading = true
  try {
    let filename = `${residual.value.description} for Netsuite.csv`

    let csvData = 'EE ID, Vendor Name, Vendor, Pay Period Dates, Bill Date, Due Date, Bill No, Expense Description, Expense Line Amount, State, Account, Department, Expense Account, Department (NS), Class (NS), Type, Description';
    csvData += '\n';

    let lastThursdayOfMonth = lastThursdayForMonth(moment(residual.value.gracePeriodEnd))
    let payPeriodDateRange = moment(residual.value.periodStart).format('MM.DD') + ' - ' + moment(residual.value.periodEnd).format('MM.DD')
    // let specialCaseUserId = 2353957 //mike false - for testing
    let specialCaseUserId = 2426298 // real - steve downing

    residualSnapshot.value.forEach((p, idx) => {
      let userFullName = (p.userFirstName + ' ' + p.userLastName)
      let type = (p.userId === specialCaseUserId ? 'BONUS' : 'Residual')
      let paymentDescription = (p.userId === specialCaseUserId ? `${residual.value.description} BONUS Payment` : `${residual.value.description} Payment`)
      csvData +=
          p.employeeId + ',' +
          userFullName + ',' +
          ',' + //an empty column for the vendor for ryan to use
          payPeriodDateRange + ',' +
          lastThursdayOfMonth + ',' +
          lastThursdayOfMonth + ',' +
          `${ moment(residual.value.gracePeriodEnd).format("MMMM YYYY")} Residual-${idx+1}` + ',' +
          (p.employeeId + ' | ' + userFullName + ' | ' + payPeriodDateRange + ' | ' + type + ' | ' + paymentDescription) + ',' +
          p.residualTotal + ',' +
          p.officeState + ',' +
          '6037 Closer Residual' + ',' +
          '220-CLOSER' + ',' +
          439 + ',' +
          7 + ',' +
          NetsuiteStateEnum.find(st => st.abbreviation === p.officeState)?.id + ',' +
          type + ',' +
          paymentDescription
      csvData += '\n';
    })


    let blob = new Blob([csvData], {
      type: 'text/csv;charset=utf-8'
    });

    saveAs(blob, filename);
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Exporting Residual Review')

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
    let params = {
      userId: residualItem.userId,
      snapshotTypeId: typeId
    }
    const {data, status} = await getRequestWithParams(`/commissionManagement/residuals/${residualItem.residualId}/snapshotFdc`, {params},'blueraven')
    modalData.value = data
    modalUserFullName.value = residualItem.userFullName
    showModal.value = true
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Data')

    appStore.loading = false
  }
}
</script>

