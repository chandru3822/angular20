<template>
  <v-container class="pa-0">
    <v-row>
      <v-col>
        <v-toolbar flat :color="payrollStatus.color">
          <v-toolbar-title :style="{'color': payrollStatus.textColor}">
            {{ payrollStatus.message }}
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <div class="commission-button-container">

            </div>
          </v-toolbar-items>
        </v-toolbar>
      </v-col>
    </v-row>
    <v-row>
      <v-col cols="6">
        <table>
          <tr>
            <td class="text-left pr-3"><strong>Payroll ID #</strong></td>
            <td class="text-left">{{payroll.id}}</td>
          </tr>
          <tr>
            <td class="text-left pr-3"><strong>Payroll Ending</strong></td>
            <td class="text-left">{{payroll.periodEnd | formatDate('date')}}</td>
          </tr>
          <tr>
            <td class="text-left pr-3"><strong>Description</strong></td>
            <td class="text-left">{{payroll.description}}</td>
          </tr>
          <tr v-for="(hx, idx) in payroll.history" :key="idx">
            <td class="text-left pr-3"><strong>{{hx.actionType}}</strong></td>
            <td class="text-left">{{hx.actionUser}} - {{hx.actionDate | formatDate('date')}}</td>
          </tr>
        </table>
      </v-col>
      <v-col cols="6" class="text-right">
        <a-btn
            color="primary"
            @click="exportPayrollReview"
            text="Export"
        ></a-btn>
      </v-col>
    </v-row>
    <v-divider></v-divider>
    <v-row>
      <v-col>
        <v-data-table
            :headers="headers"
            :items="payrollSnapshot"
            :fixed-header="true"
            disable-sort
            :loading="dataLoading"
            :items-per-page="25"
            :footer-props="footerProps"
            class="elevation-1"
        >
          <template #no-data>
            No available snapshot data
          </template>

          <template #no-results>
            No available snapshot data
          </template>

        </v-data-table>
      </v-col>
    </v-row>

  </v-container>
</template>

<script setup>

import { saveAs } from 'file-saver'
import constants from "@/helpers/constants";
import {handleHidingGlobalLoader, getRequest, getSnackbar} from '@/helpers/helpers'
import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'
import { useBrsStore } from '@/stores/BrsStore.js'
import { storeToRefs } from 'pinia'

const brsStore = useBrsStore()
const { commissionPositionId } = storeToRefs(brsStore)
const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const payroll = ref({})
const dataLoading = ref(false)
const payrollSnapshot = ref([])
const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 500],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const payrollSummary = ref([])
const payrollStatus = ref({})
const positionId = ref(brsStore.commissionPositionId)
const payrollId = ref(route.params.id)
const closerHeaders = ref([
  {text: 'Project ID', value: 'projectId', show: true},
  {text: 'Customer Name', value: 'customerName', show: true},
  {text: 'System Size (kW)', value: 'systemSize', show: true},
  {text: 'Sales Rep', value: 'salesRep', show: true},
  {text: 'Source', value: 'source', show: true},
  {text: 'Stage', value: 'stage', show: true},
  {text: 'Cancelled', value: 'cancelled', show: true},
  {text: 'IAS', value: 'installAgreementSigned', show: true},
  {text: 'FDS', value: 'finalDesignSigned', show: true},
  {text: 'FAS', value: 'financialAgreementSent', show: true},
  {text: '$/% Dep', value: 'percentOfCashDeposit', show: true},
  {text: 'SC', value: 'sc', show: true},
  {text: 'Commission Plan', value: 'commissionPlan', show: true},
  {text: 'Commission Strategy', value: 'commissionStrategyName', show: true},
  {text: 'Commissions Earned', value: 'commissionsEarned', show: true},
  {text: 'Commissions Paid To Date', value: 'commissionPaidToDate', show: true},
  {text: 'Commission Forfeited Paid to Date', value: 'commissionForfeitedPaidToDate', show: true},
  {text: 'Commission Forfeited by Closer', value: 'commissionForfeitedByCloser', show: true},
  {text: 'Forfeited Amount', value: 'forfeitedAmount', show: true},
  {text: 'Adjustment', value: 'commissionAdjustment', show: true},
  {text: 'Commission Pay', value: 'currentPayCommissions', show: true},
  {text: 'Remaining Value Commissions', value: 'remainingValueCommissions', show: true},
  {text: 'Override Plan', value: 'overridePlan', show: true},
  {text: 'Override Earned', value: 'overrideEarned', show: true},
  {text: 'Overrides Paid to Date', value: 'overridesPaidToDate', show: true},
  {text: 'Override Pay', value: 'currentPayOverrides', show: true},
  {text: 'Remaining Value Overrides', value: 'remainingValueOverrides', show: true},
  {text: 'Current Pay', value: 'currentPay', show: true},
])
const setterHeaders = ref([
  {text: 'Project ID', value: 'project_id', show: true},
  {text: 'Customer Name', value: 'project_name', show: true},
  {text: 'Setter', value: 'sales_rep', show: true},
  {text: 'Current Pay', value: 'current_pay', show: true},
  {text: 'Source', value: 'source_name', show: true},
  {text: 'Cancelled', value: 'cancelled_date', show: true},
  {text: 'Appointment Date', value: 'closer_appointment_start', show: true},
  {text: 'Appointment Outcome', value: 'closer_appointment_outcome', show: true},
  {text: 'Commission Plan', value: 'commission_plan', show: true},
  {text: 'Commissions Earned', value: 'commissions_earned', show: true},
  {text: 'Commission Paid to Date', value: 'commission_paid_to_date', show: true},
  {text: 'Adjustment', value: 'commission_adjustment', width: 150, show: true},
  {text: 'Commission Pay', value: 'current_pay_commissions', show: true},
  {text: 'Override Plan', value: 'override_plan', show: true},
  {text: 'Override Earned', value: 'override_earned', show: true},
  {text: 'Overrides Paid to Date', value: 'overrides_paid_to_date', show: true},
  {text: 'Override Pay', value: 'current_pay_overrides', show: true},
])

