<template>
  <v-container class="pa-0">
    <v-toolbar>
      <v-toolbar-title>
        Customer Current Monthly Payment  Loan Term APR
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <div class="pt-3">
          <v-btn text color="primary" @click="$emit('commissionDetailModalClosed')">
            <v-icon>close</v-icon>
          </v-btn>
        </div>
      </v-toolbar-items>
    </v-toolbar>
    <v-card class="square-card">
      <v-card-text>
        <v-data-table
            :headers="headers"
            :items="details"
            :fixed-header="true"
            :items-per-page="-1"
            hide-default-footer
            id="proposal-commission-detail-table"
            class="elevation-1"
        >
          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2, 'selected-row': item.commissionKw === currentCommissionValue}">
              <td>
                {{item.redlineAmount}}
              </td>
              <td>
                {{item.sourceDiscount}}
              </td>
              <td>
                {{item.addersDollarWatts | currency('', 2) }}
              </td>
              <td>
                {{item.basePrice}}
              </td>
              <td>
                {{item.commissionsDollarWatts  | currency('', 2) }}
              </td>
              <td>
                {{item.totalPpw | currency('', 2)}}
              </td>
              <td>
                {{item.systemSize}}
              </td>
              <td>
                {{item.cashPrice | currency('', 2)}}
              </td>
              <td>
                {{item.loanAmount | currency('', 2)}}
              </td>
              <td>
                {{item.monthlyPayment | currency('', 2)}}
              </td>
              <td>
                {{item.commissionKw}}
              </td>
              <td>
                {{item.totalCommissions}}
              </td>
              <td>
                <v-btn v-if="currentCommissionValue !== item.commissionKw" @click="selectCommission(item)">Select</v-btn>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-card-text>
      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn @click="$emit('commissionDetailModalClosed')">Choose Custom Commission</v-btn>
      </v-card-actions>
    </v-card>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {getRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'CommissionDetailsModal',
    props: {
      proposalId: Number,
      currentCommissionValue: Number,
      selectCallback: Function
    },
    computed: {
    },
    created() {
      this.getCommissionDetails()
    },
    data() {
      return {
        snackbar: {},
        detailsLoading: true,
        details: [],
        headers: [
          {text: 'Redline', value: 'redlineAmount', show: true},
          {text: 'Source Discount', value: 'sourceDiscount', show: true},
          {text: 'Adders in $/Watt', value: 'addersDollarWatts', show: true},
          {text: 'Base Price', value: 'basePrice', show: true},
          {text: 'Commission in $/Watt', value: 'commissionsDollarWatts', show: true},
          {text: 'Total PPW', value: 'totalPpw', show: true},
          {text: 'System Size', value: 'systemSize', show: true},
          {text: 'Cash Price', value: 'cashPrice', show: true},
          {text: 'Loan Amount', value: 'loanAmount', show: true},
          {text: 'Monthly Payment', value: 'monthlyPayment', show: true},
          {text: 'Commission in $/kW', value: 'commissionKw', show: true},
          {text: 'Total Commission', value: 'totalCommissions', show: true},
          {text: null, value: 'icons', show: true},
        ],
      }
    },
    methods: {
      async getCommissionDetails () {
        try {
          this.detailsLoading = true
          const {data} = await getRequest(`/proposal/${this.proposalId}/commissionDetails`, 'blueraven', [])
          this.details = data
          this.detailsLoading = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving commission details')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },
      async selectCommission (item) {
        this.selectCallback(item.commissionKw)
      },
    }
  }
</script>

<style lang="scss">
#proposal-commission-detail-table table {
  border-collapse: collapse;
}
#proposal-commission-detail-table .selected-row {
  border: solid 3px blue !important;
}
</style>

<style lang="scss" scoped>
</style>

