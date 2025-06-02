<template>
  <v-main v-if="!processStepLoading && projectMismatch">
    <div class="error--text">No Matching Process Step Found</div>
  </v-main>
  <v-main
    ref="ppsFieldsContainer"
    v-else-if="!processStepLoading"
    class="py-0 px-6 relative height-one-hunned overflow-y-auto"
  >
    <v-row>
      <v-col class="text-left px-5 py-0">
        <!--  error save dialog -->
        <ConfirmationDialog
          :open-dialog="unsavedFieldsModal"
          @confirm="[(navigationOverride = true), goToPath(toPath, query)]"
          @close-dialog="unsavedFieldsModal = false"
        >
          <template v-slot:title>Confirm</template>
          You have unsaved fields. Are you sure you want to continue without
          saving?
          <template v-slot:yes>Continue Without Saving</template>
        </ConfirmationDialog>
      </v-col>

      <v-col cols="12" class="pb-1 pt-6">
        <v-toolbar
          color="transparent"
          height="auto"
          id="pps-toolbar"
          class="elevation-0 cfg-name-toolbar"
        >
          <v-toolbar-title class="process-step-name albatross-header-2">
            <div>{{ processStep.processStepName }}</div>
            <div
              v-if="processStep.processStepStatusTypeId"
              :class="getStatusClass(processStep.processStepStatusTypeId)"
            >
              ({{ processStep.processStepStatusType }})
            </div>
            <div class="body-small grey--text text--darken-2">
              Created by {{ processStep.createdBy }}
              {{
                processStep.dateCreated
                  | formatDate('timestamp', 'M/D/YYYY [at] h:mm a')
              }}
            </div>
            <ConfirmationDialog
              :open-dialog="processStep.changeActiveConfirm"
              @cancel="
                [
                  (processStep.changeActiveConfirm = false),
                  (processStep.main = false)
                ]
              "
              @confirm="
                [
                  (processStep.changeActiveConfirm = false),
                  (processStep.main = true),
                  (showMainDialog = true)
                ]
              "
            >
              <template v-slot:title>Change Primary Process Step</template>
              Modifying the primary flag will run any automatic actions that
              have not yet been run where the criteria is met using values from
              the new active process step. Are you sure you want to set this
              process step to Primary?
              <template v-slot:yes>Yes</template>
            </ConfirmationDialog>
            <v-checkbox
              @click="
                processStep.changeActiveConfirm =
                  !processStep.changeActiveConfirm
              "
              dense
              v-model="processStep.main"
              :disabled="
                processStep.main ||
                !userCanManage ||
                availableProcessStepStatuses.length === 0
              "
              label="Primary"
            />
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items class="owner-toolbar-items">
            <div v-if="!displayChangeOwner">
              <div
                v-if="processStep.owner && processStep.owner.userId"
                class="d-flex flex-row align-center"
              >
                <div class="d-flex flex-column">
                  <div class="owner-info">
                    {{ processStep.owner.fullName }}<br />
                    <span class="owner-position albatross-body-3">
                      {{ processStep.owner.position }}
                    </span>
                  </div>
                </div>
                <a-btn
                  v-if="userCanEdit"
                  size="small"
                  icon
                  color="primary"
                  class="ml-2"
                  @click="removeOwner"
                  prepend-icon="mdi-close"
                ></a-btn>
              </div>
            </div>
            <div v-if="displayChangeOwner">
              <a-autocomplete
                v-model="processStep.owner"
                :items="availableOwners"
                class="mt-1"
                label="Select Owner"
                item-title="fullName"
                :readonly="!userCanEdit"
                :disabled="!userCanEdit"
                return-object
                hide-details
                autocomplete="off"
                @change="updateOwner"
                attach
              >
                <template v-slot:prepend>
                  <v-tooltip top small>
                    <template v-slot:activator="{ on, attrs }">
                      <v-icon
                        @click="selectSelf"
                        class="clickable"
                        color="primary"
                        v-bind="attrs"
                        v-on="on"
                        >mdi-account-arrow-right-outline</v-icon
                      >
                    </template>
                    <span class="albatross-body-3">Select Me</span>
                  </v-tooltip>
                </template>
              </a-autocomplete>
            </div>
            <div>
              <a-btn
                color="primary"
                variant="text"
                size="small"
                v-if="
                  (userCanEdit && !processStep.owner) ||
                  !processStep.owner.userId
                "
                class="change-owner-button"
                :class="{ 'mt-2': displayChangeOwner }"
                @click="displayChangeOwner = !displayChangeOwner"
                :text="displayChangeOwner ? 'cancel' : 'Add Owner'"
              ></a-btn>
            </div>
          </v-toolbar-items>
        </v-toolbar>
      </v-col>
      <v-col
        cols="12"
        class="text-left py-0"
        v-if="
          processStep && processStep?.banners && processStep?.banners?.length > 0
        "
      >
        <div>
          <v-card
            flat
            class="square-card"
            :class="{ 'mt-2': idx !== 0 }"
            v-for="(b, idx) in processStep?.banners.filter((b) => b.canPerform)"
          >
            <v-card-text class="flex-display pa-0" :style="{ color: b.color }">
              <div
                class="banner-card-swatch"
                :style="{ 'background-color': b.bgColor }"
              ></div>
              <div
                :style="{ 'background-color': b.bgColor + 20 }"
                class="one-hunned"
              >
                <pre class="app-pre-wrapper px-3 py-2">{{ b.content }}</pre>
              </div>
            </v-card-text>
          </v-card>
        </div>
      </v-col>
      <v-col
        cols="12"
        class="text-left pt-2 pb-4"
        v-if="
          userHasEventsFeature &&
          ((processStepEvents && processStepEvents.length > 0) ||
            (processStep &&
              projectProcessStepEvents &&
              projectProcessStepEvents.length > 0))
        "
      >
        <div class="pps-subheader albatross-header-3">
          All Events
          <!--          only allow events added to active process steps -->
          <a-autocomplete
            v-model="eventToAdd"
            v-if="
              processStep.processStepStatusTypeId === 1 &&
              userCanAddEvents &&
              processStepEvents &&
              processStepEvents.length > 0
            "
            :items="processStepEvents"
            placeholder="Select Event to add"
            item-title="eventName"
            item-value="id"
            return-object
            density="compact"
            style="z-index: 7"
            class="mt-2"
            @input="addEvent()"
          ></a-autocomplete>
        </div>
        <div
          v-for="e in projectProcessStepEvents"
          :key="e.id"
          class="d-inline-block mr-4 mt-2"
        >
          <EventButton :event="e" :project-id="projectId" />
        </div>
      </v-col>
      <v-col cols="12" class="text-left pt-0" id="pps-actions">
        <div class="d-flex  align-center"
        :class=" processStep && processStep?.actions && processStep?.actions?.length > 0? 'justify-space-between ':'justify-end '"
        >
          <div
          class="pps-subheader headline-small"
          v-if="
          processStep && processStep.actions && processStep.actions.length > 0">
            Actions
            <a-btn
            class="back-btn show-unperformable-actions-btn"
            variant="text"
            color="primary"
            :ripple="false"
            @click="showUnperformableActions = !showUnperformableActions"
            :text="showUnperformableActions ? 'Hide Disabled' : 'Show All'"
            ></a-btn>
          </div>
          <div class="d-flex align-center db-gap-12" v-if="userStore.userHasFeatureAccessLevel('PROJECTS', 'ADMIN')">
            <span>Check Logic</span>
            <v-switch
         :model-value="showLogic"
  color="primary"
  @click="toggleLogic"
            ></v-switch>
          </div>
        </div>
        <div
          v-for="action in enabledActions"
          :key="action.id"
          class="d-inline-block ma-1"
        >
          <ActionButton
            :action-result="action"
            :can-perform-action="
              !action.triggerAutomatically &&
              action.canPerform &&
              !processStepReadOnly &&
              userCanEdit
            "
            :complete-action="completeAction"
            :follow-multiple-links="followMultipleLinks"
          />
        </div>
        <div v-if="showLogic">
          <div class="my-3">Requirements failed:</div>
            <a-btn
            style="margin: 0.25rem;" v-for="action in checkLogicActions"
            color="primary"
            class="action-button"
             @click="getActionInfo(action.id,action.actionName)">
            {{ action.actionName }}
            </a-btn>
            
        </div>

        
       


        <div v-if="showUnperformableActions">
          <div class="my-3">Disabled actions:</div>

          <ActionButton
            v-for="action in disabledActions"
            class="d-inline-block ma-1"
            :key="action.id"
            :action-result="action"
            :can-perform-action="
              !action.triggerAutomatically &&
              action.canPerform &&
              !processStepReadOnly &&
              userCanEdit
            "
            :complete-action="completeAction"
            :follow-multiple-links="followMultipleLinks"
          />
        </div>

        <div v-if="showUnperformableActions">
          <div class="my-3">Other actions:</div>

          <ActionButton
            v-for="action in otherActions"
            :key="action.id"
            class="d-inline-block ma-1"
            :action-result="action"
            :can-perform-action="
              !action.triggerAutomatically &&
              action.canPerform &&
              !processStepReadOnly &&
              userCanEdit
            "
            :complete-action="completeAction"
            :follow-multiple-links="followMultipleLinks"
          />
        </div>

        <v-row v-if="!processStepLoading">
          <Links
            :projectProcessStepId="parseInt(projectProcessStepId)"
            :project-id="parseInt(projectId)"
            :contact-id="processStep.contactId"
            :processStepId="parseInt(processStepId)"
          />
        </v-row>
      </v-col>
      <v-col cols="12" style="height: 0; padding: 0 !important">
        <!-- this is here because i couldn't figure out how to make the toolbar sticky when in a col, and how to make the toolbar on a new row at all screen widths if not in a col-->
      </v-col>
      <v-col
        cols="12"
        class="pa-0"
        v-if="processStep.hasAttachmentTypesAssigned"
      >
        <div>
          <v-toolbar
            flat
            :color="isMobile ? 'white' : 'grey lighten-4'"
            class="cfg-detail-header px-3"
          >
            <v-toolbar-title class="headline-small">
              Process Step Documents
            </v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
              <a-btn
                variant="text"
                color="primary"
                class="px-0"
                @click="collapsedAttachments = !collapsedAttachments"
                :prepend-icon="
                  collapsedAttachments ? 'mdi-chevron-up' : 'mdi-chevron-down'
                "
              ></a-btn>
            </v-toolbar-items>
          </v-toolbar>
          <v-col
            cols="12"
            class="text-left pt-0 px-0 pb-4"
            v-if="!collapsedAttachments"
          >
            <AttachmentsFolderList
              :object-type-id="4"
              :allow-upload="true"
              :object-category-id="project.objectCategoryId"
              :small-title="true"
              is-card
              hide-empty
              title="Uploaded Documents"
            />
            <AttachmentsFolderList
              :object-type-id="4"
              :load-linked="true"
              :small-title="true"
              :object-category-id="project.objectCategoryId"
              is-card
              hide-empty
              title="Linked Documents"
            />
          </v-col>
        </div>
      </v-col>
      <v-toolbar
        flat
        :color="isMobile ? 'white' : 'grey lighten-4'"
        class="cfg-detail-header fixed-toolbar px-3 z-3"
      >
        <v-toolbar-title class="headline-small">
          Process Step Details
        </v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <a-btn
            variant="text"
            color="primary"
            @click="setSplitColumnValue()"
            v-if="!isMobile"
            class="px-0"
            :prepend-icon="
              !projectStore.manualColumnSplit
                ? 'mdi-format-columns'
                : 'mdi-format-align-justify'
            "
          ></a-btn>
          <div>
            <a-btn
              color="primary"
              id="qa-save-fields-button"
              class="ml-2 mt-1"
              :class="{ 'mt-3': !isMobile }"
              :icon="isMobile"
              :disabled="fieldsSaving || getReadOnly()"
              @click="[(fieldsSaving = true), checkFields()]"
              :text="!isMobile ? 'Save Fields' : ''"
              prepend-icon="save"
            ></a-btn>
          </div>
        </v-toolbar-items>
      </v-toolbar>
      <v-col cols="12">
        <!--    process field groups-->
        <v-expansion-panels multiple :value="expansionOpenStatus">
          <v-expansion-panel
            v-for="(cfg, index) in customFieldGroups.filter(
              (g) => g.customFieldValues?.length > 0
            )"
            :key="index"
            class="my-1"
          >
            <v-expansion-panel-header class="px-4 py-0 panel-header">
              <v-toolbar
                color="transparent"
                class="elevation-0 cfg-name-toolbar"
                dense
              >
                <v-toolbar-title>
                  <!--  @TODO: @humes, once schedule tool is ready, have this link go to a more specific location in the schedule tool-->
                  <a-btn
                    size="small"
                    variant="text"
                    v-if="cfg.eventId && userStore.userHasFeature('SCHEDULE')"
                    :to="`/schedule?projectProcessStepId=${projectProcessStepId}`"
                    color="unset"
                    prepend-icon="mdi-calendar"
                  ></a-btn>
                  {{ cfg.groupName }}
                </v-toolbar-title>
              </v-toolbar>
            </v-expansion-panel-header>
            <v-expansion-panel-content>
              <v-container fluid>
                <v-layout
                  :style="{
                    display: 'grid',
                    gridTemplateColumns: projectStore.manualColumnSplit ? '1fr 1fr' : '1fr',
                    gap: '8px', // Adjust spacing between elements as needed
                  }"
                >
                  <div>
                    <CustomValueInput
                      v-for="(field, idx) in getCustomFieldValuesToDisplay(cfg.customFieldValues, 1)"
                      :key="idx"
                      :use-field-ancillary-name="true"
                      :callback="populateDirtyCfvs"
                      :readonly="getReadOnly(field)"
                      :field="field"
                      :show-field-name="false"
                    />
                  </div>

                  <div v-if="projectStore.manualColumnSplit">
                    <CustomValueInput
                      v-for="(field, idx) in getCustomFieldValuesToDisplay(cfg.customFieldValues, 2)"
                      :key="idx"
                      :use-field-ancillary-name="true"
                      :callback="populateDirtyCfvs"
                      :readonly="getReadOnly(field)"
                      :field="field"
                      :show-field-name="false"
                    />
                  </div>
                </v-layout>
              </v-container>
            </v-expansion-panel-content>
          </v-expansion-panel>
        </v-expansion-panels>
      </v-col>
    </v-row>

    <ProjectProcessStepStatus
      :show-dialog="showMainDialog"
      :project-id="projectId"
      :project-process-step="processStep"
      :available-process-step-statuses="availableProcessStepStatuses"
      :limit-to-active="false"
      :limit-to-non-cancelled="true"
      :new-status-optional="processStep.processStepStatusTypeId !== 3"
      @updateStatus="updateMain"
      @dialogClosed="
        [
          (showMainDialog = false),
          (processStep.main = false),
          (processStep.newStatusToUse = { NEW_STATUS_TO_USE })
        ]
      "
    />
    
       <ShowLogicPopup :actionButtnInfo="actionButtnInfo" :showActionPopup="showActionPopup" @closePopup=closePopup />

 
  </v-main>
  <v-main v-else>
    <SpinnerInline centered :size="50" color="primary" />
  </v-main>



