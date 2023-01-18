<template>
  <v-container class="pa-0" id="payroll-container">
    <v-toolbar v-if="!payrollLoading && !additionalPayrollDataNeeded" :color="payrollStatus.color" class="mt-2">
      <v-toolbar-title class="app-title" :style="{'color': payrollStatus.textColor}">
        {{payrollStatus.message}}
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <div class="flex-display align-center" >
          <v-btn v-if="payrollStatus.action && $store.getters.userHasFeatureAccessLevel('COMMISSIONS', 'ADD')" :color="payrollStatus.actionColor"
                 class="white--text" @click="submitForApproval(payrollStatus.action)">
            {{payrollStatus.actionText}}
          </v-btn>
          <!-- currently only "Approve" has a secondary action which requires a dialog confirm. will have to update if that changes -->
          <v-dialog
            v-if="payrollStatus.secondaryAction && $store.getters.userHasFeatureAccessLevel('COMMISSIONS', 'ADMIN')"
            v-model="approveConfirm"
            width="500">
            <template v-slot:activator="{ on }">
              <v-btn v-on="on" :color="payrollStatus.secondaryActionColor" class="white--text ml-3">
                {{payrollStatus.secondaryActionText}}
              </v-btn>
            </template>
            <v-card>
              <v-card-title
                class="text-h5 grey lighten-2"
                primary-title
              >
                Confirm
              </v-card-title>

              <v-card-text class="pt-3">
                Are you sure you want to approve this payroll?

                <DatetimePickerInput
                  v-model="payDate"
                  :timezone="this.timezone"
                  :type="'date'"
                  :format="'MMMM DD, YYYY'"
                  label="Date Paid"
                />
              </v-card-text>


              <v-divider></v-divider>

              <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn
                  @click="approveConfirm = false">
                  No
                </v-btn>
                <v-btn
                  color="primary"
                  class="white--text"
                  :disabled="null == payDate"
                  @click="submitForApproval(payrollStatus.secondaryAction)">
                  Yes
                </v-btn>
              </v-card-actions>
            </v-card>
          </v-dialog>
        </div>
      </v-toolbar-items>
    </v-toolbar>
    <v-form ref="accountingForm">
      <v-container>
        <v-row>
          <v-col cols="12" sm="6">
            <v-card flat color="transparent" class="pa-3">
              <v-text-field text readonly label="Payroll ID #" v-model="currentPayroll.id"></v-text-field>
              <DatetimePickerInput
                  v-model="currentPayroll.periodEnd"
                  :timezone="this.timezone"
                  :readonly="!userCanEdit"
                  :disabled="!userCanEdit"
                  :type="'date'"
                  :format="'MMMM DD, YYYY'"
                  label="Period Ending"
              />
              <v-text-field text
                            label="Description"
                            placeholder=" "
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
                            v-model="currentPayroll.description"></v-text-field>

              <div class="text-left">
                <v-btn color="primary" dark v-if="userCanEdit" @click="saveChangesToPayroll()">Save Changes</v-btn>
                <v-btn color="primary" class="ml-3" dark @click="exportAccountingReview()">Export</v-btn>
              </div>
            </v-card>
          </v-col>
          <v-col cols="12" sm="6">
            <v-card class="pa-3">
              <label>Approved for Pay Only:</label>
              <input type="checkbox" class="ml-2" v-model="accountingSearch.showSelectedOnly">
              <v-text-field text
                            class="mt-3"
                            label="Project ID"
                            v-model="accountingSearch.projectId"></v-text-field>
              <v-autocomplete v-model="accountingSearch.customerId"
                              :items="customers"
                              :loading="customersLoading"
                              :search-input.sync="customerSearch"
                              label="Customer..."
                              clearable
                              item-text="fullName"
                              item-value="id"
                              autocomplete="off"
                              type="search"
                              @click:clear="customers = []"
                              attach
              ></v-autocomplete>

              <div class="text-left">
                <v-btn color="primary" dark @click="getAccountingData()">Search</v-btn>
                <v-btn class="ml-3" text color="primary" @click="[accountingSearch = {}, getAccountingData()]">Reset</v-btn>
              </div>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
    </v-form>
    <v-row>
      <v-col>
        <v-card>
          <v-card-title class="pt-0">
            <v-text-field
              v-model="search"
              prepend-inner-icon="search"
              label="Search"
              single-line
              hide-details
              @input="debounceSearch"
            ></v-text-field>
          </v-card-title>
          <v-divider></v-divider>
          <v-data-table
              :headers="headers"
              :items="accountingData"
              :fixed-header="true"
              :search="debouncedSearch"
              :footer-props="footerProps"
              :mobile-breakpoint="0"
              :show-select="payrollStatus.showSelect"
              :loading="dataLoading"
              :items-per-page="25"
              class="elevation-1"
              id="tester-face"
          >
            <template #no-data>
              <span class="default-text-color">No available accounting data</span>
            </template>

            <template #no-results>
              <span class="default-text-color">No available accounting data</span>
            </template>

            <template v-slot:header.data-table-select="{ on, props }">
              <v-checkbox color="primary" v-model="selectAll" @change="toggleSelectAll()"></v-checkbox>
            </template>

            <template #item="{ item, index }">
              <tr :class="{'shaded-row': index % 2, 'error--text': item.closer_is_terminated }" v-if="positionId === 1">
                <td v-if="payrollStatus.showSelect">
                  <v-checkbox color="primary" v-model="item.selected" @change="toggleSingleSelect(item)"></v-checkbox>
                </td>
                <td class="text-left">{{item.project_id}}</td>
                <td class="text-left">{{item.customer_name }}</td>
                <td class="text-left">{{item.system_size }}</td>
                <td class="text-left">{{item.closer }}</td>
                <td class="text-left">{{item.user_id }}</td>
                <td class="text-left">{{item.employee_id }}</td>
                <td class="text-left">{{item.current_pay || 0 | currency('$', 2)}}</td>
                <td class="text-left">{{item.source_name }}</td>
                <td class="text-left">{{item.cancelled_date }}</td>
                <td class="text-left">{{item.installation_agreement_signed_date | formatDate('date') }}</td>
                <td class="text-left">{{item.final_design_signed_date | formatDate('date') }}</td>
                <td class="text-left">{{item.agreement_signed_date | formatDate('date') }}</td>
                <td class="text-left">{{item.utility_bill_verified_date | formatDate('date') }}</td>
                <td class="text-left"></td>
                <td class="text-left">{{item.percent_of_cash_deposit }}</td>
                <td class="text-left">{{item.proof_of_homeowners_insurance_obtained_date | formatDate('date') }}</td>
                <td class="text-left">{{item.proof_of_howmeowners_insurance_required }}</td>
                <td class="text-left">{{item.substantial_completion_date | formatDate('date') }}</td>
                <td class="text-left">{{item.commission_plan }}</td>
                <td class="text-left">{{item.commission_earned || 0 | currency('$', 2) }}</td>
                <td class="text-left">{{item.commission_paid_to_date || 0 | currency('$', 2) }}</td>
                <td class="text-left">
                  {{ item.commission_adjustments || 0 | currency('$', 2) }}

                  <v-dialog
                    v-if="userCanAdd"
                    v-model="item.dialog"
                    width="500">
                    <template v-slot:activator="{ on }">
                      <v-btn x-small color="primary" dark fab class="ml-2" v-on="on"
                             @click="[delete item.adjustment, delete item.adjustmentNote, getAdjustmentHistory(item)]" >
                        <v-icon>add</v-icon>
                      </v-btn>
                    </template>
                    <v-card>
                      <v-card-title class="text-h5 grey lighten-2" primary-title>
                        Add Adjustment
                      </v-card-title>
                      <v-card-text class="pt-3">
                        <strong>Type: </strong>Commission
                        <v-text-field text
                                      type="number"
                                      label="Adjustment Amount"
                                      prepend-icon="mdi-currency-usd"
                                      persistent-hint
                                      :hint="`Max allowed: ${$filters.currency(item.remaining_value, '$', 2)}`"
                                      v-model.number="item.adjustment">
                        </v-text-field>
                        <v-textarea
                          label="Notes"
                          v-model="item.adjustmentNote"
                        ></v-textarea>
                        <v-data-table
                          :headers="adjustmentHistoryHeaders"
                          :items="item.adjustmentHistory"
                          :fixed-header="true"
                          :items-per-page="-1"
                          disable-sort
                          hide-default-footer
                          class="elevation-1"
                          v-if="item.adjustmentHistory && item.adjustmentHistory.length > 0"
                        >
                          <template #item.amount="{ item }">
                            {{item.amount | currency('$', 2)}}
                          </template>
                          <template #item.created="{ item }">
                            {{item.created | formatDate('date')}}
                          </template>
                        </v-data-table>
                        <div v-else>
                          No adjustments have been made for this project.
                        </div>
                      </v-card-text>
                      <v-divider></v-divider>
                      <v-card-actions>
                        <v-spacer></v-spacer>
                        <v-btn @click="item.dialog = false">
                          Cancel
                        </v-btn>
                        <v-btn color="primary" class="white--text"
                               :disabled="!item.adjustment || item.adjustment === 0 || !item.adjustmentNote || item.adjustment > item.remaining_value"
                               @click="addAdjustment(item)">
                          Add
                        </v-btn>
                      </v-card-actions>
                    </v-card>
                  </v-dialog>
                </td>
                <td class="text-left">{{item.current_pay_commissions || 0 | currency('$', 2) }}</td>
                <td class="text-left">{{item.remaining_value_commissions || 0 | currency('$', 2) }}</td>
                <td class="text-left">{{item.override_plan }}</td>
                <td class="text-left">{{item.override_earned || 0 | currency('$', 2) }}</td>
                <td class="text-left">{{item.overrides_paid_to_date || 0 | currency('$', 2) }}</td>
                <td class="text-left">{{item.current_pay_overrides || 0 | currency('$', 2) }}</td>
                <td class="text-left">{{item.remaining_value_overrides || 0 | currency('$', 2) }}</td>
              </tr>
              <tr :class="{'shaded-row': index % 2, 'error--text': item.closer_is_terminated }" v-else>
                <td v-if="payrollStatus.showSelect">
                  <v-checkbox color="primary" v-model="item.selected" @change="toggleSingleSelect(item)"></v-checkbox>
                </td>
                <td class="text-left">{{item.project_id}}</td>
                <td class="text-left">{{item.project_name }}</td>
                <td class="text-left">{{item.setter }}</td>
                <td class="text-left">{{item.current_pay || 0 | currency('$', 2)}}</td>
                <td class="text-left">{{item.source_name }}</td>
                <td class="text-left">{{item.cancelled_date }}</td>
                <td class="text-left">{{item.closer_appointment_start  | formatDate('date') }}</td>
                <td class="text-left">{{item.closer_appointment_outcome }}</td>
                <td class="text-left">{{item.commission_plan }}</td>
                <td class="text-left">{{item.commission_earned || 0 | currency('$', 2) }}</td>
                <td class="text-left">{{item.commission_paid_to_date || 0 | currency('$', 2) }}</td>
                <td class="text-left">
                  {{ item.commission_adjustments || 0 | currency('$', 2) }}

                  <v-dialog
                    v-if="userCanAdd"
                    v-model="item.dialog"
                    width="500">
                    <template v-slot:activator="{ on }">
                      <v-btn x-small color="primary" dark fab class="ml-2" v-on="on"
                             @click="[delete item.adjustment, delete item.adjustmentNote, getAdjustmentHistory(item)]" >
                        <v-icon>add</v-icon>
                      </v-btn>
                    </template>
                    <v-card>
                      <v-card-title class="text-h5 grey lighten-2" primary-title>
                        Add Adjustment
                      </v-card-title>
                      <v-card-text class="pt-3">
                        <strong>Type: </strong>Commission
                        <v-text-field text
                                      type="number"
                                      label="Adjustment Amount"
                                      prepend-icon="mdi-currency-usd"
                                      persistent-hint
                                      :hint="`Max allowed: ${$filters.currency(item.remaining_value, '$', 2)}`"
                                      v-model.number="item.adjustment">
                        </v-text-field>
                        <v-textarea
                          label="Notes"
                          v-model="item.adjustmentNote"
                        ></v-textarea>
                        <v-data-table
                          :headers="adjustmentHistoryHeaders"
                          :items="item.adjustmentHistory"
                          :fixed-header="true"
                          :items-per-page="-1"
                          disable-sort
                          hide-default-footer
                          class="elevation-1"
                          v-if="item.adjustmentHistory && item.adjustmentHistory.length > 0"
                        >
                          <template #item.amount="{ item }">
                            {{item.amount | currency('$', 2)}}
                          </template>
                          <template #item.created="{ item }">
                            {{item.created | formatDate('date')}}
                          </template>
                        </v-data-table>
                        <div v-else>
                          No adjustments have been made for this project.
                        </div>
                      </v-card-text>
                      <v-divider></v-divider>
                      <v-card-actions>
                        <v-spacer></v-spacer>
                        <v-btn @click="item.dialog = false">
                          Cancel
                        </v-btn>
                        <v-btn color="primary" class="white--text"
                               :disabled="!item.adjustment || item.adjustment === 0 || !item.adjustmentNote || item.adjustment > item.remaining_value"
                               @click="addAdjustment(item)">
                          Add
                        </v-btn>
                      </v-card-actions>
                    </v-card>
                  </v-dialog>
                </td>
                <td class="text-left">{{item.current_pay_commissions || 0 | currency('$', 2) }}</td>
                <td class="text-left">{{item.override_plan }}</td>
                <td class="text-left">{{item.override_earned || 0 | currency('$', 2) }}</td>
                <td class="text-left">{{item.overrides_paid_to_date || 0 | currency('$', 2) }}</td>
                <td class="text-left">{{item.current_pay_overrides || 0 | currency('$', 2) }}</td>
              </tr>
            </template>

            <template v-slot:body.append="{headers}">
              <tr>
                <td v-for="(header,i) in headers" :key="i" class="font-weight-bold">

                  <div v-if="header.value === 'closer' || header.value === 'setter'">
                    Total Pay:
                  </div>
                  <div v-if="header.value === 'current_pay'">
                    {{ totalPay | currency('$', 2) }}
                  </div>

                </td>
              </tr>
            </template>
          </v-data-table>
        </v-card>
      </v-col>
    </v-row>

  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import cloneDeep from 'lodash.clonedeep'
  import {handleHidingGlobalLoader, getRequest, postRequest, getSnackbar, getRequestWithParams} from '@/helpers/helpers'
  import Vue2Filters from "vue2-filters";
  import constants from "@/helpers/constants";
  import sumBy from "lodash.sumby";
  import { saveAs } from 'file-saver'
  import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'

  export default {
    name: 'CurrentPayroll',
    mixins: [Vue2Filters.mixin],
    components: {
      CustomValueInput,
      DatetimePickerInput
    },
    watch: {
      '$store.state.brs.commissionPositionId': function () {
        this.positionId = this.$store.state.brs.commissionPositionId
        this.getCurrentPayroll()
      },
      customerSearch (val) {
        if(!val) {
          this.customers = []
          this.accountingSearch.customerId = null
          return
        }
        this.customers = []
        this.getCustomersDebounced(val)
      },
      repSearch (val) {
        if(!val) {
          this.accountingSearch.salesRepId = null
          this.reps = []
          return
        }
        this.reps = []
        this.getRepsDebounced(val)
      }
    },
    data() {
      return {
        snackbar: {},
        dataLoading: true,
        selectAll: false,
        customers: [],
        userCanAdd: this.$store.getters.userHasFeatureAccessLevel('COMMISSIONS', 'ADD'),
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('COMMISSIONS', 'EDIT'),
        customerSearch: null,
        customersLoading: false,
        positionId: this.$store.state.brs.commissionPositionId,
        reps: [],
        repSearch: null,
        repsLoading: false,
        approveConfirm: false,
        search: '',
        debouncedSearch: '',
        payDate: null,
        additionalPayrollDataNeeded: false,
        payrollLoading: true,
        payrollSummary: [],
        timezone: this.$store.state.user.details.timezone.value,
        adjustmentHistoryHeaders: [
          {text: 'Adjustment Type', value: 'adjustmentType', show: true},
          {text: 'Amount', value: 'amount', show: true},
          {text: 'Note', value: 'note', show: true},
          {text: 'Created By', value: 'createdBy', show: true},
          {text: 'Created', value: 'created', show: true},
        ],
        accountingData: [],
        masterSelectedPayrollIds: [],
        // options: {
        //   // itemsPerPage: 100
        //   itemsPerPage: 10
        // },
        footerProps: {
          'items-per-page-options': [25, 50, 100, 500, 1000],
          'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
        },
        currentPayroll: {},
        payrollStatus: {},
        accountingSearch: {},
        totalPay: null,
        closerHeaders: [
          // {text: 'Select For Pay', value: 'select', show: true},
          {text: 'Project ID', value: 'project_id', show: true},
          {text: 'Customer Name', value: 'customer_name', show: true},
          {text: 'System Size (kW)', value: 'system_size', show: true},
          {text: 'Sales Rep', value: 'closer', show: true},
          {text: 'User ID', value: 'user_id', show: true},
          {text: 'Employee ID', value: 'employee_id', show: true},
          {text: 'Current Pay', value: 'current_pay', show: true},
          {text: 'Source', value: 'source_name', show: true},
          {text: 'Cancelled', value: 'cancelled_date', show: true},
          {text: 'IAS', value: 'installation_agreement_signed_date', show: true},
          {text: 'FDS', value: 'final_design_signed_date', show: true},
          {text: 'FAS', value: 'agreement_signed_date', show: true},
          {text: 'Utility Bill Verified', value: 'utility_bill_verified_date', show: true},
          // i dont think deposit date is being returned
          {text: 'Deposit', value: '', show: true},
          {text: '%/$ Dep', value: 'percent_of_cash_deposit', show: true},
          {text: 'HOI', value: 'proof_of_homeowners_insurance_obtained_date', show: true},
          {text: 'HOI-R', value: 'proof_of_howmeowners_insurance_required', show: true},
          {text: 'SC', value: 'substantial_completion_date', show: true},
          {text: 'Commission Plan', value: 'commission_plan', show: true},
          {text: 'Commissions Earned', value: 'commission_earned', show: true},
          {text: 'Commission Paid to Date', value: 'commission_paid_to_date', show: true},
          {text: 'Adjustment', value: 'commission_adjustments', width: 150, show: true},
          {text: 'Commission Pay', value: 'current_pay_commissions', show: true},
          {text: 'Remaining Value Commissions', value: 'remaining_value_commissions', show: true},
          {text: 'Override Plan', value: 'override_plan', show: true},
          {text: 'Override Earned', value: 'override_earned', show: true},
          {text: 'Overrides Paid to Date', value: 'overrides_paid_to_date', show: true},
          {text: 'Override Pay', value: 'current_pay_overrides', show: true},
          {text: 'Remaining Value Overrides', value: 'remaining_value_overrides', show: true},
        ],
        setterHeaders: [
          // {text: 'Select For Pay', value: 'select', show: true},
          {text: 'Project ID', value: 'project_id', show: true},
          {text: 'Customer Name', value: 'customer_name', show: true},
          {text: 'Setter', value: 'setter', show: true},
          {text: 'User ID', value: 'user_id', show: true},
          {text: 'Current Pay', value: 'current_pay', show: true},
          {text: 'Source', value: 'source_name', show: true},
          {text: 'Cancelled', value: 'cancelled_date', show: true},
          {text: 'Appointment Date', value: 'appointment_date', show: true},
          {text: 'Appointment Outcome', value: 'appointment_outcome', show: true},
          {text: 'Commission Plan', value: 'commission_plan', show: true},
          {text: 'Commissions Earned', value: 'commission_earned', show: true},
          {text: 'Commission Paid to Date', value: 'commission_paid_to_date', show: true},
          {text: 'Adjustment', value: 'commission_adjustments', width: 150, show: true},
          {text: 'Commission Pay', value: 'current_pay_commissions', show: true},
          {text: 'Override Plan', value: 'override_plan', show: true},
          {text: 'Override Earned', value: 'override_earned', show: true},
          {text: 'Overrides Paid to Date', value: 'overrides_paid_to_date', show: true},
          {text: 'Override Pay', value: 'current_pay_overrides', show: true},
        ],
      }
    },
    computed: {
      headers() {
        return this.positionId === 1 ? this.closerHeaders : this.setterHeaders
      }
    },
    created() {
      this.getCurrentPayroll()
    },
    methods: {
      toggleSelectAll () {
        this.accountingData.forEach(ad => {
          ad.selected = this.selectAll
        })
        if(this.selectAll) {
          this.currentPayroll.selectedProjectIds = this.accountingData.map(ad => ad.project_id)
        } else {
          this.currentPayroll.selectedProjectIds = []
        }
      },
      toggleSingleSelect(item) {
        if(item.selected) {
          this.currentPayroll.selectedProjectIds.push(item.project_id)
        } else {
          this.currentPayroll.selectedProjectIds = this.currentPayroll.selectedProjectIds.filter(p => p !== item.project_id)
        }
      },
      async submitForApproval (action) {
        //to avoid any unsaved changes prior to approval we are just saving changes prior to submitting
        const val = await this.saveChangesToPayroll(true)
        //dont submit for approval if the save changes request failed
        if(val) {
          this.totalPay = sumBy(this.accountingData,  function(o) { return o.selected ? o.current_pay : 0 })
          let selectedIds = this.accountingData.filter(ad => ad.selected).map(ad => ad.project_id)
          let params = {
            payDate: this.payDate
          }
          if(this.payrollStatus.showSelect && (!selectedIds || selectedIds.length === 0)) {
            this.snackbar = getSnackbar('WARNING', 'You must select at least one project.')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          } else {
            this.$store.commit(AppMutations.SET_LOADING, true)
            try {
              await postRequest(`/payroll/${this.currentPayroll.id}/${action}`, params, 'blueraven')
              this.snackbar = getSnackbar('SUCCESS', 'Successfully Updated')
              this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
              await this.getCurrentPayroll()
            } catch (e) {
              console.error('*** ERROR ***', e)
              this.snackbar = getSnackbar('ERROR', 'Error Updating')
              this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
              this.$store.commit(AppMutations.SET_LOADING, false)
            }
          }
        }
      },
      async getAdjustmentHistory (item) {
        try {
          let params = {
            projectId: item.project_id
          }
          const {data} = await getRequestWithParams(`/payroll/${this.currentPayroll.id}/adjustments`, {params}, 'blueraven')
          this.$set(item, 'adjustmentHistory', data)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Adjustment History')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async addAdjustment (item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            projectId: item.project_id,
            userId: item.user_id,
            adjustmentType: 'COMMISSION',
            maxAmount: item.remaining_value,
            amount: item.adjustment,
            note: item.adjustmentNote
          }
          await postRequest(`/payroll/${this.currentPayroll.id}/adjustments`, params, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Adjustment Added')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          await this.getCurrentPayroll()
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Adjustment')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveChangesToPayroll (keepLoading) {
        let params = {
          description: this.currentPayroll.description,
          periodEnd: this.currentPayroll.periodEnd,
          projectIds: this.currentPayroll.selectedProjectIds
        }
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await postRequest(`/payroll/${this.currentPayroll.id}`, params, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Successfully Updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.currentPayroll = data
          this.totalPay = sumBy(this.accountingData,  function(o) { return o.selected ? o.current_pay : 0 })
          this.additionalPayrollDataNeeded = null == this.currentPayroll.periodEnd || null == this.currentPayroll.description
          this.getStatusColor()
          if(null != this.currentPayroll.periodEnd) {
            await this.getCurrentPayroll()
          } else {
            this.dataLoading = false
            this.accountingData = []
          }
          if(!keepLoading) {
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
          return true
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Updating')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
          return false
        }
      },
      getStatusColor () {
        this.payrollStatus = {}
        switch(this.currentPayroll.status) {
          case 'PENDING':
            this.payrollStatus.message = 'This payroll is pending.'
            this.payrollStatus.color = '#DCDCDC'
            this.payrollStatus.showSelect = true
            this.payrollStatus.action = 'submit'
            this.payrollStatus.actionText = 'Submit For Approval'
            this.payrollStatus.actionColor = 'primary'
            break
          case 'SUBMITTED':
            this.payrollStatus.message = 'This payroll has been Submitted.'
            this.payrollStatus.color = '#DCDCDC'
            this.payrollStatus.showSelect = false
            this.payrollStatus.action = 'reject'
            this.payrollStatus.actionText = 'Reject'
            this.payrollStatus.actionColor = 'error'
            this.payrollStatus.secondaryAction = 'approve'
            this.payrollStatus.secondaryActionText = 'Approve'
            this.payrollStatus.secondaryActionColor = 'green'
            break
          case 'REJECTED':
            this.payrollStatus.message = 'This payroll has been Rejected.'
            this.payrollStatus.color = 'error'
            this.payrollStatus.textColor = 'white'
            this.payrollStatus.showSelect = true
            this.payrollStatus.action = 'submit'
            this.payrollStatus.actionText = 'Submit For Approval'
            this.payrollStatus.actionColor = 'primary'
            break
          default:
            this.payrollStatus = {}
        }
      },
      async getCurrentPayroll () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/payroll/current/${this.positionId}`, 'blueraven', [])
          this.currentPayroll = data

          this.masterSelectedPayrollIds = cloneDeep(this.currentPayroll.selectedProjectIds)
          this.getStatusColor()
          this.payrollLoading = false
          this.additionalPayrollDataNeeded = null == this.currentPayroll.periodEnd || null == this.currentPayroll.description
          if(null != this.currentPayroll.periodEnd) {
            await this.getAccountingData()
          } else {
            this.dataLoading = false
            this.accountingData = []
          }
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Current Payroll')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getAccountingData () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            payrollId: this.currentPayroll.id,
            periodEnd: this.currentPayroll.periodEnd,
            projectId: this.accountingSearch.projectId,
            customerId: this.accountingSearch.customerId,
            salesRepId: this.accountingSearch.salesRepId,
            positionId: this.positionId
          }
          if(this.currentPayroll?.status !== 'PENDING' && this.currentPayroll?.status !== 'REJECTED') {
            params.selectedProjectIds = this.currentPayroll.selectedProjectIds
          }
          const {data} = await postRequest(`/commissionManagement/accountReview/search`, params, 'blueraven', [])
          this.accountingData = []
          data.forEach(d => {
            d.selected = !!this.currentPayroll.selectedProjectIds?.includes(d.project_id)
            if(this.accountingSearch?.showSelectedOnly && d.selected) {
              this.accountingData.push(d)
            }
          })
          if(!this.accountingSearch?.showSelectedOnly) {
            this.accountingData = data
          }
          if(this.currentPayroll?.selectedProjectIds?.length === data.length) {
            this.selectAll = true
          }

          this.totalPay = sumBy(this.accountingData,  function(o) { return o.selected ? o.current_pay : 0 })

          this.dataLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Accounting Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      getCustomersDebounced(val) {
        clearTimeout(this._searchTimerId)
        this._searchTimerId = setTimeout(() => {
          this.getCustomers(val)
        }, 500) /* 500ms throttle */
      },
      async getCustomers(query) {
          this.customersLoading = true
          try {
            let params = {
              query,
              size: 10
            }
            const {data} = await getRequestWithParams(`/contact/search`, {params})
            this.customers = data.content
            this.customersLoading = false
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving Customers')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          }
      },
      debounceSearch () {
        clearTimeout(this._textSearchTimerId)
        this._textSearchTimerId = setTimeout(() => {
          this.debouncedSearch = this.search
        }, 700)

      },
      getRepsDebounced(val) {
        clearTimeout(this._repTimerId)
        this._repTimerId = setTimeout(() => {
          this.getReps(val)
        }, 500) /* 500ms throttle */
      },
      async getReps(query) {
        this.repsLoading = true
        try {
          let params = {
            query,
            size: 10
          }
          const {data} = await getRequestWithParams(`/commissionManagement/overrides/_search`, {params}, 'blueraven')
          this.reps = data
          this.repsLoading = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Sales Reps')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },
      async exportAccountingReview () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let filename = 'Accounting Review.csv';
          let csvData = 'Project ID,Customer Name,System Size (kW),Sales Rep,User ID,Employee ID,Current Pay,Source,Cancelled,IAS,FDS,FAS,Utility Bill Verified,%/$ Dep,HOI,HOI-R,SC,Commission Plan,Commissions Earned,Commission Paid to Date,Adjustment,Commission Pay,Remaining Value Commissions,Override Plan,Override Earned,Overrides Paid to Date,Override Pay,Remaining Value Overrides';
          csvData += '\n';

          this.accountingData.forEach(p => {
            if (this.masterSelectedPayrollIds.includes(p.project_id)) {
              csvData +=
                p.project_id + ',"' +
                p.customer_name + '",' +
                p.system_size + ',"' +
                p.closer + '",' +
                p.user_id + ',' +
                p.employee_id + ',' +
                p.current_pay + ',"' +
                p.source_name + '",' +
                p.cancelled_date + ',' +
                p.installation_agreement_signed_date + ',' +
                p.final_design_signed_date + ',' +
                p.agreement_signed_date + ',' +
                p.utility_bill_verified_date + ',' +
                p.percent_of_cash_deposit + ',' +
                p.proof_of_homeowners_insurance_obtained_date + ',' +
                p.proof_of_howmeowners_insurance_required + ',' +
                p.substantial_completion_date + ',"' +
                p.commission_plan + '",' +
                p.commission_earned + ',' +
                p.commission_paid_to_date + ',' +
                p.commission_adjustments + ',' +
                p.current_pay_commissions + ',' +
                p.remaining_value_commissions + ',"' +
                p.override_plan + '",' +
                p.override_earned + ',' +
                p.overrides_paid_to_date + ',' +
                p.current_pay_overrides + ',' +
                p.remaining_value_overrides
              csvData += '\n';
            }
          })

          let blob = new Blob([csvData], {
            type: 'text/csv;charset=utf-8'
          });

          saveAs(blob, filename);
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Exporting Accounting Review')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    }
  }
</script>

<style lang="scss" scoped>
  .v-data-table {
    border-radius: 0;
  }
</style>

