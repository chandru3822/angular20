<template>
<v-container id="report-editor" class="fill-height align-start">
  <v-row class="align-content-start">
    <v-col cols="12">
      <v-card class="elevation-1 square-card px-4">
        <v-toolbar flat color="white" class="report-toolbar">
          <v-toolbar-title>
            <v-text-field
              v-model="report.name"
              outlined
              label="Name"
              hide-details="true"
              ref="name"
            />
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn
              text
              color="primary"
              @click.stop="save"
            >
              <v-icon>save</v-icon>
              <span v-if="!constants.IS_MOBILE">Save</span>
            </v-btn>
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

        <v-autocomplete
          v-model="report.companyObjectTypeId"
          :items="filteredReportTypes"
          item-value="companyObjectTypeId"
          item-text="objectType"
          label="Data Type"
          placeholder="Data Type"
          :rules="constants.BASIC_REQUIRED_RULE"
        />
        <v-spacer />
      </v-card>

    </v-col>
    <v-col cols="12">
      <v-row>
        <v-col cols="3">
          <v-tabs>
            <v-tab>Columns</v-tab>
            <v-tab>Filters</v-tab>
          </v-tabs>
        </v-col>
        <v-col cols="9">
          <v-data-table>

          </v-data-table>
        </v-col>
      </v-row>
    </v-col>
  </v-row>
</v-container>
</template>

<script setup>
import useReportStore from '@/views/flow/smartlist/reportStore'
import { computed, getCurrentInstance, onMounted, ref } from 'vue'
import { getRequest, getSnackbar, logError, postRequest } from '@/helpers/helpers'
import { AppMutations } from '@/stores/AppStore'
import { DateTime } from 'luxon'
import constants from '@/helpers/constants'

const vueInstance = getCurrentInstance().proxy
const snackbar = vueInstance.$snackbar

const reportStore = useReportStore()
reportStore.$subscribe((mut, state) => localStorage.setItem('report', JSON.stringify(state)))

const store = vueInstance.$store
const userCanAdd = store.getters.userHasFeatureAccessLevel('SMARTLIST', 'ADD')
const userCanEdit = store.getters.userHasFeatureAccessLevel('SMARTLIST', 'EDIT')
const userCanDelete = store.getters.userHasFeatureAccessLevel('SMARTLIST', 'DELETE')

const reportId = vueInstance.$route.params.reportId

const report = ref({mainProcessSteps: true})
const name = ref(null)
const reportTypes = ref([])

/**
 * If editing a report, show only types available to that group
 * project/PS/PSE/contact, org/user
 */
const filteredReportTypes = computed(() => {
  if (reportId) {
    let objectTypeIds = []
    if ([1,2,4].includes(report.value.objectTypeId)) {
      objectTypeIds = [1,2,4]
    } else if ([3,5].includes(report.value.objectTypeId)) {
      objectTypeIds = [3,5]
    } else if (report.value.objectTypeId === 6) {
      objectTypeIds = [1,2,4,6]
    }
    return reportTypes.value.filter(t => objectTypeIds.includes(t.objectTypeId))
  } else {
    return reportTypes.value
  }
})

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

const save = async () => {
  try {
    store.commit(AppMutations.SET_LOADING, true)
    const {data} = await postRequest(`/smartlist`, report.value)
    report.value = data
    vueInstance.$router.replace({name: 'reportEditor', params: {reportId: data.id}})
    snackbar('SUCCESS', 'Save Successful')
  } catch (e) {
    logError(e)
  } finally {
    store.commit(AppMutations.SET_LOADING, false)
  }
}

const getReportTypes = async () => {
  try {
    const {data} = await getRequest(`/smartlistv1/companyObjectTypes`)
    reportTypes.value = data.sort((a, b) => a.objectType.localeCompare(b.objectType))
  } catch (e) {
    logError(e)
    this.snackbar = getSnackbar('ERROR', 'Error fetching object types')
    this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
  }
}

onMounted(() => {
  getReportTypes()

  if (reportId) {
    getReport()
  } else {
    name.value.focus()
  }
})
</script>

<style scoped lang="scss">
@import "@/styles/main.scss";

.report-toolbar {
  border-bottom: solid 1px rgba(0, 0, 0, 0.12) !important;
}
</style>