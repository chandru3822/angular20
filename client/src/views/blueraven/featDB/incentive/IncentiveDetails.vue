<!--suppress CssInvalidPseudoSelector -->
<template>
  <v-container id="incentive-details-container">
    <v-row>
      <v-col cols="12" class="pa-0">

        <v-row justify="space-between">
          <v-col class="text-left pa-0" cols="12">
            <v-card class="mx-4 square-card">
              <v-toolbar flat>
                <v-toolbar-title class="app-title"  v-if="incentive && incentive.name">
                  {{ incentive.name }}, {{ incentive.state }}
                </v-toolbar-title>
              </v-toolbar>
            </v-card>
          </v-col>
        </v-row>
        <v-row dense>
          <v-card class="mx-2 px-2 py-3 one-hunned square-card">
            <v-row no-gutters>
              <v-col class="form-btns" cols="12">
                <a-btn
                    variant="text"
                    color="primary"
                    class="text-capitalize"
                    @click="toggleMinimizeAll"
                    :text="expandedAll !== CollapseExpandEnum.COLLAPSED ? 'Minimize All' : 'Expand All'"
                ></a-btn>
                <a-btn
                    v-if="dataWasChanged"
                    @click="resetForm"
                    variant="text"
                    color="primary"
                    class="cancel-link"
                    html-style="margin-right: 10px"
                    text="Cancel"
                ></a-btn>
                <a-btn
                    id="save-btn"
                    v-if="userCanEdit"
                    color="primary"
                    class="mr-0"
                    @click="validateForm()"
                    text="Save"
                ></a-btn>
              </v-col>
            </v-row>
            <v-form ref="incentiveForm">
              <!-- UPPER SECTION -->
              <v-row class="mb-4 group-row" no-gutters>
                <TwoColumnMasonry v-if="dataReady"
                                  :custom-field-groups="customFieldGroups"
                                  :user-can-edit="userCanEdit"
                                  :expanded-all="expandedAll"
                                  :callback="(field) => updateDirtyValue(field)"
                                  @toggle-collapse-expand="toggleCollapseExpand($event)"
                ></TwoColumnMasonry>
              </v-row>
              <!-- LOWER SECTION -->
              <div v-if="dataReady">
                <h1 id="links" class="pb-2 mb-4 mx-3 lower-section albatross-header-2">Links and Contacts</h1>
                <v-row no-gutters>
                  <v-col cols="12" md="6" class="group px-2 py-2">
                    <!-- CONTACTS -->
                    <FeatDbContact title="Contacts"
                                   :user-can-edit="userCanEdit"
                                   :contactTypeId="13"
                                   :itemId="incentive.id"
                                   :itemType="itemType"
                                   :contacts="incentive.contacts"
                                   show-expanded
                                   :expanded-all="expandedAll"
                                   @toggle-collapse-expand="toggleCollapseExpand($event)"
                    ></FeatDbContact>
                  </v-col>
                  <v-col cols="12" md="6" class="group px-2 py-2">
                    <FeatDbLinks title="All Links"
                                 :user-can-edit="userCanEdit"
                                 :linkTypeId="14"
                                 :itemId="incentive.id"
                                 :itemType="itemType"
                                 :links="incentive.links"
                                 :isNested="false"
                                 show-expanded
                                 :expanded-all="expandedAll"
                                 @toggle-collapse-expand="toggleCollapseExpand($event)"></FeatDbLinks>
                  </v-col>
                </v-row>
              </div>
            </v-form>
          </v-card>
        </v-row>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import cloneDeep from "lodash.clonedeep"

import {getRequest, getRequestWithParams,  handleHidingGlobalLoader, putRequest} from "@/helpers/helpers"
import CustomValueInput from "@/views/flow/components/CustomValueInput.vue"
import {CollapseExpandEnum} from "@/views/blueraven/featDB/FeatDbConstants";
import TwoColumnMasonry from "@/views/blueraven/featDB/components/TwoColumnMasonry.vue";
import FeatDbContact from "@/views/blueraven/featDB/components/FeatDbContacts.vue";
import FeatDbLinks from "@/views/blueraven/featDB/components/FeatDbLinks.vue";
import FeatDbCustomFields from "@/views/blueraven/featDB/components/FeatDbCustomFieldGroup.vue";
import FeatDbCard from "@/views/blueraven/featDB/components/FeatDbCard.vue";
import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store