</template>

<script setup>
import {
  handleHidingGlobalLoader,
  followLink,
  getRequest,
  logError,
  getRequestWithParams,
  postRequest
} from '@/helpers/helpers'
import ActionButton from './ActionButton'
import EventButton from './EventButton'

import {
  getCompanyAssignedToProcessStep,
  getStatusClass
} from '@/services/processStepStatusTypeService'
import Links from '@/views/flow/components/Links'
import CustomValueInput from '@/views/flow/components/CustomValueInput'
import { getCustomFieldReadOnly } from '@/services/customFieldService'
import ProjectProcessStepStatus from '@/views/flow/project/ProjectProcessStepStatus'
import SpinnerInline from '@/components/SpinnerInline'
import AttachmentsFolderList from '@/views/flow/components/AttachmentsFolderList'
import ConfirmationDialog from '../../../components/ConfirmationDialog.vue'
import { useProjectStore } from '@/stores/ProjectStore.js'
import { onBeforeRouteLeave, onBeforeRouteUpdate } from 'vue-router/composables'

import {
  getCurrentInstance,
  toRefs,
  computed,
  ref,
  onMounted,
  watch
} from 'vue'
import { useUserStore } from '@/stores/UserStore.js'
import { useRoute, useRouter } from 'vue-router/composables'
import { useAppStore } from '@/stores/AppStore.js'

