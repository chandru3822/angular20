<template>
<fragment>
<v-container id="report-editor" class="fill-height align-start">
  <v-row class="align-content-start fill-height">
    <v-col cols="12">
      <v-card class="elevation-1 square-card pr-4">
        <v-toolbar
          flat
          color="white"
          class="report-toolbar pt-2 justify"
        >
          <v-toolbar-title class="one-hunned">
            <div class="d-flex justify-start align-center">
              <v-btn
                icon
                @click="router.go(-1)"
              >
                <v-icon>mdi-chevron-left</v-icon>
              </v-btn>

              <v-text-field
                v-show="isEditingReportName"
                v-model="report.name"
                outlined
                placeholder="Type Name"
                hide-details="true"
                ref="reportNameField"
                class="report-name"
                @blur="isEditingReportName = false"
                @keydown.enter.esc="[isEditingReportName = false, reportNameField.blur()]"
              />
              <span
                v-show="!isEditingReportName"
                class="report-name ml-3"
                @click="[isEditingReportName = true, nextTick(reportNameField.focus)]"
              >
                {{ report.name }}
              </span>
            </div>
          </v-toolbar-title>
          <v-toolbar-items>
            <SmartlistCopy
              :smartlist="report"
              :show-text="true"
              :disabled="!canView || !hasAddAccess"
              @copied="copied"
            />

            <SmartlistDelete
              :smartlist-id="report.id"
              :disabled="!canDelete"
              :show-text="true"
              @deleted="router.go(-1)"
            />

            <SmartlistShare
              :smartlist="report"
              :show-text="true"
              :disabled="!canEdit"
              @updated-public="(isPublic) => report.public = isPublic"
              @updated-owner="updateOwner"
            />

            <v-btn
              text
              color="primary"
              :disabled="!hasUnsavedChanges || (vueInstance.$route.params?.reportId && !canEdit)"
              @click="showSaveDialog = true"
            >
              <v-icon>save</v-icon>
              Save
            </v-btn>

            <SmartlistExport
              :smartlist="report"
              :show-text="true"
              :disabled="!report?.id"
            />
          </v-toolbar-items>
        </v-toolbar>

        <v-divider class="my-4 ml-4" />

        <v-row class="no-gutters ml-4">
          <v-col cols="4">
            <v-autocomplete
              v-model="report.companyObjectTypeId"
              :items="filteredReportTypes"
              item-value="companyObjectTypeId"
              item-text="objectType"
              label="Data Type"
              placeholder="Data Type"
              :rules="constants.BASIC_REQUIRED_RULE"
            />
          </v-col>

          <v-col class="flex-shrink-1 flex-grow-0 text-no-wrap">
            <v-checkbox
              v-if="[4,6].includes(report?.objectTypeId)"
              v-model="report.mainProcessSteps"
              label="Primary Steps Only"
              hide-details
              :ripple="false"
              class="px-4"
            />
          </v-col>

          <v-col class="flex-shrink-1 flex-grow-0 text-no-wrap">
            <v-checkbox
              v-model="report.projectDetails"
              label="Project Details"
              hide-details
              :ripple="false"
              class="px-4"
              @click="showDataViewDialog = true"
            />
          </v-col>
        </v-row>

      </v-card>
    </v-col>
    <v-col
      cols="12"
      id="report-editor-data"
      class="pb-0"
    >
      <v-row class="fill-height" no-gutters>
        <v-col cols="3" class="field-container elevation-1">
          <v-col class="tabs-header">
            <v-icon>mdi-menu</v-icon>
            Columns and Filters
          </v-col>
          <v-tabs v-model="tab" class="tabs">
            <v-tab>Columns</v-tab>
            <v-tab>Filters</v-tab>
          </v-tabs>
          <v-tabs-items
            v-model="tab"
            class="show-overflow"
          >
            <v-tab-item>
              <ReportFields
                :fields="fields"
                :available-fields="availableFields"
                :loading="loadingAvailableFields"
                :update-types="UPDATE_TYPE"
                @added="addField"
                @deleted="deleteField"
                @reordered="reorderFields"
                @cleared="clearFields"
              />
            </v-tab-item>
            <v-tab-item>
              <ReportRequirements
                :requirements="requirements"
                :available-fields="availableFields"
                :loading="loadingAvailableFields"
                :update-types="UPDATE_TYPE"
                @added="addRequirement"
                @deleted="deleteRequirement"
                @updated="updateRequirement"
                @cleared="clearRequirements"
              />
            </v-tab-item>
          </v-tabs-items>
        </v-col>
        <v-col cols="9">
          <ReportViewer
            :requirements="requirements.filter(r => r.updateType !== UPDATE_TYPE.DELETE)"
            :fields="fields.filter(f => f?.updateType !== UPDATE_TYPE.DELETE)"
            :report="report"
            @queued=""
            @updated=""
          />
        </v-col>
      </v-row>
    </v-col>
  </v-row>
