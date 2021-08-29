<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="app-title">Reimbursement Request
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[createNew = !createNew, newReimbursement = {}]">
              <v-icon>add</v-icon>
              New Reimbursement Request
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
      </v-col>
    </v-row>
    <v-row>
      <v-col cols="12" sm="6">
        <v-card flat v-if="createNew" class="pa-4">
          <h3>New Reimbursement Request</h3>
          <v-text-field text
                        type="number"
                        label="Dollar Amount"
                        v-model.number="newReimbursement.amount">
          </v-text-field>
          <DatetimePickerInput
            v-model="newReimbursement.expenseDate"
            :timezone="timezone"
            :type="'date'"
            :format="'MM/DD/YYYY'"
            label="Expense Date"
            :change-callback="getBudgetsForUserForExpenseDate"
          />
          <v-autocomplete v-model="newReimbursement.expenseBudgetId"
                          :items="availableBudgets"
                          label="Expense Budget"
                          item-text="fullBudgetName"
                          item-value="id"
          ></v-autocomplete>
          <label>Details:</label>
          <v-textarea class="py-2" hide-details
                      auto-grow filled
                      rows="4"
                      background-color="#F2F6F8"
                      v-model="newReimbursement.notes">
          </v-textarea>
          <label>Receipt Image: </label>
          <div v-if="!receiptLogo || !receiptLogo.id" class="mb-5">
            <form enctype="multipart/form-data" novalidate>
              <input
                type="file"
                :accept="acceptedFileTypes"
                class="file-input clickable"
                :disabled="savingReceiptImage"
                @change="uploadFile($event.target.files, attachmentTypeId, companyId)"
                name="avatar"
              >
            </form>
          </div>
          <div class="receipt-image-background mb-5" v-else>
            <img class="receipt-image" :src="receiptLogo.presignedUrl">
          </div>
          <v-btn color="primaryCustom" class="white--text"
                 :disabled="!newReimbursement.expenseDate || !newReimbursement.expenseBudgetId || !newReimbursement.amount
                            || !receiptLogo || !receiptLogo.id || !newReimbursement.notes"
                 @click="submitReimbursementRequest()">
            Submit
          </v-btn>
          <v-btn class="ml-3" @click="[newReimbursement = {}, createNew = false]">
            Cancel
          </v-btn>
        </v-card>
      </v-col>
      <v-col cols="12" sm="6">
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="app-title">Viewing Budget Data For:
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <div class="flex-display pt-3">
              <v-select v-model="selectedMonth"
                        :items="months"
                        hide-details
                        class="mr-3 reimbursement-range-selector"
                        single-line
                        label="Month"
                        item-text="name"
                        item-value="id"
              ></v-select>
              <v-select v-model="selectedYear"
                        :items="years"
                        hide-details
                        class="reimbursement-range-selector"
                        single-line
                        label="Year"
                        item-text="name"
                        item-value="id"
              ></v-select>
              <v-btn color="primaryCustom" class="white--text ml-3"
                    @click="setDataForMonth">
                Load
              </v-btn>
            </div>
          </v-toolbar-items>
        </v-toolbar>
        <v-sheet flat class="square-card pa-5">

          <v-card v-if="rejectedRequests.length > 0">
            <v-card-title class="grey lighten-2" primary-title>
              Rejected Requests
            </v-card-title>
            <v-card-text class="pt-4">
              <table>
                <thead>
                  <th>Expense Date</th>
                  <th>Amount</th>
                  <th>Details</th>
                </thead>
                <tr v-for="req in rejectedRequests">
                  <td>{{ req.expenseDate | formatDate('date') }}</td>
                  <td>{{ req.amount | currency('$', 2) }}</td>
                  <td>{{ req.details }}</td>
                </tr>
              </table>
            </v-card-text>
          </v-card>

          <v-card v-if="requestsNeedingApproval.length > 0">
            <v-card-title class="grey lighten-2" primary-title>
              Requests Needing Approval
            </v-card-title>
            <v-card-text class="pt-4">
              <table>
                <tr v-for="req in requestsNeedingApproval">
                  <td>{{ req.createdBy }} - {{req.dateCreated | date}} - Click for more details</td>
                </tr>
              </table>
            </v-card-text>
          </v-card>

          <v-card class="mt-3">
            <v-card-title class="grey lighten-2" primary-title>
              Submitted Reimbursements
            </v-card-title>
            <v-card-text class="pt-4">
              <table>
                <tr>
                  <td>Pending Approval:</td>
                  <td>{{ submittedReport.pending_approval || 0 | currency('$', 2) }}</td>
                </tr>
                <tr>
                  <td>Pending Payment:</td>
                  <td>{{ submittedReport.pending_payment || 0 | currency('$', 2)}}</td>
                </tr>
                <tr>
                  <td>Paid:</td>
                  <td>{{ submittedReport.paid || 0 | currency('$', 2)}}</td>
                </tr>
                <tr>
                  <td>Total Reimbursements:</td>
                  <td>{{ submittedReport.total || 0 | currency('$', 2) }}</td>
                </tr>
              </table>
            </v-card-text>
          </v-card>

          <v-card class="mt-3">
            <v-card-title class="grey lighten-2" primary-title>
              Recruiting Budget
            </v-card-title>
            <v-card-text class="pt-4">
              <table>
                <tr>
                  <td>Monthly Budget:</td>
                  <td>{{ submittedReport.pending_approval || 0 | currency('$', 2) }}</td>
                </tr>
                <tr>
                  <td>Pending Approval:</td>
                  <td>{{ submittedReport.pending_approval || 0 | currency('$', 2) }}</td>
                </tr>
                <tr>
                  <td>Pending Payment:</td>
                  <td>{{ submittedReport.pending_payment || 0 | currency('$', 2)}}</td>
                </tr>
                <tr>
                  <td>Paid:</td>
                  <td>{{ submittedReport.paid || 0 | currency('$', 2)}}</td>
                </tr>
                <tr>
                  <td>Other:</td>
                  <td>{{ submittedReport.paid || 0 | currency('$', 2)}}</td>
                </tr>
                <tr>
                  <td>Remaining Budget:</td>
                  <td>{{ submittedReport.total || 0 | currency('$', 2) }}</td>
                </tr>
              </table>
            </v-card-text>
          </v-card>
        </v-sheet>
      </v-col>
    </v-row>

  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar, getRequestWithParams} from '@/helpers/helpers'
