<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="app-title">Reimbursement Request
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" @click="[createNew = !createNew, newReimbursement = {}]">
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
                      v-model="newReimbursement.details">
          </v-textarea>
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
          <v-btn color="primary" class="white--text"
                 :disabled="!newReimbursement.expenseDate || !newReimbursement.expenseBudgetId || !newReimbursement.amount
                            || !receiptLogo || !receiptLogo.id || !newReimbursement.details"
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
              <v-btn color="primary" class="white--text ml-3"
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
              <table v-if="!needsApprovalRequest || !needsApprovalRequest.id">
                <tr v-for="req in requestsNeedingApproval">
                  <td>
                    <a @click="[needsApprovalRequest = req, getRequestAttachmentPresignedUrl()]">
                      {{ req.createdBy }} - {{ req.expenseDate | formatDate('date') }} - Click for more details
                    </a>
                  </td>
                </tr>
              </table>
              <div v-else>
                <table class="pb-3">
                  <tr>
                    <td class="left-column pb-3">
                      <v-btn @click="needsApprovalRequest = {}">Back</v-btn>
                    </td>
                  </tr>
                  <tr>
                    <td class="left-column">Created By:</td>
                    <td>{{ needsApprovalRequest.createdBy }}</td>
                  </tr>
                  <tr>
                    <td class="left-column">Created Date:</td>
                    <td>{{ needsApprovalRequest.dateCreated | formatDate('date') }}</td>
                  </tr>
                  <tr>
                    <td class="left-column">Budget Type:</td>
                    <td>{{ needsApprovalRequest.budgetType }}</td>
                  </tr>
                  <tr>
                    <td class="left-column">Expense Date:</td>
                    <td>{{ needsApprovalRequest.expenseDate | formatDate('date') }}</td>
                  </tr>
                  <tr>
                    <td class="left-column">Amount:</td>
                    <td>{{ needsApprovalRequest.amount | currency('$', 2) }}</td>
                  </tr>
                  <tr>
                    <td class="left-column">Details:</td>
                    <td>{{ needsApprovalRequest.details }}</td>
                  </tr>
                </table>
                <v-divider></v-divider>
                <div class="receipt-image-background" v-if="renderApprovalRequestImage && needsApprovalRequest.presignedUrl">
                  <v-tooltip bottom max-width="300px" content-class="receipt-image-tooltip">
                    <template v-slot:activator="{ on:tooltip }">
                        <v-img name="receiptImg" class="receipt-image"
                               v-on="{ ...tooltip }"
                               alt="receipt-image" :src="needsApprovalRequest.presignedUrl"></v-img>
                    </template>
                    <v-card class="receipt-image-hover-container">
                      <img class="receipt-image-hovered" :src="needsApprovalRequest.presignedUrl">
                    </v-card>
                  </v-tooltip>
                </div>
                <v-divider class="mt-3" v-if="renderApprovalRequestImage && needsApprovalRequest.presignedUrl"></v-divider>
                <div class="pt-3">
                  <label>Notes: (required for rejecting)</label>
                  <v-textarea class="py-2" hide-details
                              auto-grow filled
                              rows="4"
                              background-color="#F2F6F8"
                              v-model="needsApprovalRequest.notes">
                  </v-textarea>
                  <v-btn color="primary"
                         @click="setRequestStatusWithNotes(needsApprovalRequest, 3)"
                         class="white--text">Approve</v-btn>
                  <v-btn color="red"
                         @click="setRequestStatusWithNotes(needsApprovalRequest, 2)"
                         :disabled="!needsApprovalRequest.notes"
                         class="white--text ml-3">Reject
                  </v-btn>
                </div>
              </div>
            </v-card-text>
          </v-card>

          <v-card class="mt-3">
            <v-card-title class="grey lighten-2" primary-title>
              Submitted Reimbursements
            </v-card-title>
            <v-card-text class="pt-4">
              <table class="detail-table">
                <tr>
                  <td class="detail-column">Pending Approval:</td>
                  <td class="detail-column text-right">{{ submittedReport.pending_approval || 0 | currency('$', 2) }}</td>
                </tr>
                <tr>
                  <td class="detail-column">Pending Payment:</td>
                  <td class="detail-column text-right">{{ submittedReport.pending_payment || 0 | currency('$', 2) }}</td>
                </tr>
                <tr>
                  <td class="detail-column">Paid:</td>
                  <td class="detail-column text-right">{{ submittedReport.paid || 0 | currency('$', 2) }}</td>
                </tr>
                <tr class="total-row">
                  <td class="detail-column">Total Reimbursements:</td>
                  <td class="detail-column text-right">{{ submittedReport.total || 0 | currency('$', 2) }}</td>
                </tr>
              </table>
            </v-card-text>
          </v-card>

          <v-card class="mt-3">
            <v-card-title class="grey lighten-2" primary-title>
              Recruiting Budget
            </v-card-title>
            <v-card-text class="pt-4">
              <table class="detail-table">
                <tr>
                  <td class="detail-column">Monthly Budget:</td>
                  <td class="detail-column text-right">{{ submittedReport.pending_approval || 0 | currency('$', 2) }}</td>
                </tr>
                <tr>
                  <td class="detail-column">Pending Approval:</td>
                  <td class="detail-column text-right">{{ submittedReport.pending_approval || 0 | currency('$', 2) }}</td>
                </tr>
                <tr>
                  <td class="detail-column">Pending Payment:</td>
                  <td class="detail-column text-right">{{ submittedReport.pending_payment || 0 | currency('$', 2) }}</td>
                </tr>
                <tr>
                  <td class="detail-column">Paid:</td>
                  <td class="detail-column text-right">{{ submittedReport.paid || 0 | currency('$', 2) }}</td>
                </tr>
                <tr>
                  <td class="detail-column">Other:</td>
                  <td class="detail-column text-right">{{ submittedReport.paid || 0 | currency('$', 2) }}</td>
                </tr>
                <tr>
                  <td class="detail-column">Remaining Budget:</td>
                  <td class="detail-column text-right">{{ submittedReport.total || 0 | currency('$', 2) }}</td>
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
import {handleHidingGlobalLoader, postRequest, getSnackbar, getRequestWithParams} from '@/helpers/helpers'
import DatetimePickerInput from "@/components/DatetimePickerInput"
import constants from "@/helpers/constants"
import {Actions} from "@/store"
import moment from 'moment'
import {getReimbursementRequestImage} from './expenseService'

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
      renderApprovalRequestImage: false,
      needsApprovalRequest: {},
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

        if (this.newReimbursement.expenseBudgetId === -1) {
          this.newReimbursement.expenseBudgetId = null
        }

        let selectedBudget = this.newReimbursement.expenseBudgetId ? this.availableBudgets.find(ab => ab.id === this.newReimbursement.expenseBudgetId) : null
        this.newReimbursement.expenseBudgetUserId = selectedBudget ? selectedBudget.userId : null

        const {status} = await postRequest(`/reimbursement/request`, this.newReimbursement, 'blueraven')
        this.newReimbursement = {}
        this.receiptLogo = {}
        this.snackbar = getSnackbar('SUCCESS', 'Reimbursement Request Submitted.')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
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
    async getRequestAttachmentPresignedUrl() {
      this.renderApprovalRequestImage = false
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getReimbursementRequestImage(this.needsApprovalRequest.id)
        this.needsApprovalRequest.presignedUrl = data
        //this forces the dom to re-render the presignedUrl and i hate myself
        this.renderApprovalRequestImage = true
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Attached Image')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async uploadFile(files, attachmentTypeId) {
      try {
        this.savingReceiptImage = true
        this.$store.commit(AppMutations.SET_LOADING, true)
        await this.$store.dispatch(Actions.FILE_UPLOAD, {
          file: files[0],
          attachmentTypeId,
          sourceId: null,
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
      const {data} = await getRequestWithParams(`/expenseBudgets/availableForUser`, {
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
          }
        }, 'blueraven'
      )
      this.submittedReport = data && data[0] ? data[0] : {}
    },
    async getMonthlyBudgetReport() {
      const {data} = await getRequestWithParams(`/expenseBudgets/getMonthlyBudgetReport`, {
          params: {
            startDate: this.startDate,
            endDate: this.endDate
          }
        }, 'blueraven'
      )
      this.budgetReport = data && data[0] ? data[0] : {}
    },
    async getRejectedRequests(statusId) {
      const {data} = await getRequestWithParams(`/reimbursement/requests/byStatus`, {
          params: {
            statusId,
            startDate: this.startDate,
            endDate: this.endDate
          }
        }, 'blueraven'
      )
      this.rejectedRequests = data
    },
    async getRequestsForSupervisorByStatus(statusId) {
      const {data} = await getRequestWithParams(`/reimbursement/requests/supervisor/byStatus`, {
          params: {
            statusId,
            startDate: this.startDate,
            endDate: this.endDate
          }
        }, 'blueraven'
      )
      this.requestsNeedingApproval = data
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
    setRequestStatusWithNotes(request, statusId) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        request.reimbursementRequestStatusId = statusId
        const {status} = postRequest(`/reimbursement/request/updateStatus`, request, 'blueraven')
        this.needsApprovalRequest = {}
        //dont show the one that just got approved/rejected
        this.requestsNeedingApproval = this.requestsNeedingApproval.filter((r) => r.id !== request.id)
        let reqStatus = statusId === 2 ? 'Rejected' : 'Approved'
        let msg = 'Reimbursement Request ' + reqStatus
        this.snackbar = getSnackbar('SUCCESS', msg)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Status')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
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

      if (this.$store.getters.userHasAnyPosition([3, 6])) {
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
  border-collapse: collapse;
}

.detail-column {
  width: 50%;
}

.total-row {
  border-top: solid 1px #D8D8D8;
  font-weight: bold;
}
</style>
