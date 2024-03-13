<template>
  <div id="project-container">
    <!--    modal for editing project fields -->
    <ConfirmationDialog :open-dialog="showEditProjectModal"
                        @confirm="validateForm"
                        @close-dialog="showEditProjectModal = false">
      <template v-slot:title>Project Overview</template>
      <v-form ref="projectEditForm">
        <div>
          <div class="error-text" v-if="checkAddress">
            Please enter a valid project address.
          </div>
          <div class="error-text" v-else-if="!stateIsActive()">
            Project address is in a non-active state. Please update project address to an active state.
          </div>
          <v-text-field
              v-model="tempProject.projectName"
              :readonly="!userCanEdit"
              :disabled="!userCanEdit"
              label="Project Name"
          />
          <v-text-field
              v-model="tempProject.street1"
              label="Street"
              :readonly="!userCanEdit"
              :disabled="!userCanEdit"
              counter
              maxlength="100"
              @change="tempProject.reloadCoordinates = true"
          />
          <v-text-field
              v-model="tempProject.city"
              label="City"
              :readonly="!userCanEdit"
              :disabled="!userCanEdit"
              @change="tempProject.reloadCoordinates = true"
          />
          <v-text-field
              type="text"
              v-model="tempProject.postalCode"
              counter
              :readonly="!userCanEdit"
              :disabled="!userCanEdit"
              maxlength="10"
              @keyup="isNumberOrHyphen"
              :rules="postalCodeRules"
              @change="tempProject.reloadCoordinates = true"
              label="Postal Code"
          />
          <div v-if="tempProject.companyStateId && !stateIsActive() && !editState">
            <v-text-field
                type="text"
                v-model="tempProject.state"
                :readonly="true"
                :disabled="true"
                label="State"
                hide-details
            />
            <a class="edit-state-link" @click="editState = true">Click here to edit state</a>
          </div>
          <v-autocomplete v-else
                          v-model="tempProject.companyStateId"
                          :items="states"
                          label="State"
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
                          :loading="statesLoading"
                          item-text="state"
                          item-value="id"
                          @input="tempProject.reloadCoordinates = true"
          />
          <v-select v-model="tempProject.companyCountryId"
                    :items="countries"
                    label="Country"
                    :readonly="!userCanEdit"
                    :disabled="!userCanEdit"
                    :loading="countriesLoading"
                    @input="tempProject.reloadCoordinates = true"
                    item-text="country"
                    item-value="id"
          />
        </div>
        <v-autocomplete v-model="tempProject.owner"
                        :readonly="projectOwnerFieldIsReadOnly()"
                        :disabled="projectOwnerFieldIsReadOnly()"
                        :items="availableOwners"
                        :loading="ownersLoading"
                        label="Project Owner"
                        clearable
                        item-text="fullName"
                        return-object
                        autocomplete="off"/>
        <v-autocomplete v-model="tempProject.companyProjectStatusTypeId"
                        :items="statuses"
                        :readonly="projectStatusIsReadOnly()"
                        :disabled="projectStatusIsReadOnly()"
                        :loading="statusesLoading"
                        label="Project Stage"
                        item-text="projectStatusType"
                        item-value="id"
        />
      </v-form>
      <template v-slot:yes>Save</template>
    </ConfirmationDialog>
    <!--    end dialog -->
    <ThreeColumnLayoutMobile v-if="isMobile"
                             :menu-items="[
                                 pageOverviewMenuItem,
                                 {pageName:'Details', subMenuSlot: true},
                                 {pageName:'Active Process Steps', subMenuSlot: true, updateKey:updatePpsKey, customPath:`/project/${ route.params.projectId }/activeprocessSteps`},
                                 {pageName:'Active Events', subMenuSlot:true, updateKey:updateEventKey, customPath: `/project/${ route.params.projectId }/activeevents`},
                                 {pageName: 'Documents', customPath: `/project/${ route.params.projectId }/projectactivity/2`},
                                 {pageName: 'Notes and Activities', customPath: `/project/${ route.params.projectId }/projectactivity/1`},
                                 {pageName: 'Communication', customPath: `/project/${ route.params.projectId }/projectactivity/0`},
                                 {pageName: 'Admin', customPath: `/projectAdmin/${projectId}/processSteps`}
                                 ]"
                             :headerHeight="project.tags?.length > 0 ? '86px' : '76px'"
                             :view-change-callback="changeMobileView"
                             :subMenuSelectedView="selectedTab"
    >
      <template v-slot:subMenu_1>
        <ProjectTabs :project="project" hideAdminBtn :tab-change-callback="changeTabs" class="mx-2"></ProjectTabs>
      </template>
      <template v-slot:subMenu_2>
        <ActiveProcessSteps :project="project" :update-key="updatePpsKey" class="mx-2"></ActiveProcessSteps>
      </template>
      <template v-slot:subMenu_3>
        <ActiveEvents v-if="userHasEventsFeature"
                      :update-key="updateEventKey"
                      :projectId="projectId"
                      class="mx-2"/>
      </template>
      <template v-slot:header-contents>
        <v-toolbar-title class="title-medium text-wrap">
          <div>
            <router-link :to="`/project/${project.id}/status`" class="no-text-decoration">{{ project.projectName }}</router-link>
            <span v-if="projectStore && projectStore.pps && projectStore.pps.processStepName">
            <v-icon class="mx-4" size="20">mdi-chevron-right</v-icon>
            <router-link class="breadcrumb albatross-body-2 no-text-decoration"
                         :to="`/project/${project.id}/processStep/${projectStore.pps.projectProcessStepId}`">
              {{ projectStore.pps.processStepName }}
            </router-link>
          </span>
            <span v-if="projectStore && projectStore.ppsEvent && projectStore.ppsEvent.eventName">
            <v-icon class="mx-4" size="20">mdi-chevron-right</v-icon>
            <router-link class="breadcrumb albatross-body-2 no-text-decoration"
                         :to="`/project/${project.id}/processStep/${projectStore.pps.projectProcessStepId}/event/${projectStore.ppsEvent.id}`">
              {{ projectStore.ppsEvent.eventName }} Event
            </router-link>
          </span>
          </div>
          <div class="mt-2">
            <v-chip v-for="(tag, idx) in project.tags"
                    small
                    class="tag-chip"
                    :color="tag.bgColor"
                    :text-color="tag.fontColor"
                    :close="tag.removable"
                    :class="{'ml-2': idx !== 0}">
              {{ tag.tagName }}
            </v-chip>
          </div>
        </v-toolbar-title>
      </template>
      <template v-slot:main-column>
        <router-view @refresh-upcoming-events="updateEventKey++"
                     @refresh-upcoming-pps="updatePpsKey++"
                     @refresh-project-status="getUpdatedProjectStatus()"
                     ref="childComponent"
                     :project-tab="selectedTab"
                     v-if="project && project.id" class="router-view"
                     :project="project"
                     :milestones="milestones"
                     page-name="Project"
                     :isExpandable="false"
                     :show-edit-btn="(userStore.userHasFeatureAccessLevel('PROJECTS', 'EDIT') && userCanEdit)"
                     @clickEdit="showEditModal()"
                     :details="overviewDetails"
                     :updateKey="updateKeyProp"
                     :mobileView="true"

        />
      </template>
      <template v-slot:right-column>
        <ProjectActivity v-if="!projectLoading && (projectId !== 0 || userId !== 0)" :show-sms-tab="true"></ProjectActivity>
      </template>
    </ThreeColumnLayoutMobile>
    <ThreeColumnLayout v-else :headerLarge="project.tags?.length > 0">
      <template v-slot:header>

        <v-toolbar-title class="title-large albatross-header-1 align-center "
        >
          <div>
            <router-link :to="`/project/${project.id}/status`">{{ project.projectName }}</router-link>
            <span v-if="projectStore && projectStore.pps && projectStore.pps.processStepName">
            <v-icon class="mx-4" size="20">mdi-chevron-right</v-icon>
            <router-link class="breadcrumb albatross-body-2"
                         :to="`/project/${project.id}/processStep/${projectStore.pps.projectProcessStepId}`">
              {{ projectStore.pps.processStepName }}
            </router-link>
          </span>
            <span v-if="projectStore && projectStore.ppsEvent && projectStore.ppsEvent.eventName">
            <v-icon class="mx-4" size="20">mdi-chevron-right</v-icon>
            <router-link class="breadcrumb albatross-body-2"
                         :to="`/project/${project.id}/processStep/${projectStore.pps.projectProcessStepId}/event/${projectStore.ppsEvent.id}`">
              {{ projectStore.ppsEvent.eventName }} Event
            </router-link>
          </span>
            <span v-if="projectStore && selectedTab && $route.name === 'projectDetails'" class="breadcrumb albatross-body-2 primary--text">
            <v-icon class="mx-4" size="20">mdi-chevron-right</v-icon>
              {{ selectedTab.tabName}}
          </span>
          </div>
          <div class="mt-2">
            <v-chip v-for="(tag, idx) in project.tags"
                    small
                    class="tag-chip"
                    :color="tag.bgColor"
                    :text-color="tag.fontColor"
                    :close="tag.removable"
                    :class="{'ml-2': idx !== 0}">
              {{ tag.tagName }}
            </v-chip>
          </div>
        </v-toolbar-title>
        <v-spacer/>
        <div v-if="milestones && milestones.length > 0" class = "milestone-container toolbar-z-index-override">
          <div class="milestone-item" v-for="(milestone, idx) in milestones">
            <v-menu v-model="milestone.menuOpen"
                    offset-y
                    rounded="0"
                    :close-on-content-click="false"
                    min-width="290px">
              <template v-slot:activator="{ on }">
                <StatusTrackerIcon :on="on"
                                   :clickable="true"
                                   :milestone="milestone"
                                   :current-status-id="project.companyProjectStatusTypeId"
                ></StatusTrackerIcon>
              </template>
              <v-card class="pa-5 square-card milestone-card">
                <div class="label-large">
                  <StatusTrackerIcon :clickable="false"
                                     :milestone="milestone"
                                     :current-status-id="project.companyProjectStatusTypeId"
                  ></StatusTrackerIcon>
                  <span class="ml-2 label-large active-status">{{milestone.projectStatusType}}</span>

                </div>
                <div>
                  <div v-for="field in milestone.assignedFields">
                    <StatusTrackerItem :field="field" :cancelled="project.projectStatusType == 'Cancelled'"
                    ></StatusTrackerItem>
                  </div>
                </div>
                <div class="text-right">
                  <AlbatrossButton
                      variant="text"
                      color="primary"
                      class="body-medium milestone-button"
                      @click="milestone.menuOpen = false"
                      text="Done"
                  ></AlbatrossButton>
                </div>
              </v-card>
            </v-menu>
          </div>
        </div>
      </template>
      <template v-slot:left-column>
        <div v-if="project && project.id">
          <PageOverview
              page-name="Project"
              :show-edit-btn="(userStore.userHasFeatureAccessLevel('PROJECTS', 'EDIT') && userCanEdit)"
              @clickEdit="showEditModal()"
              :details="overviewDetails"
          />
          <v-divider/>
          <ProjectTabs :project="project" :tab-change-callback="changeTabs" class="mx-2"></ProjectTabs>
          <v-divider/>
          <ActiveProcessSteps :project="project" :update-key="updatePpsKey" class="mx-2"></ActiveProcessSteps>
          <v-divider/>
          <ActiveEvents v-if="userHasEventsFeature"
                        :update-key="updateEventKey"
                        :projectId="projectId"
                        class="mx-2"/>
          <v-divider class="mb-3"/>
        </div>
      </template>
      <template v-slot:main-column>
        <router-view @refresh-upcoming-events="updateEventKey++"
                     @refresh-upcoming-pps="updatePpsKey++"
                     @refresh-project-status="getUpdatedProjectStatus()"
                     ref="childComponent"
                     :project-tab="selectedTab"
                     v-if="project && project.id" class="router-view"
                     :project="project"
                     :milestones="milestones"
        />
      </template>
      <template v-slot:right-column>
        <ProjectActivity v-if="!projectLoading && (projectId !== 0 || userId !== 0)" :show-sms-tab="true"></ProjectActivity>
      </template>
    </ThreeColumnLayout>
  </div>
