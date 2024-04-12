<template>
  <v-container class="pa-0">
    <v-card flat color="white" class="px-3 mt-3 square-card">
      <div class="pay-header">
        <a-select v-model="status"
                  custom-classes="status-select pt-3 pl-1"
                  :items="statuses"
                  no-data-text="No Status Available"
                  label="Status: "
                  item-title="text"
                  item-value="value"
                  v-bind:class="status"
                  @change="fetchPayments()"
        ></a-select>
        <v-spacer></v-spacer>
        <div v-if="status === 'approval'" class="pl-4">Payment Amount Total: <b>{{
            paymentSum || 0 | currency('$', 2)
          }}</b></div>
        <div v-if="showApproval" class="approvalDiv default-text-color">
          <!--          not sure why they need to see this, it just shows them their own name -->
          <!--          <label><b>Approved By:</b></label>-->
          <!--          {{ userName }}-->
          <!--          <br/>-->
          <a-btn
              color="primary"
              @click="approveDialog = true"
              class="ml-3"
              text="Approve and Create Batch"
          ></a-btn>
        </div>

        <v-spacer></v-spacer>
        <a-btn
            color="primary"
            @click="exportPayments"
            text="Export"
        ></a-btn>
      </div>
      <div>
        <a-text-field
            prepend-inner-icon="search"
            label="Search payments..."
            v-model="searchQuery"
            @input="debounceFilterPayments"
        ></a-text-field>
      </div>
    </v-card>

    <v-col cols="12" class="px-0 pt-0">
      <v-data-table
          :headers="visibleHeaders"
          :items="filteredPayments"
          :search="paymentsSearch"
          :options="pagination"
          :footer-props="footerProps"
          :items-per-page="itemsPerPage"
          :show-select="showSelect"
          fixed-header
          dense
          class="elevation-1 pay-table"
      >

        <template #no-data>
          <span class="default-text-color">No payments found</span>
        </template>

        <template #no-results>
          <span class="default-text-color">No payments found</span>
        </template>

        <template v-slot:header.data-table-select="{ on, props }">
          <v-checkbox :disabled="!userCanEdit" color="primary" class="mx-2" v-model="selectAll"
                      @change="toggleSelectAll()"></v-checkbox>
        </template>

        <template #body="{ items }">
          <tr
              v-for="(it, index) in items"
              :key="it.id"
              :class="['text-sm-left', 'row-hover', { 'shaded-row': !(index % 2) }]"
          >
            <td v-if="status === 'approval'" class="flex-display justify-center">
              <v-checkbox color="primary" :readonly="!userCanEdit"
                          :disabled="!userCanEdit" v-model="it.selected"></v-checkbox>
            </td>
            <td class="text-left" v-if="status === 'invalid' || status === 'approval'"><a class="underline"
                                                                                          @click="goToDetails(it)">
              {{ it.projectName ? it.projectName : '' }}</a></td>
            <td class="text-left" v-else>{{ it.projectName ? it.projectName : '' }}</td>
            <td class="text-left">
              <router-link :to="`/project/${it.projectId}/${defaultProjectPage}`">{{ it.projectId }}</router-link>
            </td>
            <td class="text-left">{{ it.substantialCompletionDate | formatDate('date') }}</td>
            <td class="text-left">{{ it.financier ? it.financier : '' }}</td>
            <td class="text-left">{{ it.product ? it.product : '' }}</td>
            <td class="text-center">{{ it.totalPromotionAmount || 0 | currency('$', 2) }}</td>
            <td v-show="status === 'approval'" class="text-center">{{ it.numberOfPromotionPayments }}</td>
            <td v-show="status === 'approval'" class="text-center pl-5">{{ it.paymentAmount || 0 | currency('$', 2) }}</td>
            <td v-show="status === 'approval'" class="text-center pl-5">{{ it.nextScheduledPayment}}</td>
            <td v-show="status === 'approval'" class="text-left">{{ it.totalPaid || 0 | currency('$', 2) }}</td>
            <td v-show="status === 'approval'" class="text-left">{{ it.lastPaymentDate | formatDate('date') }}</td>
            <td v-show="status === 'invalid' || status === 'approval'" class="text-left">
              {{ it.balanceOwed || 0 | currency('$', 2) }}
            </td>
            <td v-show="status === 'pending'" class="text-left"><a v-if="userCanEdit" @click="enterPayment(it)"
                                                                   class="mr-3 pay-link">Enter Now</a></td>
          </tr>
        </template>
      </v-data-table>

      <v-dialog v-model="newPayDialog" max-width="1000px">
        <v-card>
          <v-card-title>
            <span class="text-h5">New Recurring Payment</span>
          </v-card-title>
          <v-card-text>
            <v-row>
              <v-col>
                <a-text-field label="Project Name"
                              v-model="newPayItem.projectName"
                              disabled
                ></a-text-field>
                <a-text-field label="Project ID"
                              v-model="newPayItem.projectId"
                              disabled
                ></a-text-field>
                <a-text-field label="Substantial Completion"
                              v-model="newPayItem.sc"
                              disabled
                ></a-text-field>
                <a-text-field label="Financier"
                              v-model="newPayItem.financier"
                              disabled
                ></a-text-field>
                <a-text-field label="Product"
                              v-model="newPayItem.product"
                              disabled
                ></a-text-field>
              </v-col>
              <v-col>
                <a-text-field label="Total Promotion Amount"
                              v-model="newPayItem.totalPromotionAmount"
                ></a-text-field>
                <a-text-field label="# of Promotion Payments"
                              v-model="newPayItem.numberOfPromotionPayments"
                ></a-text-field>
                <a-text-field label="$ / Promotion Payment"
                              v-model="perPromotionPayment"
                              disabled>
                </a-text-field>
                <a-text-field label="Verified By"
                              v-model="newPayItem.createdBy"
                              disabled
                ></a-text-field>
              </v-col>
            </v-row>
          </v-card-text>

          <v-card-actions>
            <v-spacer></v-spacer>
            <a-btn
                color="primary"
                variant="text"
                @click="close"
                text="Cancel"
            ></a-btn>
            <a-btn
                color="primary"
                raised
                :disabled="submittingPay"
                @click="submitPay"
                text="Submit"
            ></a-btn>
          </v-card-actions>
        </v-card>
      </v-dialog>
    </v-col>
    <ConfirmationDialog :open-dialog="approveDialog"
                        @close-dialog="approveDialog = false"
                        @confirm="[approveDialog=false, passwordDialog=true]">
      <template v-slot:title>Confirm</template>
      This will approve and create a batch for the selected payments, would you like to proceed?
      <template v-slot:no>cancel</template>
      <template v-slot:yes>confirm</template>
    </ConfirmationDialog>

    <ConfirmationDialog :open-dialog="passwordDialog"
                        @close-dialog="passwordDialog = false"
                        @confirm="confirmPassword()"
    >
      <template v-slot:title>Please confirm payment approval</template>
      <a-text-field class="passwordTextfield"
                    label="Please confirm your password:"
                    v-model="passwordInput"
                    type="password"
      ></a-text-field>
      <template v-slot:no>cancel</template>
      <template v-slot:yes>confirm</template>
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>
import {handleHidingGlobalLoader, getRequest, postRequest, getProjectPath,} from '@/helpers/helpers'
import constants from '@/helpers/constants'