import ShowLogicPopup from '@/views/flow/project/projectPopup/ShowLogicPopup.vue';


const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const projectStore = useProjectStore()
const vueInstance = getCurrentInstance().proxy

const vuetify = vueInstance.$vuetify

const props = defineProps({
  project: Object
})
const { project } = toRefs(props)

const NEW_STATUS_TO_USE = { id: null }

const unsavedFieldsModal = ref(false)
const fieldsSaving = ref(false)
const projectMismatch = ref(false)
const processStepReadOnly = ref(false)
const collapsedAttachments = ref(false)
const processStepId = ref(null)
const processStep = ref({})
const existingEvents = ref([])
const customFieldGroups = ref([])
const dirtyCfvs = ref([])
const toPath = ref(null)
const query = ref({})
const navigationOverride = ref(false)
const displayChangeOwner = ref(false)
const availableOwners = ref([])
const availableProcessStepStatuses = ref([])
const showMainDialog = ref(false)
const showUnperformableActions = ref(false)
const processStepLoading = ref(true)
const eventToAdd = ref({})
const processStepEvents = ref([])
const projectProcessStepEvents = ref([])
const ppsFieldsContainer = ref(null)
const showLogic=ref(false)
const actionButtnInfo = ref(null);
const showActionPopup = ref(false);

