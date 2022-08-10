<template>
  <v-container class="pt-0">
    <v-row>
      <v-col >
        <v-btn color="primary" class="white--text"
               :disabled="payrollSummary.length === 0"
               @click="exportPayrollSummary">
          Export
        </v-btn>
        <v-btn color="primary" class="white--text ml-3"
               :disabled="!currentPayroll.id || payrollSummary.length === 0"
               @click="exportAllOverrides">
          Export All Overrides
        </v-btn>
        <v-data-table
          :headers="headers"
          :items="payrollSummary"
          :fixed-header="true"
          disable-sort
          :items-per-page="25"
          :footer-props="footerProps"
          :loading="dataLoading"
          class="elevation-1 mt-2"
        >
          <template #no-data>
            No available summary data
          </template>

          <template #no-results>
            No available summary data
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.closer_user}}</td>
              <td class="text-left">{{item.total_commission | currency('$', 2)}}</td>
              <td class="text-left">{{item.total_overrides | currency('$', 2)}}</td>
              <td class="text-left">{{item.commission_adjustments | currency('$', 2)}}</td>
              <td class="text-left">{{item.current_pay | currency('$', 2)}}</td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>

  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import constants from "@/helpers/constants";
  import {handleHidingGlobalLoader, getRequest, getSnackbar} from '@/helpers/helpers'
  import { saveAs } from 'file-saver'

  export default {
    name: 'Summary',

    created() {
      this.viewSummary()
      this.getCurrentPayroll()
    },
    watch: {
      '$store.state.brs.commissionPositionId': function () {
        this.positionId = this.$store.state.brs.commissionPositionId
        this.viewSummary()
        this.getCurrentPayroll()
      }
    },
    data() {
      return {
        snackbar: {},
        payrollSummary: [],
        currentPayroll: {},
        dataLoading: false,
        positionId: this.$store.state.brs.commissionPositionId,
        footerProps: {
          'items-per-page-options': [25, 50, 100, 500],
          'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
        },
        headers: [
          { text: 'Sales Rep', value: 'closer_user', show: true },
          { text: 'Total Commission', value: 'total_commission', show: true },
          { text: 'Total Overrides', value: 'total_overrides', show: true },
          { text: 'Adjustments', value: 'commission_adjustments', show: true },
          { text: 'Current Pay', value: 'current_pay', show: true },
        ],
      }
    },
    methods: {
      async getCurrentPayroll () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/payroll/current/${this.positionId}`, 'blueraven')
          this.currentPayroll = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Current Payroll')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async viewSummary() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        this.dataLoading = true
        try {
          const {data, status} = await getRequest(`/payroll/current/summary/${this.positionId}`, 'blueraven')
          this.payrollSummary = data
          this.dataLoading = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Payroll Summary')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async exportAllOverrides () {
        try {
          const {data} = await getRequest(`/payroll/${this.currentPayroll.id}/overrides`, 'blueraven')

          let filename = 'Overrides.csv'
          let csvData = 'Project ID, Customer Name, Closer, Override Plan Name, System Size, Overrides Earned, Prior Pay, Current Pay, User Allocation, Milestone 1 Percentage, Milestone 2 Percentage, Plan Total'
          csvData += '\n'

          data.forEach(p => {
            csvData +=
              p.projectId + ',' +
              p.customerName + ',' +
              p.closer + ',' +
              p.overridePlanName + ',' +
              p.systemSize + ',' +
              p.overridesEarned + ',' +
              p.priorPay + ',' +
              p.currentPay + ',' +
              p.userAllocation + ',' +
              p.milestone1Percentage + ',' +
              p.milestone2Percentage + ',' +
              p.planTotal
            csvData += '\n';
          })

          let blob = new Blob([csvData], {
            type: 'text/csv;charset=utf-8'
          });

          saveAs(blob, filename);

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Payroll Summary')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async exportPayrollSummary () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let filename = 'Payroll Summary.csv'
          let csvData = 'Sales Rep, Total Commission, Total Overrides, Adjustments, Current Pay'
          csvData += '\n'

          this.payrollSummary.forEach(p => {
            csvData +=
              p.closer_user + ',' +
              p.total_commission + ',' +
              p.total_overrides + ',' +
              p.commission_adjustments + ',' +
              p.current_pay
            csvData += '\n';
          })

          let blob = new Blob([csvData], {
            type: 'text/csv;charset=utf-8'
          });

          saveAs(blob, filename);
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Exporting Payroll Summary')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    }
  }
</script>