import DatetimePickerInput from "@/components/DatetimePickerInput"
import constants from "@/helpers/constants"
import {Actions} from "@/store";
import moment from 'moment'

export default {
  name: 'Reimbursement',
  components: {
    DatetimePickerInput
  },
  computed: {},
  data() {
    return {
      snackbar: {},
      createNew: true,
      savingReceiptImage: false,
      attachmentTypeId: 4,
      timezone: this.$store.state.user.details.timezone.value,
      userId: this.$store.state.user.details.id,
      receiptLogo: {},
      companyId: this.$store.state.user.details.companyId,
      newReimbursement: {},
      availableBudgets: [{
        fullBudgetName: 'N/A',
        id: -1,
        sortOrder: 0
      }],
      acceptedFileTypes: constants.STANDARD_IMAGES_ONLY,
      submittedReport: {},
      rejectedRequests: [],
      requestsNeedingApproval: [],
      budgetReport: [],
      months: [
        {id: 1, name: 'January'},
        {id: 2, name: 'February'},
        {id: 3, name: 'March'},
        {id: 4, name: 'April'},
        {id: 5, name: 'May'},
        {id: 6, name: 'June'},
        {id: 7, name: 'July'},
        {id: 8, name: 'August'},
        {id: 9, name: 'September'},
        {id: 10, name: 'October'},
        {id: 11, name: 'November'},
        {id: 12, name: 'December'}
      ],
      yearStart: 2017,
      yearEnd: parseInt(moment().format('YYYY')),
      years: [],
      showingRejected: false,
      selectedMonth: parseInt(moment().format('M')),
      selectedYear: parseInt(moment().format('YYYY'))
    }
  },
  created() {
    for (let i = this.yearStart; i <= this.yearEnd; i++) {
      this.years.push(i)
    }
    //init
    this.setDataForMonth()

  },
  methods: {
    async submitReimbursementRequest() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.newReimbursement.attachmentId = this.receiptLogo.id
        // this.newReimbursement.createdByUserId = currentUser.min.id

        if (this.newReimbursement.expenseBudgetId === -1) {
          this.newReimbursement.expenseBudgetId = null
        }

        let selectedBudget = this.newReimbursement.expenseBudgetId ? this.availableBudgets.find(ab => ab.id === this.newReimbursement.expenseBudgetId) : null
        this.newReimbursement.expenseBudgetUserId = selectedBudget ? selectedBudget.userId : null

        const {data} = await postRequest(`/reimbursement/request`, this.newReimbursement, 'blueraven')
        this.newReimbursement = {}
        this.receiptLogo = {}
        this.snackbar = getSnackbar('SUCCESS', 'Reimbursement Request Submitted.')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        let msg = 'Error Submitting Reimbursement Request.'
        if (e && e.status && e.status === 406) {
          msg = 'Error, Request exceeds budget. Please contact Administrator for assistance.'
        }
        this.snackbar = getSnackbar('ERROR', msg)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async uploadFile(files, attachmentTypeId, sourceId) {
      try {
        this.savingReceiptImage = true
        this.$store.commit(AppMutations.SET_LOADING, true)
        await this.$store.dispatch(Actions.FILE_UPLOAD, {
          file: files[0],
          attachmentTypeId,
          sourceId,
          callback: async (img, error) => {
            this.savingReceiptImage = false
            if (error?.error) {
              this.snackbar = getSnackbar('ERROR', error.errorMsg)
              this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
              this.$store.commit(AppMutations.SET_LOADING, false)
            } else {
              this.receiptLogo = img
              this.snackbar = getSnackbar('SUCCESS', 'Receipt Uploaded')
              this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
              this.$store.commit(AppMutations.SET_LOADING, false)
            }
          }
        })
      } catch (e) {
        this.savingReceiptImage = false
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Uploading File')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getBudgetsForUserForExpenseDate() {
      let date = moment(this.newReimbursement.expenseDate).format('YYYY-MM-DD')
      const {data} = getRequestWithParams(`/expenseBudgets/availableForUser`, {
        params: {
          userId: this.userId,
          expenseDate: date
        }
      }, 'blueraven')
      this.availableBudgets = data || []
      this.availableBudgets.push({
        fullBudgetName: 'N/A',
        id: -1,
        sortOrder: 0
      })
    },
    async getMonthlySubmittedReport() {
      const {data} = await getRequestWithParams(`/reimbursement/getMonthlySubmittedReport`, {
        params: {
          startDate: this.startDate,
          endDate: this.endDate
        }}, 'blueraven'
      )
      this.submittedReport = data && data[0] ? data[0] : {}
    },
    async getMonthlyBudgetReport() {
      const {data} = await getRequestWithParams(`/expenseBudgets/getMonthlyBudgetReport`, {
        params: {
          startDate: this.startDate,
          endDate: this.endDate
        }}, 'blueraven'
      )
      this.budgetReport = data && data[0] ? data[0] : {}
    },
    async getRejectedRequests(statusId) {
      const {data} = await getRequestWithParams(`/reimbursement/requests/byStatus`, {
        params: {
          statusId,
          startDate: this.startDate,
          endDate: this.endDate
        }}, 'blueraven'
      )
      this.rejectedRequests = data
    },
    async getRequestsForSupervisorByStatus(statusId) {
      const {data} = await getRequestWithParams(`/reimbursement/requests/supervisor/byStatus`, {
        params: {
          statusId,
          startDate: this.startDate,
          endDate: this.endDate
        }}, 'blueraven'
      )
      this.requestsNeedingApproval = data
    },
    setDataForMonth() {
      let dateRange = this.getMonthDateRange(this.selectedMonth, this.selectedYear)
      this.startDate = dateRange.startDate
      this.endDate = dateRange.endDate

      //get rejected requests for user
      this.getRejectedRequests(2)

      //requests that supervisors need to approve
      this.getRequestsForSupervisorByStatus(6)

      //the the monthly submitted report
      this.getMonthlySubmittedReport()

      if (this.$store.getters.userHasAnyPosition([3,6])) {
        this.getMonthlyBudgetReport()
      }
    },
    getMonthDateRange(month, year) {
      let startDate = moment([year, month - 1]).format("YYYY-MM-DD")
      let endDate = moment(startDate).endOf('month').format("YYYY-MM-DD")
      return {startDate, endDate}
    }
  }
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

//.company-logo-background {
//  background-color: #bbbbbb;
//}
</style>
