<template>
  <v-container id="submitted-expense-container">
    <v-card flat color="white" class="px-5 mt-4 square-card" v-if="!selectedExpense || !selectedExpense.id">
      <v-row>
        <v-col cols="12" sm="4">
          <div class="left-header-bar">
            <v-toolbar-title class="app-title">
              Submitted Expenses
            </v-toolbar-title>
            <a-text-field
                v-model="userSearchText"
                prepend-inner-icon="search"
                label="Search"
                single-line
                class="mt-5"
                hide-details
            ></a-text-field>
          </div>
        </v-col>
        <v-col cols="12" sm="4" class="middle-header-bar">
          <div  v-if="showMiddleHeader">
            <a-btn
                @click="paymentDropdown = true"
                color="primary"
                class="ml-3"
                text="Mark as Paid"
            ></a-btn>
            <ConfirmationDialog :open-dialog="paymentDropdown" @confirm="confirmPayment"
                                @close-dialog="paymentDropdown=false">
              <template v-slot:title>Confirm</template>
              Are you sure you want to pay all selected expenses?
              <template v-slot:yes>Pay</template>
            </ConfirmationDialog>
          </div>
        </v-col>
        <v-col cols="12" sm="4">
          <div class="right-header-bar elevation-1">
            <div>From:</div>
            <div class="flex-display">
              <a-select v-model="startMonth"
                        :items="months"
                        hide-details
                        custom-classes="mr-2 range-selector"
                        single-line
                        variant="outlined"
                        density="compact"
                        label="Month"
                        item-title="name"
                        item-value="id"
              ></a-select>
              <a-select v-model="startYear"
                        :items="years"
                        hide-details
                        custom-classes="range-selector"
                        single-line
                        variant="outlined"
                        density="compact"
                        label="Year"
                        item-text="name"
                        item-value="id"
              ></a-select>
            </div>
            <div>Thru:</div>
            <div class="flex-display">
              <a-select v-model="endMonth"
                        :items="months"
                        hide-details
                        custom-classes="mr-2 range-selector"
                        single-line
                        variant="outlined"
                        density="compact"
                        label="Month"
                        item-title="name"
                        item-value="id"
              ></a-select>
              <a-select v-model="endYear"
                        :items="years"
                        hide-details
                        custom-classes="range-selector"
                        single-line
                        variant="outlined"
                        density="compact"
                        label="Year"
                        item-title="name"
                        item-value="id"
              ></a-select>
            </div>
            <a-btn
                color="primary"
                class="mt-2"
                small
                @click="getSubmittedExpenses"
                text="Show All in Range"
            ></a-btn>
            <a-btn
                color="primary"
                class="mt-2"
                small
                @click="exportExpenses(false)"
                text="Export All in Range"
            ></a-btn>
            <a-btn
                color="primary"
                class="mt-2"
                small
                @click="getAllUnpaid"
                text="Show All Unpaid"
            ></a-btn>
            <a-btn
                color="primary"
                class="mt-2"
                small
                @click="exportExpenses(true)"
                text="Export All Unpaid"
            ></a-btn>
          </div>
        </v-col>
      </v-row>
    </v-card>

    <v-divider></v-divider>
    <div v-if="!selectedExpense || !selectedExpense.id" class="submitted-expense-table-container">
      <v-data-table
          :headers="headers"
          :items="filteredSubmittedExpenses"
          :search="userSearchText"
          :items-per-page="500"
          :mobile-breakpoint="0"
          :loading="dataLoading"
          :footer-props="footerProps"
          fixed-header
          class="elevation-1 fix-column-width-bug square-card submitted-expense-table"
      >
        <template #no-data>
          <span class="default-text-color">No Matching Expenses Found</span>
        </template>

        <template #no-results>
          <span class="default-text-color">No Matching Expenses Found</span>
        </template>

        <template #header.selectBox="{}">
          <v-checkbox v-model="selectAllExpenses"
                      v-if="userCanAdmin || userCanManage"
                      @change="toggleSelectAllExpenses()"></v-checkbox>
        </template>

        <template #item="{ item, index }">
          <tr :class="{'shaded-row': index % 2}">
            <td>
              <v-checkbox v-model="item.selected"
                          v-if="userCanAdmin || (userCanManage && !item.paidDate)"
                          @change="toggleSingleSelect(item)"></v-checkbox>
            </td>
            <td class="text-left">{{ item.expenseBudgetUser }}</td>
            <td class="text-left">{{ item.amount | currency('$', 2) }}</td>
            <td class="text-left">{{ item.expenseDate | formatDate('date') }}</td>
            <td class="text-left">{{ item.budgetType }}</td>
            <td class="text-left">{{ item.glCode }}</td>
            <td class="text-left">{{ item.approvalDate | formatDate('date') }}</td>
            <td class="text-left">{{ item.approvedBy }}</td>
            <td class="text-left">{{ item.paidDate | formatDate('date') }}</td>
            <td class="text-left">{{ item.paidBy }}</td>
            <td>
              <div style="display: flex; justify-content: flex-end"
                   v-if="userCanAdmin || (userCanManage && !item.paidDate)">
                <a-btn
                    size="small"
                    variant="text"
                    color="primary"
                    @click="[selectedExpense = item, getRequestAttachmentPresignedUrl(item), getTheBudgetsForUser(selectedExpense.expenseBudgetUserId)]"
                    prepend-icon="edit"
                ></a-btn>
                <a-btn
                    size="small"
                    variant="text"
                    color="primary"
                    @click="[deleteConfirm = true, itemToDelete = item]"
                    prepend-icon="delete"
                ></a-btn>
              </div>
            </td>
          </tr>
        </template>
      </v-data-table>
    </div>
    <v-row v-else>
      <v-col cols="12">
        <v-toolbar flat class="cfg-header-bar" dense>
          <v-toolbar-title class="app-title">
            <a-btn
                variant="text"
                color="primary"
                @click="selectedExpense = {}"
                text="Back"
            ></a-btn>
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat class="px-5">
          <v-card-text class="py-1">
            <v-autocomplete v-model="selectedExpense.expenseBudgetUserId"
                            :items="usersWithBudget"
                            label="Purchaser"
                            item-text="fullName"
                            item-value="id"
                            @input="getTheBudgetsForUser(selectedExpense.expenseBudgetUserId)"
            ></v-autocomplete>
            <v-autocomplete v-model="selectedExpense.expenseBudgetId"
                            :items="budgetsForUser"
                            label="Selected Budget"
                            item-text="fullBudgetName"
                            item-value="id"
            ></v-autocomplete>
            <DatetimePickerInput
                v-model="selectedExpense.expenseDate"
                :timezone="timezone"
                :type="'date'"
                :format="'MM/DD/YYYY'"
                label="Expense Date"
            />
            <v-autocomplete v-model="selectedExpense.glCodeId"
                            :items="glCodes"
                            label="GL Code"
                            item-text="code"
                            item-value="id"
                            :filter="searchGlCodes"
            >
              <template slot='item' slot-scope='{ item }'>
                {{ item.code }} - {{ item.description }}
              </template>
              <template slot='selection' slot-scope='{ item }'>
                {{ item.code }} - {{ item.description }}
              </template>
            </v-autocomplete>

            <v-autocomplete v-model="selectedExpense.budgetTypeId"
                            :items="budgetTypes"
                            label="Budget Type"
                            item-text="name"
                            item-value="id"
            ></v-autocomplete>
            <a-text-field
                          type="number"
                          prepend-icon="mdi-currency-usd"
                          label="Amount"
                          v-model.number="selectedExpense.amount">
            </a-text-field>
            <label>Details:</label>
            <v-textarea class="py-2" hide-details
                        auto-grow filled
                        rows="4"
                        background-color="#F2F6F8"
                        v-model="selectedExpense.details">
            </v-textarea>
            <label>Notes:</label>
            <v-textarea class="py-2" hide-details
                        auto-grow filled
                        rows="4"
                        background-color="#F2F6F8"
                        v-model="selectedExpense.notes">
            </v-textarea>

            <label>Receipt Image:</label>
            <div class="receipt-image-background">
              <v-tooltip bottom max-width="300px"
                         v-if="renderRequestImage && selectedExpense.presignedUrl"
                         content-class="receipt-image-tooltip">
                <template v-slot:activator="{ on:tooltip }">
                  <v-img name="receiptImg" class="receipt-image"
                         v-on="{ ...tooltip }"
                         alt="receipt-image" :src="selectedExpense.presignedUrl"></v-img>
                </template>
                <v-card class="receipt-image-hover-container">
                  <img class="receipt-image-hovered" :src="selectedExpense.presignedUrl">
                </v-card>
              </v-tooltip>
            </div>
          </v-card-text>

          <v-card-actions>
            <v-spacer></v-spacer>
            <a-btn
                color="primary"
                variant="text"
                @click="selectedExpense = {}"
                text="Cancel"
            ></a-btn>
            <a-btn
                color="primary"
                raised
                :disabled="!selectedExpense.expenseDate || !selectedExpense.glCodeId || !selectedExpense.expenseBudgetUserId || !selectedExpense.expenseBudgetId || !selectedExpense.amount"
                @click="saveSubmittedExpense(selectedExpense)"
                text="Save Changes"
            ></a-btn>
          </v-card-actions>
        </v-card>
      </v-col>
    </v-row>
    <ConfirmationDialog
        :open-dialog=deleteConfirm
        @confirm=deleteSubmittedExpense(itemToDelete)
        @close-dialog="closeDeleteDialog">
      Are you sure you want to delete this Submitted Expense for <strong>{{ itemToDeleteUser }}:
      {{ itemToDeleteAmount | currency('$', 2) }}</strong>?
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>