const emit = defineEmits([
  'refresh-upcoming-pps',
  'refresh-project-status',
  'refresh-upcoming-events'
])

const projectId = computed(() => {
  return parseInt(route.params.projectId)
})
const projectProcessStepId = computed(() => {
  return parseInt(route.params.processStepId)
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('PROCESS_STEPS', 'EDIT')
})
const userCanAddEvents = computed(() => {
  return userStore.userHasFeatureAccessLevel('EVENTS', 'ADD')
})
const userIsAdmin = computed(() => {
  return userStore.userHasFeatureAccessLevel('PROCESS_STEPS', 'ADMIN')
})
const userCanManage = computed(() => {
  return userStore.userHasFeatureAccessLevel('PROCESS_STEPS', 'MANAGE')
})
const userHasEventsFeature = computed(() => {
  return userStore.userHasFeature('EVENTS')
})

const enabledActions = computed(() => {
  return (
    processStep.value?.actions?.filter(
      (a) => a.canPerform === true && a.hideFromWeb === false
    ) ?? []
  )
})

// non-enabled actions having assigned status/category differing from the current PS status/category
const disabledActions = computed(() => {
  return (
    processStep.value?.actions?.filter((a) => {
      if (a.canPerform === true) {
        return false
      }

      if (
        a.companyProcessStepStatusTypeIds.length === 0 &&
        a.processStepStatusTypeIds.length === 0
      ) {
        return false
      }

      return (
        a.companyProcessStepStatusTypeIds.includes(
          processStep.value.companyProcessStepStatusTypeId
        ) ||
        a.processStepStatusTypeIds.includes(
          processStep.value.processStepStatusTypeId
        )
      )
    }) ?? []
  )
})

