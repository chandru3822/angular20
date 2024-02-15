<template>
  <v-menu
      v-model="displayDropdown"
      bottom
      attach
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
    <div>
      <v-card v-if="detailsLoading" class="square-card">
        <SpinnerInline :size="20" color="primary"/>
      </v-card>
      <v-card v-else-if="!detailsLoading && fieldError" class="square-card">
        <v-card-title class="error--text">Error Loading Details</v-card-title>
        <v-card-text>
          <div class="error--text">{{fieldErrorMsg}}</div>
        </v-card-text>
      </v-card>
      <v-card v-else-if="commissionDetails && commissionDetails.length > 0" class="square-card" flat>
        <v-card-title>*Customer's Current Monthly Payment {{ commissionDetails[0].monthlyCostTodayWithoutSolar }}</v-card-title>
        <v-card-text class="pt-0">
          <v-data-table
              :headers="headers"
              :items="commissionDetails"
              :fixed-header="true"
              disable-sort
              :items-per-page="-1"
              hide-default-footer
              id="proposal-commission-detail-table"
              class="elevation-1"
          >
            <template #item="{ item, index }">
              <tr :class="{'shaded-row': index % 2, 'selected-row': item.commissionKw === currentCommissionValue}">
                <td>
                  {{item.loanAmount | currency('', 2)}}
                </td>
                <td>
                  {{item.monthlyPayment | currency('', 2)}}
                </td>
                <td>
                  <v-chip v-if="item.recommended" color="success lighten-1" class="white--text">
                    {{ item.commissionKw }}
                  </v-chip>

                  <span v-else>{{item.commissionKw}}</span>
                </td>
                <td>
                  {{item.totalCommissions | currency('', 2)}}
                </td>
              </tr>
            </template>
          </v-data-table>
        </v-card-text>
      </v-card>
    </div>
  </v-menu>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {getRequestWithParams, getSnackbar} from '@/helpers/helpers'
  import SpinnerInline from '@/components/SpinnerInline'

  export default {
    name: 'CommissionDetailsModal',
    components: {
      SpinnerInline
    },
    props: {
      proposalId: Number,
      customFieldGroups: Array,
      currentCommissionValue: Number,
      selectCallback: Function
    },
    watch: {
      displayDropdown: function () {
        if(this.displayDropdown) {
          this.getCommissionDetails()
        }
      }
    },
    computed: {
    },
    created() {
    },
    data() {
      return {
        snackbar: {},
        displayDropdown: false,
        detailsLoading: true,
        fieldError: false,
        fieldErrorMsg: '',
        commissionDetails: [],
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
          {text: 'Loan Amount', value: 'loanAmount', show: true},
          {text: 'Monthly Payment', value: 'monthlyPayment', show: true},
          {text: 'Commission in $/kW', value: 'commissionKw', show: true},
          {text: 'Total Commission', value: 'totalCommissions', show: true},
          // {text: null, value: 'icons', show: true},
        ],
        //i think BR is about to add a lot of fields to this list so i did it this funky but hopefully reusable way
        fieldsToSend: [
          { name: 'Financial Product', cfgId: 27, cfgaId: 155, dataField: 'intValue', backendProp: 'financialProductId', value: null, required: true},
          { name: 'BRS Product', cfgId: 27, cfgaId: 147, dataField: 'intValue', backendProp: 'brsProductId', value: null, required: true},
        ]
      }
    },
    methods: {
      getFieldValue(cfgId, cfgaId, dataValue) {
        let cfg = this.customFieldGroups.find(cfg => cfg.id === cfgId)
        let cf = cfg?.customFieldValues?.find(cf => cf.customFieldGroupAssignmentId === cfgaId)
        return cf ? cf[dataValue] : null
      },
      async getCommissionDetails () {
        try {
          this.detailsLoading = true
          this.fieldsToSend.forEach(f => {
            f.value = this.getFieldValue(f.cfgId, f.cfgaId, f.dataField)
          })
          let emptyRequiredFields = this.fieldsToSend.filter(f => f.required && !f.value)
          if(emptyRequiredFields.length === 0) {
            this.fieldError = false
            this.fieldErrorMsg = ''
            let params = {}
            this.fieldsToSend.forEach(f => {
              params[f.backendProp] = f.value
            })
            console.log('params',params)
            const {data} = await getRequestWithParams(`/proposal/${this.proposalId}/commissionDetails`, {params}, 'blueraven', [])
            this.commissionDetails = data
          } else {
            this.fieldError = true
            let conjunction = emptyRequiredFields.length === 1 ? ' is' : ' and'
            let fieldString = ''
            emptyRequiredFields.forEach((f, idx) => {
              if(idx !== 0) {
                fieldString = fieldString + ' and '
              }
              fieldString = fieldString + f.name
            })
            this.fieldErrorMsg = fieldString + conjunction + ' required to load commission details.'
          }
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.fieldError = true
          this.fieldErrorMsg = 'Error retrieving commission details'
          this.snackbar = getSnackbar('ERROR', 'Error retrieving commission details')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } finally {
          this.detailsLoading = false
        }
      },
    }
  }
</script>

<style lang="scss">
#commission-detail-modal-header .v-toolbar__title {
  font-size: 14px;
}

.v-menu--attached {
  display: contents;
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

