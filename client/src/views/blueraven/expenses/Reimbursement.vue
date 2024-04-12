<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="app-title">Reimbursement Request
          </v-toolbar-title>
        </v-toolbar>
        <v-divider></v-divider>
      </v-col>
    </v-row>
    <v-row>
      <v-col cols="12" sm="6">
        <v-card flat class="pa-4">
          <h3>New Reimbursement Request</h3>
          <a-text-field
                        type="number"
                        label="Dollar Amount"
                        v-model.number="newReimbursement.amount">
          </a-text-field>
          <DatetimePickerInput
              v-model="newReimbursement.expenseDate"
              :timezone="timezone"
              :type="'date'"
              :format="'MM/DD/YYYY'"
              label="Expense Date"
          />
          <a-autocomplete v-model="selectedBudgetId"
                          :items="availableBudgets"
                          disabled
                          readonly
                          label="Expense Budget"
                          item-title="fullBudgetName"
                          item-value="id"
          ></a-autocomplete>
          <a-autocomplete v-model="newReimbursement.budgetTypeId"
                          :items="budgetTypes"
                          label="Budget Type"
                          item-title="name"
                          item-value="id"
          ></a-autocomplete>
          <label>Details:</label>
          <a-textarea class="py-2 gray lighten-4" hide-details
                      auto-grow
                      variant="filled"
                      rows="4"
                      bg-color="#F2F6F8"
                      v-model="newReimbursement.details">
          </a-textarea>
          <label>Receipt Image: </label>
          <div v-if="!receiptLogo || !receiptLogo.id" class="mb-5">
            <form enctype="multipart/form-data" novalidate>
              <input
                  type="file"
                  :accept="acceptedFileTypes"
                  class="file-input clickable"
                  :disabled="savingReceiptImage"
                  @change="uploadFile($event.target.files, attachmentTypeId)"
                  name="avatar"
              >
            </form>
          </div>
          <div class="receipt-image-background mb-5" v-else>
            <img class="receipt-image" :src="receiptLogo.presignedUrl">
          </div>
          <a-btn
              color="primary"
              :disabled="!newReimbursement.expenseDate || !selectedBudgetId || !newReimbursement.amount || !newReimbursement.budgetTypeId || !receiptLogo || !receiptLogo.id || !newReimbursement.details"
              @click="submitReimbursementRequest()"
              text="Submit"
          ></a-btn>
          <a-btn
              variant="text"
              color="primary"
              class="ml-3"
              @click="newReimbursement = {}"
              text="Clear"
          ></a-btn>
        </v-card>
      </v-col>
      <v-col cols="12" sm="6">
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="app-title">
            Viewing Budget Data For:
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <div class="flex-display pt-3">
              <a-select v-model="selectedMonth"
                        :items="months"
                        hide-details
                        class="mr-3 reimbursement-range-selector"
                        single-line
                        label="Month"
                        item-title="name"
                        item-value="id"
              ></a-select>
              <a-select v-model="selectedYear"
                        :items="years"
                        hide-details
                        class="reimbursement-range-selector"
                        single-line
                        label="Year"
                        item-title="name"
                        item-value="id"
              ></a-select>
              <a-btn
                  color="primary"
                  class="ml-3"
                  @click="setDataForMonth"
                  text="Load"
              ></a-btn>
            </div>
          </v-toolbar-items>
        </v-toolbar>
        <SpinnerInline v-if="dataLoading" :size="20" color="primary"/>
        <v-sheet v-else flat class="square-card pa-5">

          <v-card v-if="rejectedRequests.length > 0">
            <v-card-title class="grey lighten-2" primary-title>
              Rejected Requests
            </v-card-title>
            <v-card-text class="pt-4">
              <table>
                <thead>
                <th class="pr-3">Expense Date</th>
                <th class="pr-3">Amount</th>
                <th class="pr-3">Details</th>
                </thead>
                <tr v-for="req in rejectedRequests">
                  <td>{{ req.expenseDate | formatDate('date') }}</td>
                  <td>{{ req.amount | currency('$', 2) }}</td>
                  <td>{{ req.notes }}</td>
                </tr>
              </table>
            </v-card-text>
          </v-card>

          <div  v-for="br in budgetReport">
            <BudgetReportTable :budget="br"></BudgetReportTable>
          </div>

        </v-sheet>
      </v-col>
    </v-row>

  </v-container>
</template>

<script setup>

import {
  handleHidingGlobalLoader,
  postRequest,

  getRequestWithParams,
  getMonthDateRange, getYears
} from '@/helpers/helpers'
import DatetimePickerInput from "@/components/DatetimePickerInput"
import constants from "@/helpers/constants"
import moment from 'moment'
import {getBudgetsForUser, getBudgetTypes, getReimbursementRequestImage} from './expenseService'
import SpinnerInline from "@/components/SpinnerInline.vue";
import BudgetReportTable from "@/views/blueraven/expenses/BudgetReportTable.vue";

import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'
import { useFileStore } from '@/stores/FileStore.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const fileStore = useFileStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const createNew = ref(true)
const dataLoading = ref(true)
const savingReceiptImage = ref(false)
const attachmentTypeId = ref(4)
const receiptLogo = ref({})
const newReimbursement = ref({})
const renderApprovalRequestImage = ref(false)
const needsApprovalRequest = ref({})
const availableBudgets = ref([])
const budgetTypes = ref([])
const acceptedFileTypes = ref(constants.STANDARD_IMAGES_ONLY)
const rejectedRequests = ref([])
const budgetReport = ref([])
const months = ref(constants.MONTHS)
const years = ref(getYears(2017, true))
const selectedMonth = ref(parseInt(moment().format('M')))
const selectedYear = ref(parseInt(moment().format('YYYY')))
const budgetsLoading = ref(false)
const startDate = ref(null)
const endDate = ref(null)

