<!--suppress CssInvalidPseudoSelector -->
<template>
  <v-card class="permit-card square-card">
    <v-row no-gutters class="px-2" id="ahj-permit">
      <v-col class="ahj-form-btns py-1" cols="12">
        <a-btn
            variant="text"
            color="primary"
            class="text-capitalize"
            @click="toggleMinimizeAll"
            :text="expandedAll !== CollapseExpandEnum.COLLAPSED ? 'Minimize All' : 'Expand All'"
        ></a-btn>
        <a-btn
            v-if="dataWasChanged"
            color="primary"
            variant="text"
            @click="resetForm"
            class="cancel-link"
            html-style="margin-right: 10px"
            text="Cancel"
        ></a-btn>
        <a-btn
            class="mr-0 save-btn"
            v-if="userCanEdit"
            color="primary"
            @click="validateForm()"
            text="Save"
        ></a-btn>
      </v-col>
    </v-row>

    <v-form ref="ahjPermitForm">
      <v-row class="mb-4 group-row" no-gutters>
        <TwoColumnMasonry v-if="dataReady"
                          :custom-field-groups="customFieldGroups"
                          :user-can-edit="userCanEdit"
                          :expanded-all="expandedAll"
                          :callback="(field) => updateDirtyValue(field)"
                          :hardcoded-docs="hardCodedDocsMap"
                          :source-id="ahjPermit.id"
                          @toggle-collapse-expand="toggleCollapseExpand($event)"
        ></TwoColumnMasonry>
      </v-row>

      <div v-if="dataReady">
        <h1 class="pb-2 mb-4"
            style="border-bottom: 1px solid #ccc; width: 100%;"
        >Links and Contacts</h1>
        <v-row no-gutters>
          <!-- FIRST COLUMN -->
          <v-col cols="12" md="6" class="px-1 mb-3">
            <FeatDbLinks title="Links"
                         :linkTypeId="linksTypeId.value"
                         :user-can-edit="userCanEdit"
                         :itemId="ahjPermit.id"
                         :itemType="itemType"
                         :ahjId="ahjId"
                         :links="ahjPermit.links"
                         show-expanded
                         :expanded-all="expandedAll"
                         @toggle-collapse-expand="toggleCollapseExpand($event)"
            ></FeatDbLinks>
          </v-col>

          <!-- SECOND COLUMN -->
          <v-col cols="12" md="6" class="px-1 mb-3">
            <FeatDbContact title="Contacts"
                           :contactTypeId="1"
                           :user-can-edit="userCanEdit"
                           :itemId="ahjPermit.id"
                           :itemType="itemType"
                           :ahjId="ahjId"
                           :contacts="ahjPermit.contacts"
                           show-expanded
                           :expanded-all="expandedAll"
                           @toggle-collapse-expand="toggleCollapseExpand($event)"
            ></FeatDbContact>
          </v-col>

        </v-row>
      </div>
      <v-dialog v-model="saveDialog" max-width="700">
        <v-card>
          <v-card-title>
            <span class="text-h5">Save Changes</span>
          </v-card-title>

          <v-divider></v-divider>

          <v-card-text class="pb-0">
            <v-radio-group v-model="ahjPermit.updateAllInArea">
              <v-radio label="Save changes to this AHJ only" :value="''"></v-radio>
              <v-radio :label="`Save changes to all AHJs in ${ahjPermit.metroArea}`" :value="'metro'"></v-radio>
              <v-radio :label="`Save changes to all AHJs in ${ahjPermit.stateName}`" :value="'state'"></v-radio>
            </v-radio-group>
          </v-card-text>

          <v-divider></v-divider>

          <v-card-actions class="px-6">
            <v-spacer></v-spacer>
            <a-btn
                @click="saveDialog = false"
                color="primary"
                variant="text"
                class="cancel-link mr-2"
                text="Cancel"
            ></a-btn>
            <a-btn
                v-if="ahjPermit.updateAllInArea?.length > 0"
                class="mr-0 save-btn"
                color="primary"
                @click="saveConfirmDialog = true"
                text="Save"
            ></a-btn>
            <a-btn
                v-else
                class="mr-0 save-btn"
                color="primary"
                @click="updateAhjPermit"
            ></a-btn>
          </v-card-actions>
        </v-card>
      </v-dialog>

      <v-dialog v-model="saveConfirmDialog" max-width="500">
        <v-card>
          <v-card-title>
            <span class="text-h5">Confirm</span>
          </v-card-title>

          <v-card-text class="pb-0 py-2">
            Are you sure you want to update <strong>ALL</strong>? This action cannot be undone.
          </v-card-text>

          <v-card-actions class="px-6">
            <v-spacer></v-spacer>
            <a-btn
                color="primary"
                variant="text"
                @click="saveConfirmDialog = false"
                class="cancel-link mr-2"
                text="Cancel"
            ></a-btn>
            <a-btn
                class="mr-0 save-btn"
                color="primary"
                @click="updateAhjPermit"
                text="Yes"
            ></a-btn>
          </v-card-actions>
        </v-card>
      </v-dialog>

    </v-form>
  </v-card>
