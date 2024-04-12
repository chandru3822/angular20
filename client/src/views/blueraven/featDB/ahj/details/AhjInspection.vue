<!--suppress CssInvalidPseudoSelector -->
<template>
  <v-card class="inspection-card square-card pb-2" v-if="dataReady">
    <v-row class="px-2" no-gutters>
      <v-col class="ahj-form-btns py-1" cols="12">
        <a-btn
            variant="text"
            color="primary"
            class="text-capitalize"
            @click="toggleMinimizeAll"
            :text="expandedAll !== CollapseExpandEnum.COLLAPSED ? 'Minimize All' : 'Expand All'"
        ></a-btn>
        <a-btn
            color="primary"
            variant="text"
            v-if="dataWasChanged"
            @click="resetForm"
            class="cancel-link text-capitalize"
            html-style="margin-right: 10px"
            text="Cancel"
        ></a-btn>
        <a-btn
            class="text-capitalize mr-0 save-btn"
            v-if="userCanEdit"
            color="primary"
            @click="validateForm()"
            text="Save"
        ></a-btn>
      </v-col>
    </v-row>
    <!-- UPPER SECTION -->
    <v-form ref="ahjInspectionForm">
      <v-row class="mb-4 group-row" no-gutters>
        <TwoColumnMasonry v-if="dataReady"
                          :custom-field-groups=filteredCfgs
                          :user-can-edit="userCanEdit"
                          :expanded-all="expandedAll"
                          :callback="(field) => updateDirtyValue(field)"
                          @toggle-collapse-expand="toggleCollapseExpand($event)"/>
      </v-row>

      <!-- LOWER SECTION -->
      <h1 class="pb-2 mb-4 lower-section">Links and Contacts</h1>
      <!-- FIRST ROW -->
      <v-row no-gutters>
        <v-col cols="12" md="4" class="px-1">
          <FeatDbLinks title="Scheduling Links"
                       :linkTypeId="1"
                       :user-can-edit="userCanEdit"
                       :itemId="ahjInspection.id"
                       :itemType="itemType"
                       :ahjId="ahjId"
                       :links="ahjInspection.schedulingLinks"
                       show-expanded
                       :expanded-all="expandedAll"
                       @toggle-collapse-expand="toggleCollapseExpand($event)"
          ></FeatDbLinks>
        </v-col>

        <v-col cols="12" md="4" class="px-1">
          <FeatDbLinks title="Links for FOT"
                       :linkTypeId="2"
                       :user-can-edit="userCanEdit"
                       :itemId="ahjInspection.id"
                       :itemType="itemType"
                       :ahjId="ahjId"
                       :links="ahjInspection.fotLinks"
                       show-expanded
                       :expanded-all="expandedAll"
                       @toggle-collapse-expand="toggleCollapseExpand($event)"
          ></FeatDbLinks>
        </v-col>

        <v-col cols="12" md="4" class="px-1">
          <FeatDbLinks title="Results Links"
                       :linkTypeId="3"
                       :user-can-edit="userCanEdit"
                       :itemId="ahjInspection.id"
                       :itemType="itemType"
                       :ahjId="ahjId"
                       :links="ahjInspection.resultsLinks"
                       show-expanded
                       :expanded-all="expandedAll"
                       @toggle-collapse-expand="toggleCollapseExpand($event)"
          ></FeatDbLinks>
        </v-col>
      </v-row>

      <!-- SECOND ROW -->
      <v-row no-gutters>
        <v-col cols="12" md="4" class="px-1">
          <FeatDbContact title="Scheduling Contacts"
                         :contactTypeId="2"
                         :user-can-edit="userCanEdit"
                         :itemId="ahjInspection.id"
                         :itemType="itemType"
                         :ahjId="ahjId"
                         :contacts="ahjInspection.schedulingContacts"
                         show-expanded
                         :expanded-all="expandedAll"
                         @toggle-collapse-expand="toggleCollapseExpand($event)"
          ></FeatDbContact>
        </v-col>

        <v-col cols="12" md="4" class="px-1">
          <FeatDbContact title="Inspector Contacts"
                         :contactTypeId="4"
                         :user-can-edit="userCanEdit"
                         :itemId="ahjInspection.id"
                         :itemType="itemType"
                         :ahjId="ahjId"
                         :contacts="ahjInspection.feeContacts"
                         show-expanded
                         :expanded-all="expandedAll"
                         @toggle-collapse-expand="toggleCollapseExpand($event)"
          ></FeatDbContact>
        </v-col>

        <v-col cols="12" md="4" class="px-1">
          <FeatDbContact title="Obtaining Results Contacts"
                         :contactTypeId="3"
                         :itemId="ahjInspection.id"
                         :user-can-edit="userCanEdit"
                         :itemType="itemType"
                         :ahjId="ahjId"
                         :contacts="ahjInspection.obtainingResultsContacts"
                         show-expanded
                         :expanded-all="expandedAll"
                         @toggle-collapse-expand="toggleCollapseExpand($event)"
          ></FeatDbContact>
        </v-col>
      </v-row>

      <!-- THIRD ROW -->
      <v-row no-gutters class="mb-5">
        <v-col cols="12" md="4" class="px-1">
          <FeatDbContact title="Utility Service Department Contacts"
                         :contactTypeId="9"
                         :user-can-edit="userCanEdit"
                         :itemId="ahjInspection.id"
                         :itemType="itemType"
                         :ahjId="ahjId"
                         :contacts="ahjInspection.utilityServiceDeptContacts"
                         :isNested="true"
                         show-expanded
                         :expanded-all="expandedAll"
                         @toggle-collapse-expand="toggleCollapseExpand($event)"
          ></FeatDbContact>
        </v-col>
        <v-col cols="12" md="4" class="px-1">
          <FeatDbCard title="Servicing FOT's" show-expanded :expanded-all="expandedAll" @toggle-collapse-expand="toggleCollapseExpand($event)">
            <AhjServicingFot :servicingFots="ahjInspection.servicingFots"
            ></AhjServicingFot>
          </FeatDbCard>
        </v-col>
        <v-col cols="12" md="4" class="px-1">
          <FeatDbCustomFieldGroup :group="installationRequirementGroup"
                                  :user-can-edit="userCanEdit"
                                  :expanded-all="expandedAll"
                                  @toggle-collapse-expand="toggleCollapseExpand($event)"
                                  :callback="(field) => updateDirtyValue(field)"
          ></FeatDbCustomFieldGroup>
        </v-col>
      </v-row>

      <v-dialog v-model="saveDialog" max-width="700">
        <v-card>
          <v-card-title>
            <span class="text-h5">Save Changes</span>
          </v-card-title>

          <v-divider></v-divider>

          <v-card-text class="pb-0">
            <v-radio-group v-model="ahjInspection.updateAllInArea">
              <v-radio label="Save changes to this AHJ only" :value="''"></v-radio>
              <v-radio :label="`Save changes to all AHJs in ${ahjInspection.metroArea}`" :value="'metro'"></v-radio>
              <v-radio :label="`Save changes to all AHJs in ${ahjInspection.stateName}`" :value="'state'"></v-radio>
            </v-radio-group>
          </v-card-text>

          <v-divider></v-divider>

          <v-card-actions class="px-6">
            <v-spacer></v-spacer>
            <a-btn
                color="primary"
                variant="text"
                @click="saveDialog = false"
                class="cancel-link mr-2"
                text="Cancel"
            ></a-btn>
            <a-btn
                v-if="ahjInspection.updateAllInArea.length > 0"
                class="mr-0 save-btn"
                color="primary"
                @click="saveConfirmDialog = true"
                text="Save"
            ></a-btn>
            <a-btn
                v-else
                class="mr-0 save-btn"
                color="primary"
                @click="updateAhjInspection"
                text="Save"
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
                @click="updateAhjInspection"
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
import AhjServicingFot from '@/views/blueraven/featDB/components/AhjServicingFots.vue'
import {CollapseExpandEnum} from "@/views/blueraven/featDB/FeatDbConstants";

