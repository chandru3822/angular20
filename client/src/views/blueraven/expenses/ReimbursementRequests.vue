<template>
  <v-container id="reimbursement-requests-container">
    <v-row v-if="!selectedRequest || !selectedRequest.id">
      <v-col cols="12">
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="app-title">Reimbursement Requests</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" v-if="userCanAdd"
                   @click="[createNew = !createNew, selectedBudgetReport = {},
                            newReimbursementRequest = {expenseBudgetId: null}]">
              <v-icon v-if="!createNew">add</v-icon>
              <v-icon v-else>close</v-icon>
              <span v-if="!isMobile">
                {{ createNew ? 'cancel' : 'Add Reimbursement Request' }}
              </span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card flat v-if="createNew" class="pa-4">
          <h3>Add Expense Item</h3>
          <!--          <v-autocomplete v-model="newReimbursementRequest.userId"-->
          <!--                          :items="users"-->
          <!--                          :loading="usersLoading"-->
          <!--                          :search-input.sync="userSearchText"-->
          <!--                          label="Purchaser"-->
          <!--                          clearable-->
          <!--                          item-text="fullName"-->
          <!--                          item-value="id"-->
          <!--                          autocomplete="off"-->
          <!--                          type="search"-->
          <!--                          @click:clear="users = []"-->
          <!--          ></v-autocomplete>-->
          <v-autocomplete v-model="newReimbursementRequest.expenseBudgetUserId"
                          :items="usersWithBudget"
                          label="Purchaser"
                          item-text="fullName"
                          item-value="id"
                          @input="[newReimbursementRequest.expenseBudgetId = null, getBudgetsForUser(newReimbursementRequest.expenseBudgetUserId, false, true)]"
          ></v-autocomplete>
          <v-autocomplete v-model="newReimbursementRequest.expenseBudgetId"
                          :items="budgetsForUser"
                          label="Selected Budget"
                          :loading="budgetsLoading"
                          :disabled="!newReimbursementRequest.expenseBudgetUserId"
                          item-text="fullBudgetName"
                          item-value="id"
                          @change="getMonthlyBudgetReport(true)">
          </v-autocomplete>
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
          <v-autocomplete v-model="newReimbursementRequest.glCodeId"
                          :items="glCodes"
                          :loading="glCodesLoading"
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
          <v-autocomplete v-model="newReimbursementRequest.budgetTypeId"
                          :items="budgetTypes"
                          :loading="budgetTypesLoading"
                          label="Budget Type"
                          item-text="name"
                          item-value="id"
          ></v-autocomplete>
          <v-text-field text
                        prepend-icon="mdi-currency-usd"
                        type="number"
                        label="Amount"
                        v-model.number="newReimbursementRequest.amount">
          </v-text-field>
          <label>Notes:</label>
          <v-textarea class="py-2" hide-details
                      auto-grow filled
                      rows="4"
                      background-color="#F2F6F8"
                      v-model="newReimbursementRequest.notes">
          </v-textarea>
          <v-btn color="primary" class="white--text"
                 :disabled="!newReimbursementRequest.expenseDate || !newReimbursementRequest.glCodeId || !newReimbursementRequest.budgetTypeId
                             || !newReimbursementRequest.expenseBudgetId || !newReimbursementRequest.amount"
                 @click="saveReimbursementRequest(newReimbursementRequest, true)">
            Save
          </v-btn>
        </v-card>
        <v-divider v-if="createNew"></v-divider>
        <v-data-table
            :headers="headers"
            :items="filterReimbursementRequests()"
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
                  <v-btn small text color="primary"
                         @click="[selectedRequest = item, getBudgetsForUser(item.expenseBudgetUserId, true, false), getRequestAttachmentPresignedUrl(item)]">
                    <v-icon>edit</v-icon>
                  </v-btn>
                  <v-btn small text color="primary" @click="[deleteConfirm = true, itemToDelete = item]">
                    <v-icon>delete</v-icon>
                  </v-btn>
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
            <v-btn text @click="selectedRequest = {}" color="primary">Back</v-btn>
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <div class="pt-3">
              <v-btn @click="validateAndApprove"
                     color="primary"
                     class="white--text">
                Approve & Submit
              </v-btn>
              <v-menu v-model="rejectDropdown"
                      bottom offset-y min-width="350"
                      :close-on-content-click="false">
                <template #activator="{on}">
                  <v-btn v-on="on" dark color="error" class="ml-3">Reject</v-btn>
                </template>
                <v-card class="pa-5">
                  <label>Reason for Rejection: (required)</label>
                  <v-textarea class="py-2" hide-details
                              auto-grow filled
                              rows="4"
                              background-color="#F2F6F8"
                              v-model="selectedRequest.notes">
                  </v-textarea>
                  <v-btn @click="rejectRequest(selectedRequest)"
                         :disabled="!selectedRequest.notes"
                         class="white--text" color="error">Reject
                  </v-btn>
                  <v-btn class="ml-3" @click="rejectDropdown = false" text color="primary">Cancel</v-btn>
                </v-card>
              </v-menu>
              <v-btn class="ml-3" @click="selectedRequest = {}" text color="primary">Cancel</v-btn>
            </div>
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat class="px-4">
          <v-row class="px-4">
            <v-col cols="12" sm="5">
              <h3 class="mb-5">Reimbursement Request Details</h3>
              <v-form ref="editRequestForm">
                <v-autocomplete v-model="selectedRequest.expenseBudgetUserId"
                                :items="usersWithBudget"
                                label="Purchaser"
                                :rules="requiredRules"
                                item-text="fullName"
                                item-value="id"
                                @input="[selectedRequest.expenseBudgetId = null, getBudgetsForUser(selectedRequest.expenseBudgetUserId)]"
                ></v-autocomplete>
                <v-autocomplete v-model="selectedRequest.expenseBudgetId"
                                :items="budgetsForUser"
                                label="Selected Budget"
                                :rules="requiredRules"
                                :loading="budgetsLoading"
                                :disabled="!selectedRequest.expenseBudgetUserId"
                                item-text="fullBudgetName"
                                item-value="id"
                                @change="getMonthlyBudgetReport(false)"
                >
                </v-autocomplete>
                <DatetimePickerInput
                    v-model="selectedRequest.expenseDate"
                    :timezone="timezone"
                    :type="'date'"
                    :required="true"
                    :format="'MM/DD/YYYY'"
                    label="Expense Date"
                />
                <v-autocomplete v-model="selectedRequest.glCodeId"
                                :items="glCodes"
                                label="GL Code"
                                :rules="requiredRules"
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
                <v-autocomplete v-model="selectedRequest.budgetTypeId"
                                :items="budgetTypes"
                                label="Budget Type"
                                :rules="requiredRules"
                                item-text="name"
                                item-value="id"
                ></v-autocomplete>
                <v-text-field text
                              type="number"
                              label="Amount"
                              prepend-icon="mdi-currency-usd"
                              :rules="requiredRules"
                              v-model.number="selectedRequest.amount">
                </v-text-field>
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

