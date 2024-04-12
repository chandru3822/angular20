<template>
  <div id="org-container">
    <!--    modal for leaving with unsaved fields -->
    <confirmation-dialog :open-dialog="unsavedFieldsModal" @close-dialog="unsavedFieldsModal = false"
                         @confirm="[navigationOverride = true, goToPath(toPath)]">
      You have unsaved fields. Are you sure you want to continue without saving?
      <template v-slot:no>Cancel</template>
      <template v-slot:yes>Don't Save</template>
    </confirmation-dialog>
    <!--    end unsaved fields modal -->
    <!--    modal for editing contact fields -->
    <confirmation-dialog :open-dialog="showEditModal" @close-dialog="showEditModal = false" @confirm="validateForm">
      <template v-slot:title>Organization Overview</template>
      <v-form ref="orgEditForm">
        <a-text-field
            v-model="tempOrg.orgName"
            :readonly="!userCanEdit"
            :disabled="!userCanEdit"
            label="Organization Name"
        ></a-text-field>
        <a-select v-model="tempOrg.orgTypeId"
                  :items="orgTypes"
                  label="Organization Type"
                  :rules="requiredRules"
                  :readonly="!userCanEdit"
                  :disabled="!userCanEdit"
                  item-title="orgType"
                  item-value="id"
                  @input="getAllOrgsByType(tempOrg.orgTypeId)"
        ></a-select>
        <a-autocomplete attach v-model="tempOrg.parentOrgId"
                        :items="parents"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        label="Parent Organization"
                        item-title="orgName"
                        item-value="id"
        ></a-autocomplete>
        <a-autocomplete attach v-model="tempOrg.companyStateId"
                        :items="states"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        label="State"
                        clearable
                        item-title="state"
                        item-value="id"
        ></a-autocomplete>
        <a-autocomplete v-model="tempOrg.companyTimezoneId"
                        :items="companyTimezones"
                        label="Time Zone"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        hide-details
                        clearable
                        item-title="timezone"
                        item-value="id"
                        attach
        ></a-autocomplete>
        <h6 class="mt-1 red-text" v-if="tempOrg.schedulable && !tempOrg.companyTimezoneId">* Required when
          Schedulable
          Organization</h6>
        <div class="mb-3 mt-3">
          <label>Active:</label>
          <input type="checkbox" :disabled="!userIsAdmin" :readonly="!userIsAdmin" class="ml-2"
                 v-model="tempOrg.activeFlag">
        </div>
        <div class="mb-3">
          <label>Show in Scheduling Tool:</label>
          <input type="checkbox" :disabled="!userCanEdit" :readonly="!userCanEdit" class="ml-2"
                 v-model="tempOrg.schedulable">
        </div>
        <div class="mb-3" v-if="userStore.isParent">
          <label>Make available in children:</label>
          <input type="checkbox" :readonly="!userCanEdit" :disabled="!userCanEdit"
                 class="ml-3" v-model="tempOrg.availableToChildren">
        </div>
      </v-form>
      <template v-slot:yes>save</template>
    </confirmation-dialog>
    <!--    end dialog -->
    <ThreeColumnLayout :header-text="org.orgName"
                       :auto-overflow-left="false">
      <template v-slot:back-btn>
        <a-btn
            icon
            variant="text"
            size="small"
            color="primary"
            class="mr-2"
            @click="goToPath('/orgs')"
            prepend-icon="mdi-view-list"
        ></a-btn>
      </template>
      <template v-slot:left-column>
        <div v-if="!projectStore.leftSideSplit && org && org.id"
             class="px-2 height-one-hunned overflow-y-auto">
          <PageOverview v-if="org && org.id"
                        page-name="Organization"
                        :show-edit-btn="userCanEdit"
                        @clickEdit="[tempOrg = cloneDeep(org), showEditModal = true]"
                        :details="overviewDetails"
                        @click-detail="goToPath(`/org/${org.parentOrgId}`, true)"
          ></PageOverview>
          <v-divider class="mt-4"></v-divider>
        </div>
      </template>
      <template v-slot:main-column>
        <div>
          <!-- this cannot be inside the v-if display or else the fixed toolbar doesn't work -->
          <v-toolbar flat color="secondary" class="cfg-name-header fixed-toolbar toolbar-z-index-override">
            <v-toolbar-title class="albatross-header-3">
              Organization Summary
            </v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
              <a-btn
                  variant="text"
                  color="primary"
                  @click="setSplitColumnValue()"
                  class="px-0"
                  :prepend-icon="!projectStore.manualColumnSplit ? 'mdi-format-columns' : 'mdi-format-align-justify'"
              ></a-btn>
              <div>
                <a-btn
                    color="primary"
                    class="mt-3"
                    v-if="userCanEdit"
                    :loading="fieldsLoading"
                    :disabled="fieldsSaving"
                    @click="saveOrg()"
                    text="Save Fields"
                ></a-btn>
              </div>
            </v-toolbar-items>
          </v-toolbar>
          <div v-if="org && org.id && !fieldsLoading" class="org-fields-container">
            <div class="px-4">
              <a-btn
                  @click="[showChildOrgs = !showChildOrgs, showUsersAssignedToOrg = false]"
                  :text="showChildOrgs ? 'Hide Child Organizations' : 'Show Child Organizations'"
                  color="primary"
                  small
              > </a-btn>
              <br/>
              <a-btn
                  @click="[showUsersAssignedToOrg = !showUsersAssignedToOrg, showChildOrgs = false]"
                  color="primary"
                  small
                  class="mt-3"
                  :text="showUsersAssignedToOrg ? 'Hide Assigned Users' : 'Show Assigned Users'"
              ></a-btn>
            </div>
            <v-toolbar color="transparent" class="elevation-0 cfg-name-toolbar px-4" dense
                       v-if="showUsersAssignedToOrg">
              <v-toolbar-title>
                Users Assigned to this Organization
              </v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
              </v-toolbar-items>
            </v-toolbar>
            <v-data-table
                v-if="showUsersAssignedToOrg"
                :headers="headers"
                :items="usersInOrg"
                :fixed-header="true"
                :items-per-page="-1"
                :mobile-breakpoint="0"
                hide-default-footer
                class="elevation-1  square-card mx-4"
            >
              <template #no-data>
                <span class="default-text-color">No users found</span>
              </template>

              <template #no-results>
                <span class="default-text-color">No users found</span>
              </template>

              <template #item="{ item:user }">
                <tr class="text-left" :class="{'shaded-row': usersInOrg.indexOf(user) % 2}">
                  <td class="text-left">{{ user.fullName }}</td>
                  <td class="text-left">{{ user.position }}</td>
                  <td class="text-right">
                    <a-btn
                        size="small"
                        variant="text"
                        class="anchor"
                        @click="goToPath(`/user/${user.id}/details`, true)"
                        color="unset"
                        prepend-icon="mdi-open-in-new"
                    ></a-btn>

                  </td>
                </tr>
              </template>

            </v-data-table>
            <v-toolbar color="transparent" class="elevation-0 cfg-name-toolbar px-4" dense v-if="showChildOrgs">
              <v-toolbar-title>
                Child Organizations
              </v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
              </v-toolbar-items>
            </v-toolbar>
            <v-data-table
                :headers="childHeaders"
                :items="org.childOrgs"
                :fixed-header="true"
                :items-per-page="-1"
                :mobile-breakpoint="0"
                hide-default-footer
                class="elevation-1 square-card mx-4"
                v-if="showChildOrgs"
            >
              <template #no-data>
                <span class="default-text-color">No child orgs found</span>
              </template>

              <template #no-results>
                <span class="default-text-color">No child orgs found</span>
              </template>

              <template #item="{ item }">
                <tr class="text-left" :class="{'shaded-row': org.childOrgs.indexOf(item) % 2}">
                  <td class="text-left">{{ item.orgName }}</td>
                  <td class="text-left">{{ item.orgType }}</td>
                  <td class="text-left">
                    <v-checkbox disabled readonly
                                v-model="item.activeFlag"/>
                  </td>
                  <td class="text-right">
                    <a-btn
                        size="small"
                        variant="text"
                        class="anchor"
                        @click="goToPath(`/org/${item.id}`, true)"
                        color="unset"
                        prepend-icon="mdi-open-in-new"
                    ></a-btn>

                  </td>
                </tr>
              </template>

            </v-data-table>

            <v-row class="px-5">
              <v-col cols="12" class="text-left py-0 px-0">
                <v-form ref="orgForm">
                  <v-col
                      class="pt-0"
                      v-for="(cfg, index) in customFieldGroups"
                      :key="index"
                  >
                    <v-toolbar color="transparent" class="elevation-0 cfg-name-toolbar" dense>
                      <v-toolbar-title>
                        {{ cfg.groupName }}
                      </v-toolbar-title>
                      <v-spacer></v-spacer>
                      <v-toolbar-items>
                      </v-toolbar-items>
                    </v-toolbar>

                    <v-card class="px-4 square-card" v-if="cfg.customFieldValues && cfg.customFieldValues.length > 0">
                      <v-row>
                        <v-col :cols="projectStore.manualColumnSplit ? 6 : 12" class="pb-0 pt-2">
                          <CustomValueInput v-for="(cf, idx) in getCustomFieldValuesToDisplay(cfg.customFieldValues, 1)"
                                            :key="idx"
                                            :required="cf.required"
                                            :readonly="getReadOnly(cf)"
                                            :callback="populateDirtyCfvs"
                                            :field="cf"
                                            :show-field-name="false"></CustomValueInput>
                        </v-col>
                        <v-col cols="6" v-if="projectStore.manualColumnSplit" class="pb-0 pt-2">
                          <CustomValueInput v-for="(cf, idx) in getCustomFieldValuesToDisplay(cfg.customFieldValues, 2)"
                                            :key="idx"
                                            :required="cf.required"
                                            :readonly="getReadOnly(cf)"
                                            :callback="populateDirtyCfvs"
                                            :field="cf"
                                            :show-field-name="false"></CustomValueInput>
                        </v-col>
                      </v-row>

                    </v-card>
                  </v-col>

                </v-form>
              </v-col>
            </v-row>
          </div>
          <div v-else>
            <SpinnerInline centered :size="50" color="primary"/>
          </div>
        </div>
      </template>
      <template v-slot:right-column>
        <ProjectActivity v-if="org && org.id"
                         :org-id="orgId"
                         :object-type-id="5"
                         :force-show-upload-btn="true"
                         :show-sms-tab="false"></ProjectActivity>
      </template>
    </ThreeColumnLayout>

  </div>
