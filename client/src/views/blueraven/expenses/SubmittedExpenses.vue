<template>
  <v-container id="submitted-expense-container">
    <v-row v-if="!selectedExpense || !selectedExpense.id">
      <v-col cols="12">
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="app-title">Submitted Expenses</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <div class="pt-5">
              <v-btn color="primaryCustom"
                     v-if="selectedExpenses.length > 0 && canPay"
                     class="white--text">
                Mark as Paid
              </v-btn>
              <v-btn color="primaryCustom"
                     v-if="selectedExpenses.length > 0 && canApprove"
                     class="white--text ml-5">
                Approve
              </v-btn>
              <v-btn color="red"
                     v-if="selectedExpenses.length > 0 && canReject"
                     class="white--text ml-5">
                Reject
              </v-btn>
              <v-btn color="primaryCustom"
                     @click="exportExpenses"
                     :disabled="selectedExpenses.length === 0"
                     class="white--text ml-5">
                Export Selected
              </v-btn>
            </div>
          </v-toolbar-items>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <div class="flex-display pt-5">
              <DatetimePickerInput v-model="startDate"
                                   :timezone="timezone"
                                   :maxDate="endDate"
                                   :type="'date'"
                                   label="From"
                                   hide-details
                                   custom-class="expense-range-selector"
              ></DatetimePickerInput>
              <DatetimePickerInput v-model="endDate"
                                   :timezone="timezone"
                                   :minDate="startDate"
                                   :type="'date'"
                                   label="To"
                                   hide-details
                                   custom-class="expense-range-selector ml-5"
              ></DatetimePickerInput>
              <v-btn color="primaryCustom" class="white--text ml-5"
                     @click="[showAll = !showAll, getSubmittedExpenses()]">
                {{ showButtonText }}
              </v-btn>
              <v-btn color="primaryCustom" class="white--text ml-5"
                     @click="exportExpenses(5)">
                Export Paid
              </v-btn>
              <v-btn color="primaryCustom" class="white--text ml-5"
                     @click="exportExpenses(-1)">
                Export All
              </v-btn>
            </div>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>

        <v-data-table
          :headers="headers"
          :items="filterSubmittedExpenses()"
          :items-per-page="-1"
          :mobile-breakpoint="0"
          disable-sort
          fixed-header
          class="elevation-1 fix-column-width-bug square-card"
        >
          <template #no-data>
            No Submitted Expenses
          </template>

          <template #no-results>
            No Submitted Expenses
          </template>

          <template #header.selectBox="{}">
            <v-checkbox v-model="selectAllExpenses" @change="toggleSelectAllExpenses()"></v-checkbox>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td><v-checkbox v-model="item.selected" @change="toggleSingleSelect(item)"></v-checkbox></td>
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
                  <v-btn small text @click="selectedExpense = item">
                    <v-icon>edit</v-icon>
                  </v-btn>
                  <v-btn small text @click="saveSubmittedExpense(item, false)" v-if="index === editIndex">
                    <v-icon>save</v-icon>
                  </v-btn>
                  <v-btn small text @click="editIndex = null" v-if="index === editIndex">
                    cancel
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
                        class="headline grey lighten-2"
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
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import {getRequest, deleteRequest, getRequestWithParams, postRequest, putRequest, getSnackbar} from '@/helpers/helpers'
import constants from "@/helpers/constants";
import {getGlCodes, getUsersWithBudget} from './expenseService'
import DatetimePickerInput from "@/components/DatetimePickerInput"
import moment from 'moment'
import { saveAs } from 'file-saver'
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
      editIndex: null,
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
      userSearchText: null,
      budgetTypesForUser: [],
      selectedExpenses: [],
      selectAllExpenses: false,
      glCodes: [],
      headers: [
        { text: '', value: 'selectBox', selectFilter:true, show: true, width: '50px' },
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
      showButtonText: "Show Paid",
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
    toggleSelectAllExpenses() {
      //reset these values first
      this.canApprove = true
      this.canReject = true
      this.canPay = true

      if (this.selectAllExpenses) {
        this.selectedExpenses = cloneDeep(this.masterExpenses)
      }
      else {
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
    filterSubmittedExpenses () {
      return this.submittedExpenses.filter(glc => !glc.archived)
    },
    async getSubmittedExpenses() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let date1 = moment(this.startDate).format('MM/DD/YYYY')
        let date2 = moment(this.endDate).format('MM/DD/YYYY')
        let url = this.showAll ? `/expenses/list` : `/expenses/unpaid`
        this.showButtonText = this.showAll ? 'Show Unpaid' : 'Show All'
        const {data} = await getRequestWithParams(url, {params: {startDate: date1, endDate: date2}}, 'blueraven')
        this.submittedExpenses = data
        this.masterExpenses = cloneDeep(data)
        this.$store.commit(AppMutations.SET_LOADING, false)
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
        await deleteRequest(`/expenses/${item.id}`, 'blueraven')
        item.archived = true
        this.$store.commit(AppMutations.SET_LOADING, false)
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
        if(typeId != null) {
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
              r.reimbursementRequestDetails

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
    async saveSubmittedExpense(item, isNew) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        //not sure what this is yet
        // item.skipApproval = self.skipApproval;
        //there is already an endpoint for lists of these so just sending up as a list
        let listOfItem = [item]
        const {data} = await postRequest(`/expenses/addExpenseItems`, listOfItem, 'blueraven')
        if (isNew) {
          //do not add the new one to the list cuz it already got approved
          this.newSubmittedExpense = {}
          this.createNew = false
        } else {
          this.editIndex = null
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Submitted Expense')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    // async getBudgetTypesForUser(item, expenseDate) {
    //   //reset the budget id every time a user or expense date changes
    //   item.expenseBudgetId = null
    //   if (null != item.expenseBudgetUserId && null != expenseDate) {
    //     this.$store.commit(AppMutations.SET_LOADING, true)
    //     try {
    //       let params = {
    //         userId: item.expenseBudgetUserId,
    //         expenseDate: expenseDate
    //       }
    //       const {data} = await getRequestWithParams(`/expenseBudgets/availableForUser`, {params}, 'blueraven')
    //       this.budgetTypesForUser = data
    //       this.$store.commit(AppMutations.SET_LOADING, false)
    //     } catch (e) {
    //       console.error('*** ERROR ***', e)
    //       this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
    //       this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
    //       this.$store.commit(AppMutations.SET_LOADING, false)
    //     }
    //   }
    // },
    // async getGlCodes() {
    //   this.$store.commit(AppMutations.SET_LOADING, true)
    //   try {
    //     const {data} = await getGlCodes()
    //     this.glCodes = data
    //     this.$store.commit(AppMutations.SET_LOADING, false)
    //   } catch (e) {
    //     console.error('*** ERROR ***', e)
    //     this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
    //     this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
    //     this.$store.commit(AppMutations.SET_LOADING, false)
    //   }
    // },
    // async getUsersWithBudget() {
    //   this.$store.commit(AppMutations.SET_LOADING, true)
    //   try {
    //     const {data} = await getUsersWithBudget()
    //     this.usersWithBudget = data
    //     this.$store.commit(AppMutations.SET_LOADING, false)
    //   } catch (e) {
    //     console.error('*** ERROR ***', e)
    //     this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
    //     this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
    //     this.$store.commit(AppMutations.SET_LOADING, false)
    //   }
    // },
  }
}
</script>

<style lang="scss">
#submitted-expense-container .v-data-table__wrapper {
  height: calc(100vh - 290px);
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


</style>
