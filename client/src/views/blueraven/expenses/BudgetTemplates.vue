<template>
  <v-container id="monthly-budget-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="app-title">Budget Templates</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                variant="text"
                color="primary"
                @click="[createNew = !createNew, newTemplate = {}, expanded = [], getAvailableUsers()]"
                :prepend-icon="!createNew ? 'add' : 'close'"
                hide-text-on-mobile
                :text="createNew ? 'cancel' : 'Add Template'"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card flat v-if="createNew" class="pa-4">
          <h3>New Template</h3>
          <v-autocomplete v-model="newTemplate.userId"
                          :items="availableUsers"
                          label="Assign to User"
                          item-text="fullName"
                          item-value="id"
          ></v-autocomplete>
          <a-text-field
                        type="number"
                        prepend-icon="mdi-currency-usd"
                        label="Amount"
                        v-model.number="newTemplate.amount">
          </a-text-field>
          <a-btn
              color="primary"
              :disabled="!newTemplate.userId || !newTemplate.amount"
              @click="saveTemplate(newTemplate, true)"
              text="Save"
          ></a-btn>
        </v-card>
        <v-divider v-if="createNew" ></v-divider>
        <v-data-table
            :headers="headers"
            :items="filteredTemplates"
            :items-per-page="100"
            :mobile-breakpoint="0"
            single-expand
            :loading="dataLoading"
            fixed-header
            :expanded.sync="expanded"
            :footer-props="footerProps"
            class="elevation-1 fix-column-width-bug square-card"
        >
          <template #no-data>
            <span class="default-text-color">No Templates</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No Templates</span>
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': templates.indexOf(item) % 2}">
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
                <a-btn
                    :disabled="false"
                    color="primary"
                    class="mr-2"
                    @click="saveTemplate(item, false)"
                    text="Save"
                ></a-btn>
              </v-card>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{ item.userFullName }}</td>
              <td class="text-left">{{ item.amount | currency('$', 2) }}</td>
              <td class="text-left">
                <div v-if="item.currentMonthBudgetId">
                  Already Exists
                </div>
                <a-btn
                    v-else
                    color="primary"
                    @click="generateCurrentMonthBudget(item)"
                    text="Generate"
                ></a-btn>
              </td>
              <td>
                <div style="display: flex; justify-content: flex-end">
                  <a-btn
                      size="small"
                      variant="text"
                      color="primary"
                      v-if="!expanded.includes(item)"
                      @click="[createNew = false, expanded = [item]]"
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
        @confirm="[itemToDelete.archived=true,deleteTemplate(itemToDeleteId)]"
        @close-dialog="closeDeleteDialog">
      Are you sure you want to this template for {{itemToDelete.userFullName}}: {{ itemToDelete.amount | currency('$', 0)}}?

    </ConfirmationDialog>
  </v-container>
</template>

<script setup>

import {handleHidingGlobalLoader, getRequest, postRequest,  deleteRequest} from '@/helpers/helpers'
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
const createNew = ref(false)
const newTemplate = ref({})
const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 500],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const availableUsers = ref([])
const templates = ref([])
const expanded = ref([])
const headers = ref([
  {text: 'User', value: 'userFullName', show: true, width: '125px'},
  {text: 'Amount', value: 'amount', show: true, width: '75px'},
  {text: 'Current Month Budget', value: 'amount', show: true, width: '125px'},
  {text: null, value: 'icons', show: true, sortable: false, width: '125px'}
])
const deleteConfirm = ref(false)
const itemToDelete = ref({})

const itemToDeleteId = computed(() => {
  return itemToDelete.value ? itemToDelete.value.id : ''
})
const isMobile = computed(() => {
  return vuetify.breakpoint.smAndDown
})
const filteredTemplates = computed(() => {
  return templates.value.filter(b => !b.archived)
})

onMounted(() => {
  getTemplates()
})

const generateCurrentMonthBudget = async(item) => {
  appStore.loading = true
  try {
    //try to add a new budget
    let params = {
      userId: item.userId,
      amount: item.amount,
      startDate: moment().startOf('month').format('YYYY-MM-DD'),
      endDate: moment().endOf('month').format('YYYY-MM-DD')
    }
    const {data, status} = await postRequest(`/expenseBudgets`, params, 'blueraven')
    item.currentMonthBudgetId = data.id
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    let msg = e?.data?.detail || 'Error Generating a Budget for this User'
    snackbar('ERROR', msg)

    appStore.loading = false
  }
}

const getTemplates = async() => {
  dataLoading.value = true
  try {
    const {data, status} = await getRequest(`/expenseBudgets/templates`, 'blueraven')
    templates.value = data
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
const deleteTemplate = async (id) => {
  appStore.loading = true

  try {
    const {status} = await deleteRequest(`/expenseBudgets/templates/${id}`, 'blueraven')
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Error Deleting Budget')

    appStore.loading = false
  }
  closeDeleteDialog()
}
const saveTemplate = async(item, isNew) => {
  appStore.loading = true
  try {
    const {data, status} = await postRequest(`/expenseBudgets/templates`, item, 'blueraven')
    if(isNew) {
      templates.value.push(data)
      newTemplate.value = {}
      createNew.value = false
    } else {
      expanded.value = []
    }
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', e?.data?.detail || 'Error Saving Template')

    appStore.loading = false
  }
}
const closeDeleteDialog = () => {
  deleteConfirm.value = false
  itemToDelete.value = {}
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
