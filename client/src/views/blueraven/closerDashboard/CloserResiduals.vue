<template>
  <v-container id="closer-residuals-container" ref="closerResidualsContainer">
    <v-row>
      <v-col cols="12">
          <v-toolbar color="white" class="elevation-1">
            <v-toolbar-title class="app-title flex-display">
              <v-btn text class="mr-2" @click="setViewingDate(false)"
                  :disabled="viewingDataFor === minDate">
                <v-icon>mdi-chevron-left</v-icon>
              </v-btn>
              <input type="month" id="viewing-date" name="viewing-date"
                     :min="minDate"
                     :max="maxDate"
                     :required="true"
                     @input="loadResidualData()"
                     v-model="viewingDataFor">
              <v-btn text class="ml-2" @click="setViewingDate(true)"
                   :disabled="viewingDataFor === currentMonth">
                <v-icon>mdi-chevron-right</v-icon>
              </v-btn>
            </v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
<!--            <div class="pt-4">-->
<!--              <v-btn @click="setViewingDate(false)">Last Month</v-btn>-->
<!--              <v-btn class="ml-3" @click="setViewingDate(true)">Current Month</v-btn>-->
<!--            </div>-->
            </v-toolbar-items>
          </v-toolbar>
      </v-col>
    </v-row>
    <v-card class="square-card pa-5 mb-3" v-if="isAdmin">
      <v-autocomplete v-model="selectedUserId"
                      :items="users"
                      label="Please select a user"
                      item-text="fullName"
                      item-value="id"
                      hide-details
                      attach
                      @change="loadResidualData()"
      ></v-autocomplete>
    </v-card>
    <div   v-if="!dataLoading && residualData && residualData.user_id">
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
              <td class="bold">
                {{ residualData.has_current_snapshot ? 'Total Residual Paid' : 'Expected Residual Payout'}}
              </td>
              <td class="residual-number-col">
                <span v-if="residualData.total_residual_paid < 0">({{residualData.total_residual_paid | currency('$', 0)}})</span>
                <span v-else>{{residualData.total_residual_paid | currency('$', 0)}}</span>
              </td>
            </tr>
          </table>
        </v-col>
        <v-col cols="12" md="4">
          <table class="residual-table" v-if="residualData.has_previous_snapshot">
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
          <div v-else class="residual-table">
            {{ residualData.no_previous_month_message }}
          </div>
        </v-col>
      </v-row>


    <v-card class="mt-3 square-card">
      <v-card-title>
        Monthly Residual Quota - Qualified FDC's
        <v-spacer></v-spacer>
        <div class="residual-total-count">Total: {{ residualData.qualified_fdc?.length || 0 }}</div>
      </v-card-title>
      <v-card-text>
        <v-data-table
          :headers="monthlyQualifiedHeaders"
          :items="residualData.qualified_fdc"
          :items-per-page="-1"
          single-expand
          dense
          :mobile-breakpoint="0"
          hide-default-footer
          class="elevation-0"
        >
          <template #item.project_id="{item}">
            <a @click="goToProject(item.project_id)">{{item.project_id}}</a>
          </template>
        </v-data-table>
      </v-card-text>
    </v-card>

    <v-card class="mt-3 square-card">
      <v-card-title>
        Current Clawbacks
        <v-spacer></v-spacer>
        <div class="residual-total-count">Total: {{residualData.clawback_projects?.length || 0}}</div>
      </v-card-title>
      <v-card-text>
        <v-data-table
          :headers="clawbackHeaders"
          :items="residualData.clawback_projects"
          :items-per-page="-1"
          single-expand
          :mobile-breakpoint="0"
          dense
          hide-default-footer
          class="elevation-0"
        >
          <template #item.project_id="{item}">
            <a @click="goToProject(item.project_id)">{{item.project_id}}</a>
          </template>
        </v-data-table>
      </v-card-text>
    </v-card>

    <v-card class="mt-3 square-card">
      <v-card-title>
        FDA in month - Not Qualifying
        <v-spacer></v-spacer>
        <div class="residual-total-count">Total: {{residualData.fda_in_month_not_qualifying?.length || 0}}</div>
      </v-card-title>
      <v-card-text>
        <v-data-table
          :headers="notQualifyingHeaders"
          :items="residualData.fda_in_month_not_qualifying"
          :items-per-page="-1"
          single-expand
          :mobile-breakpoint="0"
          hide-default-footer
          dense
          class="elevation-0"
        >
          <template #item.project_id="{item}">
            <a @click="goToProject(item.project_id)">{{item.project_id}}</a>
          </template>
        </v-data-table>
      </v-card-text>
    </v-card>


    <v-card class="mt-3 square-card">
      <v-card-title>
        Total Qualifying FDC's to date
        <v-spacer></v-spacer>
        <div class="residual-total-count">Total: {{residualData.total_qualifying_fdc_to_date?.length || 0}}</div>
      </v-card-title>
      <v-card-text>
        <v-text-field
          v-model="totalQualifyingSearch"
          prepend-inner-icon="search"
          label="Search"
          single-line
          dense
          hide-details
        ></v-text-field>
        <v-data-table
          :search="totalQualifyingSearch"
          :headers="totalQualifyingFdcHeaders"
          :items="residualData.total_qualifying_fdc_to_date"
          :options.sync="options"
          :footer-props="footerProps"
          :server-items-length="-1"
          dense
          class="elevation-0 mt-3"
        >
          <template #item.project_id="{item}">
            <a @click="goToProject(item.project_id)">{{item.project_id}}</a>
          </template>
        </v-data-table>
      </v-card-text>
    </v-card>
    </div>
    <v-card class="square-card pa-5" v-else-if="!dataLoading">
      {{ notAssignedMessage }}
    </v-card>
  </v-container>