onMounted(() => {
  getPayroll()
  getPayrollSnapshot()
})

watch(commissionPositionId, async() => {
  //if they change the position (setter vs closer) have to go back to main page
  await router.push('/commissionManagement/payroll')
})

const headers = computed(() => {
  return positionId.value === 1 ? closerHeaders.value : setterHeaders.value
})

const getPayroll = async() => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/payroll/${payrollId.value}`, 'blueraven')
    payroll.value = data
    populateStatusDetails()
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Payroll Details')

    appStore.loading = false
  }
}
const getPayrollSnapshot = async() => {
  appStore.loading = true
  dataLoading.value = true
  try {
    const {data, status} = await getRequest(`/payroll/${payrollId.value}/snapshot/${positionId.value}`, 'blueraven')
    dataLoading.value = false
    payrollSnapshot.value = data

    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Payroll Snapshot')

    appStore.loading = false
  }
}
const viewSummary = async() => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/payroll/${payrollId.value}/summary`, 'blueraven')
    payrollSummary.value = data
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Payroll Summary')

    appStore.loading = false
  }
}
const populateStatusDetails = () => {
  switch(payroll.value.status) {
    case 'PENDING':
      payrollStatus.value.message = 'This payroll is pending.'
      payrollStatus.value.color = 'primary'
      payrollStatus.value.textColor = 'white'
      break
    case 'APPROVED':
      payrollStatus.value.message = 'This payroll has been Approved for Pay.'
      payrollStatus.value.color = 'success'
      payrollStatus.value.textColor = 'white'
      break
    case 'SUBMITTED':
      payrollStatus.value.message = 'This payroll has been Submitted for Approval.'
      payrollStatus.value.color = '#DCDCDC'
      break
    case 'REJECTED':
      payrollStatus.value.message = 'This payroll has been Rejected.'
      payrollStatus.value.color = 'error'
      payrollStatus.value.textColor = 'white'
      break
    default:
      payrollStatus.value = {}
  }
}
const exportPayrollReview = async () => {
  appStore.loading = true
  try {
    let filename = 'Payroll Review.csv'
    let csvData = ''

    if(payroll.value.positionId === 1) {
      csvData += 'Project ID,Customer Name,System Size (kW),Sales Rep,Source,Stage,Cancelled,IAS,FDS,FAS,$/% Dep,SC,Commission Plan,Commission Strategy,Commissions Earned,Commissions Paid To Date,Commission Forfeited Paid to Date,Commission Forfeited by Closer,Forfeited Amount,Adjustment,Commission Pay,Remaining Value Commissions,Override Plan,Override Earned,Overrides Paid to Date,Override Pay,Remaining Value Overrides,Current Pay'
      csvData += '\n'

      payrollSnapshot.value.forEach(p => {
        csvData +=
            p.projectId + ',' +
            '"' + p.customerName + '",' +
            p.systemSize + ',' +
            '"' + p.salesRep + '",' +
            '"' + p.source + '",' +
            '"' + p.stage + '",' +
            p.cancelled + ',' +
            p.installAgreementSigned + ',' +
            p.finalDesignSigned + ',' +
            p.financialAgreementSent + ',' +
            p.percentOfCashDeposit + ',"' +
            p.sc + '","' +
            p.commissionPlan + '",' +
            p.commissionStrategyName + '",' +
            p.commissionsEarned + ',' +
            p.commissionPaidToDate + ',' +
            p.commissionForfeitedPaidToDate + ',' +
            p.commissionForfeitedByCloser + ',' +
            p.forfeitedAmount + ',' +
            p.commissionAdjustment + ',' +
            p.currentPayCommissions + ',' +
            p.remainingValueCommissions + ',' +
            p.overridePlan + ',' +
            p.overrideEarned + ',' +
            p.overridesPaidToDate + ',' +
            p.currentPayOverrides + ',' +
            p.remainingValueOverrides + ',' +
            p.currentPay
        csvData += '\n';
      })
    } else {
      csvData += 'Project ID,Customer Name,Setter,Current Pay,Source,Cancelled,Appointment Date,Appointment Outcome,Commission Plan,Commissions Earned,Commissions Paid To Date,Adjustment,Commission Pay,Override Plan,Override Earned,Overrides Paid to Date,Override Pay'
      csvData += '\n'

      payrollSnapshot.value.forEach(p => {
        csvData +=
            p.project_id + ',' +
            p.project_name + ',' +
            p.sales_rep + ',' +
            p.current_pay + ',' +
            p.source_name + ',' +
            p.cancelled + ',' +
            p.closer_appointment_start + ',' +
            p.closer_appointment_outcome + ',' +
            p.commission_plan + ',' +
            p.commissions_earned + ',' +
            p.commission_paid_to_date + ',' +
            p.commission_forfeited_paid_to_date + ',' +
            p.commission_forfeited_by_closer + ',' +
            p.commission_adjustment + ',' +
            p.current_pay_commissions + ',' +
            p.override_plan + ',' +
            p.override_earned + ',' +
            p.overrides_paid_to_date + ',' +
            p.current_pay_overrides
        csvData += '\n';
      })
    }

    let blob = new Blob([csvData], {
      type: 'text/csv;charset=utf-8'
    });

    saveAs(blob, filename);
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Exporting Payroll Review')

    appStore.loading = false
  }
}
</script>

