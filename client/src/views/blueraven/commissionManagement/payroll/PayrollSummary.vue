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
            <tr :class="{'shaded-row': index % 2}" v-if="commissionPositionId === 743 || commissionPositionId === 828">
              <td class="text-left">{{item[orgIdField] || '-'}}</td>
              <td class="text-left">{{item[orgNameField] || '-'}}</td>
              <td class="text-left">{{item.total_commissions || 0 | currency('$', 2)}}</td>
              <td class="text-left">{{item.current_pay || 0 | currency('$', 2)}}</td>
              <td></td>
            </tr>
            <tr :class="{'shaded-row': index % 2}" v-else>
              <td class="text-left">{{item.closer_user}}</td>
              <td class="text-left">{{item.total_commission || 0 | currency('$', 2)}}</td>
              <td class="text-left">{{item.total_overrides || 0 | currency('$', 2)}}</td>
              <td class="text-left">{{item.commission_adjustments || 0 | currency('$', 2)}}</td>
              <td class="text-left">{{item.current_pay || 0 | currency('$', 2)}}</td>
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

  import {handleHidingGlobalLoader, getRequest } from '@/helpers/helpers.js'
  import constants from "@/helpers/constants.js";
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
  const closerHeaders = ref([
  { text: 'Sales Rep', value: 'closer_user', show: true },
  { text: 'Total Commission', value: 'total_commission', show: true },
  { text: 'Total Overrides', value: 'total_overrides', show: true },
  { text: 'Adjustments', value: 'commission_adjustments', show: true },
  { text: 'Current Pay', value: 'current_pay', show: true },
  { text: '', value: 'icons', show: true, width: 40 },
  ])

  /*
 * Adding conditional fields below
 * `Installation Partner` returns `org_id` and `org_name` in the response
 * `Dealer` returns `partner_org_id` and `partner_org_name` in the response
 */
  const orgIdField = computed(() => {
    return commissionPositionId.value === 828 ? 'org_id' : 'partner_org_id';
  });

  const orgNameField = computed(() => {
    return commissionPositionId.value === 828 ? 'org_name' : 'partner_org_name';
  })

  const partnerHeaders = ref([
  { text: 'Org ID', value: 'org_id', show: true },
  { text: 'Org Name', value: 'org_name', show: true },
  { text: 'Total Commission', value: 'total_commission', show: true },
  { text: 'Current Pay', value: 'current_pay', show: true },
  { text: '', value: 'icons', show: true, width: 40 },
  ])
  const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 500],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
  })

  const headers = computed(() => {
  return commissionPositionId.value === 743 || commissionPositionId.value === 828 ? partnerHeaders.value : closerHeaders.value
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

  // Format currency values with $0.00
  const formatCurrencyForCSV = (value) => {
    return ((value === 0 || value === null || value === undefined) ? '$0.00' : `$${parseFloat(value).toFixed(2)}`) ?? '-';
  };

  const exportPayrollSummary = async () => {
  appStore.loading = true
  try {
    let filename = 'Payroll Summary.csv';
    let csvData;

    if (commissionPositionId.value === 743 || commissionPositionId.value === 828) {
      csvData = 'Org ID, Org Name, Total Commission, Current Pay';
      csvData += '\n';

      payrollSummary.value.forEach(p => {
        csvData +=
          (p[orgIdField.value] || '-') + ',' +
          (p[orgNameField.value] || '-') + ',' +
          formatCurrencyForCSV(p.total_commission) + ',' +
          formatCurrencyForCSV(p.current_pay)
        csvData += '\n';
      })
    } else {
      csvData = 'Sales Rep, Total Commission, Total Overrides, Adjustments, Current Pay';
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
    }

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