</template>

<script setup>

import {getCompanyStates} from '@/services/stateService'
import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
import {
  handleHidingGlobalLoader,
  getRequest,
  putRequest,
  postRequest,
  getRequestWithParams,
  logError
} from '@/helpers/helpers'
import {getOrgTypes, getOrgsByType} from '@/services/orgService'
import {getCustomFieldReadOnly} from '@/services/customFieldService'
import constants from "@/helpers/constants";
import ConfirmationDialog from "@/components/ConfirmationDialog";
import ThreeColumnLayout from '@/views/ThreeColumnLayout'
import SpinnerInline from '@/components/SpinnerInline'
import ProjectActivity from '@/views/flow/project/ProjectActivity'
import cloneDeep from 'lodash.clonedeep'
import Style from "@/views/blueraven/settings/proposalDesigner/panel/Style";
import PageOverview from "../PageOverview";
import { useProjectStore } from '@/stores/ProjectStore.js'

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'
import { onBeforeRouteLeave } from 'vue-router/composables'

const appStore = useAppStore()
const projectStore = useProjectStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const org = ref({})
const tempOrg = ref({})
const showEditModal = ref(false)
const customFieldGroups = ref([])
const usersInOrg = ref([])
const headers = ref([
  {text: 'User', value: 'user', show: true},
  {text: 'Position', value: 'position', show: true},
  {text: null, value: 'icons', show: true, sortable: false}
])
const childHeaders = ref([
  {text: 'Organization', value: 'orgName', show: true},
  {text: 'Type', value: 'orgType', show: true},
  {text: 'Active?', value: 'activeFlag', show: true},
  {text: null, value: 'icons', show: true, sortable: false}
])
const orgTypes = ref([])
const unsavedFieldsModal = ref(false)
const toPath = ref(null)
const navigationOverride = ref(false)
const requiredRules = ref(constants.BASIC_REQUIRED_RULE)
const parents = ref([])
const dirtySystemFields = ref(false)
const dirtyCfvs = ref([])
const companyTimezones = ref([])
const states = ref([])
const fieldsSaving = ref(false)
const orgEditForm = ref(null)
const orgForm = ref(null)
const showChildOrgs = ref(false)
const showUsersAssignedToOrg = ref(false)
const fieldsLoading = ref(true)

