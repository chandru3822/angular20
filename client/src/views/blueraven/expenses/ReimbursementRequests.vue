<template>
  <v-container id="reimbursement-requests-container">
    <v-row v-if="!selectedRequest || !selectedRequest.id">
      <v-col cols="12">
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="app-title">Reimbursement Requests</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" @click="[createNew = !createNew, newReimbursementRequest = {expenseBudgetId: null}]">
              <v-icon v-if="!createNew">add</v-icon>
              {{ createNew ? 'cancel' : 'Add Reimbursement Request' }}
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card flat v-if="createNew" class="pa-4">
          <h3>Add Expense Item</h3>
          <v-autocomplete v-model="newReimbursementRequest.userId"
                          :items="users"
                          :loading="usersLoading"
                          :search-input.sync="userSearchText"
                          label="Purchaser"
                          clearable
                          item-text="fullName"
                          item-value="id"
                          autocomplete="off"
                          type="search"
                          @click:clear="users = []"
          ></v-autocomplete>
          <DatetimePickerInput
            v-model="newReimbursementRequest.expenseDate"
            :timezone="timezone"
            :type="'date'"
            :format="'MM/DD/YYYY'"
            label="Expense Date"
            :change-callback="getBudgetTypesForUser"
          />
          <v-autocomplete v-model="newReimbursementRequest.glCodeId"
                          :items="glCodes"
                          label="GL Code"
                          item-text="code"
                          item-value="id"
          >
            <template slot='item' slot-scope='{ item }'>
              {{ item.code }} - {{ item.description }}
            </template>
          </v-autocomplete>
          <v-autocomplete v-model="newReimbursementRequest.expenseBudgetUserId"
                          :items="usersWithBudget"
                          label="Budget User"
                          item-text="fullName"
                          item-value="id"
                          @input="getBudgetTypesForUserNew"
          ></v-autocomplete>
          <v-autocomplete v-model="newReimbursementRequest.expenseBudgetId"
                          :items="budgetTypesForUser"
                          label="Budget Type"
                          item-text="budgetType"
                          item-value="id"
          ></v-autocomplete>
          <v-text-field text
                        type="number"
                        label="Amount"
                        v-model.number="newReimbursementRequest.expenseAmount">
          </v-text-field>
          <label>Notes:</label>
          <v-textarea class="py-2" hide-details
                      auto-grow filled
                      rows="4"
                      background-color="#F2F6F8"
                      v-model="newReimbursementRequest.notes">
          </v-textarea>
          <v-btn color="primary" class="white--text"
                 :disabled="!newReimbursementRequest.userId || !newReimbursementRequest.expenseDate || !newReimbursementRequest.glCodeId
                            || !newReimbursementRequest.expenseBudgetUserId || !newReimbursementRequest.expenseBudgetId || !newReimbursementRequest.expenseAmount"
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
          fixed-header
          :footer-props="footerProps"
          class="elevation-1 fix-column-width-bug square-card"
        >
          <template #no-data>
            No Reimbursement Requests
          </template>

          <template #no-results>
            No Reimbursement Requests
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{ item.createdBy }}</td>
              <td class="text-left">{{ item.positionName }}</td>
              <td class="text-left">{{ item.dateCreated | formatDate('date') }}</td>
              <td class="text-left">{{ item.amount | currency('$', 2) }}</td>
              <td class="text-left">{{ item.budgetType }}</td>
              <td class="text-left">{{ item.expenseBudgetUser }}</td>
              <td class="text-left">{{ item.expenseDate | formatDate('date') }}</td>
              <td>
                <div style="display: flex; justify-content: flex-end">
                  <v-btn small text color="primary" @click="[selectedRequest = item, getRequestAttachmentPresignedUrl(item)]">
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
            <v-btn text @click="selectedRequest = {}">Back</v-btn>
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <div class="pt-3">
              <v-btn @click="approveRequest"
                     :disabled="selectedRequest.expenses.length < 1"
                     color="primary"
                     class="white--text">
                Approve & Submit
              </v-btn>
              <v-menu v-model="rejectDropdown"
                      bottom offset-y min-width="350"
                      :close-on-content-click="false">
                <template #activator="{on}">
                  <v-btn v-on="on" dark color="red" class="ml-3">Reject</v-btn>
                </template>
                <v-card class="pa-5">
                  <label>Reason for Rejection: (required)</label>
                  <v-textarea class="py-2" hide-details
                              auto-grow filled
                              rows="4"
                              background-color="#F2F6F8"
                              v-model="selectedRequest.notes">
                  </v-textarea>
                  <v-btn @click="rejectRequest(selectedRequest.notes)"
                         :disabled="!selectedRequest.notes"
                         class="white--text" color="red">Reject
                  </v-btn>
                  <v-btn class="ml-3" @click="rejectDropdown = false">Cancel</v-btn>
                </v-card>
              </v-menu>
              <v-btn class="ml-3" @click="selectedRequest = {}">Cancel</v-btn>
            </div>
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat class="pa-4">
          <v-row class="px-4">
            <v-col cols="12" sm="5">
              <h3 class="mb-5">Reimbursement Request Details</h3>
              <table>
                <tr>
                  <td class="left-column">Submitted By:</td>
                  <td>{{ selectedRequest.createdBy }}</td>
                </tr>
                <tr>
                  <td class="left-column">Position:</td>
                  <td>{{ selectedRequest.positionName }}</td>
                </tr>
                <tr>
                  <td class="left-column">Amount:</td>
                  <td>{{ selectedRequest.amount | currency('$', 2) }}</td>
                </tr>
                <tr>
                  <td class="left-column">Expense Date:</td>
                  <td>{{ selectedRequest.expenseDate | formatDate('date') }}</td>
                </tr>
                <tr>
                  <td class="left-column">Budget User:</td>
                  <td>{{ selectedRequest.expenseBudgetUser }}</td>
                </tr>
                <tr>
                  <td class="left-column">Budget Type:</td>
                  <td>{{ selectedRequest.budgetType }}</td>
                </tr>
                <tr>
                  <td class="left-column">Request Created On:</td>
                  <td>{{ selectedRequest.dateCreated | formatDate('date') }}</td>
                </tr>
                <tr>
                  <td class="left-column">ID Number:</td>
                  <td>{{ selectedRequest.id }}</td>
                </tr>
                <tr>
                  <td class="left-column">Request Details:</td>
                  <td>
                    <v-card flat class="detail-container">
                      {{ selectedRequest.details }}
                    </v-card>
                  </td>
                </tr>
                <tr>
                  <td class="left-column">Receipt Image:</td>
                  <td class="receipt-image-background">
                    <v-tooltip bottom max-width="300px"
                               v-if="renderRequestImage && selectedRequest.presignedUrl"
                               content-class="receipt-image-tooltip">
                      <template v-slot:activator="{ on:tooltip }">
                        <v-img name="receiptImg" class="receipt-image"
                               v-on="{ ...tooltip }"
                               alt="receipt-image" :src="selectedRequest.presignedUrl"></v-img>
                      </template>
                      <v-card class="receipt-image-hover-container">
                        <img class="receipt-image-hovered" :src="selectedRequest.presignedUrl">
                      </v-card>
                    </v-tooltip>
                  </td>
                </tr>
              </table>
            </v-col>
            <v-col cols="12" sm="7" class="pt-0">
              <v-data-table
                v-if="selectedRequest.expenses.length > 0"
                :headers="expenseHeaders"
                :items="selectedRequest.expenses"
                disable-sort
                :items-per-page="-1"
                :mobile-breakpoint="0"
                hide-default-footer
                class="elevation-0 fix-column-width-bug square-card"
              >
                <template #header.icons="{}">
                  <div class="text-right mr-2">
                    <v-btn text x-small @click="[selectedRequest.expenses.push({
                            tempId: tempIdCount,
                            glCode: null,
                            budgets: []
                          }), tempIdCount++]">
                      <v-icon>add</v-icon>
                    </v-btn>
                  </div>
                </template>

                <template #item="{ item, index }">
                  <tr :class="{'shaded-row': index % 2}">
                    <td class="text-left">
                      <v-autocomplete v-model="item.glCodeId"
                                      :items="glCodes"
                                      label="GL Code"
                                      hide-details
                                      single-line
                                      item-text="code"
                                      item-value="id"
                      >
                        <template slot='item' slot-scope='{ item }'>
                          {{ item.code }} - {{ item.description }}
                        </template>
                      </v-autocomplete>
                    </td>
                    <td class="text-left">
                      <v-autocomplete v-model="item.expenseBudgetUserId"
                                      :items="usersWithBudget"
                                      label="Budget User"
                                      item-text="fullName"
                                      single-line
                                      hide-details
                                      type="search"
                                      item-value="id"
                                      class="clickable"
                                      @input="getBudgetTypesForUser(item, selectedRequest.expenseDate)"
                      ></v-autocomplete>
                    </td>
                    <td class="text-left">
                      <v-autocomplete v-model="item.expenseBudgetId"
                                      :items="budgetTypesForUser"
                                      label="Budget Type"
                                      class="clickable"
                                      hide-details
                                      single-line
                                      item-text="budgetType"
                                      item-value="id"
                      ></v-autocomplete>
                    </td>
                    <td>
                      <v-text-field text
                                    type="number"
                                    hide-details
                                    single-line
                                    label="Amount"
                                    v-model.number="item.expenseAmount">
                      </v-text-field>
                    </td>
                    <td class="text-left px-0">
                      <v-btn x-small v-if="!item.id" fab color="primary" dark
                             @click="removeExpenseItem(item.tempId)">
                        <v-icon>close</v-icon>
                      </v-btn>
                    </td>

                  </tr>
                </template>
              </v-data-table>

            </v-col>
          </v-row>
        </v-card>
      </v-col>
    </v-row>
    <ConfirmationDialog
        :open-confirm-delete-dialog = deleteConfirm
        @confirm-delete=deleteReimbursementRequest(itemToDelete)
        @closeConfirmDeleteDialog="closeDeleteDialog">
      Are you sure you want to delete this Reimbursement Request for <strong>{{ itemToDeleteCreatedBy }}:
      {{ itemToDeleteAmount | currency('$', 2) }}</strong>?
      <template v-slot:no>cancel</template>
      <template v-slot:yes>delete</template>
    </ConfirmationDialog>
  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import {handleHidingGlobalLoader, getRequest, deleteRequest, getRequestWithParams, postRequest, putRequest, getSnackbar} from '@/helpers/helpers'
