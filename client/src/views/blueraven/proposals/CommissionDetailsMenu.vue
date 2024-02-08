<template>
  <v-menu
      v-model="displayDropdown"
      bottom
      offset-y
      min-width="350"
      :close-on-content-click="false"
      style="z-index: 10"
  >
    <template #activator="{on}">
      <v-btn text color="primary" x-small v-on="on" class="commission-detail-button">
        <v-icon>mdi-information</v-icon>
      </v-btn>
    </template>
    <v-card class="square-card" flat>
      <v-card-title>*Customer's Current Monthly Payment {{ proposalCommission.monthlyCostTodayWithoutSolar }}</v-card-title>
      <v-card-text class="pt-0">
        <v-data-table
            :headers="headers"
            :items="proposalCommission.commissionDetails"
            :fixed-header="true"
            disable-sort
            :items-per-page="-1"
            hide-default-footer
            id="proposal-commission-detail-table"
            class="elevation-1"
        >
          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2, 'selected-row': item.commission_kw === currentCommissionValue}">
              <td>
                {{item.loan_amount | currency('', 2)}}
              </td>
              <td>
                {{item.monthly_payment | currency('', 2)}}
              </td>
              <td>
                <v-chip v-if="item.recommended" color="success lighten-1" class="white--text">
                  {{ item.commission_kw }}
                </v-chip>

                <span v-else>{{item.commission_kw}}</span>
              </td>
              <td>
                {{item.total_commissions | currency('', 2)}}
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-card-text>
    </v-card>
  </v-menu>
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
        displayDropdown: false,
        detailsLoading: true,
        proposalCommission: {},
        headers: [
            //todo: tell scott he can take these out of the function
          // {text: 'Redline', value: 'redline_amount', show: true},
          // {text: 'Source Discount', value: 'source_discount', show: true},
          // {text: 'Adders in $/Watt', value: 'adders_dollar_watts', show: true},
          // {text: 'Base Price', value: 'base_price', show: true},
          // {text: 'Commission in $/Watt', value: 'commissions_dollar_watts', show: true},
          // {text: 'Total PPW', value: 'total_ppw', show: true},
          // {text: 'System Size', value: 'system_size', show: true},
          // {text: 'Cash Price', value: 'cash_price', show: true},
          // {text: 'Above Line Rebate', value: 'above_line_rebate', show: true},
          {text: 'Loan Amount', value: 'loan_amount', show: true},
          {text: 'Monthly Payment', value: 'monthly_payment', show: true},
          {text: 'Commission in $/kW', value: 'commission_kw', show: true},
          {text: 'Total Commission', value: 'total_commissions', show: true},
          // {text: null, value: 'icons', show: true},
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
    }
  }
</script>

<style lang="scss">
#commission-detail-modal-header .v-toolbar__title {
  font-size: 14px;
}
</style>

<style lang="scss" scoped>
.commission-detail-button {
  padding: 4px !important;
  height: 28px !important;
  margin-left: 5px;
  margin-right: -5px;
}
</style>

