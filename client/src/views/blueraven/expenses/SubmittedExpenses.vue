<template>
  <v-container id="submitted-expense-container">
    <v-row v-if="!selectedExpense || !selectedExpense.id">
      <v-col cols="12">
        <v-card flat color="white" class="pa-5">
          <div class="flex-display">
            <div class="left-header-bar">
              <v-toolbar-title class="app-title">
                Submitted Expenses
              </v-toolbar-title>
              <v-text-field
                v-model="userSearchText"
                prepend-inner-icon="search"
                label="Search"
                single-line
                class="mt-5"
                hide-details
              ></v-text-field>
            </div>
            <v-spacer></v-spacer>

            <div class="right-header-bar elevation-1">
              <div>From:</div>
              <div class="flex-display">
                  <v-select v-model="startMonth"
                            :items="months"
                            hide-details
                            class="mr-2 range-selector"
                            single-line
                            outlined
                            dense
                            label="Month"
                            item-text="name"
                            item-value="id"
                  ></v-select>
                  <v-select v-model="startYear"
                            :items="years"
                            hide-details
                            class="range-selector"
                            single-line
                            outlined
                            dense
                            label="Year"
                            item-text="name"
                            item-value="id"
                  ></v-select>
              </div>
              <div>Thru:</div>
              <div class="flex-display">
                  <v-select v-model="endMonth"
                            :items="months"
                            hide-details
                            class="mr-2 range-selector"
                            single-line
                            outlined
                            dense
                            label="Month"
                            item-text="name"
                            item-value="id"
                  ></v-select>
                  <v-select v-model="endYear"
                            :items="years"
                            hide-details
                            class="range-selector"
                            single-line
                            outlined
                            dense
                            label="Year"
                            item-text="name"
                            item-value="id"
                  ></v-select>
              </div>
              <v-btn color="primary" class="white--text mt-2" small
                     @click="getSubmittedExpenses">
                Show All in Range
              </v-btn>
              <v-btn color="primary" class="white--text mt-2" small
                     @click="exportExpenses()">
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

            <template #item="{ item, index }">
              <tr :class="{'shaded-row': index % 2}">
                <td class="text-left">{{ item.expenseBudgetUser }}</td>
                <td class="text-left">{{ item.amount | currency('$', 2) }}</td>
                <td class="text-left">{{ item.expenseDate | formatDate('date') }}</td>
                <td class="text-left">{{ item.budgetType }}</td>
                <td class="text-left">{{ item.glCode }}</td>
                <td class="text-left">{{ item.dateApproved | formatDate('date') }}</td>
                <td class="text-left">{{ item.approvedBy }}</td>
                <td>
                  <div style="display: flex; justify-content: flex-end">
                    <v-btn small text color="primary"
                           @click="[selectedExpense = item, getRequestAttachmentPresignedUrl(item), getBudgetsForUser(selectedExpense.expenseBudgetUserId)]">
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
        </div>
      </v-col>
    </v-row>
    <v-row v-else>
      <v-col cols="12">
        <v-toolbar flat class="cfg-header-bar" dense>
          <v-toolbar-title class="app-title">
            <v-btn text color="primary" @click="selectedExpense = {}">Back</v-btn>
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
                            :disabled="selectedExpense.approvalDate !== null"
                            item-text="fullName"
                            item-value="id"
                            @input="getBudgetsForUser(selectedExpense.expenseBudgetUserId)"
            ></v-autocomplete>
            <v-autocomplete v-model="selectedExpense.expenseBudgetId"
                            :items="budgetsForUser"
                            label="Selected Budget"
                            :disabled="selectedExpense.approvalDate !== null"
                            item-text="fullBudgetName"
                            item-value="id"
            ></v-autocomplete>
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
                            :filter="searchGlCodes"
            >
              <template slot='item' slot-scope='{ item }'>
                {{ item.code }} - {{ item.description }}
              </template>
            </v-autocomplete>

            <v-autocomplete v-model="selectedExpense.budgetTypeId"
                            :items="budgetTypes"
                            label="Budget Type"
                            disabled
                            item-text="name"
                            item-value="id"
            ></v-autocomplete>
            <v-text-field text
                          type="number"
                          prepend-icon="mdi-currency-usd"
                          :disabled="selectedExpense.approvalDate !== null"
                          label="Amount"
                          v-model.number="selectedExpense.amount">
            </v-text-field>
            <label>Details:</label>
            <v-textarea class="py-2" hide-details
                        auto-grow filled
                        :disabled="true"
                        rows="4"
                        background-color="#F2F6F8"
                        v-model="selectedExpense.details">
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
            <v-btn color="primary" text @click="selectedExpense = {}">Cancel</v-btn>
            <v-btn color="primary" class="white--text" raised
                   :disabled="selectedExpense.approvalDate !== null || !selectedExpense.expenseDate || !selectedExpense.glCodeId
                            || !selectedExpense.expenseBudgetUserId || !selectedExpense.expenseBudgetId || !selectedExpense.amount"
                   @click="saveSubmittedExpense(selectedExpense)">Save Changes
            </v-btn>
          </v-card-actions>
        </v-card>
      </v-col>
    </v-row>
    <ConfirmationDialog
        :open-dialog = deleteConfirm
        @confirm=deleteSubmittedExpense(itemToDelete)
        @close-dialog="closeDeleteDialog">
      Are you sure you want to delete this Submitted Expense for <strong>{{ itemToDeleteUser }}:
      {{ itemToDeleteAmount | currency('$', 2) }}</strong>?
    </ConfirmationDialog>
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
  getSnackbar, getMonthDateRange
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

