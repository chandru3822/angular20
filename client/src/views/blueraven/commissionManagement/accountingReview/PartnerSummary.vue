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
              <td class="text-left">{{item.org_id}}</td>
              <td class="text-left">{{item.org_name}}</td>
              <td class="text-left">{{item.total_commissions | currency('$', 2)}}</td>
              <td class="text-left">{{item.current_pay | currency('$', 2)}}</td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>

  </v-container>
</template>

<script setup>

import constants from "@/helpers/constants.js";
import { handleHidingGlobalLoader, getRequest } from '@/helpers/helpers.js'
import { saveAs } from 'file-saver'
import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
import { useRouter } from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'
import { useBrsStore } from '@/stores/BrsStore.js'
import { storeToRefs } from 'pinia'

const brsStore = useBrsStore()
const appStore = useAppStore()
const router = useRouter()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const { commissionPositionId } = storeToRefs(brsStore)

onMounted(() => {
  viewSummary()
  getCurrentPayroll()
})

watch(commissionPositionId, () => {
  if ([743,828].includes(commissionPositionId.value)) {
    viewSummary()
    getCurrentPayroll()
  } else {
    router.push({ path: '/commissionManagement/accounting/summary' })
  }
})

const payrollSummary = ref([])
const currentPayroll = ref({})
const dataLoading = ref(false)
const positionId = ref(commissionPositionId)
const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 500],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const headers = ref([
  { text: 'Org ID', value: 'org_id', show: true },
  { text: 'Partner Org Name', value: 'org_name', show: true },
  { text: 'Total Commission', value: 'total_commissions', show: true },
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
    appStore.showSnack('ERROR', 'Error Loading Current Payroll')

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
    appStore.showSnack('ERROR', 'Error Retrieving Payroll Summary')

    appStore.loading = false
  }
}

const exportPayrollSummary = async() => {
  appStore.loading = true
  try {
    // Format currency values with $0.00 instead if returns `0`
    const formatCurrencyForCSV = (value) => {
      if (value === 0) {
        return '$0.00'
      }
      let curVal = parseFloat(value).toFixed(2);
      if (isNaN(curVal)) {
        return '-'
      }
      return `$${curVal}`
    };
    let filename = 'Payroll Summary.csv'
    let csvData = 'Org ID, Partner Org Name, Total Commission, Current Pay'
    csvData += '\n'

    payrollSummary.value.forEach(p => {
      csvData +=
        '"' + p.org_id + '",' +
        '"' + p.org_name + '",' +
        formatCurrencyForCSV(p.total_commissions) + ',' +
        formatCurrencyForCSV(p.current_pay)
      csvData += '\n';
    })

    let blob = new Blob([csvData], {
      type: 'text/csv;charset=utf-8'
    });

    saveAs(blob, filename);
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Exporting Payroll Summary')

    appStore.loading = false
  }
}
</script>
