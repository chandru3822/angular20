<template>
  <v-container>
    <v-row>
      <v-col>
        <v-data-table
            :headers="headers"
            :items="payrollSummary"
            :fixed-header="true"
            disable-sort
            :footer-props="footerProps"
            :items-per-page="25"
            :loading="dataLoading"
            class="elevation-1"
        >
          <template #no-data>
            No available summary data
          </template>

          <template #no-results>
            No available summary data
          </template>

          <template #header.icons="{}">
            <div class="text-right mr-2">
              <a-btn
                  variant="text"
                  size="x-small"
                  color="primary"
                  :disabled="dataLoading"
                  @click="exportPayrollSummary"
                  prepend-icon="download"
              ></a-btn>
            </div>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.closer_user}}</td>
              <td class="text-left">{{item.total_commission | currency('$', 2)}}</td>
              <td class="text-left">{{item.total_overrides | currency('$', 2)}}</td>
              <td class="text-left">{{item.commission_adjustments | currency('$', 2)}}</td>
              <td class="text-left">{{item.current_pay | currency('$', 2)}}</td>
              <td></td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>

  </v-container>
</template>

<script setup>
import { saveAs } from 'file-saver'

import {handleHidingGlobalLoader, getRequest, getSnackbar} from '@/helpers/helpers'
import constants from "@/helpers/constants";
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

onMounted(() => {
  viewSummary()
})

const payrollId = computed(() => {
  return parseInt(route.params.id)
})

watch(commissionPositionId, async() => {
  //if they change the position (setter vs closer) have to go back to main page
  await router.push('/commissionManagement/payroll')
})

const payrollSummary = ref([])
const dataLoading = ref(false)
const headers = ref([
  { text: 'Sales Rep', value: 'closer_user', show: true },
  { text: 'Total Commission', value: 'total_commission', show: true },
  { text: 'Total Overrides', value: 'total_overrides', show: true },
  { text: 'Adjustments', value: 'commission_adjustments', show: true },
  { text: 'Current Pay', value: 'current_pay', show: true },
  { text: '', value: 'icons', show: true, width: 40 },
])
const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 500],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})

const viewSummary = async() => {
  appStore.loading = true
  dataLoading.value = true
  try {
    const {data, status} = await getRequest(`/payroll/${payrollId.value}/summary`, 'blueraven')
    payrollSummary.value = data || []
    dataLoading.value = false
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Payroll Summary')

    appStore.loading = false
  }
}
const exportPayrollSummary = async () => {
  appStore.loading = true
  try {
    let filename = 'Payroll Summary.csv';
    let csvData = 'Sales Rep, Total Commission, Total Overrides, Adjustments, Current Pay';
    csvData += '\n';

    payrollSummary.value.forEach(p => {
      csvData +=
          '"' + p.closer_user + '",' +
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
    appStore.showSnack('ERROR', 'Error Exporting Payroll Summary')

    appStore.loading = false
  }
}
</script>