</template>

<script setup>
import {
  formatPhoneNumber,
  getRequest,
  getRequestWithParams,

  handleHidingGlobalLoader,
  isNumberOrHyphen,
  logError,
  postRequest,
  putRequest
} from '@/helpers/helpers'
import cloneDeep from 'lodash.clonedeep'

import ProjectActivity from '@/views/flow/project/ProjectActivity'
import ProjectTabs from '@/views/flow/project/ProjectTabs'
import ActiveProcessSteps from '@/views/flow/project/ActiveProcessSteps'
import ActiveEvents from '@/views/flow/project/ActiveEvents'
import {
  getCompanyProjectStatusTypes,
  getStatusColorClass
} from "@/services/projectStatusTypeService"
import constants from "@/helpers/constants";
import {getActiveStates} from "@/services/stateService";
import {getCountries} from "@/services/countryService";
import ConfirmationDialog from "@/components/ConfirmationDialog";
import PageOverview from "../PageOverview";
import StatusTrackerIcon from "@/views/flow/project/StatusTrackerIcon";
import StatusTrackerItem from "@/views/flow/project/StatusTrackerItem";
import ThreeColumnLayout from '@/views/ThreeColumnLayout'
import ThreeColumnLayoutMobile from '@/views/ThreeColumnLayoutMobile'
import { useProjectStore } from '@/stores/ProjectStorePinia.js'
import { useNotificationStore } from '@/stores/NotificationStorePinia.js'
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue"
import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter, onBeforeRouteLeave} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const notificationStore = useNotificationStore()
const projectStore = useProjectStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar
const vuetify = vueInstance.$vuetify

