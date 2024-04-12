<template>
  <v-container class="pa-0">
    <v-form ref="payrollForm">
      <v-container>
        <v-row>
          <v-col cols="12" sm="6">
            <a-text-field
                          label="User ID"
                          v-model="payrollSearch.userId"></a-text-field>
          </v-col>
          <v-col cols="12" sm="6">
            <div class="text-left">
              <a-btn
                  color="primary"
                  @click="getPayrollData"
                  text="Search"
              ></a-btn>
              <a-btn
                  variant="text"
                  color="primary"
                  class="ml-3"
                  @click="payrollSearch = {}"
                  text="Reset"
              ></a-btn>
            </div>
          </v-col>
        </v-row>
        <v-row>
          <v-col cols="12" sm="6">
            <a-text-field
                          label="User First Name"
                          v-model="payrollSearch.userFirstName"></a-text-field>
          </v-col>
          <v-col cols="12" sm="6">
            <a-text-field
                          label="User Last Name"
                          v-model="payrollSearch.userLastName"></a-text-field>
          </v-col>
        </v-row>
      </v-container>
    </v-form>
    <v-row>
      <v-col>
        <v-data-table
            :headers="headers"
            :items="payrollData"
            :fixed-header="true"
            disable-sort
            :items-per-page="25"
            :footer-props="footerProps"
            :loading="dataLoading"
            class="elevation-1"
        >
          <template #no-data>
            No available payroll data
          </template>

          <template #no-results>
            No available payroll data
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.id}}</td>
              <td class="text-left">{{item.periodEnd | formatDate('date')}}</td>
              <td class="text-left">{{item.description}}</td>
              <td class="text-left">{{item.currentPay || 0 | currency('$', 2)}}</td>
              <td class="text-left">
                <a-btn
                    class="clickable"
                    size="small"
                    variant="text"
                    color="primary"
                    @click="viewDetails(item)"
                    prepend-icon="mdi-dots-horizontal-circle"
                ></a-btn>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>

  </v-container>
</template>

<script setup>

import constants from "@/helpers/constants";
import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
import {
  handleHidingGlobalLoader,
  postRequest,

} from '@/helpers/helpers'
import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'
import { useBrsStore } from '@/stores/BrsStorePinia.js'
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

onMounted(() => {
  getPayrollData()
})

watch(commissionPositionId, () => {
  getPayrollData()
})

const payrollSearch = ref({})
const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 500],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const reps = ref([])
const positionId = ref(brsStore.commissionPositionId)
const repSearch = ref(null)
const repsLoading = ref(false)
const dataLoading = ref(false)
const headers = ref([
  {text: 'ID', value: 'id', show: true},
  {text: 'Period End', value: 'periodEnd', show: true},
  {text: 'Description', value: 'description', show: true},
  {text: 'Current Pay', value: 'currentPay', show: true},
  {text: '', value: 'icons', show: true},
])
const payrollData = ref([])


const getPayrollData = async() => {
  dataLoading.value = true
  appStore.loading = true
  try {
    let params = payrollSearch.value
    const {data, status} = await postRequest(`/payroll/residual/search`, params, 'blueraven')
    payrollData.value = data
    dataLoading.value = false
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Residual Data')

    appStore.loading = false
  }
}
const viewDetails = async(item) => {
  router.push({name: 'residual', params: { id: item.id }})
}
</script>

<style lang="scss" scoped>
.v-data-table {
  border-radius: 0;
}
</style>

