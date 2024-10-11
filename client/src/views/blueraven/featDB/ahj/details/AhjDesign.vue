<template>
  <v-card class="design-card square-card">
    <v-row no-gutters class="px-2" id="ahj-permit">
      <v-col class="form-btns py-1" cols="12">
        <v-menu v-model="showChangeLog" content-class="db-change-log-menu" v-if="hasManageAccess" max-height="60vh" :close-on-content-click="false" left offset-y attach>
          <template v-slot:activator="{on: menu, attrs }">
            <v-tooltip top>
              <template v-slot:activator="{ on: tooltip }">
                <a-btn
                  variant="text"
                  color="primary"
                  prepend-icon="history"
                  @click="getChangeLog"
                  v-bind="attrs"
                  :activation-handler="{ ...tooltip, ...menu }">
                </a-btn>
              </template>
              <span>History</span>
            </v-tooltip>
          </template>
          <DbChangeLog :history-list="changeLog" :show-change-log="showChangeLog"/>
        </v-menu>
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

    <v-form ref="ahjDesignForm">
      <v-row class="mb-4 group-row" no-gutters>
        <TwoColumnMasonry v-if="dataReady"
                          :custom-field-groups=customFieldGroups
                          :user-can-edit="userCanEdit"
                          :expanded-all="expandedAll"
                          :callback="(field) => updateDirtyValue(field)"
                          @toggle-collapse-expand="toggleCollapseExpand($event)"/>
      </v-row>

      <v-dialog v-model="saveDialog" max-width="700">
        <v-card>
          <v-card-title>
            <span class="text-h5">Save Changes</span>
          </v-card-title>

          <v-divider></v-divider>

          <v-card-text class="pb-0">
            <v-radio-group v-model="ahjDesign.updateAllInArea">
              <v-radio label="Save changes to this AHJ only" :value="''"></v-radio>
              <v-radio :label="`Save changes to all AHJs in ${ahjDesign.metroArea}`" :value="'metro'"></v-radio>
              <v-radio :label="`Save changes to all AHJs in ${ahjDesign.stateName}`" :value="'state'"></v-radio>
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
                v-if="ahjDesign.updateAllInArea?.length > 0"
                class="mr-0 save-btn"
                color="primary"
                @click="saveConfirmDialog = true"
                text="Save"
            ></a-btn>
            <a-btn
                v-else
                class="mr-0 save-btn"
                color="primary"
                @click="updateAhjDesign"
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
                @click="updateAhjDesign"
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
import DbChangeLog from "@/views/blueraven/featDB/components/DbChangeLog.vue";
import {handleHidingGlobalLoader, getRequest, getRequestWithParams, putRequest, } from '@/helpers/helpers'
import {CollapseExpandEnum} from "@/views/blueraven/featDB/FeatDbConstants";
import TwoColumnMasonry from "@/views/blueraven/featDB/components/TwoColumnMasonry.vue";
import {getCurrentInstance, computed, ref, onMounted} from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'
import axios from "axios";
import constants from "@/helpers/constants.js";
import {requestInterceptor, responseInterceptor} from "@/helpers/interceptors.js";

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const itemType = ref('design')
const saveDialog = ref(false)
const saveConfirmDialog = ref(false)
const dataWasChanged = ref(false)
const dataReady = ref(false)
const customFieldGroups = ref([])
const totalGroups = ref(8)
const expandedGroups = ref(8)
const ahjDesign = ref({designRequirements: [],electricalRequirements: [],structuralRequirements: [],contacts: []})
const ahjDesignForm = ref(null)
const showChangeLog = ref(false)
const changeLog = ref([])


const userCanEdit = computed(()  => {
  return userStore.userHasFeatureAccessLevel('AHJ', 'EDIT')
})

const hasManageAccess = computed(()  => {
  return userStore.userHasFeatureAccessLevel('AHJ', 'MANAGE')
})
const expandedAll = computed(() => {
  if(expandedGroups.value === totalGroups.value){
    return CollapseExpandEnum.EXPANDED
  } else if (expandedGroups.value === 0) {
    return CollapseExpandEnum.COLLAPSED
  } else {
    return CollapseExpandEnum.MIXED
  }
})
const ahjId = computed(() => {
  return route.params.ahjId
})
const http = axios.create({
  baseURL: `${constants.VUE_APP_BASE_API}${constants.VUE_APP_API_PATH}/flow`,
})
http.interceptors.request.use(requestInterceptor)
http.interceptors.response.use((response) => {
  if (response.status !== 403 && response.status !== 500 && response.status !== 200) {
    responseInterceptor({ response })
  }

  return response
})