// non-enabled actions which have no assigned status/category
const otherActions = computed(() => {
  return (
    processStep.value?.actions?.filter((a) => {
      if (enabledActions.value.map((i) => i.id).includes(a.id)) {
        return false
      }

      return !disabledActions.value.map((i) => i.id).includes(a.id)
    }) ?? []
  )
})

const isMobile = computed(() => {
  return vuetify.breakpoint.smAndDown
})

watch(projectProcessStepId, async () => {
  await loadAllPageDetails()
})

onMounted(async () => {
  await loadAllPageDetails()
})

onBeforeRouteUpdate(async (to, from, next) => {
  // called when the route that renders this component is about to be updated via router-view update
  if (navigationOverride.value || dirtyCfvs.value.length === 0) {
    //set overide to false before navigation or else the confirmation dialog doesn't work if the next screen is also a pps
    navigationOverride.value = false
    next()
  } else {
    toPath.value = to.path
    query.value = to.query
    unsavedFieldsModal.value = true
  }
})

onBeforeRouteLeave(async (to, from, next) => {
  // called when the route that renders this component is about to be navigated away from.
  if (
    to.path === '/login' ||
    navigationOverride.value ||
    dirtyCfvs.value.length === 0
  ) {
    //set overide to false before navigation or else the confirmation dialog doesn't work if the next screen is also a pps
    navigationOverride.value = false
    next()
  } else {
    toPath.value = to.path
    query.value = to.query
    unsavedFieldsModal.value = true
  }
})

const expansionOpenStatus = computed(() => {
  // determine which groups to collapse. Default is expand
  let indexes = []
  customFieldGroups.value?.forEach((group, index) => {
    const defaultStatusNotSet =
      group.companyProcessStepStatusTypeIds.length === 0 &&
      group.processStepStatusTypeIds.length === 0 &&
      !group.psCollapseByDefault

    const expandByCategory = group.processStepStatusTypeIds.includes(
      processStep.value.processStepStatusTypeId
    )
    const expandByStatus = group.companyProcessStepStatusTypeIds.includes(
      processStep.value.companyProcessStepStatusTypeId
    )

    if (expandByCategory || expandByStatus || defaultStatusNotSet) {
      indexes.push(index)
    }
  })
  return indexes
})

const setSplitColumnValue = () => {
  //flip the flag
  projectStore.manualColumnSplit = !projectStore.manualColumnSplit
}
const getCustomFieldValuesToDisplay = (values, columnNum) => {
  if (projectStore.manualColumnSplit) {
    return values.filter(function (element, index, values) {
      return index % 2 === (columnNum === 1 ? 0 : 1)
    })
  } else {
    return values
  }
}
const loadAllPageDetails = async () => {
  processStepLoading.value = true
  //if you add a new item to requests make sure it returns the request status
  const psStatus = await getProcessStep(true)
  const requests = [getCustomFieldGroups(), getPPsEvents()]
  await Promise.all(requests).then(async (statusVals) => {
    let success = psStatus === 200
    statusVals.forEach((status) => {
      if (status !== 200) {
        success = false
      }
    })
    if (success) {
      //this was causing issues if you moved too quickly between pps, now we load the pps first then other items when we have the process step id
      const req2 = [getProcessStepEvents()]
      await Promise.all(req2).then((statuses) => {
        let success2 = true
        statuses.forEach((status) => {
          if (status !== 200) {
            success2 = false
          }
        })
        if (success2) {
          //this was causing issues if you moved too quickly between pps
          processStepLoading.value = false
        }
      })
    }
  })
}
const goToPath = (path, query) => {
  //reset these values so the next screen works if also a pps
  unsavedFieldsModal.value = false
  dirtyCfvs.value = []
  router.push({ path, query })
}
const getAvailableStatuses = async () => {
  if (processStep.value?.processStepId) {
    try {
      const { data } = await getCompanyAssignedToProcessStep(
        processStep.value.processStepId
      )
      // const {data} = await getRequest(`/processStep/status`)
      availableProcessStepStatuses.value = data
    } catch (e) {
      appStore.showSnack(
        'ERROR',
        'Error fetching available process step statuses'
      )

      logError(e)
    }
  }
}