import {
  handleHidingGlobalLoader,
  deleteRequest,
  getRequestWithParams,
  postRequest,
  putRequest,
  getMonthDateRange, getRequest, getYears
} from '@/helpers/helpers'
import constants from "@/helpers/constants";
import {
  getBudgetsForUser,
  getBudgetTypes,
  getGlCodes,
  getReimbursementRequestImage,
  getUsersWithBudget
} from './expenseService'
import DatetimePickerInput from "@/components/DatetimePickerInput"
import moment from 'moment'
import {saveAs} from 'file-saver'
import cloneDeep from 'lodash.clonedeep'
import ConfirmationDialog from "@/components/ConfirmationDialog";

import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const selectedExpense = ref({})
const approveDropdown = ref(false)
const approveConfirmLoading = ref(false)
const paymentDropdown = ref(false)
const paymentConfirmLoading = ref(false)
const dataLoading = ref(true)
const editIndex = ref(null)
const renderRequestImage = ref(false)
const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 500],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const masterExpenses = ref([])
const submittedExpenses = ref([])
const usersWithBudget = ref([])
const users = ref([])
const usersLoading = ref(false)
const userSearchText = ref('')
const budgetsForUser = ref([])
const selectedExpenses = ref([])
const selectAllExpenses = ref(false)
const glCodes = ref([])
const budgetTypes = ref([])
const headers = ref([
  {text: '', value: 'selectBox', selectFilter: true, show: true, width: '50px', sortable: false},
  {text: 'Purchaser', value: 'expenseBudgetUser', show: true, width: '125px'},
  {text: 'Amount', value: 'amount', show: true, width: '75px'},
  {text: 'Expense Date', value: 'expenseDate', show: true, width: '125px'},
  {text: 'Budget Type', value: 'budgetType', show: true, width: '125px'},
  {text: 'GL Code', value: 'glCode', show: true, width: '125px'},
  {text: 'Approved Date', value: 'dateApproved', show: true, width: '125px'},
  {text: 'Approved By', value: 'approvedBy', show: true, width: '125px'},
  {text: 'Paid Date', value: 'datePaid', show: true, width: '125px'},
  {text: 'Paid By', value: 'paidBy', show: true, width: '125px'},
  {text: null, value: 'icons', show: true, width: '80px'}
])
const showAll = ref(false)
const rangeChanged = ref(false)
const startDate = ref(moment().startOf('month').format('YYYY-MM-DD'))
const endDate = ref(moment().endOf('month').format('YYYY-MM-DD'))
const budgetsLoading = ref(false)
const deleteConfirm = ref(false)
const itemToDelete = ref({})
const canPay = ref(false)
const approveConfirm = ref(false)
const months = ref(constants.MONTHS)
const years = ref(getYears(2017, true))
const startMonth = ref(parseInt(moment().format('M')))
const startYear = ref(parseInt(moment().format('YYYY')))
const endMonth = ref(parseInt(moment().format('M')))
const endYear = ref(parseInt(moment().format('YYYY')))
onMounted(() => {
  getTheGlCodes()
  getTheUsersWithBudget()
  getTheBudgetTypes()
  getSubmittedExpenses()
})


