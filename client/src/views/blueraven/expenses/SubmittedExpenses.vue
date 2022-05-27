<template>
  <v-container id="submitted-expense-container">
    <v-row v-if="!selectedExpense || !selectedExpense.id">
      <v-col cols="12">
        <v-card flat color="white" class="pa-5">
          <div class="flex-display">
            <div class="left-header-bar">
              <v-toolbar-title class="app-title">
                Submitted Expenses - {{ showAll ? 'In Range' : 'All Unpaid' }}
              </v-toolbar-title>
              <v-text-field
                v-model="userSearchText"
                prepend-inner-icon="search"
                label="Search"
                single-line
                class="mt-5"
                hide-details
              ></v-text-field>
              <div>
                <v-btn color="primaryCustom"
                       @click="exportExpenses"
                       :disabled="selectedExpenses.length === 0"
                       class="white--text" small>
                  Export Selected
                </v-btn>
                <v-btn color="primaryCustom" class="white--text ml-4" small
                       :disabled="!showAll"
                       @click="[rangeChanged = false, selectedExpenses = [], showAll = false, getSubmittedExpenses(false)]">
                  {{ showAll ? 'Show Unpaid' : 'Showing Unpaid'}}
                </v-btn>
              </div>
            </div>
            <v-spacer></v-spacer>
            <div class="middle-header-bar">
              <v-menu v-model="paymentDropdown"
                      v-if="selectedExpenses.length > 0 && canPay"
                      bottom offset-y min-width="350"
                      :close-on-content-click="false">
                <template #activator="{on}">
                  <v-btn v-on="on" dark color="primaryCustom" class="ml-3">Mark as Paid</v-btn>
                </template>
                <v-card class="pa-5">
                  <v-card-title>
                    <span class="text-h5">Confirm</span>
                  </v-card-title>

                  <v-card-text>
                    Are you sure you want to pay all selected expenses?
                  </v-card-text>

                  <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn color="secondaryButton" text @click="paymentDropdown = false">Cancel</v-btn>
                    <v-btn color="primaryCustom" class="white--text" raised
                           :disabled="paymentConfirmLoading"
                           @click="confirmPayment()">Yes
                    </v-btn>
                  </v-card-actions>
                </v-card>
              </v-menu>
              <v-menu v-model="approveDropdown"
                      v-if="selectedExpenses.length > 0 && canApprove"
                      bottom offset-y min-width="350"
                      :close-on-content-click="false">
                <template #activator="{on}">
                  <v-btn v-on="on" dark small color="primaryCustom" class="ml-3">Approve</v-btn>
                </template>
                <v-card class="pa-5">
                  <v-card-title>
                    <span class="text-h5">Confirm</span>
                  </v-card-title>

                  <v-card-text>
                    Are you sure you want to approve all selected expenses?
                  </v-card-text>

                  <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn color="secondaryButton" text @click="approveDropdown = false">Cancel</v-btn>
                    <v-btn color="primaryCustom" class="white--text" raised
                           :disabled="approveConfirmLoading"
                           @click="confirmApproval()">Yes
                    </v-btn>
                  </v-card-actions>
                </v-card>
              </v-menu>
              <v-menu v-model="rejectDropdown"
                      v-if="selectedExpenses.length > 0 && canReject"
                      bottom offset-y min-width="350"
                      :close-on-content-click="false">
                <template #activator="{on}">
                  <v-btn v-on="on" small dark color="red" class="ml-3">Reject</v-btn>
                </template>
                <v-card class="pa-5">
                  <label>Reason for Rejection: (required)</label>
                  <v-textarea class="py-2" hide-details
                              auto-grow filled
                              rows="4"
                              background-color="#F2F6F8"
                              v-model="rejectionReason">
                  </v-textarea>
                  <v-btn class="mr-3" @click="rejectDropdown = false">Cancel</v-btn>
                  <v-btn @click="confirmRejection()"
                         :disabled="!rejectionReason || rejectConfirmLoading"
                         class="white--text" color="red">Reject
                  </v-btn>
                </v-card>
              </v-menu>
            </div>
            <v-spacer></v-spacer>
            <div class="right-header-bar elevation-1">
              <div class="flex-display">
                <DatetimePickerInput v-model="startDate"
                                     :timezone="timezone"
                                     :maxDate="endDate"
                                     :type="'date'"
                                     label="From"
                                     hide-details
                                     @input="changeRange()"
                                     custom-class="expense-range-selector mr-3"
                ></DatetimePickerInput>
                <DatetimePickerInput v-model="endDate"
                                     :timezone="timezone"
                                     :minDate="startDate"
                                     :type="'date'"
                                     label="To"
                                     hide-details
                                     @input="changeRange()"
                                     custom-class="expense-range-selector ml-5"
                ></DatetimePickerInput>
              </div>
              <v-btn color="primaryCustom" class="white--text mt-2" small
                     :disabled="(showAll && !rangeChanged) || !startDate || !endDate"
                     @click="[rangeChanged = false, selectedExpenses = [], showAll = true, getSubmittedExpenses(true)]">
                {{ showAll && !rangeChanged ? 'Showing All in Range' : 'Show All in Range'}}
              </v-btn>
              <v-btn color="primaryCustom" class="white--text mt-2" small
                     @click="exportExpenses(5)">
                Export Paid in Range
              </v-btn>
              <v-btn color="primaryCustom" class="white--text mt-2" small
                     @click="exportExpenses(-1)">
                Export All in Range
              </v-btn>
            </div>
          </div>
        </v-card>
        <v-divider></v-divider>

        <div class="submitted-expense-table-container">
          <v-data-table
            :headers="headers"
            :items="filterSubmittedExpenses()"
            :search="userSearchText"
            :items-per-page="100"
            :mobile-breakpoint="0"
            disable-sort
            :footer-props="footerProps"
            fixed-header
            class="elevation-1 fix-column-width-bug square-card submitted-expense-table"
          >
            <template #no-data>
              No Matching Expenses Found
            </template>

            <template #no-results>
              No Matching Expenses Found
            </template>

            <template #header.selectBox="{}">
              <v-checkbox v-model="selectAllExpenses" @change="toggleSelectAllExpenses()"></v-checkbox>
            </template>

            <template #item="{ item, index }">
              <tr :class="{'shaded-row': index % 2}">
                <td>
                  <v-checkbox v-model="item.selected" @change="toggleSingleSelect(item)"></v-checkbox>
                </td>
                <td class="text-left">{{ item.createdBy }}</td>
                <td class="text-left">{{ item.positionName }}</td>
                <td class="text-left">{{ item.expenseAmount | currency('$', 2) }}</td>
                <td class="text-left">{{ item.expenseDate | formatDate('date') }}</td>
                <td class="text-left">{{ item.glCode }}</td>
                <td class="text-left">{{ item.budgetType }}</td>
                <td class="text-left">{{ item.expenseBudgetUser }}</td>
                <td class="text-left">{{ item.dateCreated | formatDate('date') }}</td>
                <td class="text-left">{{ item.createdBy }}</td>
                <td class="text-left">{{ item.dateSubmitted | formatDate('date') }}</td>
                <td class="text-left">{{ item.submittedBy }}</td>
                <td class="text-left">{{ item.approvalDate | formatDate('date') }}</td>
                <td class="text-left">{{ item.approvedBy }}</td>
                <td class="text-left">{{ item.paidDate | formatDate('date') }}</td>
                <td class="text-left">{{ item.paidBy }}</td>
                <td>
                  <div style="display: flex; justify-content: flex-end">
                    <v-btn small text
                           @click="[selectedExpense = item, getRequestAttachmentPresignedUrl(item), getGlCodes(), getUsersWithBudget(), getBudgetTypesForUser(selectedExpense, selectedExpense.expenseDate)]">
                      <v-icon>edit</v-icon>
                    </v-btn>
                    <v-dialog
                      v-model="item.deleteConfirm"
                      width="500">
                      <template #activator="{ on }">
                        <v-btn small text v-on="on">
                          <v-icon>delete</v-icon>
                        </v-btn>
                      </template>
                      <v-card>
                        <v-card-title
                          class="text-h5 grey lighten-2"
                          primary-title>
                          Confirm
                        </v-card-title>

                        <v-card-text class="pt-4">
                          Are you sure you want to delete this Submitted Expense for <strong>{{ item.createdBy }}:
                          {{ item.amount | currency('$', 2) }}</strong>?
                        </v-card-text>

                        <v-divider></v-divider>

                        <v-card-actions>
                          <v-spacer></v-spacer>
                          <v-btn
                            @click="item.deleteConfirm = false">
                            No
                          </v-btn>
                          <v-btn
                            color="primaryCustom"
                            text
                            @click="deleteSubmittedExpense(item)">
                            Yes
                          </v-btn>
                        </v-card-actions>
                      </v-card>
                    </v-dialog>
                  </div>
                </td>
              </tr>
            </template>
          </v-data-table>
        </div>
      </v-col>
    </v-row>
    <v-row v-else>
      <v-col cols="12">
        <v-toolbar flat class="cfg-header-bar" dense>
          <v-toolbar-title class="app-title">
            <v-btn text @click="selectedExpense = {}">Back</v-btn>
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat class="px-5">
          <v-card-text class="py-1">
            <v-text-field text
                          :disabled="true"
                          label="Purchaser"
                          v-model="selectedExpense.createdBy">
            </v-text-field>
            <DatetimePickerInput
              v-model="selectedExpense.expenseDate"
              :timezone="timezone"
              :type="'date'"
              :readonly="selectedExpense.approvalDate !== null"
              :format="'MM/DD/YYYY'"
              label="Expense Date"
            />
            <v-autocomplete v-model="selectedExpense.glCodeId"
                            :items="glCodes"
                            label="GL Code"
                            :disabled="selectedExpense.approvalDate !== null"
                            item-text="code"
                            item-value="id"
            >
              <template slot='item' slot-scope='{ item }'>
                {{ item.code }} - {{ item.description }}
              </template>
            </v-autocomplete>
            <v-autocomplete v-model="selectedExpense.expenseBudgetUserId"
                            :items="usersWithBudget"
                            label="Budget User"
                            :disabled="selectedExpense.approvalDate !== null"
                            item-text="fullName"
                            item-value="id"
                            @input="getBudgetTypesForUser(selectedExpense, selectedExpense.expenseDate)"
            ></v-autocomplete>
            <v-autocomplete v-model="selectedExpense.expenseBudgetId"
                            :items="budgetTypesForUser"
                            label="Budget Type"
                            :disabled="selectedExpense.approvalDate !== null"
                            item-text="budgetType"
                            item-value="id"
            ></v-autocomplete>
            <v-text-field text
                          type="number"
                          :disabled="selectedExpense.approvalDate !== null"
                          label="Amount"
                          v-model.number="selectedExpense.expenseAmount">
            </v-text-field>
            <v-text-field text
                          :disabled="true"
                          label="ID Number"
                          v-model.number="selectedExpense.reimbursementRequestId">
            </v-text-field>
            <label>Details:</label>
            <v-textarea class="py-2" hide-details
                        auto-grow filled
                        :disabled="true"
                        rows="4"
                        background-color="#F2F6F8"
                        v-model="selectedExpense.reimbursementRequestDetails">
            </v-textarea>
            <label>Notes:</label>
            <v-textarea class="py-2" hide-details
                        auto-grow filled
                        :disabled="selectedExpense.approvalDate !== null"
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
            <v-btn color="secondaryButton" text @click="selectedExpense = {}">Cancel</v-btn>
            <v-btn color="primaryCustom" class="white--text" raised
                   :disabled="selectedExpense.approvalDate !== null || !selectedExpense.expenseDate || !selectedExpense.glCodeId
                            || !selectedExpense.expenseBudgetUserId || !selectedExpense.expenseBudgetId || !selectedExpense.expenseAmount"
                   @click="saveSubmittedExpense(selectedExpense)">Save Changes
            </v-btn>
          </v-card-actions>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import {
  handleHidingGlobalLoader,
  deleteRequest,
  getRequestWithParams,
  postRequest,
  putRequest,
  getSnackbar
} from '@/helpers/helpers'
import constants from "@/helpers/constants";
import {getGlCodes, getReimbursementRequestImage, getUsersWithBudget} from './expenseService'
import DatetimePickerInput from "@/components/DatetimePickerInput"
import moment from 'moment'
import {saveAs} from 'file-saver'
import cloneDeep from 'lodash.clonedeep'

