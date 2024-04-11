<template>
  <v-container id="monthly-budget-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="app-title">
            <div class="flex-display">
              Monthly Budgets for:
              <a-select v-model="startMonth"
                        :items="months"
                        hide-details
                        custom-classes="mx-2 range-selector"
                        single-line
                        variant="outlined"
                        density="compact"
                        label="Month"
                        item-title="name"
                        item-value="id"
                        @input="getBudgets"
              ></a-select>
              <a-select v-model="startYear"
                        :items="years"
                        hide-details
                        custom-classes="range-selector"
                        single-line
                        variant="outlined"
                        density="compact"
                        label="Year"
                        item-title="name"
                        item-value="id"
                        @input="getBudgets"
              ></a-select>
            </div>
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                variant="text"
                color="primary"
                @click="[createNew = !createNew, newBudget = {}, expanded = [], getAvailableUsers()]"
                :prepend-icon="!createNew ? 'add' : 'close'"
                hide-text-on-mobile
                :text="createNew ? 'cancel' : 'Add Budget'"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card flat v-if="createNew" class="pa-4">
          <h3>New Budget</h3>
          <a-autocomplete v-model="newBudget.userId"
                          :items="availableUsers"
                          label="Assign to User"
                          item-title="fullName"
                          item-value="id"
          ></a-autocomplete>
          <a-text-field
                        type="number"
                        prepend-icon="mdi-currency-usd"
                        label="Amount"
                        v-model.number="newBudget.amount">
          </a-text-field>
          <a-select v-model="selectedMonth"
                    :items="months"
                    custom-classes="mr-3 reimbursement-range-selector"
                    label="Month"
                    item-title="name"
                    item-value="id"
          ></a-select>
          <a-select v-model="selectedYear"
                    :items="years"
                    custom-classes="reimbursement-range-selector"
                    label="Year"
                    item-title="name"
                    item-value="id"
          ></a-select>
          <a-textarea class="py-2" hide-details
                      auto-grow
                      variant="filled"
                      rows="4"
                      bg-color="#F2F6F8"
                      v-model="newBudget.notes">
          </a-textarea>
          <a-btn
              color="primary"
              :disabled="!newBudget.userId || !newBudget.amount || !selectedYear || !selectedMonth"
              @click="saveBudget(newBudget, true)"
              text="Save"
          ></a-btn>
        </v-card>
        <v-divider v-if="createNew" ></v-divider>
        <v-data-table
            :headers="headers"
            :items="filteredBudgets"
            :items-per-page="100"
            :mobile-breakpoint="0"
            :loading="dataLoading"
            single-expand
            fixed-header
            :expanded.sync="expanded"
            :footer-props="footerProps"
            class="elevation-1 fix-column-width-bug square-card"
        >
          <template #no-data>
            <span class="default-text-color">No Budgets</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No Budgets</span>
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': budgets.indexOf(item) % 2}">
              <v-card flat color="transparent" class="pa-4">
                <a-text-field
                              label="Assign to User"
                              disabled
                              v-model="item.userFullName">
                </a-text-field>
                <a-text-field
                              type="number"
                              label="Amount"
                              prepend-icon="mdi-currency-usd"
                              v-model.number="item.amount">
                </a-text-field>
                <a-select v-model="selectedMonth"
                          :items="months"
                          custom-classes="mr-3 reimbursement-range-selector"
                          label="Month"
                          item-title="name"
                          item-value="id"
                ></a-select>
                <a-select v-model="selectedYear"
                          :items="years"
                          custom-classes="reimbursement-range-selector"
                          label="Year"
                          item-title="name"
                          item-value="id"
                ></a-select>
                <a-textarea class="py-2" hide-details
                            auto-grow
                            variant="filled"
                            rows="4"
                            bg-color="#F2F6F8"
                            v-model="item.notes">
                </a-textarea>
                <a-btn
                    :disabled="false"
                    color="primary"
                    class="mr-2"
                    @click="saveBudget(item, false)"
                    text="Save"
                ></a-btn>
              </v-card>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{ item.userFullName }}</td>
              <td class="text-left">{{ item.startDate | formatDate('date', 'MMMM YYYY')}}</td>
              <td class="text-left">{{ item.amount | currency('$', 2) }}</td>
              <td class="text-left">{{ item.pendingApproval | currency('$', 2) }}</td>
              <td class="text-left">{{ item.pendingPayment | currency('$', 2) }}</td>
              <td class="text-left">{{ item.paid | currency('$', 2) }}</td>
              <td class="text-left">{{ item.balance | currency('$', 2) }}</td>
              <td>
                <div style="display: flex; justify-content: flex-end">
                  <a-btn
                      size="small"
                      variant="text"
                      color="primary"
                      v-if="!expanded.includes(item)"
                      @click="[handleItemClick(item), expanded = [item]]"
                      prepend-icon="edit"
                  ></a-btn>
                  <a-btn
                      size="small"
                      variant="text"
                      color="primary"
                      v-if="expanded.includes(item)"
                      @click="expanded = []"
                      text="cancel"
                  ></a-btn>
                  <a-btn
                      size="small"
                      variant="text"
                      color="primary"
                      @click="[deleteConfirm=true, itemToDelete = item]"
                      prepend-icon="delete"
                  ></a-btn>
                </div>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog
        :open-dialog = deleteConfirm
        @confirm="[itemToDelete.archived=true,deleteBudget(itemToDeleteId)]"
        @close-dialog="closeDeleteDialog">
      There may already be expenses assigned to this budget. Are you sure you want to delete?

    </ConfirmationDialog>
  </v-container>