const getProcessStep = async (reloadAll) => {
  try {
    showLogic.value=false
    projectMismatch.value = false
    processStepLoading.value = true
    const { data, status } = await getRequest(
      `/projectProcessStep/${projectProcessStepId.value}`
    )
    if (data && data.projectId && data.projectId !== projectId.value) {
      projectMismatch.value = true
      processStepLoading.value = false
      appStore.showSnack('ERROR', `Invalid Request: Project Mismatch`)
    } else {
      processStep.value = { ...data, newStatusToUse: { NEW_STATUS_TO_USE } }
      processStepReadOnly.value =
        processStep.value.readonly &&
        !userStore.userHasAnyPosition(
          processStep.value.whiteListedPositions?.map((wlp) => wlp.positionId)
        )
      processStepId.value = processStep.value.processStepId
      // contactId.value = processStep.value.contactId
      projectStore.pps = processStep.value
      projectStore.linkLabel = `${processStep.value.processStepName} (${processStep.value.projectProcessStepId})`
      projectStore.linkId = processStep.value.projectProcessStepId
      if (reloadAll) {
        //dont reload if only doing simple refresh
        getAvailableStatuses()
        getAvailableOwners()
      } else {
        //only set this to false when doing a simple refresh or else it will turn off loaders too soon
        processStepLoading.value = false
      }
      window.document.title = project.value?.id
        ? `${project.value.projectName} - ${processStep.value.processStepName}`
        : `${processStep.value.processStepName}`
      // return {data, status}
      return status
    }
  } catch (e) {
    logError(e)
  }
}

const getPPsEvents = async () => {
  try {
    const { data, status } = await getRequest(
      `/projectProcessStep/${projectProcessStepId.value}/event`
    )
    existingEvents.value = data
    projectProcessStepEvents.value = data
    return status
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error retrieving project events')
  }
}

