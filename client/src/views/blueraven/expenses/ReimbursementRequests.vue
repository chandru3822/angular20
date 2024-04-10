<template>
  <v-container id="reimbursement-requests-container">
    <v-row v-if="!selectedRequest || !selectedRequest.id">
      <v-col cols="12">
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="app-title">Reimbursement Requests</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                variant="text"
                color="primary"
                v-if="userCanAdd"
                @click="[createNew = !createNew, selectedBudgetReport = {}, newReimbursementRequest = {expenseBudgetId: null}]"
                :prepend-icon="!createNew ? 'add' : 'close'"
                hide-text-on-mobile
                :text="createNew ? 'cancel' : 'Add Reimbursement Request'"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card flat v-if="createNew" class="pa-4">
          <h3>Add Expense Item</h3>
          <a-autocomplete v-model="newReimbursementRequest.expenseBudgetUserId"
                          :items="usersWithBudget"
                          label="Purchaser"
                          item-title="fullName"
                          item-value="id"
                          @input="[newReimbursementRequest.expenseBudgetId = null, getTheBudgetsForUser(newReimbursementRequest.expenseBudgetUserId, false, true)]"
          ></a-autocomplete>
          <a-autocomplete v-model="newReimbursementRequest.expenseBudgetId"
                          :items="budgetsForUser"
                          label="Selected Budget"
                          :loading="budgetsLoading"
                          :disabled="!newReimbursementRequest.expenseBudgetUserId"
                          item-title="fullBudgetName"
                          item-value="id"
                          @change="getMonthlyBudgetReport(true)">
          </a-autocomplete>
          <div v-if="newReimbursementRequest.expenseBudgetId">
            <SpinnerInline v-if="loadingBudgetReport" :size="20" color="primary"/>
            <BudgetReportTable v-else class="mb-4" :budget="selectedBudgetReport"></BudgetReportTable>
          </div>
          <DatetimePickerInput
              v-model="newReimbursementRequest.expenseDate"
              :timezone="timezone"
              :type="'date'"
              :format="'MM/DD/YYYY'"
              label="Expense Date"
          />
          <a-autocomplete v-model="newReimbursementRequest.glCodeId"
                          :items="glCodes"
                          :loading="glCodesLoading"
                          label="GL Code"
                          :item-title="item => `${item.code} - ${item.description}`"
                          item-value="id"
                          :filter="searchGlCodes">
          </a-autocomplete>
          <a-autocomplete v-model="newReimbursementRequest.budgetTypeId"
                          :items="budgetTypes"
                          :loading="budgetTypesLoading"
                          label="Budget Type"
                          item-title="name"
                          item-value="id"
          ></a-autocomplete>
          <a-text-field
                        prepend-icon="mdi-currency-usd"
                        type="number"
                        label="Amount"
                        v-model.number="newReimbursementRequest.amount">
          </a-text-field>
          <label>Notes:</label>
          <v-textarea class="py-2" hide-details
                      auto-grow filled
                      rows="4"
                      background-color="#F2F6F8"
                      v-model="newReimbursementRequest.notes">
          </v-textarea>
          <a-btn
              color="primary"
              :disabled="!newReimbursementRequest.expenseDate || !newReimbursementRequest.glCodeId || !newReimbursementRequest.budgetTypeId || !newReimbursementRequest.expenseBudgetId || !newReimbursementRequest.amount"
              @click="saveReimbursementRequest(newReimbursementRequest, true)"
              text="Save"
          ></a-btn>
        </v-card>
        <v-divider v-if="createNew"></v-divider>
        <v-data-table
            :headers="headers"
            :items="filteredReimbursementRequests"
            :items-per-page="100"
            :mobile-breakpoint="0"
            :loading="dataLoading"
            fixed-header
            :footer-props="footerProps"
            class="elevation-1 fix-column-width-bug square-card"
        >
          <template #no-data>
            <span class="default-text-color">No Reimbursement Requests</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No Reimbursement Requests</span>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{ item.expenseBudgetUser }}</td>
              <td class="text-left">{{ item.dateCreated | formatDate('date') }}</td>
              <td class="text-left">{{ item.amount | currency('$', 2) }}</td>
              <td class="text-left">{{ item.budgetType }}</td>
              <td class="text-left">{{ item.expenseDate | formatDate('date') }}</td>
              <td>
                <div style="display: flex; justify-content: flex-end" v-if="userCanEdit">
                  <a-btn
                      size="small"
                      variant="text"
                      color="primary"
                      @click="[selectedRequest = item, getTheBudgetsForUser(item.expenseBudgetUserId, true, false), getRequestAttachmentPresignedUrl(item)]"
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
      </v-col>
    </v-row>
    <v-row v-else>
      <v-col cols="12">
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="app-title">
            <a-btn
                variant="text"
                @click="selectedRequest = {}"
                color="primary"
                text="Back"
            ></a-btn>
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <div class="pt-3">
              <a-btn
                  @click="validateAndApprove"
                  color="primary"
                  text="Approve & Submit"
              ></a-btn>
              <v-menu v-model="rejectDropdown"
                      bottom offset-y min-width="350"
                      :close-on-content-click="false">
                <template #activator="{on}">
                  <a-btn
                      :activation-handler="on"
                      color="error"
                      class="ml-3"
                      text="Reject"
                  ></a-btn>
                </template>
                <v-card class="pa-5">
                  <label>Reason for Rejection: (required)</label>
                  <v-textarea class="py-2" hide-details
                              auto-grow filled
                              rows="4"
                              background-color="#F2F6F8"
                              v-model="selectedRequest.notes">
                  </v-textarea>
                  <a-btn
                      @click="rejectRequest(selectedRequest)"
                      :disabled="!selectedRequest.notes"
                      color="error"
                      text="Reject"
                  ></a-btn>
                  <a-btn
                      class="ml-3"
                      @click="rejectDropdown = false"
                      variant="text"
                      color="primary"
                      text="Cancel"
                  ></a-btn>
                </v-card>
              </v-menu>
              <a-btn
                  class="ml-3"
                  @click="selectedRequest = {}"
                  variant="text"
                  color="primary"
                  text="Cancel"
              ></a-btn>
            </div>
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat class="px-4">
          <v-row class="px-4">
            <v-col cols="12" sm="5">
              <h3 class="mb-5">Reimbursement Request Details</h3>
              <v-form ref="editRequestForm">
                <a-autocomplete v-model="selectedRequest.expenseBudgetUserId"
                                :items="usersWithBudget"
                                label="Purchaser"
                                :rules="requiredRules"
                                item-title="fullName"
                                item-value="id"
                                @input="[selectedRequest.expenseBudgetId = null, getTheBudgetsForUser(selectedRequest.expenseBudgetUserId)]"
                ></a-autocomplete>
                <a-autocomplete v-model="selectedRequest.expenseBudgetId"
                                :items="budgetsForUser"
                                label="Selected Budget"
                                :rules="requiredRules"
                                :loading="budgetsLoading"
                                :disabled="!selectedRequest.expenseBudgetUserId"
                                item-title="fullBudgetName"
                                item-value="id"
                                @change="getMonthlyBudgetReport(false)"
                >
                </a-autocomplete>
                <DatetimePickerInput
                    v-model="selectedRequest.expenseDate"
                    :timezone="timezone"
                    :type="'date'"
                    :required="true"
                    :format="'MM/DD/YYYY'"
                    label="Expense Date"
                />
                <a-autocomplete v-model="selectedRequest.glCodeId"
                                :items="glCodes"
                                label="GL Code"
                                :rules="requiredRules"
                                item-value="id"
                                :item-title="item => `${item.code} - ${item.description}`"
                                :filter="searchGlCodes">
                </a-autocomplete>
                <a-autocomplete v-model="selectedRequest.budgetTypeId"
                                :items="budgetTypes"
                                label="Budget Type"
                                :rules="requiredRules"
                                item-title="name"
                                item-value="id"
                ></a-autocomplete>
                <a-text-field
                              type="number"
                              label="Amount"
                              prepend-icon="mdi-currency-usd"
                              :rules="requiredRules"
                              v-model.number="selectedRequest.amount">
                </a-text-field>
                <label>Request Details:</label>
                <v-textarea class="py-2" hide-details
                            auto-grow filled
                            rows="4"
                            background-color="#F2F6F8"
                            v-model="selectedRequest.details">
                </v-textarea>
                <label>Admin Notes:</label>
                <v-textarea class="py-2" hide-details
                            auto-grow filled
                            rows="4"
                            background-color="#F2F6F8"
                            v-model="selectedRequest.notes">
                </v-textarea>
              </v-form>
            </v-col>
            <v-col cols="12" sm="7" class="pt-0">
              <SpinnerInline v-if="loadingBudgetReport" :size="20" color="primary"/>
              <BudgetReportTable v-else class="mb-4" :budget="selectedBudgetReport"></BudgetReportTable>
              <h3 class="mb-5">Receipt Image</h3>
              <v-img name="receiptImg" class="receipt-image" v-if="renderRequestImage"
                     alt="receipt-image" :src="selectedRequest.presignedUrl"></v-img>
            </v-col>
          </v-row>
        </v-card>
      </v-col>
    </v-row>
    <ConfirmationDialog
        :open-dialog=deleteConfirm
        @confirm=deleteReimbursementRequest(itemToDelete)
        @close-dialog="closeDeleteDialog">
      Are you sure you want to delete this Reimbursement Request for <strong>{{ itemToDeleteCreatedBy }}:
      {{ itemToDeleteAmount | currency('$', 2) }}</strong>?

    </ConfirmationDialog>
  </v-container>
