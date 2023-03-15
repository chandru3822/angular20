<template>
  <v-container id="closer-residuals-container" ref="closerResidualsContainer" v-if="!dataLoading && residualData">
      <v-row>
        <v-col cols="12" md="4">
          <table class="residual-table">
            <tr>
              <td>Required FDC residual quota this period</td>
              <td class="residual-number-col">{{residualData.required_fdc_residual_this_period}}</td>
            </tr>
            <tr class="total-row">
              <td>Qualified FDC residual quota this period</td>
              <td class="residual-number-col">{{residualData.qualified_fdc_residual_this_period}}</td>
            </tr>
            <tr class="total-row">
              <td class="bold">Residual Qualified?</td>
              <td class="residual-number-col bold">{{residualData.residual_qualified ? 'Yes' : 'No'}}</td>
            </tr>
          </table>
        </v-col>
        <v-col cols="12" md="4">
          <table class="residual-table">
            <tr>
              <td>Potential Residual</td>
              <td class="residual-number-col">
                <span v-if="residualData.potential_residual < 0">({{residualData.potential_residual | currency('$', 0)}})</span>
                <span v-else>{{residualData.potential_residual | currency('$', 0)}}</span>
              </td>
            </tr>
            <tr>
              <td>Earned Residual</td>
              <td class="residual-number-col">
                <span v-if="residualData.earned_residual < 0">({{residualData.earned_residual | currency('$', 0)}})</span>
                <span v-else>{{residualData.earned_residual | currency('$', 0)}}</span>
              </td>
            </tr>
            <tr>
              <td>Clawback</td>
              <td class="residual-number-col">
                <span v-if="residualData.total_clawbacks < 0">({{residualData.total_clawbacks | currency('$', 0)}})</span>
                <span v-else>{{residualData.total_clawbacks | currency('$', 0)}}</span>
              </td>
            </tr>
            <tr>
              <td>Manual Adjustments</td>
              <td class="residual-number-col">
                <span v-if="residualData.manual_adjustments < 0">({{residualData.manual_adjustments | currency('$', 0)}})</span>
                <span v-else>{{residualData.manual_adjustments | currency('$', 0)}}</span>
              </td>
            </tr>
            <tr >
              <td class="bold">Total Residual Paid</td>
              <td class="residual-number-col">
                <span v-if="residualData.total_residual_paid < 0">({{residualData.total_residual_paid | currency('$', 0)}})</span>
                <span v-else>{{residualData.total_residual_paid | currency('$', 0)}}</span>
              </td>
            </tr>
          </table>
        </v-col>
        <v-col cols="12" md="4">
          <table class="residual-table">
            <tr>
              <td>Prior period qualified FDC's</td>
              <td class="residual-number-col">{{residualData.prior_period_qualified_fdc}}</td>
            </tr>
            <tr>
              <td>Qualified FDC's this period</td>
              <td class="residual-number-col">{{residualData.qualified_fdc_residual_this_period}}</td>
            </tr>
            <tr>
              <td>Cancelled FDC's during period</td>
              <td class="residual-number-col">{{residualData.cancelled_fdc_during_period}}</td>
            </tr>
            <tr>
              <td>Reactivated FDC's</td>
              <td class="residual-number-col">{{residualData.reactivated_fdc}}</td>
            </tr>
            <tr>
              <td class="bold">Residual Qualified FDC's</td>
              <td class="residual-number-col bold">{{residualData.residual_qualified_fdc}}</td>
            </tr>
          </table>
        </v-col>
      </v-row>


    <v-card class="mt-3">
      <v-card-title>
        Monthly Residual Quota - Qualified FDC's
        <v-spacer></v-spacer>
        Count: {{ residualData.qualified_fdc?.length || 0 }}
      </v-card-title>
      <v-card-text>
        <v-data-table
          :headers="monthlyQualifiedHeaders"
          :items="residualData.qualified_fdc"
          :items-per-page="-1"
          single-expand
          :mobile-breakpoint="0"
          hide-default-footer
          class="elevation-0"
        >
        </v-data-table>
      </v-card-text>
    </v-card>

    <v-card class="mt-3">
      <v-card-title>
        Current Clawbacks
        <v-spacer></v-spacer>
        Count: {{residualData.current_clawbacks?.length || 0}}
      </v-card-title>
      <v-card-text>
        <v-data-table
          :headers="clawbackHeaders"
          :items="residualData.current_clawbacks"
          :items-per-page="-1"
          single-expand
          :mobile-breakpoint="0"
          hide-default-footer
          class="elevation-0"
        >
        </v-data-table>
      </v-card-text>
    </v-card>

    <v-card class="mt-3">
      <v-card-title>
        FDA in month - Not Qualifying
        <v-spacer></v-spacer>
        Count: {{residualData.fda_in_month_not_qualifying?.length || 0}}
      </v-card-title>
      <v-card-text>
        <v-data-table
          :headers="notQualifyingHeaders"
          :items="residualData.fda_in_month_not_qualifying"
          :items-per-page="-1"
          single-expand
          :mobile-breakpoint="0"
          hide-default-footer
          class="elevation-0"
        >
        </v-data-table>
      </v-card-text>
    </v-card>


    <v-card class="mt-3">
      <v-card-title>
        Total Qualifying FDC's to date
        <v-spacer></v-spacer>
        Count: {{residualData.total_qualifying_fdc_to_date?.length || 0}}
      </v-card-title>
      <v-card-text>
        <v-data-table
          :headers="totalQualifyingFdcHeaders"
          :items="residualData.total_qualifying_fdc_to_date"
          :items-per-page="-1"
          single-expand
          :mobile-breakpoint="0"
          hide-default-footer
          class="elevation-0"
        >
        </v-data-table>
      </v-card-text>
    </v-card>
  </v-container>
