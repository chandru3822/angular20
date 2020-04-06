<template>
  <v-container>
    <v-row>
      <v-col>
        <v-toolbar flat color="transparent">
          <v-toolbar-title>
            Accounting Review
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <div class="button-container">
              <v-btn>
                Prepare Summary
              </v-btn>
            </div>
          </v-toolbar-items>
        </v-toolbar>
        <v-toolbar flat :color="payrollStatus.color">
          <v-toolbar-title :style="{'color': payrollStatus.textColor}">
            {{ payrollStatus.message }}
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <div class="button-container">

            </div>
          </v-toolbar-items>
        </v-toolbar>
      </v-col>
    </v-row>
    <v-row>
      <v-col>
        <table>
          <tr>
            <td class="text-left pr-3"><strong>Payroll ID #</strong></td>
            <td class="text-left">{{payroll.id}}</td>
          </tr>
          <tr>
            <td class="text-left pr-3"><strong>Payroll Ending</strong></td>
            <td class="text-left">{{payroll.periodEnd | formatDate('date')}}</td>
          </tr>
          <tr>
            <td class="text-left pr-3"><strong>Description</strong></td>
            <td class="text-left">{{payroll.description}}</td>
          </tr>
          <tr v-for="(hx, idx) in payroll.history" :key="idx">
            <td class="text-left pr-3"><strong>{{hx.actionType}}</strong></td>
            <td class="text-left">{{hx.actionUser}} - {{hx.actionDate | formatDate('date')}}</td>
          </tr>
        </table>
      </v-col>
    </v-row>
    <v-divider></v-divider>
    <v-row>
      <v-col>
        <v-data-table
          :headers="headers"
          :items="payrollSnapshot"
          :fixed-header="true"
          disable-sort
          :loading="dataLoading"
          hide-default-footer
          class="elevation-1"
        >
          <template #no-data>
            No available snapshot data
          </template>

          <template #no-results>
            No available snapshot data
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
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'Payroll',
    components: {
      Snackbar
    },
    data() {
      return {
        snackbar: {},
        payroll: {},
        dataLoading: false,
        payrollSnapshot: [],
        payrollStatus: {},
        payrollId: this.$route.params.id,
        headers: [
          {text: 'Project ID', value: 'projectId', show: true},
          {text: 'Customer Name', value: 'customerName', show: true},
          {text: 'System Size (kW)', value: 'systemSize', show: true},
          {text: 'Sales Rep', value: 'salesRep', show: true},
          {text: 'Source', value: 'source', show: true},
          {text: 'Stage', value: 'stage', show: true},
          {text: 'Cancelled', value: 'cancelled', show: true},
          {text: 'IAS', value: 'installAgreementSigned', show: true},
          {text: 'FDS', value: 'finalDesignSigned', show: true},
          {text: 'FAS', value: 'financialAgreementSent', show: true},
          {text: '$/% Dep', value: 'percentOfCashDeposit', show: true},
          {text: 'SC', value: 'sc', show: true},
          {text: 'Commission Plan', value: 'commissionPlan', show: true},
          {text: 'Commissions Earned', value: 'commissionsEarned', show: true},
          {text: 'Commissions Paid To Date', value: 'commissionPaidToDate', show: true},
          {text: 'Adjustment', value: 'commissionAdjustment', show: true},
          {text: 'Commission Pay', value: 'currentPayCommissions', show: true},
          {text: 'Remaining Value Commissions', value: 'remainingValueCommissions', show: true},
          {text: 'Override Plan', value: 'overridePlan', show: true},
          {text: 'Override Earned', value: 'overrideEarned', show: true},
          {text: 'Overrides Paid to Date', value: 'overridesPaidToDate', show: true},
          {text: 'Override Pay', value: 'currentPayOverrides', show: true},
          {text: 'Remaining Value Overrides', value: 'remainingValueOverrides', show: true},
          {text: 'Current Pay', value: 'currentPay', show: true},
        ],
      }
    },
    created() {
      this.getPayroll()
      this.getPayrollSnapshot()
    },
    methods: {
      async getPayroll() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/payroll/${this.payrollId}`, 'blueraven')
          this.payroll = data
          this.populateStatusDetails()
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Payroll Details')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getPayrollSnapshot() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        this.dataLoading = true
        try {
          const {data} = await getRequest(`/payroll/${this.payrollId}/snapshot`, 'blueraven')
          this.dataLoading = false
          this.payrollSnapshot = data

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Payroll Snapshot')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      populateStatusDetails () {
        switch(this.payroll.status) {
          case 'PENDING':
            this.payrollStatus.message = 'This payroll is pending.'
            this.payrollStatus.color = 'primary'
            this.payrollStatus.textColor = 'white'
            break
          case 'APPROVED':
            this.payrollStatus.message = 'This payroll has been Approved for Pay.'
            this.payrollStatus.color = 'green'
            this.payrollStatus.textColor = '#155724'
            break
          case 'SUBMITTED':
            this.payrollStatus.message = 'This payroll has been Approved for Pay.'
            this.payrollStatus.color = '#DCDCDC'
            break
          case 'REJECTED':
            this.payrollStatus.message = 'This payroll has been Rejected.'
            this.payrollStatus.color = 'red'
            this.payrollStatus.textColor = 'white'
            break
          default:
            this.payrollStatus = {}
        }
      }
    }
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>

</style>

