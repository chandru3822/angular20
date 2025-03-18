<template>
  <v-container class="pa-0">
    <v-form ref="payrollForm">
      <v-container>
        <v-row>
          <v-col cols="12" sm="6">
            <DatetimePickerInput
              v-model="payrollSearch.startDate"
              :timezone="timezone"
              :type="'date'"
              :format="'MMMM DD, YYYY'"
              label="Start Date"
            />
            <a-text-field
              label="Customer"
              v-model="payrollSearch.customerName"></a-text-field>
            <a-text-field
              label="Project ID"
              v-model="payrollSearch.projectId"></a-text-field>
          </v-col>
          <v-col cols="12" sm="6">
            <DatetimePickerInput
              v-model="payrollSearch.endDate"
              :timezone="timezone"
              :type="'date'"
              :format="'MMMM DD, YYYY'"
              label="End Date"
            />
            <a-autocomplete ref="repAutocomplete" v-if="commissionPositionId !== 743"
                            v-model="payrollSearch.salesRepId"
                            :items="reps"
                            :loading="repsLoading"
                            :search-input.sync="repSearch"
                            label="Sales Rep..."
                            clearable
                            item-title="name"
                            item-value="userId"
                            type="search"
                            @click:clear="reps = []"
                            attach
            ></a-autocomplete>

            <a-autocomplete ref="orgAutocomplete" v-else
                            v-model="payrollSearch.orgId"
                            :items="partnerOrgs"
                            :loading="partnerOrgsLoading"
                            :search-input.sync="partnerOrgSearch"
                            label="Partner Org Name..."
                            clearable
                            item-title="orgName"
                            item-value="orgId"
                            type="search"
                            @click:clear="partnerOrgs = []"
                            attach
            ></a-autocomplete>

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
  import constants from "@/helpers/constants.js";
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import {
    handleHidingGlobalLoader,
    postRequest,
    getRequestWithParams
  } from '@/helpers/helpers.js'
  import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
  import { useUserStore } from '@/stores/UserStore.js'
  import { useRouter } from "vue-router/composables";
  import { useAppStore } from '@/stores/AppStore.js'
  import { useBrsStore } from '@/stores/BrsStore.js'
  import debounce from 'lodash.debounce'
  import { storeToRefs } from 'pinia'

  const brsStore = useBrsStore()
  const { commissionPositionId } = storeToRefs(brsStore)
  const appStore = useAppStore()
  const router = useRouter()
  const userStore = useUserStore()
  const vueInstance = getCurrentInstance().proxy
  const store = vueInstance.$store

  const payrollSearch = ref({})
  const footerProps = ref({
    'items-per-page-options': [25, 50, 100, 500],
    'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
  })
  const partnerOrgs = ref([])
  const partnerOrgsLoading = ref(false)
  const partnerOrgSearch = ref('')
  const reps = ref([])
  const repSearch = ref('')
  const repsLoading = ref(false)
  const dataLoading = ref(false)
  const headers = ref([
    {text: 'ID', value: 'id', show: true},
    {text: 'Period End', value: 'periodEnd', show: true},
    {text: 'Description', value: 'description', show: true},
    {text: 'Current Pay', value: 'currentPay', show: true},
    {text: '', value: 'icons', show: true},
  ])

  onMounted(() => {
    getPayrollData()
  })

  watch(commissionPositionId, () => {
    getPayrollData()
  })

  watch(repSearch, (val) => {
    if(!val) {
      reps.value = []
      return
    }
    reps.value = []
    getRepsDebounced(val)
  })

  watch(partnerOrgSearch, (val) => {
    if(!val) {
      partnerOrgs.value = []
      return
    }
    partnerOrgs.value = []
    getPartnerOrgsDebounced(val)
  })

  const timezone = computed(() => {
    return userStore.timezone.value
  })

  const positionId = computed(() => {
    return commissionPositionId.value
  })

  const payrollData = ref([])

  const getPayrollData = async () => {
    dataLoading.value = true
    appStore.loading = true
    try {
      let params = payrollSearch.value
      payrollSearch.value.positionId = commissionPositionId.value
      const {data, status} = await postRequest(`/payroll/search`, params, 'blueraven')
      payrollData.value = data
      dataLoading.value = false
      handleHidingGlobalLoader( status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Loading Payroll Data')

      appStore.loading = false
    }
  }
  const viewDetails = async (item) => {
    await router.push({name: 'payrollReview', params: { id: item.id }})
  }
  const getPartnerOrgsDebounced = debounce((val) => {
    getPartnerOrgs(val)
  }, 500)
  const getPartnerOrgs = async(query) => {
    partnerOrgsLoading.value = true
    try {
      let params = {
        query,
        planId: null
      }
      const {data} = await getRequestWithParams(`/commissionManagement/dealerOrgs/_search`, {params}, 'blueraven')
      partnerOrgs.value = data
      partnerOrgsLoading.value = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Retrieving Partner Orgs')

    }
  }

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
      appStore.showSnack('ERROR', 'Error Retrieving Sales Reps')

    }
  }
</script>

<style lang="scss" scoped>
  .v-data-table {
    border-radius: 0;
  }
</style>