const editState = ref(false)
const tempProject = ref({})
const updateEventKey = ref(0)
const updatePpsKey = ref(0)
const project = ref({})
const statusesLoading = ref(true)
const projectStatusLoading = ref(false)
const ownersLoading = ref(true)
const statesLoading = ref(true)
const countriesLoading = ref(true)
const showEditProjectModal = ref(false)
const checkAddress = ref(route.query?.checkAddress === 'true')
const statuses = ref([])
const availableOwners = ref([])
const postalCodeRules = ref(constants.POSTAL_CODE_RULES)
const states = ref([])
const countries = ref([])
const selectedTab = ref({})
const milestones = ref([])
const projectLoading = ref(true)
const pageOverviewMenuItem = ref({})
const updateKeyProp = ref(0)
const projectEditForm = ref(null)

onMounted(() => {
  //have to reset this on creation in case there is already a state then they go to the project url directly
  projectStore.resetProjectState()
  loadProject();
  pageOverviewMenuItem.value = {
    archived: false,
    customPath: `/project/${ projectId.value }/projectOverview`,
    tabName: 'Overview',
    pageName: 'Overview',
    isExpandable: false,
    details: overviewDetails.value,
    uniqueIdentifier: 'menu_item_project_overview'
  }
})

onBeforeRouteLeave(async (to, from, next) => {
  to.params.useSavedFilters = "true"
})