</template>

<script setup>
import cloneDeep from 'lodash.clonedeep'

import {handleHidingGlobalLoader, getRequest, getRequestWithParams, putRequest, } from '@/helpers/helpers'
import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
import {CollapseExpandEnum} from "@/views/blueraven/featDB/FeatDbConstants";
import TwoColumnMasonry from "@/views/blueraven/featDB/components/TwoColumnMasonry.vue";
import FeatDbCustomFieldGroup from "@/views/blueraven/featDB/components/FeatDbCustomFieldGroup.vue";
import FeatDbContact from "@/views/blueraven/featDB/components/FeatDbContacts.vue";
import FeatDbLinks from "@/views/blueraven/featDB/components/FeatDbLinks.vue";
import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const itemType = ref('permit')
const saveDialog = ref(false)
const saveConfirmDialog = ref(false)
const dataWasChanged = ref(false)
const dataReady = ref(false)
const customFieldGroups = ref([])
const approvalRequiredOptions = ref([
  {id: null, name: ''}
])
const submittalMethods = ref([
  {id: null, name: ''}
])
const businessLicenseMenu = ref(false)
const contractorLicenseMenu = ref(false)
const otherLicenseMenu = ref(false)
const editRevisionSubmissionInstruction = ref(false)
const editSubmissionInstruction = ref(false)
const editAsBuiltSubmissionInstruction = ref(false)
const editNonStandardSubmissionInstruction = ref(false)
const editDeliveryInstruction = ref(false)
const editApprovalInstructions = ref(false)
const editBrsTechnicianPermitPickupAndDeliveryInstructions = ref(false)
const editCancellationAndRefundInstructions = ref(false)
const editBrsTechnicianPermitSubmissionInstructions = ref(false)
const totalGroups = ref(4)
const expandedGroups = ref(4)
const ahjPermit = ref({submissionChecklist: [],revisionChecklist: [],asBuiltChecklist: [],nonStandardChecklist: [],links:[],contacts: [],printLocations: [],})
const submissionDocuments = ref([])
const approvalDocuments = ref([])
const approvalDocTypeId = ref(981)
const linksTypeId = ref(12)
const ahjPermitForm = ref(null)

const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('AHJ', 'EDIT')
})
const hardCodedDocsMap = computed(() => {
  const docsMap = new Map()
  docsMap.set(1, {
    title: "Submission Documents",
    documents: submissionDocuments.value,
    attachmentTypeId: 1,
    attachmentType: "All Documents"
  })
  docsMap.set(4, {
    title: "Approval Documents",
    documents: approvalDocuments.value,
    attachmentTypeId: approvalDocTypeId.value,
    attachmentType: "All Documents"
  })
  return docsMap
})
const expandedAll = computed(() => {
  if (expandedGroups.value === totalGroups.value) {
    return CollapseExpandEnum.EXPANDED
  } else if (expandedGroups.value === 0) {
    return CollapseExpandEnum.COLLAPSED
  } else {
    return CollapseExpandEnum.MIXED
  }
})