const timezone = computed(() => {
  return userStore.timezone.value
})
const userId = computed(() => {
  return userStore.details.id
})
const companyId = computed(() => {
  return userStore.details.companyId
})
const selectedBudgetId = computed(() => {
  return newReimbursement.value.expenseDate != null ? availableBudgets.value.find(b => {
    return moment(newReimbursement.value.expenseDate).isBetween(b.startDate, b.endDate, null, '[]')
  })?.id : null
})

onMounted(() => {
  //init
  setDataForMonth()
  getTheBudgetTypes()
  getTheBudgetsForUser()

})

const submitReimbursementRequest = async() => {
  appStore.loading = true
  try {
    newReimbursement.value.attachmentId = receiptLogo.value.id
    newReimbursement.value.expenseBudgetId = selectedBudgetId.value

    const {status} = await postRequest(`/reimbursement/request`, newReimbursement.value, 'blueraven')
    newReimbursement.value = {}
    receiptLogo.value = {}
    snackbar('SUCCESS', 'Reimbursement Request Submitted.')

    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    let msg = 'Error Submitting Reimbursement Request.'
    if (e && e.status && e.status === 406) {
      msg = 'Error, Request exceeds budget. Please contact Administrator for assistance.'
    }
    snackbar('ERROR', msg)

    appStore.loading = false
  }
}
const getTheBudgetTypes = async() => {
  //reset the budget id every time a user or expense date changes
  appStore.loading = true
  try {
    const {data, status} = await getBudgetTypes()
    budgetTypes.value = data
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

    appStore.loading = false
  }
}
const getRequestAttachmentPresignedUrl = async() => {
  renderApprovalRequestImage.value = false
  appStore.loading = true
  try {
    const {data, status} = await getReimbursementRequestImage(needsApprovalRequest.value.id)
    needsApprovalRequest.value.presignedUrl = data
    //this forces the dom to re-render the presignedUrl and i hate myself
    renderApprovalRequestImage.value = true
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Attached Image')

    appStore.loading = false
  }
}
const uploadFile = async(files, attachmentTypeId) => {
  try {
    savingReceiptImage.value = true
    appStore.loading = true
    let file = files[0]
    await fileStore.uploadFile({
      file: file,
      attachmentTypeId,
      sourceId: null,
      displayName: file.name.substr(0, file.name.lastIndexOf('.')),
      callback: async(img, error) => {
        savingReceiptImage.value = false
        if (error?.error) {
          snackbar('ERROR', error.errorMsg)

          appStore.loading = false
        } else {
          receiptLogo.value = img
          snackbar('SUCCESS', 'Receipt Uploaded')

          appStore.loading = false
        }
      }
    })
  } catch (e) {
    savingReceiptImage.value = false
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Uploading File')

    appStore.loading = false
  }
}
const getTheBudgetsForUser = async() => {
  budgetsLoading.value = true
  try {
    const {data, status} = await getBudgetsForUser(userId.value)
    availableBudgets.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

  } finally {
    budgetsLoading.value = false
  }
}
const getMonthlyBudgetReport = async() => {
  const {data} = await getRequestWithParams(`/expenseBudgets/getMonthlyBudgetReport`, {
        params: {
          startDate: startDate.value,
          endDate: endDate.value,
          userId: userId.value
        }
      }, 'blueraven'
      , [])
  budgetReport.value = data
}
const getRejectedRequests = async(statusId) => {
  const {data} = await getRequestWithParams(`/reimbursement/requests/byStatus`, {
        params: {
          statusId,
          startDate: startDate.value,
          endDate: endDate.value
        }
      }, 'blueraven'
  )
  rejectedRequests.value = data
}
const setDataForMonth = async() => {
  dataLoading.value = true
  let dateRange = getMonthDateRange(selectedMonth.value, selectedYear.value)
  startDate.value = dateRange.startDate
  endDate.value = dateRange.endDate

  let requests = [
    //get rejected requests for user
    getRejectedRequests(2),
    getMonthlyBudgetReport()

  ]
  await Promise.all(requests).then(() => {
    dataLoading.value = false
  })
}
</script>

<style scoped lang="scss">
.receipt-image {
  margin-top: 15px;
  max-width: 200px;
  height: auto;
}

.reimbursement-range-selector {
  max-width: 100px;
}

.receipt-image-tooltip {
  max-width: 100% !important;
  background-color: transparent;
  opacity: 1 !important;
}

.receipt-image-hover-container {
  max-width: 100%;
  height: auto;
}

.receipt-image-hovered {
  max-width: 100%;
  max-height: calc(100vh - 200px);
  height: auto;
  width: auto;
}

.detail-table {
  width: 100%;
  margin-top: 10px;
  border-collapse: collapse;
}

.detail-column {
  width: 50%;
}

.detail-column-header {
  font-weight: bold;
  font-size: 14px;
}

.total-row {
  border-top: solid 1px #D8D8D8;
  font-weight: bold;
}
</style>