const projectId = computed(() => {
  return parseInt(route.params.projectId)
})
const processStepId = computed(() => {
  return route.params.processStepId
})
const ppsEventId = computed(() => {
  return route.params.ppsEventId
})

const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('PROJECTS', 'EDIT')
})
const is7oaksAdmin = computed(() => {
  return userStore.isSystemAdmin
})
const userHasEventsFeature = computed(() => {
  return userStore.userHasFeature('EVENTS')
})
const projectTagEvents = computed(() => {
  return notificationStore.getEventsByTopic('project_tag')?.filter(e => e.projectId === projectId.value)
})
const projectStage = computed(() => {
  return statuses.value?.find(s => s.id === project.value.companyProjectStatusTypeId)?.rootProjectStatusType
})
const overviewDetails = computed(() => {
  return [
    {
      label: 'Project Stage',
      type: constants.OVERVIEW_FIELD_TYPES.STATUS,
      value: project.value.projectStatusType,
      statusType: project.value.rootProjectStatusType,
      statusTypeId: project.value.projectStatusTypeId,
    },
    {
      label: 'Project id',
      type: constants.OVERVIEW_FIELD_TYPES.ID,
      value: project.value.id
    },
    {
      label: 'Address',
      type: constants.OVERVIEW_FIELD_TYPES.ADDRESS,
      value: {
        street: project.value.street1,
        city: project.value.city,
        state: project.value.stateAbbreviation,
        zip: project.value.postalCode
      }
    },
    {
      label: 'Phone number',
      type: constants.OVERVIEW_FIELD_TYPES.PHONE,
      value: project.value.phone,
    },
    {
      label: 'Mobile number',
      type: constants.OVERVIEW_FIELD_TYPES.MOBILE_PHONE,
      value: project.value.mobile
    },
    {
      label: 'Email address',
      type: constants.OVERVIEW_FIELD_TYPES.EMAIL,
      value: project.value.email
    },
    {
      type: constants.OVERVIEW_FIELD_TYPES.BUTTON,
      value: project.value.contactId
    },
    {
      label: 'Owner',
      type: constants.OVERVIEW_FIELD_TYPES.OWNER,
      value: project.value.owner
    }
  ]
})
const isMobile = computed(() => {
  return vuetify.breakpoint.smAndDown
})

