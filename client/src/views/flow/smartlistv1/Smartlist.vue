<template>
  <v-container id="smartlist-container">
    <v-row>
      <v-col cols="12">
        <v-card>
          <v-form
              ref="smartlistForm"
              class="one-hunned"
              :disabled="!userCanEdit"
          >
            <v-col cols="12">
              <v-toolbar flat class="app-toolbar">
                <a-btn
                    variant="text"
                    small
                    class="mr-3"
                    color="primary"
                    @click="router.push('/smartlistv1')"
                    prepend-icon="mdi-arrow-left"
                ></a-btn>
                <v-toolbar-title class="app-title">Smartlist Editor</v-toolbar-title>
                <a-btn
                    v-if="smartlist?.id && userCanView"
                    class="ml-6 mt-3"
                    variant="text"
                    @click="router.push(`/smartlist/editor/${smartlist.id}`)"
                    color="primary"
                    text="View new smartlist editor"
                    prepend-icon="mdi-eye"
                ></a-btn>
                <v-spacer></v-spacer>
                <v-toolbar-items>
                  <a-btn
                      v-if="smartlist.id"
                      variant="text"
                      color="primary"
                      prepend-icon="mdi-cloud-download"
                      @click="runReport"
                      text="Export"
                  ></a-btn>

                  <a-btn
                      v-if="smartlist.id && userCanAdd"
                      variant="text"
                      color="primary"
                      @click="copy"
                      prepend-icon="mdi-content-copy"
                      text="Duplicate"
                  ></a-btn>

                  <a-btn
                      v-if="userCanEdit"
                      variant="text"
                      color="primary"
                      @click="validateForm"
                      text="Save"
                      prepend-icon="save"
                  ></a-btn>
                  <a-btn
                      variant="text"
                      v-if="canDelete"
                      color="primary"
                      @click="showDeleteDialog=true"
                      text="Delete"
                      prepend-icon="delete"
                  ></a-btn>
                  <ConfirmationDialog :open-dialog="showDeleteDialog" @confirm="[showDeleteDialog = false, deleteSmartlist()]" @close-dialog="showDeleteDialog=false">
                    <template v-slot:title>Confirm</template>
                    Are you sure you want to delete this smartlist?
                  </ConfirmationDialog>
                </v-toolbar-items>
              </v-toolbar>
            </v-col>

            <v-col cols="12">
              <v-card-text>
                <v-row>
                  <v-col cols="12" md="4">
                    <a-text-field
                        label="Smartlist Name"
                        :readonly="!userCanEdit"
                        v-model="smartlist.name"
                        :rules="requiredRules"
                    />
                  </v-col>

                  <v-col cols="12" md="4">
                    <a-autocomplete
                        v-model="smartlist.companyObjectTypeId"
                        :items="companyObjectTypes"
                        item-title="objectType"
                        :readonly="!userCanEdit"
                        item-value="companyObjectTypeId"
                        label="Rows"
                        placeholder="Select one..."
                        :rules="requiredRules"
                        @change="checkObjectTypeChange"
                        attach
                    />
                    <ConfirmationDialog :open-dialog="showObjectTypeDialog"
                                        @confirm="[showObjectTypeDialog = false, toggleSmartlistObjectType()]"
                                        @close-dialog="[showObjectTypeDialog = false, smartlist.companyObjectTypeId = companyObjectTypes.find(t => t.objectTypeId === originalObjectTypeId).companyObjectTypeId]">
                      <template v-slot:title>Confirm</template>
                      Toggling to this row type will reset your smartlist, are you sure you want to continue?
                      <template v-slot:yes>Continue</template>
                    </ConfirmationDialog>
                  </v-col>
                </v-row>

                <v-row>
                  <v-col cols="4" md="2">
                    <v-checkbox
                        v-model="smartlist.shared"
                        label="Public"
                        :readonly="!userCanEdit"
                    />
                  </v-col>

                  <v-col cols="4" md="2">

                    <v-checkbox
                        v-if="isUserOrgObjectType"
                        :readonly="!userCanEdit"
                        v-model="smartlist.primaryUserPosition"
                        label="Primary Position"
                    />
                    <v-checkbox
                        v-if="!isUserOrgObjectType"
                        v-model="smartlist.projectDetails"
                        :readonly="!userCanEdit"
                        label="Project Details"
                        @click="smartlist.id ? showToggleDialog=true : showToggleDialog"
                    />
                    <ConfirmationDialog :open-dialog="showToggleDialog"
                                        @confirm="[showToggleDialog = false, toggleProjectDetails()]"
                                        @cancel="resetToggleProjectDetails"
                    >
                      <template v-slot:title>Confirm</template>
                      Toggling project details will reset your smartlist, are you sure you want to continue?
                      <template v-slot:yes>Continue</template>
                    </ConfirmationDialog>
                  </v-col>

                  <v-col cols="4" md="2">
                    <v-checkbox
                        v-if="isProcessStepOrEvent"
                        :readonly="!userCanEdit"
                        v-model="smartlist.mainProcessSteps"
                        label="Primary Steps Only"
                    />
                  </v-col>
                </v-row>
              </v-card-text>
            </v-col>
          </v-form>
        </v-card>
      </v-col>

      <SmartlistColumn
          v-if="smartlist.id"
          :company-object-types="filteredCompanyObjectTypes"
          :can-edit="userCanEdit"
          :is-project-details="smartlist.projectDetails"
          :project-details-columns="projectDetailsColumns"
          :smartlist-id="$route.params.smartlistId"
          :refresh="refreshData"
          @refreshed="refreshData = false"
      />

      <SmartlistRequirement
          v-if="smartlist.id"
          :requirements="requirements"
          :company-object-types="filteredCompanyObjectTypes"
          :reset-form="resetRequirementForm"
          :can-edit="userCanEdit"
          :is-project-details="smartlist.projectDetails"
          :project-details-requirements="projectDetailsColumns"
          @input="addNewRequirement"
          @update="updateRequirement"
          @delete="deleteRequirement"
          @form-reset="resetRequirementForm = false"
      />

      <a-btn
          color="primary"
          class="build-sql"
          @click="buildSql"
          v-if="is7oaksAdmin || userId === 2350555"
          text="BUILD SQL"
      ></a-btn>
      <div v-if="sql != null" class="pa-5">
        {{ sql }}
      </div>
    </v-row>
  </v-container>
