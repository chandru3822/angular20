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
          />
          <v-autocomplete v-model="selectedBudgetId"
                          :items="availableBudgets"
                          disabled
                          readonly
                          label="Expense Budget"
                          item-text="fullBudgetName"
                          item-value="id"
          ></v-autocomplete>
          <v-autocomplete v-model="newReimbursement.budgetTypeId"
                          :items="budgetTypes"
                          label="Budget Type"
                          item-text="name"
                          item-value="id"
          ></v-autocomplete>
          <label>Details:</label>
          <v-textarea class="py-2 gray lighten-4" hide-details
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
                 :disabled="!newReimbursement.expenseDate || !selectedBudgetId || !newReimbursement.amount || !newReimbursement.budgetTypeId
                             || !newReimbursement.details"
                 @click="submitReimbursementRequest()">
            Submit
          </v-btn>
          <v-btn text color="primary" class="ml-3" @click="newReimbursement = {}">
            Clear
          </v-btn>
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

<script>
import {AppMutations} from '@/stores/AppStore'
import {
  handleHidingGlobalLoader,
  postRequest,
  getSnackbar,
  getRequestWithParams,
  getMonthDateRange
} from '@/helpers/helpers'
import DatetimePickerInput from "@/components/DatetimePickerInput"
import constants from "@/helpers/constants"
import {Actions} from "@/store"
import moment from 'moment'
import {getBudgetsForUser, getBudgetTypes, getReimbursementRequestImage} from './expenseService'
import SpinnerInline from "@/components/SpinnerInline.vue";
import BudgetReportTable from "@/views/blueraven/expenses/BudgetReportTable.vue";

export default {
  name: 'Reimbursement',
  components: {
    SpinnerInline,
    DatetimePickerInput,
    BudgetReportTable
  },
  computed: {
    selectedBudgetId () {
      return this.newReimbursement.expenseDate != null ? this.availableBudgets.find(b => {
        return moment(this.newReimbursement.expenseDate).isBetween(b.startDate, b.endDate, null, '[]')
      })?.id : null
    }
  },
  data() {
    return {
      snackbar: {},
      createNew: true,
      dataLoading: true,
      savingReceiptImage: false,
      attachmentTypeId: 4,
      timezone: this.$store.state.user.details.timezone.value,
      userId: this.$store.state.user.details.id,
      receiptLogo: {},
      companyId: this.$store.state.user.details.companyId,
      newReimbursement: {},
      renderApprovalRequestImage: false,
      needsApprovalRequest: {},
      availableBudgets: [],
      budgetTypes: [],
      acceptedFileTypes: constants.STANDARD_IMAGES_ONLY,
      rejectedRequests: [],
      budgetReport: [],
      months: constants.MONTHS,
      yearStart: 2017,
      yearEnd: parseInt(moment().format('YYYY')),
      years: [],
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
    this.getBudgetTypes()
    this.getBudgetsForUser()

  },
  methods: {
    async submitReimbursementRequest() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.newReimbursement.attachmentId = this.receiptLogo.id
        this.newReimbursement.expenseBudgetId = this.selectedBudgetId

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
    async getBudgetTypes() {
      //reset the budget id every time a user or expense date changes
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getBudgetTypes()
        this.budgetTypes = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
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
        let file = files[0]
        await this.$store.dispatch(Actions.FILE_UPLOAD, {
          file: file,
          attachmentTypeId,
          sourceId: null,
          displayName: file.name.substr(0, file.name.lastIndexOf('.')),
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
    async getBudgetsForUser() {
      this.budgetsLoading = true
      try {
        const {data, status} = await getBudgetsForUser(this.userId)
        this.availableBudgets = data
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } finally {
        this.budgetsLoading = false
      }
    },
    async getMonthlyBudgetReport() {
      const {data} = await getRequestWithParams(`/expenseBudgets/getMonthlyBudgetReport`, {
          params: {
            startDate: this.startDate,
            endDate: this.endDate,
            userId: this.userId
          }
        }, 'blueraven'
      , [])
      this.budgetReport = data
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
    async setDataForMonth() {
      this.dataLoading = true
      let dateRange = getMonthDateRange(this.selectedMonth, this.selectedYear)
      this.startDate = dateRange.startDate
      this.endDate = dateRange.endDate

      let requests = [
        //get rejected requests for user
        this.getRejectedRequests(2),
        this.getMonthlyBudgetReport()

      ]
      await Promise.all(requests).then(() => {
        this.dataLoading = false
      })
    },
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