onMounted(async() => {
  //this is how it was before. don't hate
  await getAhjDesign()
  await getCustomFieldGroupAssignmentsForScreen()
  dataReady.value = true
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
const toggleMinimizeAll = () => {
  if (expandedAll.value !== CollapseExpandEnum.COLLAPSED) {
    expandedGroups.value = 0
  } else {
    expandedGroups.value = totalGroups.value
  }

}
const getChangeLog = async() => {
  showChangeLog.value = !showChangeLog.value
  if (hasManageAccess && showChangeLog.value) {
    appStore.loading = true
    try {
      const {data, status} = await getRequest(`/featDb/ahj/${ahjId.value}/design/getAhjDesignHistory`, 'blueraven')
      changeLog.value = cloneDeep(data)
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error retrieving AHJ Design Change Log')
      appStore.loading = false
    }
  }
}
const getAhjDesign = async() => {
  appStore.loading = true
  try {
    const apiPath ='company/blueraven'
    const path = `/featDb/ahj/${ahjId.value}/design`
    const {data, status} = await http.get(`${constants.VUE_APP_BASE_API}${constants.VUE_APP_API_PATH}/${apiPath}${path}`) ?? {
      data: {},
      status: null
    }
    // const {data, status} = await getRequest(`/featDb/ahj/${ahjId.value}/design`, 'blueraven')
    window.document.title = `AHJ - ${data.ahjName}`
    ahjDesign.value = cloneDeep(data)
    ahjDesign.value.updateAllInArea = "";
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error retrieving AHJ Design')
    appStore.loading = false
  }
}
const getCustomFieldGroupAssignmentsForScreen = async() => {
  appStore.loading = true
  try {
    if (ahjDesign.value.id) {
      const params = {sourceId: ahjDesign.value.id, objectTypeId: 1}
      const {
        data,
        status
      } = await getRequestWithParams(`/customFieldGroup/getCustomFieldGroupAssignmentsByObjectType`, {params}, 'blueraven')
      customFieldGroups.value = cloneDeep(data)
      totalGroups.value = totalGroups.value + customFieldGroups.value?.length
      expandedGroups.value = totalGroups.value
      handleHidingGlobalLoader( status)
    } else {
      console.error('*** ERROR ***', 'Missing parameter "sourceId"')
      appStore.showSnack('ERROR', 'Error retrieving custom fields')
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error retrieving custom fields')
    appStore.loading = false
  }
}
const getCustomFieldsForGroup = (groupId) => {
  let match = customFieldGroups.value.find(cfga => cfga.id === groupId)
  return match ? match.customFieldValues : []
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
  getAhjDesign().then(() => {
    getCustomFieldGroupAssignmentsForScreen().then(() => dataReady.value = true)
  })
}

const validateForm = () => {
  //checks for required fields prior to opening the save dialog
  if (ahjDesignForm.value.validate()) {
    saveDialog.value = true
  } else {
    appStore.showSnack('ERROR', 'Missing Required Fields')

  }
}
const updateAhjDesign = async() => {
  saveDialog.value = false
  saveConfirmDialog.value = false
  let updateAllInState = (ahjDesign.value.updateAllInArea == 'state');
  let updateAllInMetro = (ahjDesign.value.updateAllInArea == 'metro');


  try {
    appStore.loading = true

    if (updateAllInState) {
      try {
        const {data} = await getRequest(`/featDb/ahj/${ahjId.value}/design/searchAhjsByState/${ahjDesign.value.stateId}`, 'blueraven')
        ahjDesign.value.ahjIds = []
        ahjDesign.value.designIds = []

        data.forEach(row => {
          ahjDesign.value.ahjIds.push(row.ahjId)
          ahjDesign.value.designIds.push(row.id)
        })
      } catch (e) {
        console.error('*** ERROR ***', e)
        appStore.showSnack('ERROR', 'An error occurred when preparing to update all designs in ' + ahjDesign.value.stateName)
      }
    } else if (updateAllInMetro) {
      try {
        const {data} = await getRequest(`/featDb/ahj/${ahjId.value}/design/searchAhjsByMetro/${ahjDesign.value.metroAreaId}`, 'blueraven')
        ahjDesign.value.ahjIds = []
        ahjDesign.value.designIds = []

        data.forEach(row => {
          ahjDesign.value.ahjIds.push(row.ahjId)
          ahjDesign.value.designIds.push(row.id)
        })
      } catch (e) {
        console.error('*** ERROR ***', e)
        appStore.showSnack('ERROR', 'An error occurred when preparing to update all designs in ' + ahjDesign.value.stateName)
      }
    }

    ahjDesign.value.customFieldGroups = customFieldGroups.value
    const {
      data,
      status
    } = await putRequest(`/featDb/ahj/${ahjId.value}/design/${ahjDesign.value.id}`, ahjDesign.value, 'blueraven')
    ahjDesign.value = cloneDeep(data)
    ahjDesign.value.updateAllInArea = ""
    dataWasChanged.value = false
    resetCustomFieldValueWasChangedFlags()
    let successMessage = updateAllInState ? 'All designs in ' + ahjDesign.value.stateName + ' have been updated successfully' : updateAllInMetro ? 'All designs in ' + ahjDesign.value.metroArea + ' have been updated successfully' : 'Design updated successfully'
    appStore.showSnack('SUCCESS', successMessage)
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    let errorMessage = updateAllInState ? 'An error occurred when attempting to update all designs in ' + ahjDesign.value.stateName : 'Failed to update design'
    appStore.showSnack('ERROR', errorMessage)
    appStore.loading = false
  }
}
</script>

<style scoped lang="scss">
.padded-sides {
  padding: 0 5px;
}

.design-card {
  margin-left: 12px;
  margin-right: 12px;
}

.form-btns {
  display: flex;
  flex-flow: row nowrap;
  justify-content: flex-end;
  align-items: center;
}

.v-text-field,
.v-select,
.v-input ::v-deep label,
.v-list-item__title {
  font-size: 0.95em !important;
}

.cancel-link {
  font-size: 0.85em !important;
}

.cancel-link:hover {
  text-decoration: underline;
}

.save-btn {
  margin: 10px 5px 10px 0;
}

.v-card__title,
.v-toolbar__title {
  font-size: 1em !important;
}

.v-card__subtitle {
  color: var(--v-primaryText-base) !important;
  border-bottom: 1px solid var(--v-primaryText-base) !important;
}

.custom-field,
.structural-design-text-field {
  width: 100%;
}

@media (min-width: 960px) {
  .custom-field,
  .structural-design-text-field {
    max-width: 46%;
  }
}
</style>
