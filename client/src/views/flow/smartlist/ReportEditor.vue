<template>
<v-container id="report-editor" class="fill-height align-start">
  <v-row class="align-content-start">
    <v-col cols="12">
      <v-toolbar color="white" class="elevation-0">
        <v-toolbar-title class="app-title">{{ report.name }}</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-btn
            text
            color="primary"
            @click.stop="exportReport"
          >
            <v-icon>mdi-tray-arrow-down</v-icon>
            <span>Export</span>
          </v-btn>
        </v-toolbar-items>
      </v-toolbar>
    </v-col>
    <v-col cols="12">

    </v-col>
  </v-row>
</v-container>
</template>

<script setup>
import useReportStore from '@/views/flow/smartlist/reportStore'
import { getCurrentInstance, ref } from 'vue'
import { getRequest, getSnackbar, logError } from '@/helpers/helpers'
import { AppMutations } from '@/stores/AppStore'
import { DateTime } from 'luxon'

const vueInstance = getCurrentInstance().proxy
const route = vueInstance.$route
const snackbar = vueInstance.$snackbar

const reportStore = useReportStore()
reportStore.$subscribe((mut, state) => localStorage.setItem('report', JSON.stringify(state)))

const store = vueInstance.$store
const userCanAdd = store.getters.userHasFeatureAccessLevel('SMARTLIST', 'ADD')
const userCanEdit = store.getters.userHasFeatureAccessLevel('SMARTLIST', 'EDIT')
const userCanDelete = store.getters.userHasFeatureAccessLevel('SMARTLIST', 'DELETE')

const reportId = route.params.reportId

const report = ref({})

const getReport = async () => {
  try {
    const {data} = await getRequest(`/smartlist/${reportId}?accessControl=true`)
    report.value = data
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Unable to fetch smartlist')
  }
}

const exportReport = async () => {
  if (Object.keys(report.value).length > 0) {
    try {
      store.commit(AppMutations.SET_LOADING, true)
      const {data} = await getRequest(`/smartlist/${report.value.id}/export`)
      let blob = new Blob([data], {
        type: 'text/csv;charset=utf-8'
      })
      saveAs(blob, `${report.value.name} ${DateTime.local().toFormat('yyyy-MM-dd h_mm a')}.csv`)
    } catch (e) {
      logError(e)
      store.commit(AppMutations.SHOW_SNACK, getSnackbar('ERROR', e.data.message))
    } finally {
      store.commit(AppMutations.SET_LOADING, false)
    }
  }
}

getReport()
</script>

<style scoped>

</style>