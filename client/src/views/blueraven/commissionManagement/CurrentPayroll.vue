<template>
  <v-container class="pa-0" id="payroll-container">
    <v-toolbar v-if="!payrollLoading && !additionalPayrollDataNeeded" :color="payrollStatus.color" class="mt-2">
      <v-toolbar-title class="app-title" :style="{'color': payrollStatus.textColor}">
        {{payrollStatus.message}}
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <div class="flex-display align-center" >
          <a-btn
              v-if="payrollStatus.action && userStore.userHasFeatureAccessLevel('COMMISSIONS', 'ADD')"
              :color="payrollStatus.actionColor"
              class=""
              @click="submitForApproval(payrollStatus.action)"
              :text="payrollStatus.actionText"
          ></a-btn>
          <!-- currently only "Approve" has a secondary action which requires a dialog confirm. will have to update if that changes -->
          <v-dialog
            v-if="payrollStatus.secondaryAction && userStore.userHasFeatureAccessLevel('COMMISSIONS', 'ADMIN')"
            v-model="approveConfirm"
            width="500">
            <template v-slot:activator="{ on }">
              <a-btn
                  :activation-handler="on"
                  :color="payrollStatus.secondaryActionColor"
                  class="ml-3"
                  :text="payrollStatus.secondaryActionText"
              ></a-btn>
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
                  :timezone="timezone"
                  :type="'date'"
                  :format="'MMMM DD, YYYY'"
                  label="Date Paid"
                />
              </v-card-text>


              <v-divider></v-divider>

              <v-card-actions>
                <v-spacer></v-spacer>
                <a-btn
                    @click="approveConfirm = false"
                    color="unset"
                    text="No"
                ></a-btn>
                <a-btn
                    color="primary"
                    class=""
                    :disabled="null == payDate"
                    @click="submitForApproval(payrollStatus.secondaryAction)"
                    text="Yes"
                ></a-btn>
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
              <a-text-field  readonly label="Payroll ID #" v-model="currentPayroll.id"></a-text-field>
              <DatetimePickerInput
                  v-model="currentPayroll.periodEnd"
                  :timezone="timezone"
                  :readonly="!userCanEdit"
                  :disabled="!userCanEdit"
                  :type="'date'"
                  :format="'MMMM DD, YYYY'"
                  label="Period Ending"
              />
              <a-text-field
                            label="Description"
                            placeholder=" "
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
                            v-model="currentPayroll.description"></a-text-field>

              <div class="text-left">
                <a-btn
                    color="primary"
                    v-if="userCanEdit"
                    @click="saveChangesToPayroll()"
                    text="Save Changes"
                ></a-btn>
                <a-btn
                    color="primary"
                    class="ml-3"
                    @click="exportAccountingReview()"
                    text="Export"
                ></a-btn>
              </div>
            </v-card>
          </v-col>
          <v-col cols="12" sm="6">
            <v-card class="pa-3">
              <label>Approved for Pay Only:</label>
              <input type="checkbox" class="ml-2" v-model="accountingSearch.showSelectedOnly">
              <a-text-field
                            class="mt-3"
                            label="Project ID"
                            v-model="accountingSearch.projectId"></a-text-field>
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
                <a-btn
                    color="primary"
                    @click="getAccountingData()"
                    text="Search"
                ></a-btn>
                <a-btn
                    class="ml-3"
                    variant="text"
                    color="primary"
                    @click="[accountingSearch = {}, getAccountingData()]"
                    text="Reset"
                ></a-btn>
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
            <a-text-field
              v-model="search"
              prepend-inner-icon="search"
              label="Search"
              single-line
              hide-details
              @input="debounceSearch"
            ></a-text-field>
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
                <td class="text-left">{{item.commission_strategy_name }}</td>
                <td class="text-left">{{item.commission_earned || 0 | currency('$', 2) }}</td>
                <td class="text-left">{{item.commission_paid_to_date || 0 | currency('$', 2) }}</td>
                <td class="text-left">{{item.commission_forfeited_paid_to_date || 0 | currency('$', 2) }}</td>
                <td class="text-left">{{item.commission_forfeited_by_closer || 0 | currency('$', 2) }}</td>
                <td class="text-left">{{item.forfeited_amount || 0 | currency('$', 2) }}</td>
                <td class="text-left">
                  {{ item.commission_adjustments || 0 | currency('$', 2) }}

                  <v-dialog
                    v-if="userCanAdd"
                    v-model="item.dialog"
                    width="500">
                    <template v-slot:activator="{ on }">
                      <a-btn
                          size="x-small"
                          color="primary"
                          fab
                          class="ml-2"
                          :activation-handler="on"
                          @click="[delete item.adjustment, delete item.adjustmentNote, getAdjustmentHistory(item)]"
                          prepend-icon="add"
                      ></a-btn>
                    </template>
                    <v-card>
                      <v-card-title class="text-h5 grey lighten-2" primary-title>
                        Add Adjustment
                      </v-card-title>
                      <v-card-text class="pt-3">
                        <strong>Type: </strong>Commission
                        <a-text-field
                                      type="number"
                                      label="Adjustment Amount"
                                      prepend-icon="mdi-currency-usd"
                                      persistent-hint
                                      :hint="`Max allowed: ${filters.currency(getCurrentMaxAdjustment(item), '$', 2)}`"
                                      v-model.number="item.adjustment">
                        </a-text-field>
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
                        <a-btn
                            @click="item.dialog = false"
                            color="unset"
                            text="Cancel"
                        ></a-btn>
                        <a-btn
                            color="primary"
                            :disabled="adjustmentDisabled(item)"
                            @click="addAdjustment(item)"
                            text="Add"
                        ></a-btn>

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
                <td class="text-left">{{item.commission_strategy_name }}</td>
                <td class="text-left">{{item.commission_earned || 0 | currency('$', 2) }}</td>
                <td class="text-left">{{item.commission_paid_to_date || 0 | currency('$', 2) }}</td>
                <td class="text-left">
                  {{ item.commission_adjustments || 0 | currency('$', 2) }}

                  <v-dialog
                    v-if="userCanAdd"
                    v-model="item.dialog"
                    width="500">
                    <template v-slot:activator="{ on }">
                      <a-btn
                          size="x-small"
                          color="primary"
                          fab
                          class="ml-2"
                          :activation-handler="on"
                          @click="[delete item.adjustment, delete item.adjustmentNote, getAdjustmentHistory(item)]"
                          prepend-icon="add"
                      ></a-btn>
                    </template>
                    <v-card>
                      <v-card-title class="text-h5 grey lighten-2" primary-title>
                        Add Adjustment
                      </v-card-title>
                      <v-card-text class="pt-3">
                        <strong>Type: </strong>Commission
                        <a-text-field
                                      type="number"
                                      label="Adjustment Amount"
                                      prepend-icon="mdi-currency-usd"
                                      persistent-hint
                                      :hint="`Max allowed: ${$filters.currency(_getCurrentMaxAdjustment(item), '$', 2)}`"
                                      v-model.number="item.adjustment">
                        </a-text-field>
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
                        <a-btn
                            @click="item.dialog = false"
                            color="unset"
                            text="Cancel"
                        ></a-btn>
                        <a-btn
                            color="primary"
                            :disabled="adjustmentDisabled(item)"
                            @click="addAdjustment(item)"
                            text="Add"
                        ></a-btn>
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

