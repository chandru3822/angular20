<template>
  <v-container class="pa-0" id="commissions-container">
    <v-divider></v-divider>
    <v-card flat color="white" class="px-3 mt-3 square-card">
      <div class="pay-header pb-3">
        <a-select v-model="batchId"
                  custom-classes="batches-select"
                  label="Select a Batch"
                  hide-details
                  :items="batches"
                  no-data-text="No Batches Available"
                  item-value="id"
                  @change="getBatchDetails(batchId)"
        >
          <template v-slot:selection="{ item, index }">
            <span v-if="item.voidedBatch" class="error--text mr-2">VOIDED</span>
            #{{ item.displayName }}
          </template>
          <template v-slot:item="{ props, item }">
            <v-list-item v-bind="props">
              <span v-if="item.voidedBatch" class="error--text mr-2">VOIDED</span>
              #{{ item.displayName }}
            </v-list-item>
          </template>
        </a-select>
        <v-spacer></v-spacer>
        <span class="pl-4"
              v-show="batchLoaded && !voidedBatch">Payment Amount Total: <b>{{ paymentSum || 0 | currency('$', 2) }}</b></span>


        <v-dialog
            v-model="showVoidDialog"
            v-if="batchLoaded && batchId === maxBatchId && userIsAdmin && !voidedBatch"
            width="500">
          <template #activator="{ on }">
            <a-btn
                color="red"
                class="ml-3"
                :activation-handler="on"
                :disabled="disableVoidButton()"
                text="VOID BATCH"
            ></a-btn>
          </template>
          <v-card>
            <v-card-title
                class="text-h5 grey lighten-2"
                primary-title>
              Confirm
            </v-card-title>

            <v-card-text class="pt-4">
              Are you sure you want to void this batch? This will reset each approved payment in this batch and cannot be undone.
            </v-card-text>

            <v-divider></v-divider>

            <v-card-actions>
              <v-spacer></v-spacer>
              <a-btn
                  @click="showVoidDialog = false"
                  color="unset"
                  text="No"
              ></a-btn>
              <a-btn
                  color="primary"
                  variant="text"
                  @click="voidBatch()"
                  text="Yes"
              ></a-btn>
            </v-card-actions>
          </v-card>
        </v-dialog>
        <v-spacer></v-spacer>
        <div class="btn-container">
          <a-btn
              class="mr-3"
              variant="text"
              color="primary"
              v-show="batchLoaded && !voidedBatch"
              @click="exportChase"
              text="Download Chase CSV"
          ></a-btn>
          <a-btn
              color="primary"
              v-show="batchLoaded && !voidedBatch"
              @click="exportPayments"
              text="Export"
          ></a-btn>
        </div>
      </div>
      <div>
        <a-text-field
            prepend-inner-icon="search"
            label="Search payments..."
            v-model="searchQuery"
            v-show="batchLoaded && !voidedBatch"
            @input="debounceFilterPayments"
        ></a-text-field>
      </div>
    </v-card>
    <v-divider></v-divider>

    <v-col cols="12" class="px-0" v-show="batchLoaded">

      <div v-if="voidedBatch" class="error--text">
        Voided Batch: No Payment Details Available
      </div>

      <v-data-table
          :headers="visibleHeaders"
          :items="filteredPayments"
          :footer-props="footerProps"
          :search="paymentsSearch"
          :options="pagination"
          :items-per-page="-1"
          :mobile-breakpoint="0"
          fixed-header
          dense
          v-else
          class="elevation-1 pay-table"
      >

        <template #no-data>
          <span class="default-text-color">No data available</span>
        </template>

        <template #no-results>
          <span class="default-text-color">No data available</span>
        </template>

        <template #item="{ item: it, index }">
          <tr :class="{'shaded-row': index % 2}">
            <td class="text-left"><a href="" @click="goToDetails(it)"> {{ it.projectName ? it.projectName : '' }}</a>
            </td>
            <td class="text-left">{{ it.projectId ? it.projectId : '' }}</td>
            <td class="text-left">{{ it.paymentNbr ? it.paymentNbr : '' }}</td>
            <td class="text-left">{{ it.paymentAmount || 0 | currency('$', 2) }}</td>
            <td class="text-left">{{ it.checkNumber ? it.checkNumber : '' }}</td>
          </tr>
        </template>
      </v-data-table>

    </v-col>

  </v-container>
</template>

<script setup>


import {handleHidingGlobalLoader, getRequest, postRequest, } from '@/helpers/helpers'
import constants from '@/helpers/constants'
import moment from 'moment'
import {saveAs} from 'file-saver'
import {mapState} from "vuex";
import debounce from "lodash.debounce";

import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const FILTER_TYPE = {
  TEXT: 'text',
  SELECT: 'select'
}

const FILTER_DEFAULTS = {
  projectName: {value: [], type: FILTER_TYPE.TEXT, model: 'projectName'},
  projectId: {value: [], type: FILTER_TYPE.TEXT, model: 'projectId'}
}

