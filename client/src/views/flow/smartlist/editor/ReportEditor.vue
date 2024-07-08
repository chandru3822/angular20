<template>
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
              <a-btn
                  icon
                  @click="router.push('/smartlist')"
                  color="unset"
                  prepend-icon="mdi-chevron-left"
              ></a-btn>

              <a-text-field
                v-show="isEditingReportName"
                v-model="report.name"
                variant="outlined"
                placeholder="Type Name"
                :hide-details="true"
                id="qa-smartlist-name"
                ref="reportNameField"
                class="report-name"
                @blur="toggleEditingReportName"
                @keydown.enter.esc="reportNameField.blur"
              />
              <span
                v-show="!isEditingReportName"
                class="ml-3"
                :class="{'report-name': canEdit}"
                @click="editNameClicked()"
              >
                {{ report.name }}

              </span>
              <span class="owner-display pl-2">{{ (isOwner) ? 'Owner' : report.owner }}</span>
              <a-btn
                  v-if="report?.id && canView"
                  color="primary"
                  variant="text"
                  @click="router.push(`/smartlistv1/${report.id}`)"
                  prepend-icon="mdi-eye"
                  text="View old smartlist editor"
              ></a-btn>
            </div>
          </v-toolbar-title>
          <v-toolbar-items>
            <SmartlistCopy
              :smartlist="report"
              :show-text="true"
              :disabled="!hasAddAccess || (!canView && !report?.public)"
              @copied="copied"
            />

            <SmartlistDelete
              :smartlist-id="report.id"
              :disabled="!canDelete"
              :show-text="true"
              @deleted="deleteReport"
            />

            <SmartlistShare
              :smartlist="report"
              :show-text="true"
              :disabled="!canShare || !isEditing"
              @updated-public="(isPublic) => report.public = isPublic"
              @updated-owner="updateOwner"
            />

            <a-btn
                id="reportEditor-save"
                variant="text"
                color="primary"
                :disabled="!hasUnsavedChanges || (isEditing && !canEdit)"
                @click="saveClicked"
                prepend-icon="save"
                text="Save"
            ></a-btn>

            <SmartlistExport
              :smartlist="report"
              :show-text="true"
              :disabled="!report?.id"
              timezone="UTC"
            />
          </v-toolbar-items>
        </v-toolbar>

        <v-divider class="my-4 ml-4" />

        <v-row class="no-gutters ml-4">
          <v-col cols="4">
            <a-autocomplete
              v-model="report.companyObjectTypeId"
              :disabled="!canEdit && isEditing"
              :items="filteredReportTypes"
              item-value="companyObjectTypeId"
              item-title="objectType"
              id="qa-smartlist-data-type"
              label="Data Type"
              placeholder="Data Type"
              :rules="constants.BASIC_REQUIRED_RULE"
              @change="updateObjectType"
              @click="prevObjectTypeId = report.objectTypeId"
            />
          </v-col>

          <v-col
            class="flex-shrink-1 flex-grow-0 text-no-wrap"
            v-if="[4,6].includes(report?.objectTypeId)"
          >
            <v-checkbox
              v-model="report.mainProcessSteps"
              :disabled="!canEdit && report?.id != null"
              label="Primary Steps Only"
              hide-details
              :ripple="false"
              class="px-4"
            />
          </v-col>

          <v-col
            class="flex-shrink-1 flex-grow-0 text-no-wrap"
            v-if="[3,5].includes(report?.objectTypeId)"
          >
            <v-checkbox
              v-model="report.primaryUserPosition"
              :disabled="!canEdit"
              label="Primary Position"
              hide-details
              :ripple="false"
              class="px-4"
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
            <v-tab id="qa-smartlist-columns">Columns</v-tab>
            <v-tab id="qa-smartlist-filters">Filters</v-tab>
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
                :can-edit="canEdit"
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
                :can-edit="canEdit"
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
        <a-btn
            variant="text"
            @click="showSaveDialog = false"
            color="unset"
            text="Cancel"
        ></a-btn>

        <a-btn
            color="primary"
            @click="[showSaveDialog = false, save()]"
            text="Save"
        ></a-btn>
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
        <a-btn
            variant="text"
            @click="unsavedPromiseResolve(false)"
            color="unset"
            text="Leave Without Saving"
        ></a-btn>

        <a-btn color="primary" @click="unsavedPromiseResolve(true)" text="Save"></a-btn>
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
        <a-btn
            variant="text"
            @click="[revertObjectType(), showDataViewDialog = false]"
            color="unset"
            text="Cancel"
        ></a-btn>

        <a-btn
            color="primary"
            @click="[showDataViewDialog = false, toggleDataView()]"
            text="Save"
        ></a-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</v-container>