import {saveAs} from 'file-saver'
import moment from "moment";
import debounce from "lodash.debounce";
import ConfirmationDialog from "@/components/ConfirmationDialog";

import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const defaultProjectPage = ref(getProjectPath().pathSuffix)
const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 500],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const payments = ref([])
const headers = ref([
  {text: 'Project Name', value: 'projectName', show: true},
  {text: 'Project ID', value: 'projectId', show: true},
  {text: 'Substantial Completion', value: 'substantialCompletionDate', show: true},
  {text: 'Financier', value: 'financier', show: true},
  {text: 'Product', value: 'product', show: true},
  {text: 'Total Promotion Amount', value: 'totalPromotionAmount', show: true},
  {text: '# Payments', value: 'numberOfPromotionPayments', show: false},
  {text: 'Payment Amount', value: 'paymentAmount', show: false},
  {text: 'Next Payment #', value: 'nextScheduledPayment', show: false},
  {text: 'Total Paid', value: 'totalPaid', show: false},
  {text: 'Last Payment Date', value: 'lastPaymentDate', show: false},
  {text: 'Balance Owed', value: 'balanceOwed', show: false},
  {text: '', show: false}
])
const statuses = ref([
  {text: 'New Pending',value: 'pending'},
  {text: 'Needs Approval',value: 'approval'},
  {text: 'Invalid',value: 'invalid'}
])
const status = ref('approval')
const newPayItem = ref({projectName: '',projectId: 0,sc: '',financier: '',product: '',totalPromotionAmount: 0,numberOfPromotionPayments: 0,paymentAmount: 0,nextScheduledPayment: 1,verifiedBy: '',createdByUserId: '',paymentStartDate: '',selected: false,})
const paymentsSearch = ref('')
const submittingPay = ref(false)
const pagination = ref({})
const selectAll = ref(false)
const showSelect = ref(false)
const itemsPerPage = ref(50)
const userName = ref('')
const approveDialog = ref(false)
const passwordDialog = ref(false)
const newPayDialog = ref(false)
const passwordInput = ref('')
const searchQuery = ref('')
const filteredPayments = ref([])