const orgId = computed(() => {
  return parseInt(route.params.id)
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('ORGS', 'EDIT')
})
const userIsAdmin = computed(() => {
  return userStore.userHasFeatureAccessLevel('ORGS', 'ADMIN')
})
const companyId = computed(() => {
  return userStore.details.companyId
})
const overviewDetails = computed(() => {
  if (org.value) {
    return [
      {
        label: 'Status',
        type: constants.OVERVIEW_FIELD_TYPES.STATUS,
        value: org.value.activeFlag ? 'Active' : 'Inactive',
        active: org.value.activeFlag
      },
      {
        label: 'Type',
        type: constants.OVERVIEW_FIELD_TYPES.DEFAULT,
        value: org.value.orgType
      },
      {
        label: 'Parent',
        type: constants.OVERVIEW_FIELD_TYPES.DEFAULT,
        value: org.value.parentOrgName,
        clickable: true
      },
      {
        label: 'State',
        type: constants.OVERVIEW_FIELD_TYPES.DEFAULT,
        value: org.value.state
      },
      {
        label: 'Timezone',
        type: constants.OVERVIEW_FIELD_TYPES.DEFAULT,
        value: org.value.timezone
      },
      {
        label: 'Show in Scheduling Tool',
        type: constants.OVERVIEW_FIELD_TYPES.DEFAULT,
        value: org.value.schedulable ? 'Yes' : 'No'
      }
    ];
  }
  return []
})