<script>
import {AppMutations} from '@/stores/AppStore'
import {
  handleHidingGlobalLoader,
  getRequest,
  deleteRequest,
  getRequestWithParams,
  postRequest,
  putRequest,
  getSnackbar
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

export default {
  name: 'ReimbursementRequests',
  components: {
    BudgetReportTable,
    ConfirmationDialog,
    DatetimePickerInput,
    SpinnerInline
  },
  computed: {
    itemToDeleteCreatedBy() {
      return this.itemToDelete ? this.itemToDelete.createdBy : ''
    },
    itemToDeleteAmount() {
      return this.itemToDelete ? this.itemToDelete.amount : 0
    },
    isMobile(){
      return this.$vuetify.breakpoint.smAndDown
    }
  },
  data() {
    return {
      snackbar: {},
      createNew: false,
      dataLoading: true,
      budgetsLoading: false,
      userCanAdd: this.$store.getters.userHasFeatureAccessLevel('EXPENSES', 'ADD'),
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('EXPENSES', 'EDIT'),
      newReimbursementRequest: {
        expenseBudgetId: null
      },
      requiredRules: constants.BASIC_REQUIRED_RULE,
      timezone: this.$store.state.user.details.timezone.value,
      selectedRequest: {},
      editIndex: null,
      footerProps: {
        'items-per-page-options': [25, 50, 100, 500],
        'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
      },
      reimbursementRequests: [],
      budgetsForUser: [],
      selectedBudgetReport: {},
      loadingBudgetReport: true,
      usersWithBudget: [],
      userId: this.$store.state.user.details.id,
      budgetTypes: [],
      glCodes: [],
      headers: [
        {text: 'Purchaser', value: 'expenseBudgetUser', show: true, width: '125px'},
        {text: 'Created Date', value: 'dateCreated', show: true, width: '125px'},
        {text: 'Amount', value: 'amount', show: true, width: '75px'},
        {text: 'Budget Type', value: 'budgetType', show: true, width: '125px'},
        {text: 'Expense Date', value: 'expenseDate', show: true, width: '125px'},
        {text: null, value: 'icons', show: true, width: '80px'}
      ],
      tempIdCount: 0,
      expenseHeaders: [
        {text: 'GL Code', value: 'glCode', show: true},
        {text: 'Budget User', value: 'budgetUser', show: true},
        {text: 'Budget Type', value: 'budgetType', show: true},
        {text: 'Amount', value: 'amount', show: true},
        {text: null, value: 'icons', show: true, width: '50px'}
      ],
      rejectDropdown: false,
      glError: false,
      budgetError: false,
      amountError: false,
      renderRequestImage: false,
      deleteConfirm: false,
      budgetTypesLoading: true,
      glCodesLoading: true,
      itemToDelete: null
    }
  },
  created() {
    this.getReimbursementRequests()
    this.getGlCodes()
    this.getBudgetTypes()
    this.getUsersWithBudget()
  },
  watch: {
    userSearchText(val) {
      if (!val) {
        this.users = []
        this.newReimbursementRequest.userId = null
        return
      }
      this.userIds = []
      this.getReimbursementUsersDebounced(val)
    },
  },
  methods: {
    searchGlCodes(item, queryText) {
      let data = item.code.toLowerCase() + ' - ' + item.description.toLowerCase()
      return data.includes(queryText.toLowerCase())
    },
    removeExpenseItem(itemTempId) {
      this.selectedRequest.expenses = this.selectedRequest.expenses.filter((item) => {
        return item.tempId !== itemTempId
      })
    },
    filterReimbursementRequests() {
      return this.reimbursementRequests?.filter(glc => !glc.archived)
    },
    async getReimbursementRequests() {
      this.dataLoading = true
      try {
        const {data, status} = await getRequest(`/reimbursement/requests/pending`, 'blueraven')
        this.reimbursementRequests = data
        this.dataLoading = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async deleteReimbursementRequest(item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await deleteRequest(`/reimbursement/${item.id}`, 'blueraven')
        item.archived = true
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Reimbursement Request')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
      this.closeDeleteDialog()
    },
    async saveReimbursementRequest(item, isNew) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        item.reimbursementRequestStatusId = 1 //override the status to be approved since this came from an admin
        await putRequest(`/reimbursement/request`, item, 'blueraven')
        if (isNew) {
          //do not add the new one to the list cuz it already got approved
          this.newReimbursementRequest = {}
          this.createNew = false
        } else {
          this.editIndex = null
        }
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Reimbursement Request')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async validateAndApprove() {
      if (this.$refs.editRequestForm.validate()) {
        await this.approveRequest()
      }
    },
    async approveRequest() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        //1 = approve
        this.selectedRequest.reimbursementRequestStatusId = 1
        await putRequest(`/reimbursement/request`, this.selectedRequest, 'blueraven')
        this.snackbar = getSnackbar('SUCCESS', 'Request Approved')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.reimbursementRequests = this.reimbursementRequests?.filter(rr => rr.id !== this.selectedRequest.id)
        this.rejectDropdown = false
        this.selectedRequest = {}
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Approving Reimbursement Request')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async rejectRequest(item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        item.reimbursementRequestStatusId = 2
        const {status} = await postRequest(`/reimbursement/request/updateStatus`, item, 'blueraven')
        this.snackbar = getSnackbar('SUCCESS', 'Request Rejected.')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)

        this.selectedRequest = {}
        this.rejectDropdown = false
        this.reimbursementRequests = this.reimbursementRequests?.filter(rr => rr.id !== item.id)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Rejecting Reimbursement Request')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getBudgetTypes() {
      //reset the budget id every time a user or expense date changes
      this.budgetTypesLoading = true
      try {
        const {data, status} = await getBudgetTypes()
        this.budgetTypes = data
        this.budgetTypesLoading = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getGlCodes() {
      this.glCodesLoading = true
      try {
        const {data, status} = await getGlCodes()
        this.glCodes = data
        this.glCodesLoading = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getUsersWithBudget() {
      try {
        const {data, status} = await getUsersWithBudget()
        this.usersWithBudget = data
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getMonthlyBudgetReport(isNew) {
      let selectedBudget = this.budgetsForUser.find(b => b.id === (isNew ? this.newReimbursementRequest.expenseBudgetId : this.selectedRequest.expenseBudgetId))
      if (selectedBudget && selectedBudget.startDate && selectedBudget.endDate) {
        try {
          this.loadingBudgetReport = true
          const {data} = await getRequestWithParams(`/expenseBudgets/getMonthlyBudgetReport`, {
                params: {
                  startDate: selectedBudget.startDate,
                  endDate: selectedBudget.endDate,
                  userId: selectedBudget.userId
                }
              }, 'blueraven'
              , [])
          this.selectedBudgetReport = data && data.length > 0 ? data[0] : []
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } finally {
          this.loadingBudgetReport = false
        }
      }
    },
    async getBudgetsForUser(userId, doReportLoad, isNew) {
      this.budgetsLoading = true
      try {
        const {data, status} = await getBudgetsForUser(userId)
        this.budgetsForUser = data
        //dont await this. it will load separately
        if(doReportLoad) {
          this.getMonthlyBudgetReport(isNew)
        }
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } finally {
        this.budgetsLoading = false
      }
    },
    async getRequestAttachmentPresignedUrl(item) {
      this.renderRequestImage = false
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getReimbursementRequestImage(item.id)
        item.presignedUrl = data
        //this forces the dom to re-render the presignedUrl and i hate myself
        this.renderRequestImage = true
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Attached Image')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },

    closeDeleteDialog() {
      this.deleteConfirm = false
      this.itemToDelete = null
    }
  }
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