const userCanEdit = computed(()  => {
  return userStore.userHasFeatureAccessLevel("INCENTIVE", "EDIT")
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


const itemType = ref("incentive")
const dataWasChanged = ref(false)
const dataReady = ref(false)
const customFieldGroups = ref([])
const incentive = ref({})
const totalGroups = ref(2)
const expandedGroups = ref(2)
const incentiveForm = ref(null)

const incentiveId = computed(() => {
  return route.params.incentiveId
})

onMounted(async() => {
  await getIncentive()
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
const getIncentive = async()  => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/featDb/incentive/${incentiveId.value}`, "blueraven")
    incentive.value = cloneDeep(data)
    window.document.title = `Incentive - ${incentive.value.name}`
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error("*** ERROR ***", e)
    appStore.showSnack("ERROR", "Error retrieving Incentive")

    appStore.loading = false
  }
}
const validateForm = () => {
  //checks for required fields prior to opening the save dialog
  if (incentiveForm.value.validate()) {
    saveIncentive()
  } else {
    appStore.showSnack('ERROR', 'Missing Required Fields')

  }
}
const getCustomFieldGroupAssignmentsForScreen = async()  => {
  appStore.loading = true
  try {
    const params = {sourceId: incentive.value.id, objectTypeId: 31}
    const {
      data,
      status
    } = await getRequestWithParams(`/customFieldGroup/getCustomFieldGroupAssignmentsByObjectType`, {params}, "blueraven")
    customFieldGroups.value = cloneDeep(data)
    totalGroups.value = totalGroups.value + customFieldGroups.value.length;
    expandedGroups.value = totalGroups.value;
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error("*** ERROR ***", e)
    appStore.showSnack("ERROR", "Error retrieving custom fields")

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
const resetForm = async()  => {
  appStore.loading = true
  dataWasChanged.value = false
  dataReady.value = false
  getIncentive().then(() => {
    getCustomFieldGroupAssignmentsForScreen().then(() => dataReady.value = true)
  })
}
const saveIncentive = async()  => {
  appStore.loading = true

  try {
    incentive.value.customFieldGroups = customFieldGroups.value
    const {data, status} = await putRequest("/featDb/incentive", incentive.value, "blueraven")
    incentive.value = cloneDeep(data)
    dataWasChanged.value = false
    appStore.showSnack("SUCCESS", "Incentive saved")

    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error("*** ERROR ***", e)
    appStore.showSnack("ERROR", "Error saving Incentive")

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
#incentive-details-container {
  padding-right: 9px;
  padding-left: 9px;
  padding-top: 10px;
}

#back-btn {
  text-transform: unset;
  letter-spacing: unset;

  &:before {
    background-color: initial;
  }

  #back-btn-text:hover {
    text-decoration: underline;
  }
}

.page-title {
  font-size: 32px;
  font-weight: 200;
}

.page-info {
  font-family: 'Roboto Condensed', sans-serif;
  font-size: 20px;
  text-align: right;
}

#incentive-tab-bar {
  border-top: 1px solid #E6E6E6;
  border-bottom: 1px solid #E6E6E6;

  .v-tab:hover {
    color: var(--v-primary-base);
  }
}

.form-btns {
  display: flex;
  flex-flow: row nowrap;
  justify-content: flex-end;
  align-items: center;
  margin-bottom: 10px;
}

#save-btn {
  margin: 0 5px 0 0;
  text-transform: capitalize;
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

.cancel-link {
  font-size: 0.85em !important;
}

.cancel-link:hover {
  text-decoration: underline;
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

.custom-field {
  width: 48%;
}

.other-field {
  margin-top: -20px;
}

.group-row {
  justify-content: space-between;
}

.col-gap {
  width: 3em;
}

.lower-section {
  border-bottom: 1px solid #ccc;
  width: calc(100% - 20px);
}

.v-input--is-disabled ::v-deep .v-input__slot,
.v-input--is-disabled ::v-deep input {
  cursor: not-allowed;
  pointer-events: all;
}

.v-input--is-disabled ::v-deep label {
  color: rgba(0, 0, 0, 0.38) !important;
}
</style>