</v-container>

<v-dialog
  v-model="showSaveDialog"
  persistent
  width="450"
>
  <v-card>
    <v-card-title>Save Smartlist</v-card-title>

    <v-card-text>
      Do you want to save this smartlist?
    </v-card-text>

    <v-card-actions class="justify-end">
      <v-btn
        text
        @click="showSaveDialog = false"
      >
        Cancel
      </v-btn>

      <v-btn
        color="primary"
        @click="[showSaveDialog = false, save()]"
      >
        Save
      </v-btn>
    </v-card-actions>
  </v-card>
</v-dialog>

<v-dialog
  v-model="showUnsavedDialog"
  persistent
  width="450"
>
  <v-card>
    <v-card-title>Unsaved Work</v-card-title>

    <v-card-text>
      You have unsaved changes to your smartlist. Would you like to save changes before leaving?
    </v-card-text>

    <v-card-actions class="justify-end">
      <v-btn
        text
        @click="unsavedPromiseResolve(false)"
      >
        Leave Without Saving
      </v-btn>

      <v-btn
        color="primary"
        @click="unsavedPromiseResolve(true)"
      >
        Save
      </v-btn>
    </v-card-actions>
  </v-card>
</v-dialog>

<v-dialog
  v-model="showDataViewDialog"
  persistent
  width="450"
>
  <v-card>
    <v-card-title>Confirm</v-card-title>

    <v-card-text>
      Toggling project details will reset your smartlist. Are you sure you want to continue?
    </v-card-text>

    <v-card-actions class="justify-end">
      <v-btn
        text
        @click="[report.projectDetails = !report.projectDetails, showDataViewDialog = false]"
      >
        Cancel
      </v-btn>

      <v-btn
        color="primary"
        @click="[showDataViewDialog = false, toggleDataView()]"
      >
        Save
      </v-btn>
    </v-card-actions>
  </v-card>
</v-dialog>
</fragment>
</template>

<script setup>
import useReportStore from '@/views/flow/smartlist/reportStore'
import { computed, getCurrentInstance, onMounted, onUnmounted, ref, watch, nextTick } from 'vue'
import { getRequest, logError, postRequest, putRequest } from '@/helpers/helpers'
import { AppMutations } from '@/stores/AppStore'
import constants from '@/helpers/constants'
import ReportFields from '@/views/flow/smartlist/editor/ReportFields.vue'
import ReportRequirements from '@/views/flow/smartlist/editor/ReportRequirements.vue'
import isEqual from 'lodash.isequal'
import cloneDeep from 'lodash.clonedeep'
import ReportViewer from '@/views/flow/smartlist/editor/ReportViewer.vue'
import { onBeforeRouteLeave, onBeforeRouteUpdate } from 'vue-router/composables'
import { Fragment } from 'vue-frag'
import Smartlist from '@/views/flow/smartlist/Smartlist'
import SmartlistShare from '@/views/flow/smartlist/SmartlistShare.vue'
import SmartlistCopy from '@/views/flow/smartlist/SmartlistCopy.vue'
import SmartlistDelete from '@/views/flow/smartlist/SmartlistDelete.vue'
import SmartlistExport from '@/views/flow/smartlist/SmartlistExport.vue'

//This matches the backend fieldUpdateType enum. Could potentially fetch types dynamically from the backend
const UPDATE_TYPE = Object.freeze({
  ADD: 'ADD',
  UPDATE: 'UPDATE',
  DELETE: 'DELETE'
})

const vueInstance = getCurrentInstance().proxy
const router = vueInstance.$router
const snackbar = vueInstance.$snackbar

const reportStore = useReportStore()
reportStore.$subscribe((mut, state) => localStorage.setItem('report', JSON.stringify(state)))

const store = vueInstance.$store
const hasAddAccess = store.getters.userHasFeatureAccessLevel('SMARTLIST', 'ADD')
const hasEditAccess = store.getters.userHasFeatureAccessLevel('SMARTLIST', 'EDIT')
const hasDeleteAccess = store.getters.userHasFeatureAccessLevel('SMARTLIST', 'DELETE')
const isSmartlistAdmin = store.getters.userHasFeatureAccessLevel('SMARTLIST', 'ADMIN')
const isSystemAdmin = store.getters.isFullAdmin

const tab = ref(null)
const loadingAvailableFields = ref(false)
const showSaveDialog = ref(false)
const showUnsavedDialog = ref(false)
const unsavedPromiseResolve = ref(null)
const isEditingReportName = ref(false)
const reportNameField = ref(null)
const showDataViewDialog = ref(false)

