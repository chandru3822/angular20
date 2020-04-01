<template>
  <v-container class="pa-0">
    <v-toolbar v-if="!payrollLoading && !additionalPayrollDataNeeded" :color="payrollStatus.color" class="mt-2">
      <v-toolbar-title class="app-title" :style="{'color': payrollStatus.textColor}">
        {{payrollStatus.message}}
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <div class="flex-display align-center" >
          <v-btn v-if="payrollStatus.action" :color="payrollStatus.actionColor"
                 class="white--text" @click="submitForApproval(payrollStatus.action)">
            {{payrollStatus.actionText}}
          </v-btn>
          <!-- currently only "Approve" has a secondary action which requires a dialog confirm. will have to update if that changes -->
          <v-dialog
            v-if="payrollStatus.secondaryAction"
            v-model="approveConfirm"
            width="500">
            <template v-slot:activator="{ on }">
              <v-btn v-on="on" :color="payrollStatus.secondaryActionColor" class="white--text ml-3">
                {{payrollStatus.secondaryActionText}}
              </v-btn>
            </template>
            <v-card>
              <v-card-title
                class="headline grey lighten-2"
                primary-title
              >
                Confirm
              </v-card-title>

              <v-card-text class="pt-3">
                Are you sure you want to approve this payroll?

                <DatetimePickerInput
                  v-model="payDate"
                  :timezone="this.timezone"
                  :type="'date'"
                  :format="'MMMM DD, YYYY'"
                  label="Date Paid"
                />
              </v-card-text>


              <v-divider></v-divider>

              <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn
                  @click="approveConfirm = false">
                  No
                </v-btn>
                <v-btn
                  color="primaryCustom"
                  class="white--text"
                  :disabled="null == payDate"
                  @click="submitForApproval(payrollStatus.secondaryAction)">
                  Yes
                </v-btn>
              </v-card-actions>
            </v-card>
          </v-dialog>
        </div>
      </v-toolbar-items>
    </v-toolbar>
    <v-toolbar v-else-if="!payrollLoading" :color="payrollStatus.color" class="mt-2">
      <v-toolbar-title class="app-title">
        This payroll requires an end date and description.
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <div class="flex-display align-center" >
          <v-btn color="primaryCustom"
                 class="white--text" @click="saveChangesToPayroll()">
            Save Changes
          </v-btn>
        </div>
      </v-toolbar-items>
    </v-toolbar>
    <v-form ref="accountingForm">
      <v-container>
        <v-row>
          <v-col cols="12" sm="6">
            <v-card flat color="transparent" class="pa-3">
              <v-text-field text readonly label="Payroll ID #" v-model="currentPayroll.id"></v-text-field>
              <DatetimePickerInput
                  v-model="currentPayroll.periodEnd"
                  :timezone="this.timezone"
                  :type="'date'"
                  :format="'MMMM DD, YYYY'"
                  label="Period Ending"
              />
              <v-text-field text
                            label="Description"
                            v-model="currentPayroll.description"></v-text-field>
            </v-card>
          </v-col>
          <v-col cols="12" sm="6">
            <v-card class="pa-3">
              <v-text-field text
                            label="Project ID"
                            v-model="accountingSearch.projectId"></v-text-field>
              <v-autocomplete v-model="accountingSearch.customerId"
                              :items="customers"
                              :loading="customersLoading"
                              :search-input.sync="customerSearch"
                              label="Customer..."
                              item-text="fullName"
                              item-value="id"
                              autocomplete="off"
              ></v-autocomplete>
              <v-autocomplete v-model="accountingSearch.salesRepId"
                              :items="reps"
                              :loading="repsLoading"
                              :search-input.sync="repSearch"
                              label="Sales Rep..."
                              item-text="name"
                              item-value="userId"
                              autocomplete="off"
              ></v-autocomplete>
              <div class="text-left">
                <v-btn color="primaryCustom" dark @click="getAccountingData()">Search</v-btn>
                <v-btn class="ml-3" @click="accountingSearch = {}">Reset</v-btn>
              </div>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
    </v-form>
    <v-row>
      <v-col>
        <v-data-table
            :headers="headers"
            :items="accountingData"
            :fixed-header="true"
            disable-sort
            :show-select="payrollStatus.showSelect"
            :loading="dataLoading"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            No available accounting data
          </template>

          <template #no-results>
            No available accounting data
          </template>

          <template v-slot:header.data-table-select="{ on, props }">
            <v-checkbox color="primaryCustom" v-model="selectAll" @change="toggleSelectAll()"></v-checkbox>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td v-if="payrollStatus.showSelect">