const getCustomFieldGroups = async () => {
  try {
    const { data, status } = await getRequestWithParams(
      `/customFieldValues/project/${projectId.value}/processStep/${projectProcessStepId.value}`,
      null,
      null,
      []
    )
    customFieldGroups.value = data
    return status
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error Retrieving Custom Fields')
  }
}
const getAvailableOwners = async () => {
  // appStore.loading = true
  if (processStep.value?.processStepProcessId) {
    try {
      const { data } = await getRequest(
        `/projectProcessStep/owners/${processStep.value.processStepProcessId}`,
        null,
        []
      )
      availableOwners.value = data

      // appStore.loading = false
    } catch (e) {
      logError(e)
      appStore.showSnack('ERROR', 'Error Retrieving List of Owners')

      // appStore.loading = false
    }
  }
}
const checkFields = async () => {
  //why is this still here?
  await updateFieldGroups()
}
const updateFieldGroups = async () => {
  appStore.loading = true
  // processStep.value.customFieldGroups = customFieldGroups.value
  try {
    // const {data} = await putRequest(`/projectProcessStep`, processStep.value)
    // save dirty custom field values
    const { data } = await postRequest(
      `/customFieldValues/project/${projectId.value}/processStep/${projectProcessStepId.value}`,
      dirtyCfvs.value
    )
    dirtyCfvs.value = []
    customFieldGroups.value = data
    emit('refresh-upcoming-pps')
    await getProcessStep(false)
    //not sure why $refs.value.ppsFieldsContainer.scrollTop = 0 works everywhere else in the app but not here
    ppsFieldsContainer.value.$el.scrollTop = 0
    appStore.showSnack('SUCCESS', 'Fields Saved')

    appStore.loading = false
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error Saving Custom Fields')

    appStore.loading = false
  } finally {
    fieldsSaving.value = false
  }
}
const populateDirtyCfvs = (field) => {
  //i think we could mostly remove this code now that round robin moved to events
  //some fields are for unique behavior and they dont need to be saved. this check should filter them out
  fieldsSaving.value = true //disable the save button until the dirtyCfvs has been updated
  if (field.customFieldId) {
    let match = dirtyCfvs.value.find(
      (f) =>
        (null !== f.id && f.id === field.id) ||
        f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId
    )
    if (!match) {
      dirtyCfvs.value.push(field)
    }
    fieldsSaving.value = false //re-enable the save button
  }
}
const removeOwner = async () => {
  appStore.loading = true
  try {
    processStep.value.owner = {}
    const { status } = await postRequest(
      `/projectProcessStep/${projectProcessStepId.value}/owner`,
      processStep.value.owner
    )
    appStore.showSnack('SUCCESS', 'Owner Removed')

    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Removing Owner')

    appStore.loading = false
  }
}
const updateOwner = async () => {
  displayChangeOwner.value = false
  appStore.loading = true
  try {
    const { status } = await postRequest(
      `/projectProcessStep/${projectProcessStepId.value}/owner`,
      processStep.value.owner
    )
    emit('refresh-upcoming-pps')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Saving Owner')

    appStore.loading = false
  }
}
const selectSelf = () => {
  let currentUserId = userStore.details.id
  let currentUserOwner = availableOwners.value.find(
    (o) => o.userId === currentUserId
  )
  if (!!currentUserOwner) {
    processStep.value.owner = currentUserOwner
    updateOwner()
  }
}
const updateMain = async (pps) => {
  showMainDialog.value = false
  try {
    appStore.loading = true
    await postRequest(
      `/projectProcessStep/${pps.projectProcessStepId}/main`,
      pps.newStatusToUse
    )
    const status = await getProcessStep(false)
    handleHidingGlobalLoader(status)
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Unable to update to primary process step')

    processStep.value.main = false
    appStore.loading = false
  }
}
const getReadOnly = (field) => {
  // if process_step admin then they can edit any process step fields, otherwise they can only edit active ones (1 = active)
  let fieldReadOnly = false
  if (null != field) {
    fieldReadOnly = getCustomFieldReadOnly(field)
  }
  let val =
    (!userIsAdmin.value && processStep.value?.processStepStatusTypeId !== 1) ||
    fieldReadOnly ||
    !userCanEdit.value ||
    processStepReadOnly.value
  return val
}
const followMultipleLinks = (action) => {
  let params = {
    projectId: projectId.value,
    ppsId: projectProcessStepId.value,
    contactId: processStep.value.contactId
  }

  action?.processStepActionLinks?.forEach((link) => {
    followLink(this, link.url, params)
  })
}
const completeAction = async (action) => {
  try {
    appStore.loading = true
    const { data, status } = await postRequest(
      `/projectProcessStep/${projectProcessStepId.value}/action/${action.id}`
    )
    if (status === 204 || status === 200) {
      handleActionCompleted(data)
    } else {
      handleOnCompleteError(action.id)
    }
    handleHidingGlobalLoader(status)
  } catch (e) {
    handleOnCompleteError(action.id, e.data.message)
    appStore.loading = false
  }
}
const handleActionCompleted = (data) => {
  emit('refresh-upcoming-pps')
  emit('refresh-project-status')

  appStore.showSnack('SUCCESS', 'Action Completed')

  //if there are links returned, open them
  data?.childFunctionReturnedStrings?.forEach((rs) => {
    //the date stringify guarantees a new tab opens every time
    window.open(rs, JSON.stringify(new Date()))
  })

  //if root status is not active then go back to project screen
  if (data?.processStepStatusTypeId !== 1) {
    //just in case something wasn't saved before running this action then still allow the nav
    navigationOverride.value = true
    router.push({
      name: 'projectDetails',
      params: { projectId: projectId.value }
    })
  } else {
    getProcessStep(false)
    //have to reload the custom field groups as well in case the action populated something
    getCustomFieldGroups()
  }
}
const handleOnCompleteError = (actionId, errorMessage) => {
  logError(`Failed to complete action with actionId: ${actionId}`)

  let message = 'Unable to Complete Action'

  // See if this is a java function failure and display a more specific error message
  if (errorMessage && typeof errorMessage === 'string') {
    let lastClause = errorMessage.substring(errorMessage.lastIndexOf('*** '))

    // This is specific to BR to display if a loan wasn't found. Genericize when we get "free time"
    if (lastClause.includes('Unable to locate application')) {
      message = 'Unable to locate loan application'
    }
  }

  appStore.showSnack('ERROR', message)
}
const addEvent = async () => {
  appStore.loading = true
  try {
    const { data } = await postRequest(
      `/projectProcessStep/${projectProcessStepId.value}/event/${eventToAdd.value.id}`,
      {}
    )
    emit('refresh-upcoming-events')
    await router.push(
      `/project/${projectId.value}/processStep/${data.projectProcessStepId}/event/${data.id}`
    )
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Adding Event')

    appStore.loading = false
  }
}
const getProcessStepEvents = async () => {
  //this gets the events assigned to the procez_ss step so we know which ADD buttons to show
  try {
    const { data, status } = await getRequest(
      `/processStep/${processStepId.value}/event`,
      null,
      []
    )
    processStepEvents.value = data
    if (!userStore.isSystemAdmin) {
      //if the user is a 7 Oaks admin, they should see the event regardless of readonly status
      processStepEvents.value = processStepEvents.value.filter((pse) => {
        if (pse.readonly) {
          for (let wlp of pse.readonlyWhiteListPositions) {
            let match = userStore.details.userPositions.find(
              (up) => up.positionId === wlp.positionId
            )
            if (match) {
              return true //if the user has a position that matches any of the whiteList positions, the user should see the event
            }
          }
          return false //if we go through all the whiteList positions and haven't found a match, the user should not see the event
        }
        return true //if the event is not readonly, the user should see the event
      })
    }
    return status
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Details')

    appStore.loading = false
  } 
}


