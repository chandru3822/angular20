<!--suppress CssInvalidPseudoSelector -->
<template>
  <v-card class="new-home-card square-card pb-2" v-if="dataReady">
    <v-row class="px-2" no-gutters>
      <v-col class="form-btns py-1" cols="12">
        <v-menu content-class="db-change-log-menu" v-if="hasManageAccess" max-height="60vh" :close-on-content-click="false" left offset-y attach>
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
          <DbChangeLog :history-list="changeLog"/>
        </v-menu>
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
    <v-form ref="ahjNewHomeForm">
      <v-row class="mb-4 group-row" no-gutters>
        <TwoColumnMasonry v-if="dataReady"
                          :custom-field-groups="customFieldGroups"
                          :user-can-edit="userCanEdit"
                          :expanded-all="expandedAll"
                          :callback="(field) => updateDirtyValue(field)"
                          @toggle-collapse-expand="toggleCollapseExpand($event)"/>
      </v-row>

      <div v-if="dataReady">
        <h1 class="pb-2 mb-4"
            style="border-bottom: 1px solid #ccc; width: 100%;"
        >Links and Contacts</h1>
        <v-row no-gutters>
          <!-- FIRST COLUMN -->
          <v-col cols="12" md="6" class="px-1 mb-3">
            <FeatDbLinks title="Links"
                         :linkTypeId="15"
                         :user-can-edit="userCanEdit"
                         :itemId="ahjNewHome.id"
                         :itemType="itemType"
                         :ahjId="ahjId"
                         :links="ahjNewHome.links"
                         show-expanded
                         :expanded-all="expandedAll"
                         @toggle-collapse-expand="toggleCollapseExpand($event)"
            ></FeatDbLinks>
          </v-col>

          <!-- SECOND COLUMN -->
          <v-col cols="12" md="6" class="px-1 mb-3">
            <FeatDbContact title="Contacts"
                           :contactTypeId="14"
                           :user-can-edit="userCanEdit"
                           :itemId="ahjNewHome.id"
                           :itemType="itemType"
                           :ahjId="ahjId"
                           :contacts="ahjNewHome.contacts"
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
            <v-radio-group v-model="ahjNewHome.updateAllInArea">
              <v-radio label="Save changes to this AHJ only" :value="''"></v-radio>
              <v-radio :label="`Save changes to all AHJs in ${ahjNewHome.metroArea}`" :value="'metro'"></v-radio>
              <v-radio :label="`Save changes to all AHJs in ${ahjNewHome.stateName}`" :value="'state'"></v-radio>
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
                v-if="ahjNewHome.updateAllInArea.length > 0"
                class="mr-0 save-btn"
                color="primary"
                @click="saveConfirmDialog = true"
                text="Save"
            ></a-btn>
            <a-btn
                v-else
                class="mr-0 save-btn"
                color="primary"
                @click="updateAhjNewHome"
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
                @click="updateAhjNewHome"
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
import TwoColumnMasonry from "@/views/blueraven/featDB/components/TwoColumnMasonry.vue";
import FeatDbCard from "@/views/blueraven/featDB/components/FeatDbCard.vue";
import FeatDbCustomFieldGroup from "@/views/blueraven/featDB/components/FeatDbCustomFieldGroup.vue";
import FeatDbContact from "@/views/blueraven/featDB/components/FeatDbContacts.vue";
import FeatDbLinks from "@/views/blueraven/featDB/components/FeatDbLinks.vue";
import { getCurrentInstance, computed, ref, onMounted } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'
import DbChangeLog from "@/views/blueraven/featDB/components/DbChangeLog.vue";

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store


const itemType = ref('newHome')
const saveDialog = ref(false)
const saveConfirmDialog = ref(false)
const dataWasChanged = ref(false)
const dataReady = ref(false)
const customFieldGroups = ref([])
const totalGroups = ref(0)
const expandedGroups = ref(0)
const ahjNewHome = ref({})
const ahjNewHomeForm = ref(null)
const showChangeLog = ref(false);
const changeLog = ref([])

const userCanEdit = computed(()  => {
  return userStore.userHasFeatureAccessLevel('AHJ', 'EDIT')
})