<!--                <input type="checkbox" class="ml-2" v-model="item.selected">-->
                <v-checkbox color="primaryCustom" v-model="item.selected"></v-checkbox>
              </td>
              <td class="text-left">{{item.project_id}}</td>
              <td class="text-left">{{item.customer_name }}</td>
              <td class="text-left">{{item.system_size }}</td>
              <td class="text-left">{{item.closer }}</td>
              <td class="text-left">{{item.current_pay || 0 | currency('$', 2)}}</td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import cloneDeep from 'lodash.clonedeep'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import {getRequestWithParams} from "../../helpers/helpers";

  export default {
    name: 'Accounting',
    components: {
      Snackbar,
      DatetimePickerInput
    },
    created() {
      this.getCurrentPayroll()
    },
    watch: {
      customerSearch (val) {
        if(!val) {
          return
        }
        this.customers = []
        this.getCustomersDebounced(val)
      },
      repSearch (val) {
        console.log('value value val', val)
        if(!val) {
          return
        }
        this.reps = []
        this.getRepsDebounced(val)
      }
    },
    data() {
      return {
        snackbar: {},
        dataLoading: true,
        selectAll: false,
        customers: [],
        customerSearch: null,
        customersLoading: false,
        reps: [],
        repSearch: null,
        repsLoading: false,
        approveConfirm: false,
        payDate: null,
        additionalPayrollDataNeeded: false,
        payrollLoading: true,
        timezone: this.$store.state.user.details.timezone.value,
        headers: [
          // {text: 'Select For Pay', value: 'select', show: true},
          {text: 'Project ID', value: 'projectId', show: true},
          {text: 'Customer Name', value: 'customerName', show: true},
          {text: 'System Size (kW)', value: 'systemSize', show: true},
          {text: 'Sales Rep', value: 'salesRep', show: true},
          {text: 'Current Pay', value: 'currentPay', show: true},
        ],
        accountingData: [],
        currentPayroll: {},
        payrollStatus: {},
        accountingSearch: {}
      }
    },
    methods: {
      toggleSelectAll () {
        this.accountingData.forEach(ad => {
          ad.selected = this.selectAll
        })
      },
      async submitForApproval (action) {
        let selectedIds = this.accountingData.filter(ad => ad.selected).map(ad => ad.project_id)
        console.log('submit', selectedIds)
        let params = {
          payDate: this.payDate
        }
        if(this.payrollStatus.showSelect && (!selectedIds || selectedIds.length === 0)) {
          this.snackbar = getSnackbar('WARNING', 'You must select at least one project.')
        } else {
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            await postRequest(`/payroll/${this.currentPayroll.id}/${action}`, params, 'blueraven')
            this.snackbar = getSnackbar('SUCCESS', 'Successfully Updated')
            this.getCurrentPayroll()
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Updating')
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      async saveChangesToPayroll () {
        let params = {
          description: this.currentPayroll.description,
          periodEnd: this.currentPayroll.periodEnd,
          lockedProjects: [],
          projectIds: []
        }
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await postRequest(`/payroll/${this.currentPayroll.id}`, params, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Successfully Updated')
          this.currentPayroll = data
          this.additionalPayrollDataNeeded = null == this.currentPayroll.periodEnd || null == this.currentPayroll.description
          this.getStatusColor()
          this.getAccountingData()
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Updating')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      getStatusColor () {
        this.payrollStatus = {}
        switch(this.currentPayroll.status) {
          case 'PENDING':
            this.payrollStatus.message = 'This payroll is pending.'
            this.payrollStatus.color = '#DCDCDC'
            this.payrollStatus.showSelect = true
            this.payrollStatus.action = 'submit'
            this.payrollStatus.actionText = 'Submit For Approval'
            this.payrollStatus.actionColor = 'primaryCustom'
            break
          case 'SUBMITTED':
            this.payrollStatus.message = 'This payroll has been Submitted.'
            this.payrollStatus.color = '#DCDCDC'
            this.payrollStatus.showSelect = false
            this.payrollStatus.action = 'reject'
            this.payrollStatus.actionText = 'Reject'
            this.payrollStatus.actionColor = 'red'
            this.payrollStatus.secondaryAction = 'approve'
            this.payrollStatus.secondaryActionText = 'Approve'
            this.payrollStatus.secondaryActionColor = 'green'
            break
          case 'REJECTED':
            this.payrollStatus.message = 'This payroll has been Rejected.'
            this.payrollStatus.color = 'red'
            this.payrollStatus.textColor = 'white'
            this.payrollStatus.showSelect = true
            this.payrollStatus.action = 'submit'
            this.payrollStatus.actionText = 'Submit For Approval'
            this.payrollStatus.actionColor = 'primaryCustom'
            break
          default:
            this.payrollStatus = {}
        }
      },
      async getCurrentPayroll () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/payroll/current`, 'blueraven')
          this.currentPayroll = data
          this.getStatusColor()
          this.payrollLoading = false
          this.additionalPayrollDataNeeded = null == this.currentPayroll.periodEnd || null == this.currentPayroll.description
          if(null != this.currentPayroll.periodEnd) {
            this.getAccountingData()
          } else {
            this.dataLoading = false
            this.accountingData = []
          }
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Current Payroll')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getAccountingData () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            payrollId: this.currentPayroll.id,
            periodEnd: this.currentPayroll.periodEnd,
            projectId: this.accountingSearch.projectId,
            customerId: this.accountingSearch.customerId,
            salesRepId: this.accountingSearch.salesRepId
          }
          const {data} = await postRequest(`/commissionManagement/accountReview/search`, params, 'blueraven')
          data.forEach(d => {
            d.selected = !!this.currentPayroll.selectedProjectIds?.includes(d.project_id)
          })
          this.accountingData = data
          this.dataLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Accounting Data')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async viewDetails (item) {
        console.log('randaLogger', item)
      },
      getCustomersDebounced(val) {
        clearTimeout(this._searchTimerId)
        this._searchTimerId = setTimeout(() => {
          this.getCustomers(val)
        }, 500) /* 500ms throttle */
      },
      async getCustomers(query) {
          this.customersLoading = true
          try {
            let params = {
              query,
              size: 10
            }
            const {data} = await getRequestWithParams(`/contact/search`, {params})
            this.customers = data.content
            this.customersLoading = false
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving Customers')
          }
      },
      getRepsDebounced(val) {
        clearTimeout(this._repTimerId)
        this._repTimerId = setTimeout(() => {
          this.getReps(val)
        }, 500) /* 500ms throttle */
      },
      async getReps(query) {
        this.repsLoading = true
        try {
          let params = {
            query,
            size: 10
          }
          const {data} = await getRequestWithParams(`/commissionManagement/overrides/_search`, {params}, 'blueraven')
          this.reps = data
          console.log('randaLogger', this.reps)
          this.repsLoading = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Sales Reps')
        }
      },
    }
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>
  .v-data-table {
    border-radius: 0;
  }
</style>