const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('REBATES', 'EDIT')
})
const visibleHeaders = computed(() => {
  return headers.value.filter(header => header.show === true)
})
const perPromotionPayment = computed(() => {
  return newPayItem.value.numberOfPromotionPayments == 0 ? 0 : (newPayItem.value.totalPromotionAmount / newPayItem.value.numberOfPromotionPayments).toFixed(2);
})
const showApproval = computed(() => {
  return payments.value.filter(p => p.selected === true).length > 0
})
const paymentIdsToApprove = computed(() => {
  return payments.value.filter(p => p.selected === true).map(p => p.paymentId)
})
const paymentSum = computed(() => {
  let sum = 0;
  let selectedPayments = filteredPayments.value.filter(p => p.selected === true);
  if (selectedPayments.length > 0) {
    selectedPayments.forEach(p => sum += p.paymentAmount)
  } else {
    filteredPayments.value.forEach(p => sum += p.paymentAmount)
  }

  return sum;
})

onMounted(() => {
  appStore.loading = true
  Promise.all([
    fetchPayments()
  ]).then(() => appStore.loading = false)
})

const fetchPayments = async() => {
  appStore.loading = true
  try {
    if (status.value === 'approval') {
      const {data, status} = await getRequest('/rebate/needsApproval', 'blueraven')
      showSelect.value = true;
      // # Of Payments
      headers.value[6].show = true;
      //Payment Amount
      headers.value[7].show = true;
      // Next Payment #
      headers.value[8].show = true;
      // Total Paid
      headers.value[9].show = true;
      // Last Payment Date
      headers.value[10].show = true;
      // Balance Owed
      headers.value[11].show = true;
      //empty header
      headers.value[12].show=false

      payments.value = data;
      filteredPayments.value = data;

      let userData = await getRequest('/user/current')
      userName.value = userData.data.fullName;
      handleHidingGlobalLoader( status)
    } else if (status.value === 'pending') {
      const {data, status} = await getRequest('/rebate/pending', 'blueraven')
      payments.value = data;
      filteredPayments.value = data;

      showSelect.value = false;
      // # Of Payments
      headers.value[6].show = false;
      //Payment Amount
      headers.value[7].show = false;
      // Total Paid
      headers.value[8].show = false;
      // Last Payment Date
      headers.value[9].show = false;
      // Balance Owed
      headers.value[10].show = false;
      //empty header
      headers.value[11].show = userCanEdit.value;

      handleHidingGlobalLoader( status)
    } else if (status.value === 'invalid') {
      const {data, status} = await getRequest('/rebate/unbalancedPayments', 'blueraven')
      payments.value = data;
      filteredPayments.value = data;

      showSelect.value = false;
      // # Of Payments
      headers.value[6].show = false;
      //Payment Amount
      headers.value[7].show = false;
      // Total Paid
      headers.value[8].show = false;
      // Last Payment Date
      headers.value[9].show = false;
      // Balance Owed
      headers.value[10].show = false;
      // Balance Owed
      headers.value[10].show = true;
      //empty header
      headers.value[11].show = false;
      handleHidingGlobalLoader( status)
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving rebate payments')

  }
}

const debounceFilterPayments = debounce((query) => {
  filteredPayments.value = payments.value.filter(pay => {
    return (pay['projectName'].toLowerCase().includes(searchQuery.value.toLowerCase()) ||
        pay['projectId'].toString().toLowerCase().includes(searchQuery.value.toLowerCase()) ||
        pay['product'].toString().toLowerCase().includes(searchQuery.value.toLowerCase())
    )
  })

  if (itemsPerPage.value > filteredPayments.value.length) {
    itemsPerPage.value = filteredPayments.value.length;
  }
}, 500)
const exportPayments = async() => {
  appStore.loading = true
  try {
    let filename = '';
    let csvData = 'Project Name,Project ID,Substantial Completion,Financier,Product,Total Promotion Amount, Next Payment #';
    if (status.value === 'approval') {
      filename = 'Needs Approval Payments.csv';
      csvData += ',# of Payments,$ / Promotion Payment,' +
          'Total Paid,Last Payment Date,Balance Owed';
    } else if (status.value === 'invalid') {
      filename = 'Invalid Payments.csv';
      csvData += ',Balance Owed';
    } else if (status.value === 'pending') {
      filename = 'New Pending Payments.csv';
    }

    csvData += '\n';

    filteredPayments.value.forEach(p => {
      csvData += '"' + p.projectName + '",' + p.projectId + ',' +
          (p.substantialCompletionDate != null ? moment(p.substantialCompletionDate).format('MM/DD/YYYY') : '') +
          ',"' + p.financier + '","' + p.product + '","' + p.totalPromotionAmount + '",' + p.nextScheduledPayment;

      if (status.value === 'approval') {
        csvData += ',' + p.numberOfPromotionPayments + ',' + p.paymentAmount + ',' + p.totalPaid + ',' +
            (p.lastPaymentDate != null ? moment(p.lastPaymentDate).format('MM/DD/YYYY') : '');
      }

      if (status.value === 'approval' || status.value === 'invalid') {
        csvData += ',' + p.balanceOwed;
      }

      csvData += '\n';
    })

    let blob = new Blob([csvData], {
      type: 'text/csv;charset=utf-8'
    });

    saveAs(blob, filename);
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Exporting Proposal Logs')

    appStore.loading = false
  }
}
const enterPayment = (item) => {
  if (item.substantialCompletionDate != null) {
    item.sc = moment(item.substantialCompletionDate).format('MM/DD/YYYY')
  }

  newPayItem.value = Object.assign({}, item)
  newPayDialog.value = true
}
const close = () => {
  newPayDialog.value = false
  newPayItem.value = {}
}
const submitPay = async() => {
  submittingPay.value = true
  try {
    const {status} = await postRequest('/rebate/recurringPayment', newPayItem.value, 'blueraven')
    snackbar('SUCCESS', 'Recurring Payment Saved')

    handleHidingGlobalLoader( status)
    await fetchPayments();
    submittingPay.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Failed to save Recurring Payment')

    appStore.loading = false
  }
  newPayDialog.value = false;
}
const changeSort = (column) => {
  if (pagination.value.sortBy === column) {
    pagination.value.descending = !pagination.value.descending
  } else {
    pagination.value.sortBy = column
    pagination.value.descending = false
  }
}
const goToDetails = (item) => {
  router.push({name: 'rebateDetails', params: {id: item.projectId}})
}
const toggleSelectAll = () => {
  filteredPayments.value.forEach(p => {
    p.selected = selectAll.value
  })
}
const confirmPassword = async() => {
  try {
    const params = {password: passwordInput.value}
    const resp = await postRequest('/user/validate', params)
    const {status} = resp

    if (status === 200) {
      let param = {paymentIds: paymentIdsToApprove.value}
      await postRequest('/rebate/approve', param, 'blueraven')
      window.location.reload()
      snackbar('SUCCESS', 'Payment approved')

    }
    passwordDialog.value = false;
    passwordInput.value = '';
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Failed to approve payment')

    passwordDialog.value = false;
    appStore.loading = false
  }
}
</script>

<style lang="scss" scoped>

.pay-link {
  color: var(--v-primary-lighten1);
  text-decoration: none;

  &:hover {
    text-decoration: underline;
  }
}

.pay-table {
  margin-top: 2px;
}

.v-data-table ::v-deep .v-data-table__wrapper {
  max-height: calc(100vh - 390px);
}

.v-data-table ::v-deep .v-data-table-header th {
  padding: 0;
  white-space: nowrap;
}

.status-select {
  max-width: 200px;
}

.pending {
  outline: 2px solid var(--v-warning-base);
}

.approval {
  outline: 2px solid var(--v-success-lighten1);
}

.invalid {
  outline: 2px solid var(--v-error-lighten1);
}

.approvalDiv {
  font-size: 14px
}

.pay-header {
  display: flex;
  align-items: center;
}

.underline{
  text-decoration: underline;
}
</style>
