<template>
  <v-container id="users-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">Error Log</v-toolbar-title>
          <v-spacer></v-spacer>
        </v-toolbar>
        <v-data-table
            :headers="headers"
            :items="filterErrors()"
            :fixed-header="true"
            disable-sort
            :mobile-breakpoint="0"
            :loading="dataLoading"
            hide-default-footer
            :calculate-widths="true"
            class="elevation-1 fix-column-width-bug"
        >
          <template #no-data>
            <span class="default-text-color">No available errors</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available errors</span>
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{ item.featureName }}</td>
              <td class="text-left">{{ item.errorMessage }}</td>
              <td class="text-left">{{ item.errorLogStatus }}</td>
              <td>
                <a-btn size="small" prepend-icon="delete" @click="logToDelete=item" />
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!logToDelete" @confirm="[logToDelete.archived = true, deleteError()]"
                        @close-dialog="logToDelete = null">
      Are you sure you want to delete this error log?
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>
import {handleHidingGlobalLoader, getRequest, deleteRequest, getSnackbar} from '@/helpers/helpers'
import ConfirmationDialog from "@/components/ConfirmationDialog";
import {getCurrentInstance, onMounted, ref} from 'vue'

import { useAppStore } from '@/stores/AppStore.js'
const appStore = useAppStore()

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const router = vueInstance.$router
const snackbar = vueInstance.$snackbar

const dialog = ref(false)
const errors = ref([])
const dataLoading = ref(true)
const logToDelete = ref(null)
const headers = ref([
  {text: 'Feature', value: 'featureName', show: true},
  {text: 'Error', value: 'errorMessage', show: true},
  {text: 'Status', value: 'errorLogStatus', show: true},
  {text: '', value: 'icons', show: true},
])

onMounted(() => {
  getErrors()
})

const getErrors = async () => {
  dataLoading.value = true
  try {
    const {data} = await getRequest(`/errorLog`)
    errors.value = data
    dataLoading.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Error Logs')
    dataLoading.value = false
  }
}
const deleteError = async () => {
  const id = logToDelete.value.id
  appStore.loading = true

  try {
    const {status} = await deleteRequest(`/errorLog/${id}`)
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Error Deleting Log')
    appStore.loading = false
  }
}
const filterErrors = () => {
  return errors.value.filter(e => {
    return !e.archived
  })
}
</script>

<style lang="scss">
#users-container .v-data-table__wrapper {
  height: calc(100vh - 290px);
  min-height: 300px;
}

.filter-header-non-select {
  padding-bottom: 12px !important;
}

.user-filter-select,
.user-filter-select .v-input__control,
.user-filter-select .v-input__control .v-input__slot,
.user-filter-select .v-input__control .v-input__slot fieldset {
  height: 40px !important;
  min-height: 40px !important;
}

.user-filter-select .v-select__selections {
  padding: 0 0 5px 0 !important;
  height: 40px !important;
}

.user-filter-select .v-input__append-inner {
  margin-top: 5px !important;
}
</style>

<style lang="scss" scoped>
#users-container {
  margin-top: -15px;
  padding-left: 0;
  padding-right: 0;
  padding-top: 0;
}

.user-table {
  margin-top: 2px;
}

.user-column {
  overflow: hidden;
}
</style>