onMounted(async () => {
  let requests = [
    getCustomFieldGroups(),
    getCompanyTimezones(),
    getAllOrgTypes(),
    getOrg(),
    getAllCompanyStates(),
    getUsersInOrg()
  ]
  await Promise.all(requests).then(async () => {
    fieldsLoading.value = false
    if (org.value.parentOrgTypeId) {
      getOrgsByType(org.value.parentOrgTypeId)
    }
  })
})
onBeforeRouteLeave(async (to, from, next) => {
  // called when the route that renders this component is about to
  // be navigated away from.
  // has access to `this` component instance.
  if (navigationOverride.value || (dirtyCfvs.value.length === 0 && !dirtySystemFields.value)) {
    //navigationOverride gets set to true if they click "Yes" to continue. if you don't override then it just hits the else again before navigating
    to.params.useSavedFilters = "true"
    console.log('randalogger',to.params.useSavedFilters)
    next()
  } else {
    toPath.value = to.path
    unsavedFieldsModal.value = true
  }
})

const setSplitColumnValue = () => {
  //flip the flag
  projectStore.manualColumnSplit != projectStore.manualColumnSplit
}
const getCustomFieldValuesToDisplay = (values, columnNum) => {
  if (projectStore.manualColumnSplit) {
    return values.filter(function (element, index, values) {
      return (index % 2 === (columnNum === 1 ? 0 : 1));
    });
  } else {
    return values
  }
}
const goToPath = (path, targetBlank) => {
  if (targetBlank) {
    let routerData = router.resolve({path})
    window.open(routerData.href, '_blank')
  } else {
    router.push(path)
  }
}
const validateForm = async() => {
  if (orgEditForm.value.validate()) {
    await saveOrgSystemFields()
    showEditModal.value = false
  }
}
const saveOrgSystemFields = async() => {
  appStore.loading = true
  try {
    const {data, status} = await putRequest(`/org`, tempOrg.value)
    org.value = data
    showEditModal.value = false
    snackbar('SUCCESS', 'Organization Updated')

    handleHidingGlobalLoader( status)
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error Saving Fields')

    appStore.loading = false
  }
}
const saveOrg = async() => {
  if (orgForm.value.validate()) {
    fieldsSaving.value = true
    appStore.loading = true
    // org.value.customFieldGroups = customFieldGroups.value
    try {
      // update dirty field values
      const {data} = await postRequest(`/customFieldValues/org/${orgId.value}`, dirtyCfvs.value)
      dirtyCfvs.value = []
      customFieldGroups.value = data
      snackbar('SUCCESS', 'Organization Saved')

      fieldsSaving.value = false
      handleHidingGlobalLoader( status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      let msg = org.value.id ? 'Error Saving Organization' : 'Error Adding Organization'
      snackbar('ERROR', msg)

      fieldsSaving.value = false
      appStore.loading = false
    }
  } else {
    snackbar('ERROR', 'Missing Required Fields')

  }
}
const populateDirtyCfvs = (field) => {
  let match = dirtyCfvs.value.find(f => (null !== f.id && f.id === field.id) || f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId)
  if (!match) {
    dirtyCfvs.value.push(field)
  }
}
const getCustomFieldGroups = async() => {
  appStore.loading = true
  try {
    const {data, status} = await getRequestWithParams(`/customFieldValues/org/${orgId.value}`)
    customFieldGroups.value = data
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Custom Fields')

    appStore.loading = false
  }
}
const getCompanyTimezones = async() => {
  appStore.loading = true
  try {
    const {data, status} = await getRequestWithParams(`/timezone`)
    companyTimezones.value = data
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Timezones')

    appStore.loading = false
  }
}
const getOrg = async() => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/org/${orgId.value}`)
    org.value = data

    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Organization')

    appStore.loading = false
  }
}
const getAllOrgTypes = async() => {
  appStore.loading = true
  try {
    const {data, status} = await getOrgTypes()
    orgTypes.value = data
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Org Types')

    appStore.loading = false
  }
}
const getAllOrgsByType = async(orgTypeId) => {
  try {
    const {data, status} = await getOrgsByType(orgTypeId)
    parents.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Parent Orgs')

    appStore.loading = false
  }
}
const getUsersInOrg = async() => {
  try {
    const {data, status} = await getRequest(`/org/${orgId.value}/users`)
    usersInOrg.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Users In Org')

  }
}
const getAllCompanyStates = async() => {
  appStore.loading = true
  try {
    const {data, status} = await getCompanyStates()
    states.value = data
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving States')

    appStore.loading = false
  }
}
const getReadOnly = (field) => {
  return getCustomFieldReadOnly(field) || !userCanEdit.value
}

</script>

<style lang="scss">
.cfg-name-toolbar .v-toolbar__content {
  padding-left: 0 !important;
  padding-right: 0 !important;
}

.cfg-name-toolbar .v-toolbar__title {
  font-size: 14px;
}

.cfg-detail-header .v-toolbar__content {
  padding-left: 0 !important;
  padding-right: 0 !important;
}

.cfg-detail-header .v-toolbar__title {
  font-size: 16px;
}
</style>

<style lang="scss" scoped>
#org-container {
  width: 100vw;
  height: 100%;
  max-height: 100% !important;
  padding: 0 !important;
  overflow: hidden;
}

#three-column-container {
  div.org-fields-container {
    overflow: auto ;
    overflow-x: hidden;
    height: calc(100vh - 200px);
    padding-bottom: 0;
  }
}
.cfg-detail-header {
  background-color: var(--v-secondary-base) !important;
  margin-left: -10px;
  margin-right: -10px;
  padding-left: 10px;
  padding-right: 10px;
}

.org-header {
  background-color: white;
}

.org-title {
  font-size: 30px;
}

.org-subtitle {
  font-size: 20px;
}

.v-select ::v-deep .v-select__selection {
  color: var(--v-primaryText-base);
}

.detail-label {
  font-size: 12px;
  color: var(--v-grey-darken1);
}

.detail-item {
  font-size: 0.875rem;
  margin-left: 5px;
  overflow-wrap: break-word;
}

</style>