watch(processStepId, async() => {
  projectStore.resetProjectState()
})
watch(ppsEventId, async() => {
  projectStore.resetPpsEventState()
})

watch(projectTagEvents, async() => {
  if (projectTagEvents.value?.length > 0) {
    await notificationStore.processProjectMsg(projectId.value)
    await getProjectTags()
  }
})

const loadProject = async()=> {
  await getProject()
  await getMilestones()
}
const changeTabs = (selectedTab, buttonClicked)  => {
  selectedTab.value = selectedTab
  if (buttonClicked && route.name !== 'projectDetails') {
    router.push({name: 'projectDetails', projectId: projectId.value})
  }
}
const changeMobileView = (selectedView) => {
  updateKeyProp.value = selectedView.updateKey | 0
  router.push(selectedView.customPath)
}
const stateIsActive = ()  => {
  //states is already a list of company states
  let companyStateIds = states.value.map(s => s.id)
  return companyStateIds.includes(tempProject.value.companyStateId)
}
const showEditModal = async() => {
  //doing all this in a method so we can call it when the page loads if needed
  let requests = [
    getStatesAndCountries(),
    getOwners(),
    getStatuses()
  ]
  await Promise.all(requests)
  tempProject.value = cloneDeep(project.value)
  showEditProjectModal.value = true
}
const getProject = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/project/${projectId.value}`)
    project.value = data

    window.document.title = `${project.value.projectName} - Project Details`
    if (checkAddress.value) {
      showEditModal()
    }
    projectLoading.value = false
    handleHidingGlobalLoader( status)
  } catch (e) {
    projectLoading.value = false
    appStore.loading = false
    logError(e)
  }
}
const getMilestones = async() => {
  try {
    const {data, status} = await getRequest(`/project/${projectId.value}/statusFields`)
    milestones.value = data
    let statusCompleted = false;
    for(let x = milestones.value.length - 1; x >= 0; x--){
      if(project.value.projectStatusType == 'Cancelled'){
        milestones.value[x].btnColor = 'grey'
        milestones.value[x].iconColor = 'grey'
        continue;
      }
      if(statusCompleted || (milestones.value[x].assignedFields.length > 0 && milestones.value[x].assignedFields.every(f => f.fieldValue))) {
        milestones.value[x].btnColor = 'success lighten-1'
        milestones.value[x].iconColor = 'white'
      } else {
        milestones.value[x].btnColor = 'grey'
        milestones.value[x].iconColor = 'grey'
      }

      if(project.value.projectStatusType == milestones.value[x].projectStatusType){
        statusCompleted = true;
      }
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Status Tracker Details')

  }
}
const getProjectTags = async () => {
  try {
    const {data, status} = await getRequestWithParams(`/tag/project/${projectId.value}`,
        {skipCancel: true}, null, [])
    project.value.tags = data
  } catch (e) {
    logError(e)
  }
}
const getUpdatedProjectStatus = async () => {
  //this gets called if an event gets run, in case it updated the project status
  projectStatusLoading.value = true
  try {
    const {data, status} = await getRequest(`/project/${projectId.value}/status`)
    if (data) {
      project.value.companyProjectStatusTypeId = data.companyProjectStatusTypeId
      project.value.projectStatusType = data.projectStatusType
      project.value.projectStatusTypeId = data.projectStatusTypeId
      project.value.rootProjectStatusType = data.rootProjectStatusType
    }
    projectStatusLoading.value = false
  } catch (e) {
    projectStatusLoading.value = false
    appStore.loading = false
    logError(e)
  }
}
const getStatuses = async () => {
  try {
    statusesLoading.value = true
    const {data} = await getCompanyProjectStatusTypes(projectId.value, true)
    statuses.value = data
    statusesLoading.value = false
  } catch (e) {
    statusesLoading.value = false
    snackbar('ERROR', 'Error fetching project statuses')

  }
}
const projectStatusIsReadOnly = () => {
  if (is7oaksAdmin.value) {
    return false
  } else {
    return project.value.statusReadOnly
  }
}
const projectOwnerFieldIsReadOnly = () => {
  if (is7oaksAdmin.value) {
    return false
  } else {
    return project.value.ownerReadOnly
  }
}
const updateStatus = async () => {
  try {
    appStore.loading = true
    let params = {
      companyProjectStatusTypeId: tempProject.value.companyProjectStatusTypeId
    }
    const {data, status} = await postRequest(`/project/${projectId.value}/status`, params)
    tempProject.value.companyProjectStatusTypeId = data.companyProjectStatusTypeId
    tempProject.value.projectStatusType = data.projectStatusType
    tempProject.value.projectStatusTypeId = data.projectStatusTypeId
    tempProject.value.rootProjectStatusType = data.rootProjectStatusType
    handleHidingGlobalLoader( status)
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error updating project status')

    appStore.loading = false
  }
}
const updateOwner = async () => {
  appStore.loading = true
  try {
    //we use tempProject to save values in case they cancel then it repopulates at the end
    const {status} = await putRequest(`/project/${projectId.value}/owner`, tempProject.value.owner || {userPositionId: null})
    handleHidingGlobalLoader( status)
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error Saving Owner')

    appStore.loading = false
  }
}
const getStatesAndCountries = () => {
  // only load countries and states if they try to edit the project address and they haven't already been loaded
  if (states.value.length === 0 || countries.value.length === 0) {
    getCompanyStates()
    getAllCountries()
  }
}
const getCompanyStates = async () => {
  try {
    statesLoading.value = true
    const {data, status} = await getActiveStates()
    states.value = data
    statesLoading.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving States')

    statesLoading.value = false
  }
}
const getAllCountries = async () => {
  try {
    countriesLoading.value = true
    const {data, status} = await getCountries()
    countries.value = data
    countriesLoading.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Countries')

    countriesLoading.value = false
  }
}
const validateForm = async() => {
  if (projectEditForm.value.validate()) {
    //these could be combined - just dont have time atm
    saveProjectAddressFields()
    updateOwner()
    //have to wait for this one to complete or it doesn't have the right values to display fresh ones
    await updateStatus()
    //set project values if they hit save, have to update state stuff differently cuz there are multiple values needed
    let selectedState = states.value.find(s => s.id === tempProject.value.companyStateId)
    tempProject.value.state = selectedState?.state || null
    tempProject.value.stateAbbreviation = selectedState?.abbreviation || null
    //if they entered a valid address then stop asking for it
    if (tempProject.value.companyStateId && stateIsActive()) {
      router.replace({'query': null})
      checkAddress.value = false
    }
    project.value = cloneDeep(tempProject.value)
    showEditProjectModal.value = false
  }
}
const saveProjectAddressFields = async () => {
  appStore.loading = true
  try {
    //temp project holds all the changes in case they cancel. use those values
    const {status} = await putRequest(`/project`, tempProject.value)
    snackbar('SUCCESS', 'Project Updated')

    handleHidingGlobalLoader( status)
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error Saving Address')

    appStore.loading = false
  }
}
const getOwners = async () => {
  try {
    ownersLoading.value = true
    const {data, status} = await getRequest(`/project/owners`)
    availableOwners.value = data
    ownersLoading.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    ownersLoading.value = false
    snackbar('ERROR', 'Error Retrieving Available Owners')

  }
}
</script>

<style lang="scss">
.match-lower-width .v-toolbar__content {
  padding: 4px 8px 4px 0px;
}

#tag-toolbar {
  height: 35px !important;

  .v-toolbar__content {
    align-items: start;
    height: 35px !important;
  }
}

.project-section-header .v-toolbar__content {
  padding-left: 0 !important;
  padding-right: 0 !important;
}

.title-large, .breadcrumb {
  a {
    text-decoration-line: none;
  }
}
</style>

<style lang="scss" scoped>
.active-status {
  color: #000000;
}

#project-container {
  width: 100%;
  height: 100%;
  max-height: 100% !important;
  padding: 0 !important;
  overflow: hidden;
}

.project-detail-label {
  font-size: 12px;
  color: #9E9C9C;
}

.project-detail-item {
  font-size: 0.875rem;
  margin-left: 5px;
  overflow-wrap: break-word;
}

.project-header {
  height: 64px;
}

.project-header-with-tags {
  height: 94px !important;
}

.project-split-container {
  max-width: 100%;
  width: 100%;
  margin-right: 0 !important;
  margin-left: 0 !important;
}

.split-container-no-tags {
  height: calc(100% - 50px);
}

.split-container-with-tags {
  height: calc(100% - 80px);
}

.overflow-y-auto {
  overflow: auto;
}

.project-section {
  max-height: 100%;
  padding-top: 16px;
}

.left-panel-scrollable-area {
  height: calc(100% - 30px);
}

.project-section.left-panel,
.project-section.center-panel {
  //box-shadow: 1px 0px 1px #C4C4C4;
  //the way the center and right panels sit on each other the box shadow just wasn't working - going to try this border and see if they care
  border-right: solid #C4C4C4 1px;
}

.white-bg {
  background-color: #fff !important;
}

.collapse-left {
  width: 72px;
  padding: 12px;
}

//.left-expander-button {
//  margin-left: 10px;
//}

.title-collapsed {
  margin-top: 12px;
}

.collapse-right {
  width: 72px;
  padding: 12px;
}

.center-width-left-side-collapse {
  width: calc(50% - 36px);
  padding: 10px !important;
}

.right-width-left-side-collapse {
  width: calc(50% - 36px);
  padding: 24px 10px 10px 10px !important;
}

.tag-chip {
  font-weight: 600;
}


.center-width-right-side-collapse {
  width: calc(83.33% - 72px);
  padding: 10px !important;
}

.center-width-both-collapse {
  width: calc(100% - 144px);
  padding: 10px !important;
}

.edit-state-link {
  margin-bottom: 3px;
  font-size: 11px;
}

.milestone-container{
  height: 28px;
}

.milestone-item {
  display: inline-block;
  margin-right: 16px;
  position:relative;
}

.milestone-item:before,
.milestone-item:after
{
  content:'';
  width: 16px;
  border-bottom:1px solid #9E9E9E;
  position:absolute;
  top:50%;

}
:after {
  left:100%;
}
:before {
  right:100%;
}
.milestone-item:first-of-type:before,
.milestone-item:last-of-type:after {
  display:none;
}

.milestone-button{
  margin-top: 12px;
  text-transform: unset !important;
}

.milestone-card{
  padding: 16px !important;
  border-radius: 4px !important;
}

</style>

