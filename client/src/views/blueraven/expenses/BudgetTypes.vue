<template>
  <v-container id="budget-type-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="app-title">Budget Types</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                variant="text"
                color="primary"
                @click="[createNew = !createNew, newBudgetType = {}]"
                :prepend-icon="!createNew ? 'add' : 'close'"
                :text="createNew ? 'cancel' : 'Add Budget Template'"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card flat v-if="createNew" class="pa-4">
          <h3>New Budget Type</h3>
          <a-text-field
                        type="text"
                        label="Budget Type"
                        v-model="newBudgetType.name">
          </a-text-field>
          <a-btn
              color="primary"
              :disabled="!newBudgetType.name"
              @click="saveBudgetType(newBudgetType, true)"
              text="Save"
          ></a-btn>
        </v-card>
        <v-divider v-if="createNew" ></v-divider>
        <v-data-table
            :headers="headers"
            :items="filteredBudgetTypes"
            :items-per-page="-1"
            :loading="dataLoading"
            :mobile-breakpoint="0"
            class="elevation-1 fix-column-width-bug square-card"
            :footer-props="footerProps"
        >
          <template #no-data>
            <span class="default-text-color">No Budget Types</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No Budget Types</span>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">
                <a-text-field
                              type="text"
                              v-if="index === editIndex"
                              label="Budget Type"
                              v-model="item.name">
                </a-text-field>
                <div v-else>
                  {{ item.name }}
                </div>
              </td>
              <td>
                <div style="display: flex; justify-content: flex-end">
                  <a-btn
                      size="small"
                      variant="text"
                      color="primary"
                      @click="editIndex = index"
                      v-if="index !== editIndex"
                      prepend-icon="edit"
                  ></a-btn>
                  <a-btn
                      size="small"
                      variant="text"
                      color="primary"
                      @click="saveBudgetType(item, false)"
                      v-if="index === editIndex"
                      prepend-icon="save"
                  ></a-btn>
                  <a-btn
                      size="small"
                      variant="text"
                      color="primary"
                      @click="editIndex = null"
                      v-if="index === editIndex"
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
        @confirm=deleteBudgetType(itemToDelete)
        @close-dialog="closeDeleteDialog">
      Are you sure you want to delete this Budget Type <strong>{{itemToDeleteName}}</strong>?
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>

import {handleHidingGlobalLoader, getRequest, deleteRequest, postRequest, } from '@/helpers/helpers'
import ConfirmationDialog from "@/components/ConfirmationDialog";
import constants from "@/helpers/constants.js";

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

const createNew = ref(false)
const dataLoading = ref(true)
const newBudgetType = ref({})
const editIndex = ref(null)
const budgetTypes = ref([])
const headers = ref([
  {text: 'Type', value: 'name', show: true},
  {text: null, value: 'icons', show: true}
])
const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 500],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const deleteConfirm = ref(false)
const itemToDelete = ref(null)

const itemToDeleteName = computed(() => {
  return itemToDelete.value ? itemToDelete.value.name : ''
})
const isMobile = computed(() => {
  return vuetify.breakpoint.smAndDown
})
const filteredBudgetTypes = computed(() => {
  return budgetTypes.value.filter(bt => !bt.archived)
})
onMounted(() => {
  getBudgetTypes()
})

const getBudgetTypes = async() => {
  dataLoading.value = true
  try {
    const {data, status} = await getRequest(`/expenseBudgets/budgetTypes`, 'blueraven')
    budgetTypes.value = data
    dataLoading.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

  }
}
const deleteBudgetType = async(item) => {
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`/expenseBudgets/budgetType/${item.id}`, 'blueraven')
    item.archived = true
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting Budget Type')

    appStore.loading = false
  }
  closeDeleteDialog()
}
const saveBudgetType = async(item, isNew) => {
  appStore.loading = true
  try {
    const {data, status} = await postRequest(`/expenseBudgets/budgetType`, item, 'blueraven')
    if(isNew) {
      budgetTypes.value.push(data)
      newBudgetType.value = {}
      createNew.value = false
    } else {
      editIndex.value = null
    }
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Budget Type')

    appStore.loading = false
  }
}
const closeDeleteDialog = () => {
  deleteConfirm.value = false
  itemToDelete.value = null
}
</script>

<style lang="scss">
#budget-type-container .v-data-table__wrapper {
  height: calc(100vh - 290px);
  min-height: 300px;
}
</style>

<style lang="scss" scoped>
#budget-type-container {
  margin-top: -15px;
  padding-left: 0;
  padding-right: 0;
  padding-top: 0;
}
</style>