</template>

<script setup>


import {handleHidingGlobalLoader, getRequest, getRequestWithParams, putRequest, postRequest, deleteRequest, logError, } from '@/helpers/helpers'
import constants from '@/helpers/constants'


import SmartlistRequirement from './SmartlistRequirement'
import SmartlistColumn from '@/views/flow/smartlistv1/SmartlistColumn'
import { saveAs } from 'file-saver'
import {DateTime} from 'luxon'
import ConfirmationDialog from '@/components/ConfirmationDialog'
import Smartlist from '@/views/flow/smartlist/Smartlist'

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const smartlist = ref({mainProcessSteps: true})
const companyObjectTypes = ref([])
const operations = ref([])
const requirements = ref([])
const fetchedLogic = ref([])
const logic = ref([])
const logicUpdated = ref(false)
const resetRequirementForm = ref(false)
const requiredRules = ref(constants.BASIC_REQUIRED_RULE)
const showDeleteDialog = ref(false)
const showToggleDialog = ref(false)
const showObjectTypeDialog = ref(false)
const originalObjectTypeId = ref(null)
const smartlistForm = ref(null)
const projectDetailsColumns = ref([])
const sql = ref('')
const refreshData = ref(false)

onMounted(() => {
  if (route.params?.smartlistId !== "null") {
    getSmartlist()
    getRequirements()
    getLogic()
    getProjectDetailsColumns()
  }
  getOperations()
  getCompanyObjectTypes()
})