</template>

<script setup>

import {
  handleHidingGlobalLoader,
  getRequest,
  deleteRequest,
  getRequestWithParams,
  postRequest,
  putRequest,

} from '@/helpers/helpers'
import constants from "@/helpers/constants";
import {
  getGlCodes,
  getBudgetTypes,
  getReimbursementRequestImage,
  getUsersWithBudget,
  getBudgetsForUser
} from './expenseService'
import DatetimePickerInput from "@/components/DatetimePickerInput"
import ConfirmationDialog from "@/components/ConfirmationDialog";
import BudgetReportTable from "@/views/blueraven/expenses/BudgetReportTable.vue";
import SpinnerInline from "@/components/SpinnerInline.vue";

import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'
import debounce from 'lodash.debounce'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar
const vuetify = vueInstance.$vuetify

const createNew = ref(false)
const dataLoading = ref(true)
const budgetsLoading = ref(false)
const newReimbursementRequest = ref({expenseBudgetId: null})
const requiredRules = ref(constants.BASIC_REQUIRED_RULE)
const selectedRequest = ref({})
const editIndex = ref(null)
const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 500],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const reimbursementRequests = ref([])
const budgetsForUser = ref([])
const selectedBudgetReport = ref({})
const loadingBudgetReport = ref(true)
const usersWithBudget = ref([])
const budgetTypes = ref([])
const glCodes = ref([])
const headers = ref([
  {text: 'Purchaser', value: 'expenseBudgetUser', show: true, width: '125px'},
  {text: 'Created Date', value: 'dateCreated', show: true, width: '125px'},
  {text: 'Amount', value: 'amount', show: true, width: '75px'},
  {text: 'Budget Type', value: 'budgetType', show: true, width: '125px'},
  {text: 'Expense Date', value: 'expenseDate', show: true, width: '125px'},
  {text: null, value: 'icons', show: true, width: '80px'}
])
const tempIdCount = ref(0)
const expenseHeaders = ref([
  {text: 'GL Code', value: 'glCode', show: true},
  {text: 'Budget User', value: 'budgetUser', show: true},
  {text: 'Budget Type', value: 'budgetType', show: true},
  {text: 'Amount', value: 'amount', show: true},
  {text: null, value: 'icons', show: true, width: '50px'}
])
const rejectDropdown = ref(false)
const glError = ref(false)
const budgetError = ref(false)
const amountError = ref(false)
const renderRequestImage = ref(false)
const deleteConfirm = ref(false)
const budgetTypesLoading = ref(true)
const glCodesLoading = ref(true)
const itemToDelete = ref(null)
const editRequestForm = ref(null)

