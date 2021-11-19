<template>
  <v-container>
    <v-row>
      <v-col>
        <v-data-table
          :headers="headers"
          :items="payrollSummary"
          :fixed-header="true"
          disable-sort
          :footer-props="footerProps"
          :items-per-page="25"
          :loading="dataLoading"
          class="elevation-1"
        >
          <template #no-data>
            No available summary data
          </template>

          <template #no-results>
            No available summary data
          </template>

          <template #header.icons="{}">
            <div class="text-right mr-2">
              <v-btn text x-small :disabled="dataLoading" @click="exportPayrollSummary">
                <v-icon>download</v-icon>
              </v-btn>
            </div>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.closer_user}}</td>
              <td class="text-left">{{item.total_commission | currency('$', 2)}}</td>
              <td class="text-left">{{item.total_overrides | currency('$', 2)}}</td>
              <td class="text-left">{{item.commission_adjustments | currency('$', 2)}}</td>
              <td class="text-left">{{item.current_pay | currency('$', 2)}}</td>
              <td></td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>

  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import { saveAs } from 'file-saver'
  import {handleHidingGlobalLoader, getRequest, getSnackbar} from '@/helpers/helpers'
  import constants from "@/helpers/constants";

  export default {
    name: 'Summary',

    created() {
      this.viewSummary()
    },
    watch: {
      '$store.state.brs.commissionPositionId': function () {
        //they can't switch between Setter/Closer while on an actual payroll
        this.$router.push(`/commissionManagement/payroll`)

      }
    },
    data() {
      return {
        snackbar: {},
        payrollSummary: [],
        dataLoading: false,
        positionId: this.$store.state.brs.commissionPositionId,
        payrollId: parseInt(this.$route.params.id),
        headers: [
          { text: 'Sales Rep', value: 'closer_user', show: true },
          { text: 'Total Commission', value: 'total_commission', show: true },
          { text: 'Total Overrides', value: 'total_overrides', show: true },
          { text: 'Adjustments', value: 'commission_adjustments', show: true },
          { text: 'Current Pay', value: 'current_pay', show: true },
          { text: '', value: 'icons', show: true, width: 40 },
        ],
        footerProps: {
          'items-per-page-options': [25, 50, 100, 500],
          'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
        },
      }
    },
    methods: {
      async viewSummary() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        this.dataLoading = true
        try {
          const {data, status} = await getRequest(`/payroll/${this.payrollId}/summary/`, 'blueraven')
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
      async exportPayrollSummary () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let filename = 'Payroll Summary.csv';
          let csvData = 'Sales Rep, Total Commission, Total Overrides, Adjustments, Current Pay';
          csvData += '\n';

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