const timezone = computed(() => {
  return userStore.timezone.value
})
const userFullName = computed(() => {
  return userStore.details.fullName
})
const userCanManage = computed(() => {
  return userStore.userHasFeatureAccessLevel('EXPENSES', 'MANAGE')
})
const userCanAdmin = computed(() => {
  return userStore.userHasFeatureAccessLevel('EXPENSES', 'ADMIN')
})
const userId = computed(() => {
  return userStore.details.id
})
const showMiddleHeader = computed(() => {
  return selectedExpenses.value.length > 0 && canPay.value
})
const itemToDeleteUser = computed(() => {
  return itemToDelete.value ? itemToDelete.value.expenseBudgetUser : ''
})
const itemToDeleteAmount = computed(() => {
  return itemToDelete.value ? itemToDelete.value.amount : ''
})
const filteredSubmittedExpenses = computed(() => {
  return submittedExpenses.value.filter(glc => !glc.archived)
})


const searchGlCodes = (item, queryText) => {
  let data = item.code.toLowerCase() + ' - ' + item.description.toLowerCase()
  return data.includes(queryText.toLowerCase())
}
const toggleSelectAllExpenses = () => {
  //reset these values first
  canApprove.value = true
  canReject.value = true
  canPay.value = true

  if (selectAllExpenses.value) {
    selectedExpenses.value = cloneDeep(masterExpenses.value)
  } else {
    selectedExpenses.value = []
  }

  submittedExpenses.value.forEach(item => {
    item.selected = selectAllExpenses.value

    if (!item.approvalDate || item.paidDate != null) {
      //if any selected do not have an approved date they cannot pay
      //if any selected have a paid date they cannot do anything
      canPay.value = false
    }
  })
}
const toggleSingleSelect = (item) => {
  //reset these values first
  canPay.value = true

  //set the selected item
  if (item.selected) {
    selectedExpenses.value.push(item)
  } else {
    selectedExpenses.value = selectedExpenses.value.filter(u => u.id !== item.id)
    selectAllExpenses.value = false
  }

  selectedExpenses.value.forEach(item => {
    if (!item.approvalDate || item.paidDate != null) {
      //if any selected do not have an approved date they cannot pay
      //if any selected have a paid date they cannot do anything
      canPay.value = false
    }
  })
}
const getSubmittedExpenses = async() => {
  try {
    dataLoading.value = true
    let dateRange1 = getMonthDateRange(startMonth.value, startYear.value)
    let dateRange2 = getMonthDateRange(endMonth.value, endYear.value)
    let date1 = dateRange1.startDate
    let date2 = dateRange2.endDate
    const {data, status} = await getRequestWithParams('/reimbursement/requests/approved', {
      params: {
        startDate: date1,
        endDate: date2
      }
    }, 'blueraven')
    submittedExpenses.value = data
    dataLoading.value = false
    masterExpenses.value = cloneDeep(data)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

  }
}
const deleteSubmittedExpense = async(item) => {
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`/reimbursement/${item.id}`, 'blueraven')
    item.archived = true
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting Submitted Expense')

    appStore.loading = false
  }
  closeDeleteDialog()
}
const exportExpenses = async(unpaid) => {
  appStore.loading = true
  try {
    let filename = unpaid ? 'unpaid_expenses' : 'expenses.csv'
    let results = []
    let url = unpaid ? '/reimbursement/requests/unpaid' : '/reimbursement/requests/approved'
    let dateRange1 = getMonthDateRange(startMonth.value, startYear.value)
    let dateRange2 = getMonthDateRange(endMonth.value, endYear.value)
    let date1 = dateRange1.startDate
    let date2 = dateRange2.endDate
    const {data} = await getRequestWithParams(url, {params: {startDate: date1, endDate: date2}}, 'blueraven')
    results = data

    let csvData = getCsvHeaders()
    csvData += '\n'

    results.forEach(r => {
      csvData +=
          '"' + r.expenseBudgetUser + '",' +
          r.amount + ',' +
          moment.utc(r.expenseDate).format('MM/DD/YYYY') + ',' +
          r.budgetType + ',' +
          r.glCode + ',' +
          `${r.approvalDate ? moment(r.approvalDate).format('MM/DD/YYYY') : null}` + ',' +
          '"' + r.approvedBy + '",' +
          `${r.paidDate ? moment(r.paidDate).format('MM/DD/YYYY') : null}` + ',' +
          '"' + r.paidBy + '",' +
          '"' + r.details + '"'

      csvData += '\n'

    })
    let blob = new Blob([csvData], {
      type: 'text/csv;charset=utf-8'
    });

    saveAs(blob, filename);
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Exporting Expenses')

    appStore.loading = false
  }

}
const getCsvHeaders = () => {
  return [
    'Purchaser',
    'Amount',
    'Expense Date',
    'Budget Type',
    'GL Code',
    'Approved Date',
    'Approved By',
    'Paid Date',
    'Paid By',
    'Details'
  ]
}
const getAllUnpaid = async() => {
  try {
    dataLoading.value = true
    const {data, status} = await getRequest('/reimbursement/requests/unpaid', 'blueraven')
    submittedExpenses.value = data
    dataLoading.value = false
    masterExpenses.value = cloneDeep(data)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

  }
}
const confirmPayment = async() => {
  appStore.loading = true
  paymentConfirmLoading.value = true
  try {
    await postRequest(`/reimbursement/requests/markPaid`, selectedExpenses.value, 'blueraven')

    //reload the requests cuz a lot can change
    await getSubmittedExpenses()
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Marking Selected Expenses as Paid')
    paymentConfirmLoading.value = false

    appStore.loading = false
  }
}
const saveSubmittedExpense = async(item) => {
  appStore.loading = true
  try {
    await putRequest(`/reimbursement/request`, item, 'blueraven')
    selectedExpense.value = {}
    //reload them after saving changes
    await getSubmittedExpenses()
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Changes to Expense')

    appStore.loading = false
  }
}
const getTheBudgetsForUser = async(userId) => {
  budgetsLoading.value = true
  try {
    const {data, status} = await getBudgetsForUser(userId)
    budgetsForUser.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

  } finally {
    budgetsLoading.value = false
  }
}
const getTheBudgetTypes = async() => {
  //reset the budget id every time a user or expense date changes
  try {
    const {data, status} = await getBudgetTypes()
    budgetTypes.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

  }
}
const getTheGlCodes = async() => {
  try {
    const {data, status} = await getGlCodes()
    glCodes.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

  }
}
const getTheUsersWithBudget = async() => {
  try {
    const {data, status} = await getUsersWithBudget()
    usersWithBudget.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

  }
}
const getRequestAttachmentPresignedUrl = async(item) => {
  renderRequestImage.value = false
  appStore.loading = true
  try {
    const {data, status} = await getReimbursementRequestImage(item.id)
    selectedExpense.value.presignedUrl = data
    //this forces the dom to re-render the presignedUrl and i hate myself
    renderRequestImage.value = true
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Attached Image')

    appStore.loading = false
  }
}
const closeDeleteDialog = () => {
  deleteConfirm.value = false
  itemToDelete.value = null
}

</script>

<style lang="scss">
#submitted-expense-container .v-data-table__wrapper {
  height: calc(100vh - 500px);
  min-height: 300px;
}

#submitted-expense-container .expense-range-selector {
  max-width: 150px !important;
}
</style>

<style lang="scss" scoped>
#submitted-expense-container {
  margin-top: -15px;
  padding-left: 0;
  padding-right: 0;
  padding-top: 0;
}

.left-column {
  width: 175px;
}

.detail-container {
  width: 250px;
  height: auto
}

//.submitted-expense-table-container {
//  max-width: 100% !important;
//}

//.submitted-expense-table {
//  min-width: 1400px !important;
//}


.receipt-image-background {
  max-width: 250px !important;
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

.left-header-bar {
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

.right-header-bar {
  display: flex;
  padding: 5px;
  border: solid 1px #ccc;
  text-align: left;
  flex-direction: column;
  justify-content: space-between;
}

.middle-header-bar {
  display: flex;
  align-items: end;
  justify-content: center;
}

.range-selector {
  max-width: 150px;
}

</style>
