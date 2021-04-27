<template>
  <v-container class="pa-0">
    <v-row>
      <v-col>
        <v-toolbar flat :color="payrollStatus.color">
          <v-toolbar-title :style="{'color': payrollStatus.textColor}">
            {{ payrollStatus.message }}
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <div class="commission-button-container">

            </div>
          </v-toolbar-items>
        </v-toolbar>
      </v-col>
    </v-row>
    <v-row>
      <v-col cols="6">
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
      <v-col cols="6" class="text-right">
        <v-btn color="primaryCustom" @click="exportPayrollReview" class="white--text">Export</v-btn>
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
          :items-per-page="25"
          :footer-props="footerProps"
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

  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import { saveAs } from 'file-saver'
  import constants from "@/helpers/constants";
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'Payroll',

    data() {
      return {
        snackbar: {},
        payroll: {},
        dataLoading: false,
        payrollSnapshot: [],
        footerProps: {
          'items-per-page-options': [25, 50, 100, 500],
          'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
        },
        payrollSummary: [],
        payrollStatus: {},
        positionId: this.$store.state.brs.commissionPositionId,
        payrollId: this.$route.params.id,
        closerHeaders: [
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
        setterHeaders: [
          // {text: 'Select For Pay', value: 'select', show: true},
          {text: 'Project ID', value: 'project_id', show: true},
          {text: 'Customer Name', value: 'project_name', show: true},
          {text: 'Setter', value: 'sales_rep', show: true},
          {text: 'Current Pay', value: 'current_pay', show: true},
          {text: 'Source', value: 'source_name', show: true},
          {text: 'Cancelled', value: 'cancelled_date', show: true},
          {text: 'Appointment Date', value: 'closer_appointment_start', show: true},
          {text: 'Appointment Outcome', value: 'closer_appointment_outcome', show: true},
          {text: 'Commission Plan', value: 'commission_plan', show: true},
          {text: 'Commissions Earned', value: 'commissions_earned', show: true},
          {text: 'Commission Paid to Date', value: 'commission_paid_to_date', show: true},
          {text: 'Adjustment', value: 'commission_adjustment', width: 150, show: true},
          {text: 'Commission Pay', value: 'current_pay_commissions', show: true},
          {text: 'Override Plan', value: 'override_plan', show: true},
          {text: 'Override Earned', value: 'override_earned', show: true},
          {text: 'Overrides Paid to Date', value: 'overrides_paid_to_date', show: true},
          {text: 'Override Pay', value: 'current_pay_overrides', show: true},
        ]
      }
    },
    created() {
      this.getPayroll()
      this.getPayrollSnapshot()
    },
    watch: {
      '$store.state.brs.commissionPositionId': function () {
        this.positionId = this.$store.state.brs.commissionPositionId
        //they can't switch between Setter/Closer while on an actual payroll
        this.$router.push(`/commissionManagement/payroll`)
      }
    },
    computed: {
      headers() {
        return this.positionId === 1 ? this.closerHeaders : this.setterHeaders
      }
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
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getPayrollSnapshot() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        this.dataLoading = true
        try {
          const {data} = await getRequest(`/payroll/${this.payrollId}/snapshot/${this.positionId}`, 'blueraven')
          this.dataLoading = false
          this.payrollSnapshot = data

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Payroll Snapshot')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async viewSummary() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/payroll/${this.payrollId}/summary`, 'blueraven')
          this.payrollSummary = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Payroll Summary')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      populateStatusDetails () {
        switch(this.payroll.status) {
          case 'PENDING':
            this.payrollStatus.message = 'This payroll is pending.'
            this.payrollStatus.color = 'primaryCustom'
            this.payrollStatus.textColor = 'white'
            break
          case 'APPROVED':
            this.payrollStatus.message = 'This payroll has been Approved for Pay.'
            this.payrollStatus.color = 'green'
            this.payrollStatus.textColor = '#155724'
            break
          case 'SUBMITTED':
            this.payrollStatus.message = 'This payroll has been Submitted for Approval.'
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
      },
      async exportPayrollReview () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let filename = 'Payroll Review.csv'
          let csvData = ''

          if(this.payroll.positionId === 1) {
            csvData += 'Project ID,Customer Name,System Size (kW),Sales Rep,Source,Stage,Cancelled,IAS,FDS,FAS,$/% Dep,SC,Commission Plan,Commissions Earned,Commissions Paid To Date,Adjustment,Commission Pay,Remaining Value Commissions,Override Plan,Override Earned,Overrides Paid to Date,Override Pay,Remaining Value Overrides,Current Pay'
            csvData += '\n'

            this.payrollSnapshot.forEach(p => {
              csvData +=
                p.projectId + ',' +
                p.customerName + ',' +
                p.systemSize + ',' +
                p.salesRep + ',' +
                p.source + ',' +
                p.stage + ',' +
                p.cancelled + ',' +
                p.installAgreementSigned + ',' +
                p.finalDesignSigned + ',' +
                p.financialAgreementSent + ',' +
                p.percentOfCashDeposit + ',' +
                p.sc + ',' +
                p.commissionPlan + ',' +
                p.commissionsEarned + ',' +
                p.commissionPaidToDate + ',' +
                p.commissionAdjustment + ',' +
                p.currentPayCommissions + ',' +
                p.remainingValueCommissions + ',' +
                p.overridePlan + ',' +
                p.overrideEarned + ',' +
                p.overridesPaidToDate + ',' +
                p.currentPayOverrides + ',' +
                p.remainingValueOverrides + ',' +
                p.currentPay
              csvData += '\n';
            })
          } else {
            csvData += 'Project ID,Customer Name,Setter,Current Pay,Source,Cancelled,Appointment Date,Appointment Outcome,Commission Plan,Commissions Earned,Commissions Paid To Date,Adjustment,Commission Pay,Override Plan,Override Earned,Overrides Paid to Date,Override Pay'
            csvData += '\n'

            this.payrollSnapshot.forEach(p => {
              csvData +=
                p.project_id + ',' +
                p.project_name + ',' +
                p.sales_rep + ',' +
                p.current_pay + ',' +
                p.source_name + ',' +
                p.cancelled + ',' +
                p.closer_appointment_start + ',' +
                p.closer_appointment_outcome + ',' +
                p.commission_plan + ',' +
                p.commissions_earned + ',' +
                p.commission_paid_to_date + ',' +
                p.commission_adjustment + ',' +
                p.current_pay_commissions + ',' +
                p.override_plan + ',' +
                p.override_earned + ',' +
                p.overrides_paid_to_date + ',' +
                p.current_pay_overrides
              csvData += '\n';
            })
          }

          let blob = new Blob([csvData], {
            type: 'text/csv;charset=utf-8'
          });

          saveAs(blob, filename);
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Exporting Payroll Review')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    }
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>

</style>

