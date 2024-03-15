<template>
  <v-container class="pt-0">
    <v-row>
      <v-col >
        <a-btn
            color="primary"
            :disabled="payrollSummary.length === 0"
            @click="exportPayrollSummary"
            text="Export"
        ></a-btn>
        <a-btn
            color="primary"
            class="ml-3"
            :disabled="!currentPayroll.id || payrollSummary.length === 0"
            @click="exportAllOverrides"
            text="Export All Overrides"
        ></a-btn>
        <v-data-table
            :headers="headers"
            :items="payrollSummary"
            :fixed-header="true"
            disable-sort
            :items-per-page="25"
            :footer-props="footerProps"
            :loading="dataLoading"
            class="elevation-1 mt-2"
        >
          <template #no-data>
            <span class="default-text-color">No available summary data</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available summary data</span>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.closer_employee_id}}</td>
              <td class="text-left">{{item.closer_user}}</td>
              <td class="text-left">{{item.total_commission | currency('$', 2)}}</td>
              <td class="text-left">{{item.total_overrides | currency('$', 2)}}</td>
              <td class="text-left">{{item.commission_adjustments | currency('$', 2)}}</td>
              <td class="text-left">{{item.current_pay | currency('$', 2)}}</td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>

  </v-container>
</template>

<script setup>

import constants from "@/helpers/constants";
import {handleHidingGlobalLoader, getRequest, } from '@/helpers/helpers'
import { saveAs } from 'file-saver'
import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'
import { useBrsStore } from '@/stores/BrsStorePinia.js'

const brsStore = useBrsStore()
const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

onMounted(() => {
  viewSummary()
  getCurrentPayroll()
})

const payrollSummary = ref([])
const currentPayroll = ref({})
const dataLoading = ref(false)
const positionId = ref(brsStore.commissionPositionId)
const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 500],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const headers = ref([
  { text: 'Employee ID', value: 'closer_employee_id', show: true },
  { text: 'Sales Rep', value: 'closer_user', show: true },
  { text: 'Total Commission', value: 'total_commission', show: true },
  { text: 'Total Overrides', value: 'total_overrides', show: true },
  { text: 'Adjustments', value: 'commission_adjustments', show: true },
  { text: 'Current Pay', value: 'current_pay', show: true },
])

const getCurrentPayroll = async() => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/payroll/current/${positionId.value}`, 'blueraven')
    currentPayroll.value = data
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Current Payroll')

    appStore.loading = false
  }
}
const viewSummary = async () => {
  appStore.loading = true
  dataLoading.value = true
  try {
    const {data, status} = await getRequest(`/payroll/current/summary/${positionId.value}`, 'blueraven')
    payrollSummary.value = data
    dataLoading.value = false
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Payroll Summary')

    appStore.loading = false
  }
}
const exportAllOverrides = async() => {
  try {
    const {data} = await getRequest(`/payroll/${currentPayroll.value.id}/overrides`, 'blueraven')

    let filename = 'Overrides.csv'
    let csvData = 'Project ID, Customer Name, Closer, Employee ID, Override Plan Name, System Size, Overrides Earned, Prior Pay, Current Pay, User Allocation, Milestone 1 Percentage, Milestone 2 Percentage, Plan Total'
    csvData += '\n'

    data.forEach(p => {
      csvData +=
          p.projectId + ',' +
          '"' + p.customerName + '","' +
          p.closer + '","' +
          p.closerEmployeeId + '","' +
          p.overridePlanName + '",' +
          p.systemSize + ',' +
          p.overridesEarned + ',' +
          p.priorPay + ',' +
          p.currentPay + ',' +
          p.userAllocation + ',' +
          p.milestone1Percentage + ',' +
          p.milestone2Percentage + ',' +
          p.planTotal
      csvData += '\n';
    })

    let blob = new Blob([csvData], {
      type: 'text/csv;charset=utf-8'
    });

    saveAs(blob, filename);

    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Payroll Summary')

    appStore.loading = false
  }
}
const exportPayrollSummary = async() => {
  appStore.loading = true
  try {
    let filename = 'Payroll Summary.csv'
    let csvData = 'Employee ID, Sales Rep, Total Commission, Total Overrides, Adjustments, Current Pay'
    csvData += '\n'

    payrollSummary.value.forEach(p => {
      csvData +=
          '"' + p.closer_employee_id + '",' +
          p.closer_user + ',' +
          p.total_commission + ',' +
          p.total_overrides + ',' +
          p.commission_adjustments + ',' +
          p.current_pay
      csvData += '\n';
    })

    let blob = new Blob([csvData], {
      type: 'text/csv;charset=utf-8'
    });

    saveAs(blob, filename);
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Exporting Payroll Summary')

    appStore.loading = false
  }
}
</script>