<script setup>
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'

  import cloneDeep from 'lodash.clonedeep'
  import {handleHidingGlobalLoader, getRequest, postRequest, getSnackbar, getRequestWithParams} from '@/helpers/helpers'
  import constants from "@/helpers/constants";
  import sumBy from "lodash.sumby";
  import { saveAs } from 'file-saver'
  import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
  import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
  import {useUserStore} from '@/stores/UserStorePinia.js'
  import {useRoute} from "vue-router/composables";
  import { useBrsStore } from '@/stores/BrsStorePinia.js'
  import { useAppStore } from '@/stores/AppStorePinia.js'
  import debounce from 'lodash.debounce'

  const route = useRoute()
  const userStore = useUserStore()
  const brsStore = useBrsStore()
  const appStore = useAppStore()
  const vueInstance = getCurrentInstance().proxy
  const store = vueInstance.$store
  const snackbar = vueInstance.$snackbar
  const filters = vueInstance.$filters

        const dataLoading = ref(true)
        const selectAll = ref(false)
        const customers = ref([])
        const customerSearch = ref(null)
        const customersLoading = ref(false)
        const positionId = ref(brsStore.commissionPositionId)
        const reps = ref([])
        const repSearch = ref(null)
        const repsLoading = ref(false)
        const approveConfirm = ref(false)
        const search = ref('')
        const debouncedSearch = ref('')
        const payDate = ref(null)
        const additionalPayrollDataNeeded = ref(false)
        const payrollLoading = ref(true)
        const payrollSummary = ref([])
        const accountingData = ref([])
        const masterSelectedPayrollIds = ref([])
        const currentPayroll = ref({})
        const payrollStatus = ref({})
        const accountingSearch = ref({})
        const totalPay = ref(null)
        const adjustmentHistoryHeaders = ref([
          {text: 'Adjustment Type', value: 'adjustmentType', show: true},
          {text: 'Amount', value: 'amount', show: true},
          {text: 'Note', value: 'note', show: true},
          {text: 'Created By', value: 'createdBy', show: true},
          {text: 'Created', value: 'created', show: true},
        ])
        const footerProps = ref({
          'items-per-page-options': [25, 50, 100, 500, 1000],
          'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
        })
        const closerHeaders = ref([
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
          {text: 'Commission Strategy', value: 'commission_strategy_name', show: true},
          {text: 'Commissions Earned', value: 'commission_earned', show: true},
          {text: 'Commission Paid to Date', value: 'commission_paid_to_date', show: true},
          {text: 'Commission Forfeited Paid to Date', value: 'commission_forfeited_paid_to_date', show: true},
          {text: 'Commission Forfeited by Closer', value: 'commission_forfeited_by_closer', show: true},
          {text: 'Forfeited Amount', value: 'forfeited_amount', show: true},
          {text: 'Adjustment', value: 'commission_adjustments', width: 150, show: true},
          {text: 'Commission Pay', value: 'current_pay_commissions', show: true},
          {text: 'Remaining Value Commissions', value: 'remaining_value_commissions', show: true},
          {text: 'Override Plan', value: 'override_plan', show: true},
          {text: 'Override Earned', value: 'override_earned', show: true},
          {text: 'Overrides Paid to Date', value: 'overrides_paid_to_date', show: true},
          {text: 'Override Pay', value: 'current_pay_overrides', show: true},
          {text: 'Remaining Value Overrides', value: 'remaining_value_overrides', show: true},
        ])
        const setterHeaders = ref([
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
        ])



      const userCanAdd = computed(() => {
        return userStore.userHasFeatureAccessLevel('COMMISSIONS', 'ADD')
      })
      const userCanEdit = computed(() => {
        return userStore.userHasFeatureAccessLevel('COMMISSIONS', 'EDIT')
      })
      const timezone = computed(() => {
        return userStore.timezone.value
      })
      const headers = computed(() => {
        return positionId.value === 1 ? closerHeaders.value : setterHeaders.value
      })

      watch(customerSearch, (val) => {
        if(!val) {
          customers.value = []
          accountingSearch.value.customerId = null
          return
        }
        customers.value = []
        getCustomersDebounced(val)
      })

      watch(repSearch, (val) => {
        if(!val) {
          accountingSearch.value.salesRepId = null
          reps.value = []
          return
        }
        reps.value = []
        getRepsDebounced(val)
      })
      onMounted(() => {
        getCurrentPayroll()
      })

      const getCurrentMaxAdjustment = (item)=> {
        const maxAdjustment = item.remaining_value_commissions - (item.current_pay_commissions < 0 ? 0 : item.current_pay_commissions) - item.commission_forfeited_by_closer - item.commission_forfeited_paid_to_date
        return (maxAdjustment < 0) ? 0 : maxAdjustment
      }
      const adjustmentDisabled = (item)=> {
        const maxAdjustment = getCurrentMaxAdjustment(item)
        return !item.adjustment || item.adjustment === 0 || !item.adjustmentNote || item.adjustment > maxAdjustment
      }
      const toggleSelectAll =  () => {
        accountingData.value.forEach(ad => {
          ad.selected = selectAll.value
        })
        if(selectAll.value) {
          currentPayroll.value.selectedProjectIds = accountingData.value.map(ad => ad.project_id)
        } else {
          currentPayroll.value.selectedProjectIds = []
        }
      }
      const toggleSingleSelect = (item) => {
        if(item.selected) {
          currentPayroll.value.selectedProjectIds.push(item.project_id)
        } else {
          currentPayroll.value.selectedProjectIds = currentPayroll.value.selectedProjectIds.filter(p => p !== item.project_id)
        }
      }
      const submitForApproval = async (action) => {
        //to avoid any unsaved changes prior to approval we are just saving changes prior to submitting
        const val = await saveChangesToPayroll(true)
        //dont submit for approval if the save changes request failed
        if(val) {
          totalPay.value = sumBy(accountingData.value,  function(o) { return o.selected ? o.current_pay : 0 })
          let selectedIds = accountingData.value.filter(ad => ad.selected).map(ad => ad.project_id)
          let params = {
            payDate: payDate.value
          }
          if(payrollStatus.value.showSelect && (!selectedIds || selectedIds.length === 0)) {
            snackbar('WARNING', 'You must select at least one project.')
          } else {
            appStore.loading = true
            try {
              await postRequest(`/payroll/${currentPayroll.value.id}/${action}`, params, 'blueraven')
              snackbar('SUCCESS', 'Successfully Updated')
              await getCurrentPayroll()
            } catch (e) {
              console.error('*** ERROR ***', e)
              snackbar('ERROR', 'Error Updating')
              appStore.loading = false
            }
          }
        }
      }
      const getAdjustmentHistory = async (item) => {
        try {
          let params = {
            projectId: item.project_id
          }
          const {data} = await getRequestWithParams(`/payroll/${currentPayroll.value.id}/adjustments`, {params}, 'blueraven')
          vueInstance.$set(item, 'adjustmentHistory', data)
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Retrieving Adjustment History')
          appStore.loading = false
        }
      }
      const addAdjustment = async (item) => {
        appStore.loading = true
        try {
          let params = {
            projectId: item.project_id,
            userId: item.user_id,
            adjustmentType: 'COMMISSION',
            maxAmount: item.remaining_value,
            amount: item.adjustment,
            note: item.adjustmentNote
          }
          await postRequest(`/payroll/${currentPayroll.value.id}/adjustments`, params, 'blueraven')
          snackbar('SUCCESS', 'Adjustment Added')
          await getCurrentPayroll()
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Adding Adjustment')
          appStore.loading = false
        }
      }
      const saveChangesToPayroll = async (keepLoading) => {
        let params = {
          description: currentPayroll.value.description,
          periodEnd: currentPayroll.value.periodEnd,
          projectIds: currentPayroll.value.selectedProjectIds
        }
        appStore.loading = true
        try {
          const {data} = await postRequest(`/payroll/${currentPayroll.value.id}`, params, 'blueraven')
          snackbar('SUCCESS', 'Successfully Updated')
          currentPayroll.value = data
          totalPay.value = sumBy(accountingData.value,  function(o) { return o.selected ? o.current_pay : 0 })
          additionalPayrollDataNeeded.value = null == currentPayroll.value.periodEnd || null == currentPayroll.value.description
          getStatusColor()
          if(null != currentPayroll.value.periodEnd) {
            await getCurrentPayroll()
          } else {
            dataLoading.value = false
            accountingData.value = []
          }
          if(!keepLoading) {
            appStore.loading = false
          }
          return true
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Updating')
          appStore.loading = false
          return false
        }
      }
      const getStatusColor =  () => {
        payrollStatus.value = {}
        switch(currentPayroll.value.status) {
          case 'PENDING':
            payrollStatus.value.message = 'This payroll is pending.'
            payrollStatus.value.color = '#DCDCDC'
            payrollStatus.value.showSelect = true
            payrollStatus.value.action = 'submit'
            payrollStatus.value.actionText = 'Submit For Approval'
            payrollStatus.value.actionColor = 'primary'
            break
          case 'SUBMITTED':
            payrollStatus.value.message = 'This payroll has been Submitted.'
            payrollStatus.value.color = '#DCDCDC'
            payrollStatus.value.showSelect = false
            payrollStatus.value.action = 'reject'
            payrollStatus.value.actionText = 'Reject'
            payrollStatus.value.actionColor = 'error'
            payrollStatus.value.secondaryAction = 'approve'
            payrollStatus.value.secondaryActionText = 'Approve'
            payrollStatus.value.secondaryActionColor = 'green'
            break
          case 'REJECTED':
            payrollStatus.value.message = 'This payroll has been Rejected.'
            payrollStatus.value.color = 'error'
            payrollStatus.value.textColor = 'white'
            payrollStatus.value.showSelect = true
            payrollStatus.value.action = 'submit'
            payrollStatus.value.actionText = 'Submit For Approval'
            payrollStatus.value.actionColor = 'primary'
            break
          default:
            payrollStatus.value = {}
        }
      }
      const getCurrentPayroll = async () => {
        appStore.loading = true
        try {
          const {data, status} = await getRequest(`/payroll/current/${positionId.value}`, 'blueraven', [])
          currentPayroll.value = data

          masterSelectedPayrollIds.value = cloneDeep(currentPayroll.value.selectedProjectIds)
          getStatusColor()
          payrollLoading.value = false
          additionalPayrollDataNeeded.value = null == currentPayroll.value.periodEnd || null == currentPayroll.value.description
          if(null != currentPayroll.value.periodEnd) {
            await getAccountingData()
          } else {
            dataLoading.value = false
            accountingData.value = []
          }
          handleHidingGlobalLoader(status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Loading Current Payroll')
          appStore.loading = false
        }
      }
      const getAccountingData = async () => {
        appStore.loading = true
        try {
          let params = {
            payrollId: currentPayroll.value.id,
            periodEnd: currentPayroll.value.periodEnd,
            projectId: accountingSearch.value.projectId,
            customerId: accountingSearch.value.customerId,
            salesRepId: accountingSearch.value.salesRepId,
            positionId: positionId.value
          }
          if(currentPayroll.value?.status !== 'PENDING' && currentPayroll.value?.status !== 'REJECTED') {
            params.selectedProjectIds = currentPayroll.value.selectedProjectIds
          }
          const {data} = await postRequest(`/commissionManagement/accountReview/search`, params, 'blueraven', [])
          accountingData.value = []
          data.forEach(d => {
            d.selected = !!currentPayroll.value.selectedProjectIds?.includes(d.project_id)
            if(accountingSearch.value?.showSelectedOnly && d.selected) {
              accountingData.value.push(d)
            }
          })
          if(!accountingSearch.value?.showSelectedOnly) {
            accountingData.value = data
          }
          if(currentPayroll.value?.selectedProjectIds?.length === data.length) {
            selectAll.value = true
          }

          totalPay.value = sumBy(accountingData.value,  function(o) { return o.selected ? o.current_pay : 0 })

          dataLoading.value = false
          appStore.loading = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Loading Accounting Data')
          appStore.loading = false
        }
      }
      const getCustomers = async(query) => {
          customersLoading.value = true
          try {
            let params = {
              query,
              size: 10
            }
            const {data} = await getRequestWithParams(`/contact/search`, {params})
            customers.value = data.content
            customersLoading.value = false
          } catch (e) {
            console.error('*** ERROR ***', e)
            snackbar('ERROR', 'Error Retrieving Customers')
          }
      }
  const getCustomersDebounced = debounce((val) => {
    getCustomers(val)
  }, 500)
  //wtf?
  const debounceSearch = debounce(() => {
    debouncedSearch.value = search.value
  }, 500)
  const getRepsDebounced = debounce((val) => {
    getReps(val)
  }, 500)

      const getReps = async(query) => {
        repsLoading.value = true
        try {
          let params = {
            query,
            size: 10
          }
          const {data} = await getRequestWithParams(`/commissionManagement/overrides/_search`, {params}, 'blueraven')
          reps.value = data
          repsLoading.value = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Retrieving Sales Reps')
        }
      }
      const exportAccountingReview = async () => {
        appStore.loading = true
        try {
          let filename = 'Accounting Review.csv';
          let csvData = 'Project ID,Customer Name,System Size (kW),Sales Rep,User ID,Employee ID,Current Pay,Source,Cancelled,IAS,FDS,FAS,Utility Bill Verified,%/$ Dep,HOI,HOI-R,SC,Commission Plan,Commission Strategy,Commissions Earned,Commission Paid to Date,Commission Forfeited Paid to Date,Commission Forfeited by Closer,Forfeited Amount,Adjustment,Commission Pay,Remaining Value Commissions,Override Plan,Override Earned,Overrides Paid to Date,Override Pay,Remaining Value Overrides';
          csvData += '\n';

          accountingData.value.forEach(p => {
            if (masterSelectedPayrollIds.value?.includes(p.project_id)) {
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
                p.commission_strategy_name + '",' +
                p.commission_earned + ',' +
                p.commission_paid_to_date + ',' +
                p.commission_forfeited_paid_to_date + ',' +
                p.commission_forfeited_by_closer + ',' +
                p.forfeited_amount + ',' +
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
          appStore.loading = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Exporting Accounting Review')
          appStore.loading = false
        }
      }
</script>

<style lang="scss" scoped>
  .v-data-table {
    border-radius: 0;
  }
</style>