</template>

<script>
  import constants from '@/helpers/constants'
  import { getRequest, getRequestWithParams, getSnackbar } from '@/helpers/helpers'
  import { AppMutations } from '@/stores/AppStore'
  import SpinnerInline from '@/components/SpinnerInline'
  import moment from 'moment'

  export default {
    name: 'closerResiduals',
    components: {
      SpinnerInline,
    },
    props: {
      isAdmin: Boolean
    },
    computed: {
      notAssignedMessage() {
        return this.isAdmin && this.selectedUserId === null ? 'You must select a user'
          : this.isAdmin ? 'This user is not assigned to a residual plan. Please contact an administrator.'
          : 'You are not assigned to a residual plan.  Please contact an administrator.'
      }
    },
    watch: {
    },
    created () {
      this.loadResidualData()
      if(this.isAdmin) {
        this.loadUsers()
      }
    },
    data () {
      return {
        snackbar: {},
        constants,
        users: [],
        selectedUserId: null,
        currentUserId: this.$store.state.user.details.id,
        residualData: {},
        totalQualifyingSearch: '',
        minDate: '2023-02',
        maxDate: moment().format('YYYY-MM'),
        currentMonth: moment().startOf('month').format('YYYY-MM'),
        viewingDataFor: moment().startOf('month').format('YYYY-MM'),
        usersLoading: true,
        dataLoading: true,
        totalQualifyingFdcHeaders: [
          {text: 'Contact Name', value: 'contact_name', show: true},
          {text: 'Project ID', value: 'project_id', show: true},
        ],
        monthlyQualifiedHeaders: [
          {text: 'Contact Name', value: 'contact_name', show: true},
          {text: 'Project ID', value: 'project_id', show: true},
          {text: 'FDA', value: 'final_design_signed_date', show: true},
          {text: 'FDC', value: 'final_design_complete_date', show: true},
          {text: 'Utility Bill Verified', value: 'utility_bill_verified_date', show: true},
          {text: 'FAS', value: 'financial_agreement_signed_date', show: true},
          {text: 'Proof Of Homeowners Insurance', value: 'proof_of_homeowners_insurance_obtained_date', show: true},
          {text: 'SC', value: 'substantial_completion_date', show: true},
          {text: 'Cancelled', value: 'cancelled_date', show: true},
          {text: 'On Hold', value: 'on_hold_date', show: true},
          {text: 'Total Cash Down Payment', value: 'total_cash_down_payment', show: true},
          {text: 'First Cash Payment Amount', value: 'first_cash_payment_amount', show: true},
        ],
        clawbackHeaders: [
          {text: 'Contact Name', value: 'contact_name', show: true},
          {text: 'Project ID', value: 'project_id', show: true},
          {text: 'Cancelled Date', value: 'cancelled_date', show: true},
          {text: 'Current Clawbacks', value: 'current_clawbacks', show: true},
          {text: 'Existing Clawbacks', value: 'existing_clawbacks', show: true},
        ],
        notQualifyingHeaders: [
          {text: 'Contact Name', value: 'contact_name', show: true},
          {text: 'Project ID', value: 'project_id', show: true},
          {text: 'FDA', value: 'final_design_signed_date', show: true},
          {text: 'FDC', value: 'final_design_complete_date', show: true},
          {text: 'Utility Bill Verified', value: 'utility_bill_verified_date', show: true},
          {text: 'FAS', value: 'financial_agreement_signed_date', show: true},
          {text: 'Proof Of Homeowners Insurance', value: 'proof_of_homeowners_insurance_obtained_date', show: true},
          {text: 'SC', value: 'substantial_completion_date', show: true},
          {text: 'Cancelled', value: 'cancelled_date', show: true},
          {text: 'On Hold', value: 'on_hold_date', show: true},
          {text: 'Total Cash Down Payment', value: 'total_cash_down_payment', show: true},
          {text: 'First Cash Payment Amount', value: 'first_cash_payment_amount', show: true},
        ],
        footerProps: {
          'items-per-page-options': [10, 20, 50],
          'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
        },
        options: {
          itemsPerPage: 20
        },
      }
    },
    methods: {
      setViewingDate(goForward) {
        this.viewingDataFor = goForward ? moment(this.viewingDataFor).add(1, 'month').format('YYYY-MM')
            : moment(this.viewingDataFor).subtract(1, 'month').format('YYYY-MM')
        this.loadResidualData()
      },
      goToProject(projectId) {
        this.$router.push(`/project/${projectId}`)
      },
      async loadUsers () {
        this.usersLoading = true
        try {
          const {data} = await getRequest('/closerDashboard/closers', 'blueraven')
          this.users = data
        } catch (e) {
          this.snackbar = getSnackbar('ERROR', 'Error retrieving users')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.usersLoading = false
        }
      },
      async loadResidualData () {
        if((this.isAdmin && this.selectedUserId != null) || !this.isAdmin) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          this.dataLoading = true
          try {
            this.viewingDataFor = this.viewingDataFor === '' ? this.currentMonth : this.viewingDataFor
            let params = {
              residualDate: moment(this.viewingDataFor).format('YYYY-MM-DD')
            }
            let url = this.isAdmin ? `/closerDashboard/residuals/${this.selectedUserId}` : '/closerDashboard/residuals'
            const {data} = await getRequestWithParams(url, {params}, 'blueraven')
            this.residualData = data
            this.dataLoading = false
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            this.snackbar = getSnackbar('ERROR', 'Error retrieving residual data')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.dataLoading = false
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        } else {
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

.residual-total-count {
  font-size: 14px;
}

input::-webkit-clear-button {
  display: none;
}

</style>