</template>

<script setup>

import {
  handleHidingGlobalLoader,
  getRequest,
  getRequestWithParams,
  postRequest,

  deleteRequest,
  getYears,
  getMonthDateRange
} from '@/helpers/helpers'
import moment from 'moment'
import constants from "@/helpers/constants"
import DatetimePickerInput from "@/components/DatetimePickerInput"
import ConfirmationDialog from "@/components/ConfirmationDialog";

import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar
const vuetify = vueInstance.$vuetify


const dataLoading = ref(true)
const selectedMonth = ref(parseInt(moment().format('M')))
const selectedYear = ref(parseInt(moment().format('YYYY')))
const startMonth = ref(parseInt(moment().format('M')))
const startYear = ref(parseInt(moment().format('YYYY')))
const months = ref(constants.MONTHS)
const years = ref(getYears(2017, true))
const createNew = ref(false)
const newBudget = ref({})
const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 500],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const showPastBudgets = ref(false)
const availableUsers = ref([])
const budgets = ref([])
const expanded = ref([])
const headers = ref([
  {text: 'User', value: 'userFullName', show: true, width: '125px'},
  {text: 'Budget Month', value: 'startDate', show: true, width: '125px'},
  {text: 'Amount', value: 'amount', show: true, width: '75px'},
  {text: 'Pending Approval', value: 'pendingApproval', show: true, width: '75px'},
  {text: 'Pending Payment', value: 'pendingPayment', show: true, width: '75px'},
  {text: 'Paid', value: 'paid', show: true, width: '75px'},
  {text: 'Remaining Budget', value: 'balance', show: true, width: '75px'},
  {text: null, value: 'icons', show: true, sortable: false, width: '125px'}
])
const deleteConfirm = ref(false)
const itemToDelete = ref(null)

const itemToDeleteId = computed(() => {
  return itemToDelete.value ? itemToDelete.value.id : ''
})
const isMobile = computed(() => {
  return vuetify.breakpoint.smAndDown
})
const filteredBudgets = computed(() => {
  return budgets.value?.filter(b => !b.archived)
})

onMounted(() => {
  getBudgets()
})

const handleItemClick = (item) => {
  createNew.value = false
  selectedMonth.value = parseInt(moment(item.startDate).format('M'))
  selectedYear.value = parseInt(moment(item.endDate).format('YYYY'))
}
const getBudgets = async() => {
  budgets.value = []
  dataLoading.value = true
  try {
    const { startDate } = getMonthDateRange(startMonth.value, startYear.value)
    let params = {
      startDate
    }
    const {data, status} = await getRequestWithParams(`/expenseBudgets/list`, {params}, 'blueraven')
    budgets.value = data
    dataLoading.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

  }
}
const getAvailableUsers = async() => {
  if(createNew.value) {
    appStore.loading = true
    try {
      const {data, status} = await getRequest(`/expenseBudgets/availableUsers`, 'blueraven')
      availableUsers.value = data
      handleHidingGlobalLoader( status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Data')

      appStore.loading = false
    }
  }
}
const deleteBudget = async (id) => {
  appStore.loading = true

  try {
    const {status} = await deleteRequest(`/expenseBudgets/${id}`, 'blueraven')
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Error Deleting Budget')

    appStore.loading = false
  }
  closeDeleteDialog()
}
const saveBudget = async(item, isNew) => {
  appStore.loading = true
  try {
    let startDate = moment([selectedYear.value, selectedMonth.value - 1]).format("YYYY-MM-DD")
    let endDate = moment(startDate).endOf('month').format("YYYY-MM-DD")
    item.startDate = startDate
    item.endDate = endDate

    const {data, status} = await postRequest(`/expenseBudgets`, item, 'blueraven')
    if(isNew) {
      budgets.value.push(data)
      newBudget.value = {}
      createNew.value = false
    } else {
      expanded.value = []
    }
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', e?.data?.message || 'Error Saving Budget')

    appStore.loading = false
  }
}
const closeDeleteDialog = () => {
  deleteConfirm.value = false
  itemToDelete.value = null
}

</script>

<style lang="scss">
#monthly-budget-container .v-data-table__wrapper {
  height: calc(100vh - 290px);
  min-height: 300px;
}
</style>

<style lang="scss" scoped>
#monthly-budget-container {
  margin-top: -15px;
  padding-left: 0;
  padding-right: 0;
  padding-top: 0;
}
</style>