import constants from "@/helpers/constants";
import {getGlCodes, getReimbursementRequestImage, getUsersWithBudget} from './expenseService'
import DatetimePickerInput from "@/components/DatetimePickerInput"
import ConfirmationDialog from "@/ConfirmationDialog";

export default {
  name: 'ReimbursementRequests',
  components: {
    ConfirmationDialog,
    DatetimePickerInput
  },
  computed: {
    itemToDeleteCreatedBy() {
      return this.itemToDelete ? this.itemToDelete.createdBy : ''
    },
    itemToDeleteAmount() {
      return this.itemToDelete ? this.itemToDelete.amount : 0
    }
  },
  data() {
    return {
      snackbar: {},
      createNew: false,
      newReimbursementRequest: {
        expenseBudgetId: null
      },
      timezone: this.$store.state.user.details.timezone.value,
      selectedRequest: {},
      editIndex: null,
      footerProps: {
        'items-per-page-options': [25, 50, 100, 500],
        'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
      },
      reimbursementRequests: [],
      usersWithBudget: [],
      users: [],
      userId: this.$store.state.user.details.id,
      usersLoading: false,
      userSearchText: null,
      budgetTypesForUser: [],
      glCodes: [],
      headers: [
        {text: 'Rep', value: 'createdBy', show: true},
        {text: 'Position', value: 'positionName', show: true},
        {text: 'Submitted Date', value: 'dateCreated', show: true},
        {text: 'Amount', value: 'amount', show: true},
        {text: 'Budget Type', value: 'budgetType', show: true},
        {text: 'Budget User', value: 'expenseBudgetUser', show: true},
        {text: 'Expense Date', value: 'expenseDate', show: true},
        {text: null, value: 'icons', show: true}
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
      itemToDelete: null
    }
  },
  created() {
    this.getReimbursementRequests()
    this.getGlCodes()
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
    removeExpenseItem(itemTempId) {
      this.selectedRequest.expenses = this.selectedRequest.expenses.filter((item) => {
        return item.tempId !== itemTempId
      })
    },
    filterReimbursementRequests() {
      return this.reimbursementRequests.filter(glc => !glc.archived)
    },
    async getReimbursementRequests() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/reimbursement/requests/pending`, 'blueraven')
        this.reimbursementRequests = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
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
        //not sure what this is yet
        // item.skipApproval = self.skipApproval;
        //there is already an endpoint for lists of these so just sending up as a list
        let listOfItem = [item]
        const {status} = await postRequest(`/expenses/addExpenseItems`, listOfItem, 'blueraven')
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
    async approveRequest() {
      this.glError = false;
      this.budgetError = false;
      this.amountError = false;
      this.selectedRequest.expenses.forEach((item) => {
        if (item.glCodeId == null) {
          this.glError = true
        } else if (item.expenseAmount == null) {
          this.amountError = true
        } else if (item.expenseBudgetUserId == null || (item.expenseBudgetId == null && item.expenseBudgetUserId !== -1)) {
          this.budgetError = true
        } else {
          item.userId = this.selectedRequest.createdById;
          item.expenseDate = this.selectedRequest.expenseDate;
          item.notes = null;
          item.reimbursementRequestId = this.selectedRequest.id
          item.submittedById = this.userId
          item.updatedById = this.userId
        }
      })

      if (this.glError) {
        this.snackbar = getSnackbar('ERROR', 'All Items Must Have a GL Code')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } else if (this.amountError) {
        this.snackbar = getSnackbar('ERROR', 'All Items Must Have an Amount')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } else if (this.budgetError) {
        this.snackbar = getSnackbar('ERROR', 'All Items Must Have a Budget User and Budget Type')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } else {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          //1 = approve
          this.selectedRequest.reimbursementRequestStatusId = 1
          await putRequest(`/reimbursement/request`, this.selectedRequest, 'blueraven')

          await postRequest(`/expenses/addExpenseItems`, this.selectedRequest.expenses, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Request Approved')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          await this.resetPage()
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Approving Reimbursement Request')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    async resetPage() {
      //reload the data cuz things changed that we don't pass back to the UI
      this.selectedRequest = {}
      this.rejectDropdown = false
      await this.getReimbursementRequests()
    },
    async rejectRequest(notes) {
      this.selectedRequest.expenses.forEach(e => {
        e.notes = notes
      })

      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await postRequest(`/expenses/markExpensesRejected`, this.selectedRequest.expenses, 'blueraven')
        this.snackbar = getSnackbar('SUCCESS', 'Expenses Rejected.')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)

        await this.resetPage()
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Rejecting Reimbursement Request')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getBudgetTypesForUserNew() {
      return this.getBudgetTypesForUser(this.newReimbursementRequest, this.newReimbursementRequest.expenseDate)
    },
    async getBudgetTypesForUser(item, expenseDate) {
      //reset the budget id every time a user or expense date changes
      item.expenseBudgetId = null
      if (null != item.expenseBudgetUserId && null != expenseDate) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            userId: item.expenseBudgetUserId,
            expenseDate: expenseDate
          }
          const {data, status} = await getRequestWithParams(`/expenseBudgets/availableForUser`, {params}, 'blueraven')
          this.budgetTypesForUser = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    getReimbursementUsersDebounced(val) {
      clearTimeout(this._searchTimerId)
      this._searchTimerId = setTimeout(() => {
        this.getReimbursementUsers(val)
      }, 500) /* 500ms throttle */
    },
    async getReimbursementUsers() {
      this.usersLoading = true
      try {
        let body = {
          query: this.userSearchText
        }
        const {data} = await postRequest(`/reimbursement/users`, body, 'blueraven')
        this.users = data
        this.usersLoading = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.usersLoading = false
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getGlCodes() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getGlCodes()
        this.glCodes = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getUsersWithBudget() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getUsersWithBudget()
        this.usersWithBudget = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
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