export default {
  name: 'SubmittedExpenses',
  components: {
    ConfirmationDialog,
    DatetimePickerInput
  },
  data() {
    return {
      snackbar: {},
      timezone: this.$store.state.user.details.timezone.value,
      selectedExpense: {},
      approveDropdown: false,
      approveConfirmLoading: false,
      dataLoading: true,
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
      budgetsForUser: [],
      selectedExpenses: [],
      selectAllExpenses: false,
      glCodes: [],
      budgetTypes: [],
      headers: [
        {text: 'Purchaser', value: 'expenseBudgetUser', show: true},
        {text: 'Amount', value: 'amount', show: true},
        {text: 'Expense Date', value: 'expenseDate', show: true},
        {text: 'Budget Type', value: 'budgetType', show: true},
        {text: 'GL Code', value: 'glCode', show: true},
        {text: 'Approved Date', value: 'dateApproved', show: true},
        {text: 'Approved By', value: 'approvedBy', show: true},
        {text: null, value: 'icons', show: true}
      ],
      showAll: false,
      rangeChanged: false,
      startDate: moment().startOf('month').format('YYYY-MM-DD'),
      endDate: moment().endOf('month').format('YYYY-MM-DD'),
      deleteConfirm: false,
      itemToDelete: {},
      approveConfirm: false,
      months: constants.MONTHS,
      yearStart: 2017,
      yearEnd: parseInt(moment().format('YYYY')),
      years: [],
      startMonth: parseInt(moment().format('M')),
      startYear: parseInt(moment().format('YYYY')),
      endMonth: parseInt(moment().format('M')),
      endYear: parseInt(moment().format('YYYY'))
    }
  },
  created() {
    for (let i = this.yearStart; i <= this.yearEnd; i++) {
      this.years.push(i)
    }
    this.getGlCodes()
    this.getUsersWithBudget()
    this.getBudgetTypes()
    this.getSubmittedExpenses()
  },
  computed: {
    itemToDeleteUser(){
      return this.itemToDelete ? this.itemToDelete.expenseBudgetUser : ''
    },
    itemToDeleteAmount(){
      return this.itemToDelete ? this.itemToDelete.amount : ''
    }
  },
  methods: {
    searchGlCodes(item, queryText) {
      let data = item.code.toLowerCase() + ' - ' + item.description.toLowerCase()
      return data.includes(queryText.toLowerCase())
    },
    filterSubmittedExpenses() {
      return this.submittedExpenses.filter(glc => !glc.archived)
    },
    async getSubmittedExpenses() {
      try {
        this.dataLoading = true
        let dateRange1 = getMonthDateRange(this.startMonth, this.startYear)
        let dateRange2 = getMonthDateRange(this.endMonth, this.endYear)
        let date1 = dateRange1.startDate
        let date2 = dateRange2.endDate
        const {data, status} = await getRequestWithParams('/reimbursement/requests/approved', {
          params: {
            startDate: date1,
            endDate: date2
          }
        }, 'blueraven')
        this.submittedExpenses = data
        this.dataLoading = false
        this.masterExpenses = cloneDeep(data)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async deleteSubmittedExpense(item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await deleteRequest(`/reimbursement/${item.id}`, 'blueraven')
        item.archived = true
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Submitted Expense')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
      this.closeDeleteDialog()
    },
    async exportExpenses() {
      //not sure what these type Ids were, i just copied this over
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let filename = 'expenses.csv'
        let results = []
        let url = '/reimbursement/requests/approved'
        let date1 = moment(this.startDate).format('MM/DD/YYYY')
        let date2 = moment(this.endDate).format('MM/DD/YYYY')
        const {data} = await getRequestWithParams(url, {params: {startDate: date1, endDate: date2}}, 'blueraven')
        results = data

        let csvData = this.getCsvHeaders()
        csvData += '\n'

        results.forEach(r => {
          csvData +=
            '"' + r.expenseBudgetUser + '",' +
            r.amount + ',' +
            moment.utc(r.expenseDate).format('MM/DD/YYYY') + ',' +
            r.budgetType + ',' +
            r.glCode + ',' +
            `${r.dateApproved ? moment.utc(r.dateApproved).format('MM/DD/YYYY') : null}` + ',' +
            '"' + r.approvedBy + '",' +
            '"' + r.details + '"'

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
        'Purchaser',
        'Amount',
        'Expense Date',
        'Budget Type',
        'GL Code',
        'Approved Date',
        'Approved By',
        'Details'
      ]
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
    async getBudgetsForUser(userId) {
      this.budgetsLoading = true
      try {
        const {data, status} = await getBudgetsForUser(userId)
        this.budgetsForUser = data
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } finally {
        this.budgetsLoading = false
      }
    },
    async getBudgetTypes() {
      //reset the budget id every time a user or expense date changes
      try {
        const {data, status} = await getBudgetTypes()
        this.budgetTypes = data
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getGlCodes() {
      try {
        const {data, status} = await getGlCodes()
        this.glCodes = data
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
    async getRequestAttachmentPresignedUrl(item) {
      this.renderRequestImage = false
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getReimbursementRequestImage(item.id)
        this.selectedExpense.presignedUrl = data
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
  text-align: left;
  flex-direction: column;
  justify-content: space-between;
}

.middle-header-bar {
  display: flex;
  align-items: end;
}

.range-selector {
  max-width: 150px;
}

</style>