import {handleHidingGlobalLoader, getRequest, getRequestWithParams, putRequest, } from '@/helpers/helpers'
import orderBy from "lodash.orderby";
import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
import TwoColumnMasonry from "@/views/blueraven/featDB/components/TwoColumnMasonry.vue";
import FeatDbCard from "@/views/blueraven/featDB/components/FeatDbCard.vue";
import FeatDbCustomFieldGroup from "@/views/blueraven/featDB/components/FeatDbCustomFieldGroup.vue";
import FeatDbContact from "@/views/blueraven/featDB/components/FeatDbContacts.vue";
import FeatDbLinks from "@/views/blueraven/featDB/components/FeatDbLinks.vue";
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


const itemType = ref('inspection')
const saveDialog = ref(false)
const saveConfirmDialog = ref(false)
const dataWasChanged = ref(false)
const dataReady = ref(false)
const customFieldGroups = ref([])
const installationRequirementGroup = ref({})
const totalGroups = ref(8)
const expandedGroups = ref(8)
const ahjInspection = ref({schedulingLinks: [],fotLinks: [],resultsLinks: [],schedulingContacts: [],feeContacts: [],obtainingResultsContacts: [],servicingFots: []})
const ahjInspectionForm = ref(null)

const filteredCfgs = computed(() => {
  return customFieldGroups.value.filter(cfg => cfg.id !== 45)
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('AHJ', 'EDIT')
})
const expandedAll = computed(()=> {
  if(expandedGroups.value === totalGroups.value){
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
  getAhjInspection().then(() => {
    getCustomFieldGroupAssignmentsForScreen().then(() => dataReady.value = true)
  })
})

const updateDirtyValue = (item) => {
  item.valueWasChanged = true
  dataWasChanged.value = true
}
const toggleCollapseExpand = (wasExpanded) => {
  if(wasExpanded === false) {
    expandedGroups.value--
  }else {
    expandedGroups.value++
  }
}
const getAhjInspection = async() => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/featDb/ahj/${ahjId.value}/inspection`, 'blueraven')
    window.document.title = `AHJ - ${data.ahjName}`
    if (data.servicingFots && data.servicingFots.length > 0) {
      data.servicingFots.forEach(servicingFot => {
        if (servicingFot.hierarchy && servicingFot.hierarchy.length > 0) {
          servicingFot.hierarchy = servicingFot.hierarchy[0]
        }
      })

      data.servicingFots = orderBy(data.servicingFots, fot => {
        if (fot.hierarchy && fot.hierarchy.orgName) {
          return fot.hierarchy.orgName.toLowerCase()
        }
      })
    } else {
      data.servicingFots = []
    }

    ahjInspection.value = cloneDeep(data)
    ahjInspection.value.updateAllInArea = ""
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving AHJ Inspection')
    appStore.loading = false
  }
}
const getCustomFieldGroupAssignmentsForScreen = async() => {
  appStore.loading = true
  try {
    const params = {sourceId: ahjInspection.value.id, objectTypeId: 3}
    const {
      data,
      status
    } = await getRequestWithParams(`/customFieldGroup/getCustomFieldGroupAssignmentsByObjectType`, {params}, 'blueraven')
    customFieldGroups.value = cloneDeep(data)
    installationRequirementGroup.value = customFieldGroups.value.find(cfg => cfg.id === 45)
    totalGroups.value = totalGroups.value + customFieldGroups.value.length;
    expandedGroups.value = totalGroups.value;
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving custom fields')
    appStore.loading = false
  }
}
const validateForm = () => {
  //checks for required fields prior to opening the save dialog
  if (ahjInspectionForm.value.validate()) {
    saveDialog.value = true
  } else {
    snackbar('ERROR', 'Missing Required Fields')

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
  getAhjInspection().then(() => {
    getCustomFieldGroupAssignmentsForScreen().then(() => dataReady.value = true)
  })
}
const updateAhjInspection = async() => {
  saveDialog.value = false
  saveConfirmDialog.value = false
  let updateAllInState = (ahjInspection.value.updateAllInArea == 'state');
  let updateAllInMetro = (ahjInspection.value.updateAllInArea == 'metro');


  try {
    appStore.loading = true

    if (updateAllInState) {
      try {
        const {data} = await getRequest(`/featDb/ahj/${ahjId.value}/inspection/searchAhjsByState/${ahjInspection.value.stateId}`, 'blueraven')
        ahjInspection.value.ahjIds = []
        ahjInspection.value.inspectionIds = []

        data.forEach(row => {
          ahjInspection.value.ahjIds.push(row.ahjId)
          ahjInspection.value.inspectionIds.push(row.id)
        })
      } catch (e) {
        console.error('*** ERROR ***', e)
        snackbar('ERROR', 'An error occurred when preparing to update all inspections in ' + ahjInspection.value.stateName)
      }
    }

    else if (updateAllInMetro){
      try {
        const {data} = await getRequest(`/featDb/ahj/${ahjId.value}/inspection/searchAhjsByMetro/${ahjInspection.value.metroAreaId}`, 'blueraven')
        ahjInspection.value.ahjIds = []
        ahjInspection.value.inspectionIds = []

        data.forEach(row => {
          ahjInspection.value.ahjIds.push(row.ahjId)
          ahjInspection.value.inspectionIds.push(row.id)
        })
      } catch (e) {
        console.error('*** ERROR ***', e)
        snackbar('ERROR', 'An error occurred when preparing to update all inspections in ' + ahjInspection.value.stateName)
      }
    }

    ahjInspection.value.customFieldGroups = customFieldGroups.value
    const {
      data,
      status
    } = await putRequest(`/featDb/ahj/${ahjId.value}/inspection/${ahjInspection.value.id}`, ahjInspection.value, 'blueraven')
    ahjInspection.value = cloneDeep(data)
    ahjInspection.value.updateAllInArea = ''
    dataWasChanged.value = false
    resetCustomFieldValueWasChangedFlags()
    let successMessage = updateAllInState ? 'All inspections in ' + ahjInspection.value.stateName + ' have been updated successfully' : updateAllInMetro ? 'All inspections in ' + ahjInspection.value.metroArea + ' have been updated successfully': 'Inspection updated successfully'
    snackbar('SUCCESS', successMessage)
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    let errorMessage = updateAllInState ? 'An error occurred when attempting to update all inspections in ' + ahjInspection.value.stateName : updateAllInMetro ? 'An error occurred when attempting to update all inspections in ' + ahjInspection.value.metroArea : 'Failed to update inspection'
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

<style scoped lang="scss">
.padded-sides {
  padding: 0 5px;
}

.inspection-card {
  margin-left: 12px;
  margin-right: 12px;
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
.empty-list {
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

.group {
}

.lower-section {
  border-bottom: 1px solid #ccc;
  width: 100%;
}

.other-field {
  margin-top: -20px;
}
</style>