const userId = computed(() => {
  return userStore.details.id
})
const timezone = computed(() => {
  return userStore.timezone.value
})
const is7oaksAdmin = computed(() => {
  return userStore.isSystemAdmin
})
const isSmartlistAdmin = computed(() => {
  return userStore.userHasFeatureAccessLevel('SMARTLIST', 'ADMIN')
})
const userCanAdd = computed(() => {
  return userStore.userHasFeatureAccessLevel('SMARTLIST', 'ADD')
})
const hasViewAccess = computed(() => {
  return userStore.userHasFeatureAccessLevel('SMARTLIST', 'VIEW')
})
const hasViewAllAccess = computed(() => {
  return userStore.userHasFeatureAccessLevel('SMARTLIST', 'VIEW_ALL')
})
const hasManageAccess = computed(() => {
  return userStore.userHasFeatureAccessLevel('SMARTLIST', 'MANAGE')
})
const isProcessStepOrEvent = computed(() => {
  return smartlist.value.companyObjectTypeId !== null && ([4,6].includes(companyObjectTypes.value.find(t => t.companyObjectTypeId === smartlist.value?.companyObjectTypeId)?.objectTypeId))
})
const isUserOrgObjectType = computed(() => {
  if (smartlist.value.companyObjectTypeId) {
    const objectTypeId = companyObjectTypes.value.find(t => t.companyObjectTypeId === smartlist.value?.companyObjectTypeId)?.id
    return objectTypeId && [3, 5].includes(objectTypeId)
  }
  return false
})
const userCanEdit = computed(() => {
  if (!smartlist.value?.id) {
    return true
  }

  if (!userStore.userHasFeatureAccessLevel('SMARTLIST', 'EDIT')) {
    return false
  }

  if (userStore.details.id === this?.smartlist?.ownerId ||
      userStore.userHasFeatureAccessLevel('SMARTLIST', 'ADMIN')
  ) {
    return true
  }

  return Smartlist.userCanEdit(smartlist.value)
})
const userCanView = computed(() => {
  if (!hasViewAccess.value && !hasViewAllAccess.value && !hasManageAccess.value && !isSmartlistAdmin.value && !is7oaksAdmin.value) {
    return false
  }

  return Smartlist.userCanView(smartlist.value)
})
const canDelete = computed(() => {
  return ((!smartlist.value?.id || userStore.details.id === this?.smartlist?.ownerId) && userStore.userHasFeatureAccessLevel('SMARTLIST', 'DELETE')) || userStore.userHasFeatureAccessLevel('SMARTLIST', 'ADMIN')
})
const filteredCompanyObjectTypes = computed(() => {
  if (smartlist.value.id) {
    let objectTypeIds = []
    if ([1,2,4].includes(smartlist.value.objectTypeId)) {
      objectTypeIds = [1,2,4]
    } else if ([3,5].includes(smartlist.value.objectTypeId)) {
      objectTypeIds = [3,5]
    } else if (smartlist.value.objectTypeId === 6) {
      objectTypeIds = [1,2,4,6]
    }
    return companyObjectTypes.value.filter(t => objectTypeIds.includes(t.objectTypeId))
  } else {
    return companyObjectTypes.value
  }
})