const userCanAdd = computed(() => {
  return userStore.userHasFeatureAccessLevel('EXPENSES', 'ADD')
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('EXPENSES', 'EDIT')
})
const timezone = computed(() => {
  return userStore.timezone.value
})
const userId = computed(() => {
  return userStore.details.id
})
const itemToDeleteCreatedBy = computed(() => {
  return itemToDelete.value ? itemToDelete.value.createdBy : ''
})
const itemToDeleteAmount = computed(() => {
  return itemToDelete.value ? itemToDelete.value.amount : 0
})
const isMobile = computed(() => {
  return vuetify.breakpoint.smAndDown
})
const filteredReimbursementRequests = computed(() => {
  return reimbursementRequests.value?.filter(glc => !glc.archived)
})

onMounted(() => {
  getReimbursementRequests()
  getTheGlCodes()
  getTheBudgetTypes()
  getTheUsersWithBudget()
})

// watch(userSearchText, (val) => {
//   if (!val) {
//     users.value = []
//     newReimbursementRequest.value.userId = null
//     return
//   }
//   userIds.value = []
//   getReimbursementUsersDebounced(val)
// })

const searchGlCodes = (item, queryText) => {
  let data = item.code.toLowerCase() + ' - ' + item.description.toLowerCase()
  return data.includes(queryText.toLowerCase())
}
const removeExpenseItem = (itemTempId) => {
  selectedRequest.value.expenses = selectedRequest.value.expenses.filter((item) => {
    return item.tempId !== itemTempId
  })
}