const ahjId = computed(() => {
  return parseInt(route.params.ahjId)
})

onMounted(() => {
  getAhjPermit().then(() => {
    getCustomFieldGroupAssignmentsForScreen()
    getSubmissionDocuments()
    getApprovalDocuments()
  })
})

const updateDirtyValue = (item) => {
  item.valueWasChanged = true
  dataWasChanged.value = true
}
const validateForm = () => {
  //checks for required fields prior to opening the save dialog
  if (ahjPermitForm.value.validate()) {
    saveDialog.value = true
  } else {
    snackbar('ERROR', 'Missing Required Fields')

  }
}
const toggleCollapseExpand = (wasExpanded) => {
  if (wasExpanded === false) {
    expandedGroups.value--
  } else {
    expandedGroups.value++
  }
}
const getAhjPermit = async() => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/featDb/ahj/${ahjId.value}/permit`, 'blueraven')

    ahjPermit.value = cloneDeep(data)
    window.document.title = `AHJ - ${ahjPermit.value.ahjName}`
    ahjPermit.value.updateAllInArea = ""
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving AHJ Permit')
    appStore.loading = false
  }
}
const getCustomFieldGroupAssignmentsForScreen = async() => {
  appStore.loading = true
  try {
    const params = {sourceId: ahjPermit.value.id, objectTypeId: 4}
    const {
      data,
      status
    } = await getRequestWithParams(`/customFieldGroup/getCustomFieldGroupAssignmentsByObjectType`, {params}, 'blueraven')
    customFieldGroups.value = cloneDeep(data)
    totalGroups.value = totalGroups.value + customFieldGroups.value.length;
    expandedGroups.value = totalGroups.value;
    dataReady.value = true
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving custom fields')
    appStore.loading = false
  }
}
const getCustomFieldsForGroup = (groupId) => {
  let match = customFieldGroups.value.find(cfga => cfga.id === groupId)
  return match ? match.customFieldValues : []
}
const showOtherField = (int, list) => {
  let match = list.find(l => l.id === int)
  return match ? match.showOther : false
}
const resetCustomFieldValueWasChangedFlags = () => {
  customFieldGroups.value.forEach(group => {
    group.customFieldValues.forEach(cfv => cfv.valueWasChanged = false)
  })
}
const resetForm = async() => {
  appStore.loading = true
  dataWasChanged.value = false
  dataReady.value = false
  getAhjPermit().then(() => {
    getCustomFieldGroupAssignmentsForScreen()
  })
}
const getSubmissionDocuments = async() => {
  appStore.loading = true
  try {
    const params = {sourceId: ahjPermit.value.id, attachmentTypeId: 1}
    const {data, status} = await getRequestWithParams('/attachment', {params})
    submissionDocuments.value = cloneDeep(data)
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving documents')
    appStore.loading = false
  }
}
const getApprovalDocuments = async() => {
  appStore.loading = true
  try {
    const params = {sourceId: ahjPermit.value.id, attachmentTypeId: approvalDocTypeId.value}
    const {data, status} = await getRequestWithParams('/attachment', {params})
    approvalDocuments.value = cloneDeep(data)
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving documents')
    appStore.loading = false
  }
}
const updateAhjPermit = async() => {
  saveDialog.value = false
  saveConfirmDialog.value = false
  let updateAllInState = (ahjPermit.value.updateAllInArea == 'state');
  let updateAllInMetro = (ahjPermit.value.updateAllInArea == 'metro');

  try {
    appStore.loading = true

    if (updateAllInState) {
      try {
        const {data} = await getRequest(`/featDb/ahj/${ahjId.value}/permit/searchAhjsByState/${ahjPermit.value.stateId}`, 'blueraven')
        ahjPermit.value.ahjIds = []
        ahjPermit.value.permitIds = []

        data.forEach(row => {
          ahjPermit.value.ahjIds.push(row.ahjId)
          ahjPermit.value.permitIds.push(row.id)
        })
      } catch (e) {
        console.error('*** ERROR ***', e)
        snackbar('ERROR', 'An error occurred when preparing to update all permits in ' + ahjPermit.value.stateName)
      }
    }

    else if (updateAllInMetro){
      try {
        const {data} = await getRequest(`/featDb/ahj/${ahjId.value}/permit/searchAhjsByMetro/${ahjPermit.value.metroAreaId}`, 'blueraven')
        ahjPermit.value.ahjIds = []
        ahjPermit.value.permitIds = []

        data.forEach(row => {
          ahjPermit.value.ahjIds.push(row.ahjId)
          ahjPermit.value.permitIds.push(row.id)
        })
      } catch (e) {
        console.error('*** ERROR ***', e)
        snackbar('ERROR', 'An error occurred when preparing to update all permits in ' + ahjPermit.value.stateName)
      }
    }

    ahjPermit.value.customFieldGroups = customFieldGroups.value
    const {
      data,
      status
    } = await putRequest(`/featDb/ahj/${ahjId.value}/permit/${ahjPermit.value.id}`, ahjPermit.value, 'blueraven')

    ahjPermit.value = cloneDeep(data)
    ahjPermit.value.updateAllInArea = ''
    dataWasChanged.value = false
    resetCustomFieldValueWasChangedFlags()
    let successMessage = updateAllInState ? 'All permits in ' + ahjPermit.value.stateName + ' have been updated successfully' : updateAllInMetro ? 'All permits in ' + ahjPermit.value.metroArea + ' have been updated successfully': 'Permit updated successfully'
    snackbar('SUCCESS', successMessage)

    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    let errorMessage = updateAllInState ? 'An error occurred when attempting to update all permits in ' + ahjPermit.value.stateName : updateAllInMetro ? 'An error occurred when attempting to update all permits in ' + ahjPermit.value.metroArea : 'Failed to update permit'
    snackbar('ERROR', errorMessage)
    appStore.loading = false
  }

}

const toggleMinimizeAll = () => {
  if (expandedAll.value !== CollapseExpandEnum.COLLAPSED) {
    expandedGroups.value = 0
  } else {
    expandedGroups.value = totalGroups.value
  }
}
</script>

<style lang="scss">
.override-readonly-font-color textarea {
  color: var(--v-primaryText-base) !important;
}
</style>

<style scoped lang="scss">
.padded-sides {
  padding: 0 5px;
}

.permit-card {
  margin-left: 12px;
  margin-right: 12px;
}

.row {
  width: 100%;
}

.ahj-form-btns {
  display: flex;
  flex-flow: row nowrap;
  justify-content: flex-end;
  align-items: center;
}

.title-with-icon {
  display: flex;
  justify-content: space-between;

  .v-icon {
    cursor: pointer;
  }
}

.v-card__title,
.v-toolbar__title {
  font-size: 1em !important;
}

.v-text-field,
.v-select,
.v-input ::v-deep label,
.v-list-item__title,
.list-link {
  font-size: 0.95em !important;
}

.cancel-link,
.empty-list,
.horizontal-dl,
table {
  font-size: 0.85em !important;
}

.link-btns {
  display: flex;
  flex-flow: row nowrap;
  justify-content: flex-end;
  align-items: center;

  button {
    margin: 0 0 0 7px;
  }
}

.save-btn {
  margin: 10px 5px 10px 0;
  text-transform: capitalize;
}

.empty-list {
  padding: 20px;
}

.list-link {
  text-decoration: none;
}

.cancel-link:hover,
.list-link:hover {
  text-decoration: underline;
}

.flex-row-center {
  display: flex;
  flex-flow: row nowrap;
  align-items: center;
}

.row {
  width: 100%;
}

.group-row {
  justify-content: space-between;
}

.col-gap {
  width: 3em;
}

.other-field {
  margin-top: -20px;
}
</style>
