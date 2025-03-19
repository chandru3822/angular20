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
            v-if="payrollStatus.action && userCanAdd"
            :color="payrollStatus.actionColor"
            class=""
            @click="submitForApproval(payrollStatus.action)"
            :text="payrollStatus.actionText"
          ></a-btn>
          <!-- currently only "Approve" has a secondary action which requires a dialog confirm. will have to update if that changes -->
          <v-dialog
            v-if="payrollStatus.secondaryAction && userIsAdmin"
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
              <a-text-field
                readonly
                disabled
                label="Payroll ID"
                v-model="currentPayroll.id"
              />
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
              <a-autocomplete v-model="accountingSearch.customerId"
                              :items="customers"
                              :loading="customersLoading"
                              :search-input.sync="customerSearch"
                              label="Customer..."
                              clearable
                              item-title="fullName"
                              item-value="id"
                              autocomplete="off"
                              type="search"
                              @click:clear="customers = []"
                              attach
              ></a-autocomplete>

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
                  @click="resetSearch"
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
            <template v-slot:no-data>
              <div class="text-center pa-5 default-text-color">
                No commission plans found
              </div>
            </template>

            <template v-slot:no-results>
              <div class="text-center pa-5 default-text-color">
                No results matching your search criteria
              </div>
            </template>

            <template v-slot:header.data-table-select="{ on, props }">
              <v-checkbox color="primary" v-model="selectAll" @change="toggleSelectAll()"></v-checkbox>
            </template>

            <template v-slot:item="{ item, index }">
              <tr :class="{'shaded-row': index % 2, 'error--text': item.closer_is_terminated }">
                <td v-if="payrollStatus.showSelect">
                  <v-checkbox color="primary" v-model="item.selected" @change="toggleSingleSelect(item)"></v-checkbox>
                </td>
                <td class="text-left">{{ formatOrDash(item.project_id) }}</td>
                <td class="text-left">{{ formatOrDash(item.customer_name) }}</td>
                <td class="text-left">{{ formatOrDash(item.system_size) }}</td>
                <td class="text-left">{{ formatOrDash(item.panel_quantity) }}</td>
                <td class="text-left">{{ formatOrDash(item.partner_org_name) }}</td>
                <td class="text-left">{{ formatOrDash(item.org_id) }}</td>
                <td class="text-left">{{ item[milestone1Field] | formatDate('date') || '-' }}</td>
                <td class="text-left">{{ item[milestone2Field] | formatDate('date') || '-' }}</td>
                <td class="text-left">{{ formatOrDash(item.commission_plan) }}</td>
                <td class="text-left">{{ item.base_commission || 0 | currency('$', 2)}}</td>
                <td class="text-left">{{ item.custom_adder_amount || 0 | currency('$', 2)}}</td>
                <td class="text-left">{{ item.selected_adder_amount || 0 | currency('$', 2) }}</td>
                <td class="text-left">{{ item.total_commissions || 0 | currency('$', 2) }}</td>
                <td class="text-left">{{ item.commission_earned || 0 | currency('$', 2)}}</td>
                <td class="text-left">{{ item.commission_paid_to_date || 0 | currency('$', 2) }}</td>
                <td class="text-left">{{ item.current_pay_commissions || 0 | currency('$', 2) }}</td>
                <td class="text-left">{{ item.remaining_value_commissions || 0 | currency('$', 2) }}</td>
              </tr>
            </template>

            <template v-slot:body.append="{ headers }">
              <tr>
                <td v-for="(header, i) in headers" :key="i" class="font-weight-bold">
                  <div v-if="header.value === 'panel_quantity'">
                    Total Pay:
                  </div>
                  <div v-if="header.value === 'org_id'">
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
  import {
    handleHidingGlobalLoader,
    getRequest,
    postRequest,
    getRequestWithParams,
    formatOrDash
  } from '@/helpers/helpers.js'
  import constants from "@/helpers/constants.js";
  import sumBy from "lodash.sumby";
  import { saveAs } from 'file-saver'
  import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
  import {useUserStore} from '@/stores/UserStore.js'
  import {useRouter} from "vue-router/composables";
  import { useBrsStore } from '@/stores/BrsStore.js'
  import { useAppStore } from '@/stores/AppStore.js'
  import debounce from 'lodash.debounce'
  import {storeToRefs} from "pinia";
  import {getCommissionPlans} from "@/services/commissionService.js";

  const router = useRouter()
  const userStore = useUserStore()
  const brsStore = useBrsStore()
  const appStore = useAppStore()
  const vueInstance = getCurrentInstance().proxy

  const { commissionPositionId } = storeToRefs(brsStore)
  const dataLoading = ref(true)
  const selectAll = ref(false)
  const customers = ref([])
  const customerSearch = ref(null)
  const customersLoading = ref(false)
  const reps = ref([])
  const commissionPlans = ref([])
  const repSearch = ref(null)
  const repsLoading = ref(false)
  const approveConfirm = ref(false)
  const search = ref('')
  const debouncedSearch = ref('')
  const payDate = ref(null)
  const additionalPayrollDataNeeded = ref(false)
  const payrollLoading = ref(true)
  const accountingData = ref([])
  const masterSelectedPayrollIds = ref([])
  const currentPayroll = ref({})
  const payrollStatus = ref({})
  const accountingSearch = ref({})
  const totalPay = ref(null)

  const footerProps = ref({
    'items-per-page-options': [25, 50, 100, 500, 1000],
    'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
  })

  // Add these computed properties to your script setup section
  const milestone1Field = computed(() => {
    return commissionPositionId.value === 828 ? 'substantial_completion_date' : 'final_design_complete_date'
  });

  const milestone2Field = computed(() => {
    return commissionPositionId.value === 828 ? 'final_inspection_verified' : 'substantial_completion_date';
  });

  const headers = ref([
    { text: 'Project ID', value: 'project_id', show: true },
    { text: 'Customer Name', value: 'customer_name', show: true },
    { text: 'System Size (kW)', value: 'system_size', show: true },
    { text: 'Panel Quantity', value: 'panel_quantity', show: true },
    { text: 'Org Name', value: 'partner_org_name', show: true },
    { text: 'Org ID', value: 'org_id', show: true },
    { text: 'Milestone 1 Date', value: 'milestone_1', show: true },
    { text: 'Milestone 2 Date', value: 'milestone_2', show: true },
    { text: 'Commission Plan', value: 'commission_plan', width: 300, show: true },
    { text: 'Base Commission', value: 'base_commission', show: true },
    { text: 'Custom Adders', value: 'custom_adder_amount', show: true },
    { text: 'Selected Adders', value: 'selected_adder_amount', show: true },
    { text: 'Total Commissions', value: 'total_commissions', show: true },
    { text: 'Commission Earned', value: 'commission_earned', show: true },
    { text: 'Commission Paid to Date', value: 'commission_paid_to_date', show: true },
    { text: 'Commission Pay', value: 'current_pay_commissions', show: true },
    { text: 'Remaining Commission Value', value: 'remaining_value_commissions', show: true },
  ])

  const userCanAdd = computed(() => {
    return userStore.userHasFeatureAccessLevel('COMMISSIONS_DEALER', 'ADD') ||
      userStore.userHasFeatureAccessLevel('COMMISSIONS_INSTALLATION_PARTNER', 'ADD')
  })

  const userCanEdit = computed(() => {
    return userStore.userHasFeatureAccessLevel('COMMISSIONS_DEALER', 'EDIT') ||
      userStore.userHasFeatureAccessLevel('COMMISSIONS_INSTALLATION_PARTNER', 'EDIT')
  })

  const userIsAdmin = computed(() => {
    return userStore.userHasFeatureAccessLevel('COMMISSIONS_DEALER', 'ADMIN') ||
      userStore.userHasFeatureAccessLevel('COMMISSIONS_INSTALLATION_PARTNER', 'ADMIN')
  })

  const timezone = computed(() => {
    return userStore.timezone.value
  })

  // Methods
  const resetSearch = () => {
    accountingSearch.value = {}
    getAccountingData()
  }

  const toggleSelectAll = () => {
    accountingData.value.forEach(ad => {
      ad.selected = selectAll.value
    })

    if (selectAll.value) {
      currentPayroll.value.selectedProjectIds = accountingData.value.map(ad => ad.project_id)
    } else {
      currentPayroll.value.selectedProjectIds = []
    }
  }

  const toggleSingleSelect = (item) => {
    if (!currentPayroll.value.selectedProjectIds) {
      currentPayroll.value.selectedProjectIds = []
    }

    if (item.selected) {
      currentPayroll.value.selectedProjectIds.push(item.project_id)
    } else {
      currentPayroll.value.selectedProjectIds = currentPayroll.value.selectedProjectIds.filter(p => p !== item.project_id)
    }
  }

  const submitForApproval = async (action) => {
    // Save changes before approval
    const val = await saveChangesToPayroll(true)

    // Don't submit for approval if the save changes request failed
    if (!val) return

    totalPay.value = sumBy(accountingData.value, function(o) {
      return o.selected ? o.current_pay : 0
    })

    const selectedIds = accountingData.value
      .filter(ad => ad.selected)
      .map(ad => ad.project_id)

    const params = {
      payDate: payDate.value
    }

    if (payrollStatus.value.showSelect && (!selectedIds || selectedIds.length === 0)) {
      appStore.showSnack('WARNING', 'You must select at least one project.')
      return
    }

    appStore.loading = true
    try {
      await postRequest(`/payroll/${currentPayroll.value.id}/${action}`, params, 'blueraven')
      appStore.showSnack('SUCCESS', 'Successfully Updated')
      await getCurrentPayroll()
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Updating')
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
      const { data } = await postRequest(`/payroll/${currentPayroll.value.id}`, params, 'blueraven')
      appStore.showSnack('SUCCESS', 'Successfully Updated')

      currentPayroll.value = data
      totalPay.value = sumBy(accountingData.value, function(o) {
        return o.selected ? o.current_pay : 0
      })

      additionalPayrollDataNeeded.value = !currentPayroll.value.periodEnd || !currentPayroll.value.description
      getStatusColor()

      if (currentPayroll.value.periodEnd) {
        await getCurrentPayroll()
      } else {
        dataLoading.value = false
        accountingData.value = []
      }

      if (!keepLoading) {
        appStore.loading = false // Fixing typo in property name
      }

      return true
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Updating')
      appStore.loading = false
      return false
    }
  }

  const getStatusColor = () => {
    payrollStatus.value = {}

    switch (currentPayroll.value.status) {
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

  const getPlans = async () => {
    try {
      const { data, status } = await getCommissionPlans(commissionPositionId.value)
      commissionPlans.value = data
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Loading Commissions')
    }
  }

  const getCurrentPayroll = async () => {
    appStore.loading = true

    try {
      const { data, status } = await getRequest(
        `/payroll/current/${commissionPositionId.value}`,
        'blueraven'
      )

      currentPayroll.value = data
      masterSelectedPayrollIds.value = cloneDeep(currentPayroll.value.selectedProjectIds || [])

      getStatusColor()
      payrollLoading.value = false
      additionalPayrollDataNeeded.value = !currentPayroll.value.periodEnd || !currentPayroll.value.description

      if (currentPayroll.value.periodEnd) {
        await getAccountingData()
      } else {
        dataLoading.value = false
        accountingData.value = []
      }

      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Loading Current Payroll')
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
        customerId: accountingSearch.value.customerId?.id || accountingSearch.value.customerId, // Handle object or ID
        orgId: accountingSearch.value.orgId,
        positionId: commissionPositionId.value
      }

      if (currentPayroll.value?.status !== 'PENDING' && currentPayroll.value?.status !== 'REJECTED') {
        params.selectedProjectIds = currentPayroll.value.selectedProjectIds
      }

      const { data } = await postRequest(`/commissionManagement/accountReview/search`, params, 'blueraven')
      accountingData.value = []

      // Process data and handle filtering for selected only view
      data.forEach(d => {
        d.selected = !!currentPayroll.value.selectedProjectIds?.includes(d.project_id)
        if (accountingSearch.value?.showSelectedOnly && d.selected) {
          accountingData.value.push(d)
        }
      })

      if (!accountingSearch.value?.showSelectedOnly) {
        accountingData.value = data
      }

      if (currentPayroll.value?.selectedProjectIds?.length === data.length) {
        selectAll.value = true
      }

      totalPay.value = sumBy(accountingData.value, function(o) {
        return o.selected ? o.current_pay : 0
      })

      dataLoading.value = false
      appStore.loading = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Loading Accounting Data')
      appStore.loading = false
    }
  }


  const getCustomers = async (query) => {
    customersLoading.value = true
    try {
      let params = {
        query,
        size: 10
      }
      const { data } = await getRequestWithParams(`/contact/search`, {params})
      customers.value = data.content
      customersLoading.value = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Retrieving Customers')
      customersLoading.value = false
    }
  }

  // Debounced functions
  const getCustomersDebounced = debounce((val) => {
    getCustomers(val)
  }, 500)

  const debounceSearch = debounce(() => {
    debouncedSearch.value = search.value
  }, 500)

  const getRepsDebounced = debounce((val) => {
    getReps(val)
  }, 500)

  const getReps = async (query) => {
    repsLoading.value = true
    try {
      let params = {
        query,
        size: 10
      }
      const { data } = await getRequestWithParams(`/commissionManagement/overrides/_search`, { params }, 'blueraven')
      reps.value = data
      repsLoading.value = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Retrieving Sales Reps')
      repsLoading.value = false
    }
  }

  // Format currency values with $0.00 or '-' if NaN
  const formatCurrencyForCSV = (value) => {
    return ((value === 0 || value === null || value === undefined) ? '$0.00' : `$${parseFloat(value).toFixed(2)}`) ?? '-';
  };

  const exportAccountingReview = async () => {
    appStore.loading = true
    try {
      let filename = 'Accounting Review.csv'
      let csvData = 'Project ID,Customer Name,System Size (kW),Panel Quantity,Org Name,Org ID,Milestone 1 Date,Milestone 2 Date,Commission Plan,Base Commission,Custom Adders,Selected Adders,Total Commissions,Commission Earned,Commission Paid to Date,Commission Pay,Remaining Commission Value'
      csvData += '\n'

      accountingData.value.forEach(p => {
        if (masterSelectedPayrollIds.value?.includes(p.project_id)) {
          // Use the computed milestone fields
          const milestone1 = p[milestone1Field.value] || '-';
          const milestone2 = p[milestone2Field.value] || '-';

          csvData +=
            (p.project_id || '-') + ',"' +
            (p.customer_name || '-') + '",' +
            (p.system_size || '-') + ',' +
            (p.panel_quantity || '-') + ',"' +
            (p.partner_org_name || '-') + '",' +
            (p.org_id || '-') + ',' +
            milestone1 + ',' +
            milestone2 + ',"' +
            (p.commission_plan || '-') + '",' +
            formatCurrencyForCSV(p.base_commission) + ',' +
            formatCurrencyForCSV(p.custom_adder_amount) + ',' +
            formatCurrencyForCSV(p.selected_adder_amount) + ',' +
            formatCurrencyForCSV(p.total_commissions) + ',' +
            formatCurrencyForCSV(p.commission_earned) + ',' +
            formatCurrencyForCSV(p.commission_paid_to_date) + ',' +
            formatCurrencyForCSV(p.current_pay_commissions) + ',' +
            formatCurrencyForCSV(p.remaining_value_commissions)
          csvData += '\n'
        }
      })
      let blob = new Blob([csvData], {
        type: 'text/csv;charset=utf-8'
      })

      saveAs(blob, filename)
      appStore.loading = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Exporting Accounting Review')
      appStore.loading = false
    }
  }
  // Event watchers
  watch(customerSearch, (val) => {
    if (!val) {
      customers.value = []
      accountingSearch.value.customerId = null
      return
    }
    customers.value = []
    getCustomersDebounced(val)
  })

  watch(repSearch, (val) => {
    if (!val) {
      accountingSearch.value.salesRepId = null
      reps.value = []
      return
    }
    reps.value = []
    getRepsDebounced(val)
  })

  watch(commissionPositionId, async () => {
    if ([743,828].includes(commissionPositionId.value)) {
      await getPlans()
      await getCurrentPayroll()
    } else {
      await router.push({ path: '/commissionManagement/accounting/current' })
    }
  })

  // Initialize component
  onMounted(async () => {
    let requests = [
      getPlans(),
      getCurrentPayroll()
    ]
    await Promise.all(requests).then(() => {
      // appStore.loading = false
    })
  })
</script>

<style lang="scss" scoped>
  .v-data-table {
    border-radius: 0;
  }
</style>