const getReimbursementRequests = async() => {
  dataLoading.value = true
  try {
    const {data, status} = await getRequest(`/reimbursement/requests/pending`, 'blueraven')
    reimbursementRequests.value = data
    dataLoading.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

  }
}
const deleteReimbursementRequest = async(item) => {
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`/reimbursement/${item.id}`, 'blueraven')
    item.archived = true
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting Reimbursement Request')

    appStore.loading = false
  }
  closeDeleteDialog()
}
const saveReimbursementRequest = async(item, isNew) => {
  appStore.loading = true
  try {
    item.reimbursementRequestStatusId = 1 //override the status to be approved since this came from an admin
    await putRequest(`/reimbursement/request`, item, 'blueraven')
    if (isNew) {
      //do not add the new one to the list cuz it already got approved
      newReimbursementRequest.value = {}
      createNew.value = false
    } else {
      editIndex.value = null
    }
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Reimbursement Request')

    appStore.loading = false
  }
}
const validateAndApprove = async() => {
  if (editRequestForm.value.validate()) {
    await approveRequest()
  }
}
const approveRequest = async() => {
  appStore.loading = true
  try {
    //1 = approve
    selectedRequest.value.reimbursementRequestStatusId = 1
    await putRequest(`/reimbursement/request`, selectedRequest.value, 'blueraven')
    snackbar('SUCCESS', 'Request Approved')

    reimbursementRequests.value = reimbursementRequests.value?.filter(rr => rr.id !== selectedRequest.value.id)
    rejectDropdown.value = false
    selectedRequest.value = {}
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Approving Reimbursement Request')

    appStore.loading = false
  }
}
const rejectRequest = async(item) => {
  appStore.loading = true
  try {
    item.reimbursementRequestStatusId = 2
    const {status} = await postRequest(`/reimbursement/request/updateStatus`, item, 'blueraven')
    snackbar('SUCCESS', 'Request Rejected.')


    selectedRequest.value = {}
    rejectDropdown.value = false
    reimbursementRequests.value = reimbursementRequests.value?.filter(rr => rr.id !== item.id)
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Rejecting Reimbursement Request')

    appStore.loading = false
  }
}
const getTheBudgetTypes = async() => {
  //reset the budget id every time a user or expense date changes
  budgetTypesLoading.value = true
  try {
    const {data, status} = await getBudgetTypes()
    budgetTypes.value = data
    budgetTypesLoading.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

  }
}
const getTheGlCodes = async() => {
  glCodesLoading.value = true
  try {
    const {data, status} = await getGlCodes()
    glCodes.value = data
    glCodesLoading.value = false
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
const getMonthlyBudgetReport = async(isNew) => {
  let selectedBudget = budgetsForUser.value.find(b => b.id === (isNew ? newReimbursementRequest.value.expenseBudgetId : selectedRequest.value.expenseBudgetId))
  if (selectedBudget && selectedBudget.startDate && selectedBudget.endDate) {
    try {
      loadingBudgetReport.value = true
      const {data} = await getRequestWithParams(`/expenseBudgets/getMonthlyBudgetReport`, {
            params: {
              startDate: selectedBudget.startDate,
              endDate: selectedBudget.endDate,
              userId: selectedBudget.userId
            }
          }, 'blueraven'
          , [])
      selectedBudgetReport.value = data && data.length > 0 ? data[0] : []
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Data')

    } finally {
      loadingBudgetReport.value = false
    }
  }
}
const getTheBudgetsForUser = async(userId, doReportLoad, isNew) => {
  budgetsLoading.value = true
  try {
    const {data, status} = await getBudgetsForUser(userId)
    budgetsForUser.value = data
    //dont await  it.value will load separately
    if(doReportLoad) {
      getMonthlyBudgetReport(isNew)
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

  } finally {
    budgetsLoading.value = false
  }
}
const getRequestAttachmentPresignedUrl = async(item) => {
  renderRequestImage.value = false
  appStore.loading = true
  try {
    const {data, status} = await getReimbursementRequestImage(item.id)
    item.presignedUrl = data
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
#reimbursement-requests-container .v-data-table__wrapper {
  height: calc(100vh - 290px);
  min-height: 300px;
}
</style>

<style lang="scss" scoped>
#reimbursement-requests-container {
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

</style>