const getSmartlist = async () => {
  try {
    // hit v2 endpoint to get access control (needed for button to v2 editor)
    const {data} = await getRequest(`/smartlist/${route.params.smartlistId}?accessControl=true`)
    smartlist.value = data
    originalObjectTypeId.value = data.objectTypeId
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error fetching smartlist')

  }
}
const getCompanyObjectTypes = async () => {
  try {
    const {data} = await getRequest(`/smartlistv1/companyObjectTypes`)
    companyObjectTypes.value = data.sort((a, b) => a.objectType.localeCompare(b.objectType))
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error fetching object types')

  }
}
const getRequirements = async () => {
  try {
    const {data} = await getRequest(`/smartlistv1/${route.params.smartlistId}/requirement`)
    requirements.value = data
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error fetching requirements')

  }
}
const getLogic = async () => {
  try {
    const {data} = await getRequest(`/smartlistv1/${route.params.smartlistId}/logic`)
    fetchedLogic.value = [...data]
    logic.value = data
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error fetching smartlist logic')

  }
}
const getProjectDetailsColumns = async () => {
  try {
    const {data} = await getRequest(`/smartlistv1/availableProjectDetailsFields`)
    projectDetailsColumns.value = data
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error fetching project details fields')

  }
}
const getOperations = async () => {
  try {
    const {data} = await getRequest(`/operation`)
    operations.value = data
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error fetching operations')

  }
}
const addSmartlist = async () => {
  try {
    appStore.loading = true

    if (!isProcessStepOrEvent.value) {
      smartlist.value.mainProcessSteps = true
    }

    const {data, status} = await postRequest(`/smartlistv1`, smartlist.value)
    smartlist.value = data
    originalObjectTypeId.value = data.objectTypeId
    router.replace({name: 'smartlistEditor', params: {smartlistId: smartlist.value.id}})
    appStore.showSnack('SUCCESS', `Smartlist Created`)

    handleHidingGlobalLoader( status)
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', e.message || e.data?.message || 'Error saving smartlist')

    appStore.loading = false
  }
}
const addNewRequirement = async (requirement) => {
  try {
    const maxNumber = requirements.value.map(r => r.displayOrder).reduce((max, cur) => Math.max(max, cur), 0)
    appStore.loading = true
    const {data, status} = await postRequest(`/smartlistv1/${smartlist.value.id}/requirement`, {
      ...requirement,
      smartlistId: smartlist.value.id,
      secondaryRequirementValue: requirement.secondaryRequirementValue || null,
      displayOrder: maxNumber + 1,
      projectDetailsColumn: requirement.projectDetailsColumn,
      processStepEventId: requirement.processStepEventId
    })
    requirements.value.push(data)
    resetRequirementForm.value = true
    handleHidingGlobalLoader( status)
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error adding requirement to smartlist')

    appStore.loading = false
  }
}
const updateSmartlist = async () => {
  try {
    appStore.loading = true

    if (!isProcessStepOrEvent.value) {
      smartlist.value.mainProcessSteps = true
    }

    const {status} = await putRequest(`/smartlistv1/${smartlist.value.id}`, smartlist.value)
    const companyObjectType = companyObjectTypes.value.find(t => t.companyObjectTypeId === smartlist.value.companyObjectTypeId)
    originalObjectTypeId.value = companyObjectType.objectTypeId
    appStore.showSnack('SUCCESS', `Smartlist Updated`)

    handleHidingGlobalLoader( status)
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', e.message || 'Error saving smartlist')

    appStore.loading = false
  }
}
const updateLogic = async () => {
  try {
    appStore.loading = true
    const {data, status} = await putRequest(`/smartlistv1/${smartlist.value.id}/logic`, logic.value)
    fetchedLogic.value = [...data]
    logic.value = data
    handleHidingGlobalLoader( status)
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error updating smartlist logic')

    appStore.loading = false
  }
}
const updateRequirement = async (requirement) => {
  try {
    appStore.loading = true
    const {data, status} = await putRequest(`/smartlistv1/${smartlist.value.id}/requirement/${requirement.id}`, requirement)
    requirements.value.splice(requirements.value.findIndex(r => r.id === requirement.id), 1, data)
    handleHidingGlobalLoader( status)
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error updating requirement')

    appStore.loading = false
  }
}
const deleteSmartlist = async () => {
  try {
    appStore.loading = true
    const {status} = await deleteRequest(`/smartlistv1/${route.params.smartlistId}`)
    handleHidingGlobalLoader( status)
    router.go(-1)
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Unable to delete smartlist')

    appStore.loading = false
  }
}
const deleteRequirement = async (requirement) => {
  try {
    const deleteIndex = requirements.value.findIndex(r => r.id === requirement.id)
    if (deleteIndex === -1) {
      throw 'Given requirement not found in requirement list'
    }
    appStore.loading = true
    await deleteRequest(`/smartlistv1/${smartlist.value.id}/requirement/${requirement.id}`)
    requirements.value.splice(deleteIndex, 1)
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error deleting requirement')

  } finally {
    appStore.loading = false
  }
}
const runReport = async () => {
  try {
    appStore.loading = true
    const params = {timezone: timezone}
    const {data, status} = await getRequestWithParams(`/smartlistv1/${smartlist.value.id}/csv`, {params})
    let blob = new Blob([data], {
      type: 'text/csv;charset=utf-8'
    })
    saveAs(blob, `${smartlist.value.name} ${DateTime.local().toFormat('yyyy-MM-dd h_mm a')}.csv`);
    handleHidingGlobalLoader( status)
  } catch (e) {
    appStore.showSnack('ERROR', e.data.message)

    logError(e)
    appStore.loading = false
  }
}
const validateForm  = () => {
  if (smartlistForm.value.validate()) {
    smartlist.value.id ? updateSmartlist() : addSmartlist()
    if (smartlist.value.projectDetails && projectDetailsColumns.value.length === 0) {
      getProjectDetailsColumns()
    }
  }
}
const toggleProjectDetails = async () => {
  try {
    appStore.loading = true
    const {status} = await putRequest(`/smartlistv1/${smartlist.value.id}/toggleProjectDetails`)
    refreshData.value = true
    requirements.value = []
    handleHidingGlobalLoader( status)
  } catch (e) {
    logError(e)
    smartlist.value.projectDetails = !smartlist.value.projectDetails
    appStore.showSnack('ERROR', 'Error updating smartlist')

    appStore.loading = false
  }
}
const resetToggleProjectDetails = ()=> {
  smartlist.value.projectDetails = !smartlist.value.projectDetails
  showToggleDialog.value = false
}
const checkObjectTypeChange  = () => {
  if (smartlist.value.id) {
    const newObjectTypeId = companyObjectTypes.value.find(t => t.companyObjectTypeId === smartlist.value.companyObjectTypeId)?.objectTypeId
    if ([1, 2, 4].includes(originalObjectTypeId.value) && [3, 5, 6].includes(newObjectTypeId)) {
      showObjectTypeDialog.value = true
      return
    }

    if ([3, 5].includes(originalObjectTypeId.value) && [1, 2, 4, 6].includes(newObjectTypeId)) {
      showObjectTypeDialog.value = true
      return
    }

    if (originalObjectTypeId.value === 6 && newObjectTypeId !== 6) {
      showObjectTypeDialog.value = true
    }
  }
}
const toggleSmartlistObjectType = async () => {
  try {
    appStore.loading = true
    const companyObjectType = companyObjectTypes.value.find(t => t.companyObjectTypeId === smartlist.value.companyObjectTypeId)
    smartlist.value.objectTypeId = companyObjectType.objectTypeId

    const {data, status} = await putRequest((`/smartlistv1/${smartlist.value.id}/toggleObjectType`), smartlist.value)

    smartlist.value = data
    originalObjectTypeId.value = data.objectTypeId
    refreshData.value = true
    requirements.value = []
    handleHidingGlobalLoader( status)
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error updating smartlist row type')
    smartlist.value.objectTypeId = originalObjectTypeId.value
    smartlist.value.companyObjectTypeId = companyObjectTypes.value.find(t => t.objectTypeId === originalObjectTypeId.value).companyObjectTypeId

    appStore.loading = false
  }
}
const copy = async () => {
  try {
    appStore.loading = true
    const {data, status} = await postRequest(`/smartlistv1/${smartlist.value.id}/copy`)
    router.go(-1)
    appStore.showSnack('SUCCESS', `Smartlist "${data.name}" was created`)

    handleHidingGlobalLoader( status)
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error duplicating smartlist')

    appStore.loading = false
  }
}
const buildSql = async() => {
  try {
    const params = {timezone: timezone.value}
    const {data} = await getRequestWithParams(`/smartlistv1/${smartlist.value.id}/getSqlString`, {params})
    sql.value = data
    navigator.clipboard.writeText(sql.value);
    appStore.showSnack('SUCCESS', 'Copied query to clipboard')

  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error fetching sql')

  }
}
</script>

<style scoped lang="scss">

@import "@/styles/main.scss";

::v-deep {
  [v-cloak] {
    display: none;
  }
}

.build-sql {
  position: absolute;
  bottom: 10px;
  right: 25px;
}
</style>