const report = ref({mainProcessSteps: true, name: ''})
const fields = ref([])
const requirements = ref([])

//keep track of original data
const sourceReport = ref({mainProcessSteps: true, name: ''})
const sourceFields = ref([])
const sourceRequirements = ref([])

const reportTypes = ref([])
const availableFields = ref([])

/**
 * If editing a report, show only types available to that group
 * project/PS/PSE/contact, org/user
 */
const filteredReportTypes = computed(() => {
  if (vueInstance.$route.params?.reportId) {
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

const hasUnsavedChanges = computed(() => {
  return !isEqual(report.value, sourceReport.value) ||
         !isEqual(fields.value, sourceFields.value) ||
         !isEqual(requirements.value, sourceRequirements.value)
})

const canView = computed(() => {
  if (!hasAddAccess && !isSmartlistAdmin && !isSystemAdmin) {
    return false
  }

  return Smartlist.userCanView(report.value)
})

const canEdit = computed(() => {
  if (!hasEditAccess && !isSmartlistAdmin && !isSystemAdmin) {
    return false
  }

  return Smartlist.userCanEdit(report.value)
})

const canDelete = computed(() => {
  if (isSmartlistAdmin || isSystemAdmin) {
    return true
  }

  if (report.value?.ownerId === store.state.user.details.id && hasAddAccess) {
    return true
  }

  return false
})

watch(() => vueInstance.$route.params?.reportId, async () => {
  if (vueInstance.$route.params?.reportId) {
    refreshReport()
  }
})

const refreshReport = async (forceUpdate = false) => {
  await getReport()
  getFields()
  getRequirements()
  getAvailableFields(forceUpdate)
}

const getReport = async () => {
  try {
    const {data} = await getRequest(`/smartlist/${vueInstance.$route.params?.reportId}?accessControl=true`)
    report.value = cloneDeep(data)
    sourceReport.value = cloneDeep(data)
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Unable to fetch smartlist')
  }
}

const getFields = async () => {
  try {
    const {data} = await getRequest(`/smartlist/${report.value.id}/field`)
    fields.value = cloneDeep(data)
    sourceFields.value = cloneDeep(data)
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Unable to fetch columns')
  }
}

const getRequirements = async() => {
  try {
    const {data} = await getRequest(`/smartlist/${report.value.id}/requirement`)
    requirements.value = cloneDeep(data)
    sourceRequirements.value = cloneDeep(data)
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Unable to fetch filters')
  }
}

const updateOwner = (newOwner) => {
  report.value.ownerId = newOwner.userId
  report.value.owner = newOwner.name
}

const copied = async (copiedReport) => {
  await router.push({name: 'reportEditor', params: {reportId: copiedReport.id}})
  await refreshReport()
}

const save = async () => {
  try {
    store.commit(AppMutations.SET_LOADING, true)

    if (report.value?.id) {
      //send all fields for re-ordering, but send only requirements which have changed
      const hasReportUpdated = !isEqual(report.value, sourceReport.value)
      const hasFieldsUpdated = !isEqual(fields.value, sourceFields.value)
      const updatedRequirements = requirements.value.filter(r => r.updateType)

      await putRequest(`/smartlist/${report.value.id}`, {
        smartlist: report.value,
        fields: (hasFieldsUpdated) ? fields.value : [],
        requirements: updatedRequirements
      })

      if (hasFieldsUpdated) {
        getFields()
      }

      if (updatedRequirements.length > 0) {
        getRequirements()
      }

      if (hasReportUpdated) {
        sourceReport.value = cloneDeep(report.value)
      }
    } else {
      const {data} = await postRequest(`/smartlist`, report.value)
      report.value = cloneDeep(data)
      sourceReport.value = cloneDeep(data)
      await router.replace({name: 'reportEditor', params: {reportId: data.id}})
      await refreshReport()
    }
    snackbar('SUCCESS', 'Save Successful')
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error saving smartlist')
  } finally {
    store.commit(AppMutations.SET_LOADING, false)
  }
}

const getReportTypes = async () => {
  try {
    loadingAvailableFields.value = true
    const {data} = await getRequest(`/smartlistv1/companyObjectTypes`)
    reportTypes.value = data.sort((a, b) => a.objectType.localeCompare(b.objectType))
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error fetching data types')
  } finally {
    loadingAvailableFields.value = false
  }
}

const getAvailableFields = async (forceUpdate = false) => {
  //this endpoint returns a large amount of data. Fetch data only if we already haven't
  if (availableFields.value.length === 0 || forceUpdate) {
    try {
      loadingAvailableFields.value = true
      const csvReportTypes = filteredReportTypes.value.map(t => t.objectTypeId).join(',')
      const {data} = await getRequest(`/smartlist/fields?objectTypeIds=${csvReportTypes}&projectDetails=${report.value.projectDetails}`)
      availableFields.value = data
    } catch (e) {
      logError(e)
      snackbar('ERROR', 'Error fetching available columns')
    } finally {
      loadingAvailableFields.value = false
    }
  }
}

const addField = (field) => {
  if (field) {
    field.updateType = UPDATE_TYPE.ADD
    fields.value.push(field)
    updateDisplayOrder()
  }
}

const deleteField = (index) => {
  if (fields.value[index].id) {
    fields.value[index].updateType = UPDATE_TYPE.DELETE
  } else {
    fields.value.splice(index, 1)
  }
  updateDisplayOrder()
}

const updateDisplayOrder = () => {
  fields.value.filter(f => f.updateType !== UPDATE_TYPE.DELETE)
              .forEach((f, i) => f.displayOrder = i + 1)
}

const reorderFields = (updatedFields) => {
  fields.value = updatedFields
  updateDisplayOrder()
}

const clearFields = () => {
  fields.value = fields.value.filter(f => !!f.id)
  fields.value.forEach(f => f.updateType = UPDATE_TYPE.DELETE)
}

const clearRequirements = () => {
  requirements.value = requirements.value.filter(r => !!r.id)
  requirements.value.forEach(r => r.updateType = UPDATE_TYPE.DELETE)
}

const addRequirement = (requirement) => {
  requirement.updateType = UPDATE_TYPE.ADD
  requirements.value.push(requirement)
}

const deleteRequirement = (index) => {
  if (requirements.value[index].id) {
    requirements.value[index].updateType = UPDATE_TYPE.DELETE
  } else {
    requirements.value.splice(index, 1)
  }
}

const updateRequirement = (requirement, index) => requirements.value.splice(index, 1, {...requirement, updateType: UPDATE_TYPE.UPDATE})

const toggleDataView = async () => {
  try {
    store.commit(AppMutations.SET_LOADING, true)
    await putRequest(`/smartlist/${report.value.id}/toggleProjectDetails`)
    refreshReport(true)
  } catch (e) {
    report.value.projectDetails = !report.value.projectDetails
    snackbar('ERROR', 'Unable to update project details setting')
  } finally {
    store.commit(AppMutations.SET_LOADING, false)
  }
}

onMounted(async () => {
  window.addEventListener('beforeunload', windowLeave)

  await getReportTypes()

  if (vueInstance.$route.params?.reportId) {
    refreshReport()
  } else {
    isEditingReportName.value = true
    nextTick(reportNameField.value.focus)
  }
})

onUnmounted(() => window.removeEventListener('beforeunload', windowLeave))

onBeforeRouteLeave(async (to, from, next) => {
  if (hasUnsavedChanges.value) {
    const shouldSave = await unsavedPrompt()

    if (shouldSave) {
      await save()
    }
  }

  next()
})

onBeforeRouteUpdate(async (to, from, next) => {
  if (hasUnsavedChanges.value) {
    const shouldSave = await unsavedPrompt()

    if (shouldSave) {
      await save()
    }
  }

  next()
})


const unsavedPrompt = async () => {
  showUnsavedDialog.value = true
  return new Promise((resolve, reject) => {
    unsavedPromiseResolve.value = resolve
  })
}

const windowLeave = async (event) => {
  if (hasUnsavedChanges.value) {
    event.preventDefault()
    event.returnValue = ''
  }
}
</script>

<style scoped lang="scss">
@import "@/styles/main";

.report-toolbar {
  :deep(.v-toolbar__content) {
    padding-left: 0;
    padding-right: 0;
    justify-content: space-between;
  }

  .report-name {
    font-size: 20px;
    font-weight: 700;
    letter-spacing: normal;

    &:hover {
      cursor: pointer;
    }
  }

  :deep(.borderless fieldset) {
    border: none;
  }
}

#report-editor-data {
  height: calc(100vh - 257px);

  :deep(.v-data-footer) {
    position: fixed;
    bottom: 0;
    left: 0;
    width: 100%;
    background-color: white;
  }

  :deep(.v-data-table__wrapper) {
    height: calc(100vh - 270px) !important;
  }

  .v-item-group {
    height: calc(100vh - 400px);
  }

  .v-window-item {
    height: calc(100vh - 400px);
  }

  .tabs-header {
    background-color: white;
  }

  .tabs {
    border-bottom: solid 1px var(--v-grey-lighten2) !important;
  }

  .field-container {
    width: 350px;
    min-width: 350px;
    max-width: 350px;
    background-color: white;
    z-index: 0;
  }

  .show-overflow.v-window {
    overflow: visible !important;
  }
}
</style>