</template>

<script>
  import constants from '@/helpers/constants'
  import { handleHidingGlobalLoader, getRequest, getSnackbar } from '@/helpers/helpers'
  import { AppMutations } from '@/stores/AppStore'
  import SpinnerInline from '@/components/SpinnerInline'

  export default {
    name: 'closerResiduals',
    components: {
      SpinnerInline,
    },
    computed: {
    },
    watch: {},
    created () {
      this.loadResidualData()
    },
    data () {
      return {
        snackbar: {},
        constants,
        currentUserId: this.$store.state.user.details.id,
        residualData: {},
        dataLoading: true,
        totalQualifyingFdcHeaders: [
          {text: 'Contact Name', value: 'contact_name', show: true},
          {text: 'Project ID', value: 'project_id', show: true},
          {text: 'Total', value: 'total', show: true},
        ],
        monthlyQualifiedHeaders: [
          {text: 'Contact Name', value: 'contact_name', show: true},
          {text: 'Project ID', value: 'project_id', show: true},
        ],
        clawbackHeaders: [
          {text: 'Contact Name', value: 'contact_name', show: true},
          {text: 'Project ID', value: 'project_id', show: true},
          {text: 'Total Clawbacks', value: 'total_clawbacks', show: true},
          {text: 'Existing Clawbacks', value: 'existing_clawbacks', show: true},
        ],
        notQualifyingHeaders: [
          {text: 'Contact Name', value: 'contact_name', show: true},
          {text: 'Project ID', value: 'project_id', show: true},
        ],
      }
    },
    methods: {
      async loadResidualData () {
        this.dataLoading = true
        try {
          const {data} = await getRequest('/closerDashboard/residuals', 'blueraven')
          this.residualData = data
          this.dataLoading = false
        } catch (e) {
          this.snackbar = getSnackbar('ERROR', 'Error retrieving residual data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.dataLoading = false
        }
      },

    },

  }
</script>
<style lang="scss" scoped>
.residual-table {
  border: solid black 2px;
  padding: 5px 10px;
  width: 100%;
  background: white;
}

.residual-number-col {
  padding: 0 15px;
  width: 50px;
}

.total-row {
  border-top: solid black 1px;
  border-bottom: solid black 1px;
}

</style>