</template>

<script setup>
import { computed, getCurrentInstance, onMounted, onUnmounted, ref, watch, nextTick } from 'vue'
import { getRequest, logError, postRequest, putRequest } from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ReportFields from '@/views/flow/smartlist/editor/ReportFields.vue'
import ReportRequirements from '@/views/flow/smartlist/editor/ReportRequirements.vue'
import isEqual from 'lodash.isequal'
import cloneDeep from 'lodash.clonedeep'
import ReportViewer from '@/views/flow/smartlist/editor/ReportViewer.vue'
import { onBeforeRouteLeave, onBeforeRouteUpdate } from 'vue-router/composables'
import Smartlist from '@/views/flow/smartlist/Smartlist'
import SmartlistShare from '@/views/flow/smartlist/SmartlistShare.vue'
import SmartlistCopy from '@/views/flow/smartlist/SmartlistCopy.vue'
import SmartlistDelete from '@/views/flow/smartlist/SmartlistDelete.vue'
import SmartlistExport from '@/views/flow/smartlist/SmartlistExport.vue'
import { useUserStore } from '@/stores/UserStore.js'
import { useAppStore } from '@/stores/AppStore.js'
import {useRouter, useRoute} from "vue-router/composables"

//This matches the backend fieldUpdateType enum. Could potentially fetch types dynamically from the backend
const UPDATE_TYPE = Object.freeze({
  ADD: 'ADD',
  UPDATE: 'UPDATE',
  DELETE: 'DELETE'
})

const vueInstance = getCurrentInstance().proxy
const router = useRouter()
const route = useRoute()

const store = vueInstance.$store
const userStore = useUserStore()
const appStore = useAppStore()

const hasViewAccess = userStore.userHasFeatureAccessLevel('SMARTLIST', 'VIEW')
const hasViewAllAccess = userStore.userHasFeatureAccessLevel('SMARTLIST', 'VIEW_ALL')
const hasAddAccess = userStore.userHasFeatureAccessLevel('SMARTLIST', 'ADD')
const hasManageAccess = userStore.userHasFeatureAccessLevel('SMARTLIST', 'MANAGE')
const isSmartlistAdmin = userStore.userHasFeatureAccessLevel('SMARTLIST', 'ADMIN')
const isSystemAdmin = userStore.isSystemAdmin

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
const isEditing = ref(typeof route.params.reportId !== 'undefined')
const prevObjectTypeId = ref([])
/**
 * If editing a report, show only types available to that group
 * project/PS/PSE/contact, org/user
 */