const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 500],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const headers = ref([
  {text: 'Project Name', value: 'projectName', show: true},
  {text: 'Project ID', value: 'projectId', show: true},
  {text: 'Payment #', value: 'paymentNbr', show: true},
  {text: 'Payment Amount', value: 'paymentAmount', show: true},
  {text: 'Check #', value: 'checkNumber', show: true},
])
const batches = ref([])
const payments = ref([])
const batchId = ref('')
const batchLoaded = ref(false)
const paymentSearchFilters = ref({projectName: [],projectId: []})
const paymentsSearch = ref('')
const voidedBatch = ref(false)
const pagination = ref({})
const paymentSum = ref(0)
const showVoidDialog = ref(false)
const batchDisplayName = ref('')
const maxBatchId = ref(null)
const newPayDialog = ref(false)
const searchQuery = ref('')
const filteredPayments = ref([])

onMounted(() => {
  getAllBatches()
})

const userIsAdmin = computed(() => {
  return userStore.userHasFeatureAccessLevel('REBATES', 'ADMIN')
})
const visibleHeaders = computed(() => {
  return headers.value.filter(header => header.show === true)
})
watch(payments, () => {
  let paymentAmountSum = 0;
  filteredPayments.value.forEach(p => {
    paymentAmountSum += p.paymentAmount;
  });
  paymentSum.value = paymentAmountSum;
})

const getAllBatches = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest('/rebate/getBatches', 'blueraven')
    batches.value = data

    batches.value.forEach(b => {
      b.displayName = b.id + ' - ' + formatDate(b.batchDate) + ' - ' + b.updatedByUser;
    });

    maxBatchId.value = Math.max(...batches.value.map(b => b.id))

    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Batches')

    appStore.loading = false
  }
}
const disableVoidButton = () => {
  //dont allow voiding batch if not the most recent batch OR if any payment in the batch has a check number
  return batchId.value !== maxBatchId.value || payments.value.some(p => p.checkNumber != null)
}
const voidBatch = async () => {
  appStore.loading = true
  try {
    const {status} = await postRequest('/rebate/voidBatch/' + batchId.value, {},'blueraven')
    voidedBatch.value = true
    showVoidDialog.value = false
    handleHidingGlobalLoader( status)
    snackbar('SUCCESS', 'Batch Voided')

  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Voiding Batch')

    appStore.loading = false
  }
}
const getBatchDetails = async (batchId) => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest('/rebate/getBatchDetails/' + batchId, 'blueraven')
    payments.value = data.rebatePayments;
    filteredPayments.value = data.rebatePayments;
    batchDisplayName.value = data.id + ' - ' + formatDate(data.batchDate) + ' - ' + data.updatedByUser;
    voidedBatch.value = data.voidedBatch
    batchLoaded.value = true;
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Batch Details')

    appStore.loading = false
  }
}
const exportPayments = async () => {
  appStore.loading = true
  try {
    let csvData = 'Project Name,Project ID,Payment #,Payment Amount,Check #\n';
    filteredPayments.value.forEach(p => {
      csvData += '"' + p.projectName + '",' + p.projectId + ',' + p.paymentNbr + ',' + p.paymentAmount
          + ',' + p.checkNumber + '\n';
    })
    let blob = new Blob([csvData], {
      type: 'text/csv;charset=utf-8'
    });
    saveAs(blob, batchDisplayName.value + ".csv");
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Exporting Batch')

    appStore.loading = false
  }
}
const exportChase = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest('/rebate/getBatchDetails/' + batchId.value + '/chase-csv', 'blueraven')
    let blob = new Blob([data], {
      type: 'text/csv;charset=utf-8'
    });
    saveAs(blob, 'ChaseCSV_Batch_' + batchId.value + ".csv");
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Exporting Chase CSV')

    appStore.loading = false
  }
}
const debounceFilterPayments = debounce((query) => {
  filteredPayments.value = payments.value && payments.value.filter(pay => {

    return (pay['projectName'].toLowerCase().includes(searchQuery.value.toLowerCase()) ||
        pay['projectId'].toString().includes(searchQuery.value.toLowerCase()) ||
        pay['paymentNbr'].toString().includes(searchQuery.value.toLowerCase()) ||
        (pay['checkNumber'] == null ? false : pay['checkNumber'].toString().includes(searchQuery.value.toLowerCase()))
    )
  })
}, 500)
const formatDate = (value) => {
  if (value) {
    return moment(String(value)).format('MM/DD/YYYY')
  }
}
const goToDetails = (item) => {
  router.push({name: 'rebateDetails', params: {id: item.projectId}})
}
const addItem = () => {
  newPayDialog.value = true
}
const changeSort = (column) => {
  if (pagination.value.sortBy === column) {
    pagination.value.descending = !pagination.value.descending
  } else {
    pagination.value.sortBy = column
    pagination.value.descending = false
  }
}
</script>

<style lang="scss">
#commissions-container .v-data-table__wrapper {
  height: calc(100vh - 375px);
  min-height: 300px;
}
</style>

<style lang="scss" scoped>
.v-data-table {
  border-radius: 0;
}

.batches-select {
  max-width: 500px;
}

.btn-container {
  display: flex;
  align-items: center;
}

.pay-header {
  display: flex;
  align-items: center;
}
</style>