export default {
  name: 'SubmittedExpenses',
  components: {
    DatetimePickerInput
  },
  computed: {},
  data() {
    return {
      snackbar: {},
      timezone: this.$store.state.user.details.timezone.value,
      selectedExpense: {},
      approveDropdown: false,
      approveConfirmLoading: false,
      paymentDropdown: false,
      paymentConfirmLoading: false,
      rejectDropdown: false,
      rejectConfirmLoading: false,
      rejectionReason: '',
      editIndex: null,
      renderRequestImage: false,
      footerProps: {
        'items-per-page-options': [25, 50, 100, 500],
        'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
      },
      masterExpenses: [],
      submittedExpenses: [],
      usersWithBudget: [],
      users: [],
      userId: this.$store.state.user.details.id,
      usersLoading: false,
      userSearchText: '',
      budgetTypesForUser: [],
      selectedExpenses: [],
      selectAllExpenses: false,
      glCodes: [],
      headers: [
        {text: '', value: 'selectBox', selectFilter: true, show: true, width: '50px'},
        {text: 'Rep', value: 'createdBy', show: true},
        {text: 'Position', value: 'positionName', show: true},
        {text: 'Amount', value: 'amount', show: true},
        {text: 'Expense Date', value: 'expenseDate', show: true},
        {text: 'GL Code', value: 'glCode', show: true},
        {text: 'Budget Type', value: 'budgetType', show: true},
        {text: 'Budget User', value: 'expenseBudgetUser', show: true},
        {text: 'Submitted Date', value: 'dateCreated', show: true},
        {text: 'Submitted By', value: 'createdBy', show: true},
        {text: 'Reviewed Date', value: 'reviewedDate', show: true},
        {text: 'Reviewed By', value: 'reviewedBy', show: true},
        {text: 'Approved Date', value: 'approvedDate', show: true},
        {text: 'Approved By', value: 'approvedBy', show: true},
        {text: 'Paid Date', value: 'paidDate', show: true},
        {text: 'Paid By', value: 'paidBy', show: true},
        {text: null, value: 'icons', show: true}
      ],
      showAll: false,
      rangeChanged: false,
      startDate: moment().startOf('month').format('YYYY-MM-DD'),
      endDate: moment().endOf('month').format('YYYY-MM-DD'),
      canReject: true,
      canApprove: true,
      canPay: true
    }
  },
  created() {
    this.getSubmittedExpenses()
  },
  methods: {
    changeRange() {
      console.log('got here')
      this.rangeChanged = true
    },
    toggleSelectAllExpenses() {
      //reset these values first
      this.canApprove = true
      this.canReject = true
      this.canPay = true

      if (this.selectAllExpenses) {
        this.selectedExpenses = cloneDeep(this.masterExpenses)
      } else {
        this.selectedExpenses = []
      }

      this.submittedExpenses.forEach(item => {
        item.selected = this.selectAllExpenses

        if (!item.approvalDate) {
          //if any selected do not have an approved date they cannot pay
          this.canPay = false
        }
        if (item.approvalDate != null) {
          //if any selected have an approved date they cannot reject or approve
          this.canReject = false
          this.canApprove = false
        }
        if (item.paidDate != null) {
          //if any selected have a paid date they cannot do anything
          this.canReject = false
          this.canApprove = false
          this.canPay = false
        }
      })
    },
    toggleSingleSelect(item) {
      //reset these values first
      this.canApprove = true
      this.canReject = true
      this.canPay = true

      //set the selected item
      if (item.selected) {
        this.selectedExpenses.push(item)
      } else {
        this.selectedExpenses = this.selectedExpenses.filter(u => u.id !== item.id)
        this.selectAllExpenses = false
      }

      this.selectedExpenses.forEach(item => {
        if (!item.approvalDate) {
          //if any selected do not have an approved date they cannot pay
          this.canPay = false
        }
        if (item.approvalDate != null) {
          //if any selected have an approved date they cannot reject or approve
          this.canReject = false
          this.canApprove = false
        }
        if (item.paidDate != null) {
          //if any selected have a paid date they cannot do anything
          this.canReject = false
          this.canApprove = false
          this.canPay = false
        }
      })
    },
    filterSubmittedExpenses() {
      return this.submittedExpenses.filter(glc => !glc.archived)
    },
    async getSubmittedExpenses(showAll) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let date1 = moment(this.startDate).format('MM/DD/YYYY')
        let date2 = moment(this.endDate).format('MM/DD/YYYY')
        let url = showAll ? `/expenses/list` : `/expenses/unpaid`
        const {data, status} = await getRequestWithParams(url, {
          params: {
            startDate: date1,
            endDate: date2
          }
        }, 'blueraven')
        this.submittedExpenses = data
        this.masterExpenses = cloneDeep(data)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteSubmittedExpense(item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await deleteRequest(`/expenses/${item.id}`, 'blueraven')
        item.archived = true
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Submitted Expense')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async exportExpenses(typeId) {
      //not sure what these type Ids were, i just copied this over
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let filename = 'selected-expenses.csv'
        let results = []
        if (typeId != null) {
          filename = typeId === 5 ? 'paid-expenses.csv' : 'expenses.csv'
          let url = typeId === 5 ? '/expenses/paid' : '/expenses/list'
          let date1 = moment(this.startDate).format('MM/DD/YYYY')
          let date2 = moment(this.endDate).format('MM/DD/YYYY')
          const {data} = await getRequestWithParams(url, {params: {startDate: date1, endDate: date2}}, 'blueraven')
          results = data
        } else {
          results = cloneDeep(this.selectedExpenses)
        }

        let csvData = this.getCsvHeaders()
        csvData += '\n'

        results.forEach(r => {
          let approvedDate = null

          if (r.approvalDate) {
            approvedDate = moment(r.approvalDate).format('MM/DD/YYYY h:mm a')
          } else if (r.skipApproval) {
            approvedDate = 'Not Required'
          }

          let paidDate = null
          if (r.paidDate) {
            paidDate = moment(r.paidDate).format('MM/DD/YYYY h:mm a')
          } else if (r.skipApproval) {
            paidDate = 'Not Required'
          }

          csvData +=
            r.createdBy + ',' +
            r.positionName + ',' +
            r.expenseAmount + ',' +
            moment.utc(r.expenseDate).format('MM/DD/YYYY') + ',' +
            r.glCode + ',' +
            r.budgetType + ',' +
            r.expenseBudgetUser + ',' +
            moment.utc(r.dateCreated).format('MM/DD/YYYY') + ',' +
            r.createdBy + ',' +
            `${r.dateSubmitted ? moment.utc(r.dateSubmitted).format('MM/DD/YYYY') : null}` + ',' +
            r.submittedBy + ',' +
            approvedDate + ',' +
            `${r.skipApproval ? 'Not Required' : r.approvedBy}` + ',' +
            paidDate + ',' +
            `${r.skipApproval ? 'Not Required' : r.paidBy}` + ',' +
            '"' + r.reimbursementRequestDetails + '"'

          csvData += '\n'

        })
        let blob = new Blob([csvData], {
          type: 'text/csv;charset=utf-8'
        });

        saveAs(blob, filename);
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Exporting Selected Expenses')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }

    },
    getCsvHeaders() {
      return [
        'Rep',
        'Position',
        'Amount',
        'Expense Date',
        'GL Code',
        'Budget Type',
        'Budget User',
        'Submitted Date',
        'Submitted By',
        'Reviewed Date',
        'Reviewed By',
        'Approved Date',
        'Approved By',
        'Paid Date',
        'Paid By',
        'Details'
      ]
    },
    async confirmApproval() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      this.approveConfirmLoading = true
      try {
        await postRequest(`/expenses/markExpensesApproved`, this.selectedExpenses, 'blueraven')
        //coolness
        window.location.reload()
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Approving Selected Expenses')
        this.approveConfirmLoading = false
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async confirmPayment() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      this.paymentConfirmLoading = true
      try {
        await postRequest(`/expenses/markExpensesPaid`, this.selectedExpenses, 'blueraven')
        //coolness
        window.location.reload()
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Marking Selected Expenses as Paid')
        this.paymentConfirmLoading = false
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async confirmRejection() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      this.rejectConfirmLoading = true
      try {
        this.selectedExpenses.forEach(e => {
          e.notes = this.rejectionReason
        })
        await postRequest(`/expenses/markExpensesRejected`, this.selectedExpenses, 'blueraven')
        //coolness
        window.location.reload()
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Rejecting Selected Expenses')
        this.rejectConfirmLoading = false
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveSubmittedExpense(item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await putRequest(`/expenses`, item, 'blueraven')
        //yep
        window.location.reload()
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Changes to Expense')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getBudgetTypesForUser(item, expenseDate, reloadForChange) {
      //reset the budget id if they change it but not if loading for the first time on this screen
      if (reloadForChange) {
        item.expenseBudgetId = null
      }
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
        const {data, status} = await getReimbursementRequestImage(item.reimbursementRequestId)
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
  }
}
</script>

<style lang="scss">
#submitted-expense-container .v-data-table__wrapper {
  height: calc(100vh - 450px);
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
  text-align: right;
  flex-direction: column;
  justify-content: space-between;
}

.middle-header-bar {
  display: flex;
  align-items: end;
}
</style>