const hasManageAccess = computed(()  => {
  return userStore.userHasFeatureAccessLevel('AHJ', 'MANAGE')
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

onMounted(async () => {
  getAhjNewHome().then(() => {
    getCustomFieldGroupAssignmentsForScreen().then(() => dataReady.value = true)
  })
})

const getChangeLog = async() => {
  showChangeLog.value = !showChangeLog.value
  if(showChangeLog.value) {
    appStore.loading = true
    try {
      const {data, status} = await getRequest(`/featDb/ahj/${ahjId.value}/newHome/history`, 'blueraven')
      changeLog.value = cloneDeep(data)
      handleHidingGlobalLoader( status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error retrieving AHJ New Home Change Log')
      appStore.loading = false
    }
  }
}
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
const getAhjNewHome = async() => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/featDb/ahj/${ahjId.value}/newHome`, 'blueraven')
    window.document.title = `AHJ - ${data.ahjName}`

    ahjNewHome.value = cloneDeep(data)
    ahjNewHome.value.updateAllInArea = ""
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error retrieving AHJ New Home')
    appStore.loading = false
  }
}
const getCustomFieldGroupAssignmentsForScreen = async() => {
  appStore.loading = true
  try {
    const params = {sourceId: ahjNewHome.value.id, objectTypeId: 99}
    const {
      data,
      status
    } = await getRequestWithParams(`/customFieldGroup/getCustomFieldGroupAssignmentsByObjectType`, {params}, 'blueraven')
    customFieldGroups.value = cloneDeep(data)
    totalGroups.value = totalGroups.value + customFieldGroups.value.length;
    expandedGroups.value = totalGroups.value;
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error retrieving custom fields')
    appStore.loading = false
  }
}
const validateForm = () => {
  //checks for required fields prior to opening the save dialog
  if (ahjNewHomeForm.value.validate()) {
    saveDialog.value = true
  } else {
    appStore.showSnack('ERROR', 'Missing Required Fields')

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
  getAhjNewHome().then(() => {
    getCustomFieldGroupAssignmentsForScreen().then(() => dataReady.value = true)
  })
}
const updateAhjNewHome = async() => {
  saveDialog.value = false
  saveConfirmDialog.value = false
  let updateAllInState = (ahjNewHome.value.updateAllInArea == 'state');
  let updateAllInMetro = (ahjNewHome.value.updateAllInArea == 'metro');


  try {
    appStore.loading = true

    if (updateAllInState) {
      try {
        const {data} = await getRequest(`/featDb/ahj/${ahjId.value}/newHome/searchAhjsByState/${ahjNewHome.value.stateId}`, 'blueraven')
        ahjNewHome.value.ahjIds = []
        ahjNewHome.value.newHomeIds = []

        data.forEach(row => {
          ahjNewHome.value.ahjIds.push(row.ahjId)
          ahjNewHome.value.newHomeIds.push(row.id)
        })
      } catch (e) {
        console.error('*** ERROR ***', e)
        appStore.showSnack('ERROR', 'An error occurred when preparing to update all new homes in ' + ahjNewHome.value.stateName)
      }
    }

    else if (updateAllInMetro){
      try {
        const {data} = await getRequest(`/featDb/ahj/${ahjId.value}/newHome/searchAhjsByMetro/${ahjNewHome.value.metroAreaId}`, 'blueraven')
        ahjNewHome.value.ahjIds = []
        ahjNewHome.value.newHomeIds = []

        data.forEach(row => {
          ahjNewHome.value.ahjIds.push(row.ahjId)
          ahjNewHome.value.newHomeIds.push(row.id)
        })
      } catch (e) {
        console.error('*** ERROR ***', e)
        appStore.showSnack('ERROR', 'An error occurred when preparing to update all new homes in ' + ahjNewHome.value.stateName)
      }
    }

    ahjNewHome.value.customFieldGroups = customFieldGroups.value
    const {
      data,
      status
    } = await putRequest(`/featDb/ahj/${ahjId.value}/newHome/${ahjNewHome.value.id}`, ahjNewHome.value, 'blueraven')
    ahjNewHome.value = cloneDeep(data)
    ahjNewHome.value.updateAllInArea = ''
    dataWasChanged.value = false
    resetCustomFieldValueWasChangedFlags()
    let successMessage = updateAllInState ? 'All new homes in ' + ahjNewHome.value.stateName + ' have been updated successfully' : updateAllInMetro ? 'All new homes in ' + ahjNewHome.value.metroArea + ' have been updated successfully': 'New Home updated successfully'
    appStore.showSnack('SUCCESS', successMessage)
    await getChangeLog()
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    let errorMessage = updateAllInState ? 'An error occurred when attempting to update all new homes in ' + ahjNewHome.value.stateName : updateAllInMetro ? 'An error occurred when attempting to update all new homes in ' + ahjNewHome.value.metroArea : 'Failed to update new home'
    appStore.showSnack('ERROR', errorMessage)
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

.new-home-card {
  margin-left: 12px;
  margin-right: 12px;
}

.form-btns {
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