const filteredReportTypes = computed(() => {
  if (isEditing.value) {
    let objectTypeIds = []
    if ([1,2,4,8].includes(report.value.objectTypeId)) {
      objectTypeIds = [1,2,4,8]
    } else if ([3,5].includes(report.value.objectTypeId)) {
      objectTypeIds = [3,5]
    } else if (report.value.objectTypeId === 6) {
      objectTypeIds = [1,2,4,6,8]
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

const isOwner = computed(() => {
  return report.value?.ownerId === userStore.details.id
})

const canView = computed(() => {
  if (!hasViewAccess && !hasViewAllAccess && !hasManageAccess && !isSmartlistAdmin && !isSystemAdmin) {
    return false
  }

  return Smartlist.userCanView(report.value)
})

const canAdd = computed(() => {
  return !!(hasAddAccess || hasManageAccess || isSmartlistAdmin || isSystemAdmin);
})

const canEdit = computed(() => {
  if (!hasAddAccess && !isSmartlistAdmin && !isSystemAdmin) {
    return false
  }

  return Smartlist.userCanEdit(report.value)
})

const canShare = computed(() => {
  return !!(canAdd.value && (isOwner.value || isSmartlistAdmin || isSystemAdmin))
})

const canDelete = computed(() => {
  if (isSmartlistAdmin || isSystemAdmin) {
    return true
  }

  if (isOwner.value && hasAddAccess) {
    return true
  }

  return false
})

watch(() => route.params?.reportId, async () => {
  if (route.params?.reportId) {
    isEditing.value = true
    refreshReport()
  }
})

watch (() => userStore.timezone.value, () => {
  refreshReport()
})

const refreshReport = async (forceUpdate = false) => {
  await getReport()

  if (!Smartlist.userCanView(report.value) && !report.value?.public) {
    router.push('/')
    return
  }

  getFields()
  getRequirements()
  getAvailableFields(forceUpdate)
}

const getReport = async () => {
  try {
    const {data} = await getRequest(`/smartlist/${route.params?.reportId}?accessControl=true`)
    report.value = cloneDeep(data)
    sourceReport.value = cloneDeep(data)
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Unable to fetch smartlist')
  }
}

const getFields = async () => {
  try {
    const {data} = await getRequest(`/smartlist/${report.value.id}/field?timezone=${userStore.timezone.value}`)
    fields.value = cloneDeep(data)
    sourceFields.value = cloneDeep(data)
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Unable to fetch columns')
  }
}

const getRequirements = async() => {
  try {
    const {data} = await getRequest(`/smartlist/${report.value.id}/requirement`)
    requirements.value = cloneDeep(data)
    sourceRequirements.value = cloneDeep(data)
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Unable to fetch filters')
  }
}

const updateOwner = (newOwner) => {
  report.value.ownerId = newOwner.userId
  report.value.owner = newOwner.name
}

const copied = async (copiedReport) => {
  await router.push({name: 'reportEditor', params: {reportId: copiedReport.id}})
  showUnsavedDialog.value = false
  await refreshReport()
}

const save = async () => {
  try {
    appStore.loading = true

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
    appStore.showSnack('SUCCESS', 'Save Successful')
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', e.message || e.data?.message || 'Error saving smartlist')
  } finally {
    appStore.loading = false
  }
}

const getReportTypes = async () => {
  try {
    loadingAvailableFields.value = true
    const {data} = await getRequest(`/smartlist/companyObjectTypes`)
    reportTypes.value = data.sort((a, b) => a.objectType.localeCompare(b.objectType))
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error fetching data types')
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
      if (report.value.objectTypeId === 8) {
        report.value.projectDetails = true
      }

      const {data} = await getRequest(`/smartlist/fields?objectTypeIds=${csvReportTypes}&projectDetails=${report.value.projectDetails}`)
      availableFields.value = data
    } catch (e) {
      logError(e)
      appStore.showSnack('ERROR', 'Error fetching available columns')
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

const updateObjectType = () => {
  const selectedType = reportTypes.value.find(t => t.id === report.value.companyObjectTypeId)
  if (selectedType) {
    // If Object Type is being changed from or to Project Details
    if (report.value?.id && (selectedType.objectTypeId === 8 || prevObjectTypeId.value === 8)) {
      showDataViewDialog.value = true
    }
    else {
      report.value.objectTypeId = selectedType.objectTypeId
    }
  }
}

const revertObjectType = () => {
  const selectedType = reportTypes.value.find(t => t.objectTypeId === prevObjectTypeId.value)
  if (selectedType) {
    report.value.objectTypeId = selectedType.objectTypeId
    report.value.companyObjectTypeId = selectedType.companyObjectTypeId
  }
}

const updateRequirement = (requirement, index) => requirements.value.splice(index, 1, {...requirement, updateType: UPDATE_TYPE.UPDATE})

const toggleDataView = async () => {
  try {
    appStore.loading = true
    const selectedType = reportTypes.value.find(t => t.id === report.value.companyObjectTypeId)
    report.value.objectTypeId = selectedType.objectTypeId

    await putRequest(`/smartlist/toggleProjectDetails`, report.value)
    refreshReport(true)
  } catch (e) {
    appStore.showSnack('ERROR', 'Unable to update project details setting')
  } finally {
    appStore.loading = false
  }
}

const toggleEditingReportName = () => {
  if (isEditing.value) {
    isEditingReportName.value = !isEditingReportName.value
  }
}

const saveClicked = () => {
  if (!isEditing.value) {
    if (!Object.hasOwn(report.value, 'companyObjectTypeId') || report.value.name.trim().length < 1) {
      appStore.showSnack('ERROR', 'Smartlist must have a name and data type')
      return
    }
  }

  showSaveDialog.value = true
}

const editNameClicked = () => {
  if (canEdit.value) {
    isEditingReportName.value = true
    nextTick(reportNameField.value.focus())
  }
}

onMounted(async () => {
  window.addEventListener('beforeunload', windowLeave)

  await getReportTypes()

  if (isEditing.value) {
    refreshReport()
  } else {
    if (!canAdd) {
      router.push('/')
      return
    }

    isEditingReportName.value = true
    nextTick(reportNameField.value.focus())
  }
})

onUnmounted(() => window.removeEventListener('beforeunload', windowLeave))

const deleteReport = () => {
  report.archived = true;
  router.go(-1)
}

onBeforeRouteLeave(async (to, from, next) => {
  if (hasUnsavedChanges.value && !report.value.archived) {
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

    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    min-width: 200px;

    &:hover {
      cursor: pointer;
    }
  }

  .owner-display {
    font-size: 12px;
    font-weight: 400;
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

    .v-data-footer__select > .v-input {
      margin-top: 0;
      margin-bottom: 0;
    }
  }

  :deep(.v-data-table__wrapper) {
    height: calc(100vh - 300px) !important;
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