const getActionInfo = async (actionId,tittle) => {
  try {
    // Fetch action result
    const { data } = await getRequest(`/projectProcessStep/${projectProcessStepId.value}/${actionId}`);
    const statusMap = new Map(
      Object.entries(data.requirementIdsFulfilledStatus || {}).map(([key, value]) => [Number(key), value])
    );
    const logicList = data.processStepLogicList || [];
    // Map the fulfillment status directly
    logicList.forEach((logicItem) => {
      logicItem.isPassAction = statusMap.has(logicItem.processStepRequirementId)
        ? statusMap.get(logicItem.processStepRequirementId)
        : true;
    });
    let popupData={
      processStepLogicList:logicList,
      heading:tittle
    }
    actionButtnInfo.value = popupData;
    showActionPopup.value = true;
  } catch (e) {
    logError('Error fetching action result:', e);
  }
};

const closePopup = (newValue) => {
  showActionPopup.value = newValue
}

const toggleLogic = () => {
  showLogic.value = !showLogic.value
  console.log("Switch toggled to:", showLogic.value)
}

const checkLogicActions=computed(() => {
  return (
    processStep.value?.actions?.filter(
      (a) => a.canPerform === false 
    ) ?? []
  )
})
</script>

<style lang="scss">
#pps-toolbar .v-toolbar__content {
  display: flex;
  align-items: flex-start;
}
#pps-toolbar {
  z-index: 8;
}

.cfg-name-toolbar .v-toolbar__content {
  padding-left: 0 !important;
  padding-right: 0 !important;
}

#pps-toolbar.cfg-name-toolbar .v-toolbar__content {
  @media (max-width: 600px) {
    flex-direction: column;
  }
}

.cfg-name-toolbar .v-toolbar__title {
  font-size: 14px;
}

.cfg-detail-header {
  z-index: 6;
}

.cfg-detail-header .v-toolbar__content {
  padding-left: 0 !important;
  padding-right: 0 !important;
}

.owner-toolbar-items {
  flex-direction: column;
  text-align: right;
}
</style>
<style lang="scss" scoped>
.process-step-name {
  font-weight: normal;
  font-size: 1.25rem;
  white-space: normal;
}

.owner-image {
  display: inline-block;
  vertical-align: top;
  margin-top: 5px;
}

owner-toolbar-tools {
  display: flex;
}

.owner-info {
  display: inline-block;
  font-size: 14px;
}

.owner-position {
  color: var(--v-grey-darken2);
}

.banner-card-swatch {
  min-height: 100%;
  width: 30px;
}

.pps-subheader {
  width: 186px;
  margin-top: 5px;
}

.panel-header {
  font-weight: 600;

  border-bottom: 1px solid var(--v-grey-lighten2) !important;
  border-bottom-left-radius: 0 !important;
  border-bottom-right-radius: 0 !important;
}

::v-deep {
  .v-btn.back-btn {
    text-transform: capitalize;
    text-decoration: underline;

    &:not(.v-btn--round) {
      padding: 0;
    }

    &:hover:before {
      opacity: 0 !important;
    }

    .v-btn__content {
      justify-content: start;
    }
  }

  .show-unperformable-actions-btn {
    margin-bottom: 2px;
    margin-left: 10px;
    font-size: 12px;
  }

  .v-expansion-panel-header--active {
    min-height: 48px;
  }
}
</style>
