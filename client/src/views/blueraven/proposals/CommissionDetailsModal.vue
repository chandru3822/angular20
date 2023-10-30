<template>
  <v-container class="pa-0">
    <v-toolbar>
      <v-toolbar-title>
        Customer Current Monthly Payment {{ proposalCommission.monthlyCostTodayWithoutSolar }},  Loan Term {{ proposalCommission.loanTerm }}, APR {{ proposalCommission.apr }}
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
            :items="proposalCommission.commissionDetails"
            :fixed-header="true"
            :items-per-page="-1"
            hide-default-footer
            id="proposal-commission-detail-table"
            class="elevation-1"
        >
          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2, 'selected-row': item.commission_kw === currentCommissionValue}">
              <td>
                {{item.redline_amount}}
              </td>
              <td>
                {{item.source_discount}}
              </td>
              <td>
                {{item.adders_dollar_watts | currency('', 2) }}
              </td>
              <td>
                {{item.base_price | currency('', 2)}}
              </td>
              <td>
                {{item.commissions_dollar_watts  | currency('', 2) }}
              </td>
              <td>
                {{item.total_ppw | currency('', 2)}}
              </td>
              <td>
                {{item.system_size}}
              </td>
              <td>
                {{item.cash_price | currency('', 2)}}
              </td>
              <td>
                {{item.above_line_rebate | currency('', 2)}}
              </td>
              <td>
                {{item.loan_amount | currency('', 2)}}
              </td>
              <td>
                {{item.monthly_payment | currency('', 2)}}
              </td>
              <td>
                {{item.commission_kw}}
              </td>
              <td>
                {{item.total_commissions | currency('', 2)}}
              </td>
              <td>
                <v-btn v-if="currentCommissionValue !== item.commission_kw" @click="selectCommission(item)">Select</v-btn>
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
        proposalCommission: {},
        headers: [
          {text: 'Redline', value: 'redline_amount', show: true},
          {text: 'Source Discount', value: 'source_discount', show: true},
          {text: 'Adders in $/Watt', value: 'adders_dollar_watts', show: true},
          {text: 'Base Price', value: 'base_price', show: true},
          {text: 'Commission in $/Watt', value: 'commissions_dollar_watts', show: true},
          {text: 'Total PPW', value: 'total_ppw', show: true},
          {text: 'System Size', value: 'system_size', show: true},
          {text: 'Cash Price', value: 'cash_price', show: true},
          {text: 'Above Line Rebate', value: 'above_line_rebate', show: true},
          {text: 'Loan Amount', value: 'loan_amount', show: true},
          {text: 'Monthly Payment', value: 'monthly_payment', show: true},
          {text: 'Commission in $/kW', value: 'commission_kw', show: true},
          {text: 'Total Commission', value: 'total_commissions', show: true},
          {text: null, value: 'icons', show: true},
        ],
      }
    },
    methods: {
      async getCommissionDetails () {
        try {
          this.detailsLoading = true
          const {data} = await getRequest(`/proposal/${this.proposalId}/commissionDetails`, 'blueraven', [])
          this.proposalCommission = data
          this.detailsLoading = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving commission details')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },
      async selectCommission (item) {
        this.selectCallback(item.commission_kw)
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

