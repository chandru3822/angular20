<template>
  <v-main v-if="!eventDetailsLoading && projectMismatch">
    <div class="error--text">
      No Matching Event Found
    </div>
  </v-main>
  <v-main ref="ppseFieldsContainer" class="pa-0 relative height-one-hunned overflow-y-auto"
          v-else-if="!eventDetailsLoading">
    <ConfirmationDialog :open-dialog="unsavedFieldsModal"
                        @confirm="[navigationOverride = true, goToPath(toPath, query)]"
                        @close-dialog="unsavedFieldsModal = false">
      <template v-slot:title>Confirm</template>
      You have unsaved fields. Are you sure you want to continue without saving?
      <template v-slot:yes>Continue and Don't Save</template>
    </ConfirmationDialog>
    <div v-if="selectedEvent.id" class="pt-6">
      <v-toolbar color="transparent" height="auto"
                 class="elevation-0 cfg-name-toolbar px-6" id="event-header">
        <v-toolbar-title class="albatross-header-2">
          <div>{{ selectedEvent.eventName }}</div>
          <div :class="getStatusClass(selectedEvent.eventStatusTypeId)">({{ selectedEvent.eventStatusType }})</div>
          <div class="body-small grey--text text--darken-2" v-if="selectedEvent.scheduledDate">
            Scheduled {{ selectedEvent.scheduledDate | formatDate('timestamp', 'M/D/YYYY [at] h:mm a') }}
          </div>
          <div class="body-small grey--text text--darken-2">Created by {{ selectedEvent.createdBy }} {{selectedEvent.dateCreated | formatDate('timestamp', 'M/D/YYYY [at] h:mm a')}}</div>
        </v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <a-btn
              v-if="(selectedEvent.startTime === null && selectedEvent.allowAllUserDeletion) || userStore.userHasFeatureAccessLevel('EVENTS', 'ADMIN')"
              size="small"
              variant="text"
              color="primary"
              class="align-self-end"
              @click="showDeleteDialog = true"
              prepend-icon="delete"
          ></a-btn>
          <ConfirmationDialog :open-dialog="showDeleteDialog" @confirm="deleteEvent"
                              @close-dialog="showDeleteDialog=false">
            Are you sure you want to delete this event: <strong>{{ selectedEvent.eventName }}</strong>?
          </ConfirmationDialog>
        </v-toolbar-items>
      </v-toolbar>
      <div class="pb-4 px-6">
        <div class="mt-2" v-if="selectedEvent && selectedEvent.eventBanners && selectedEvent.eventBanners.length > 0">
          <v-card class="square-card" :class="{'mt-2': idx !== 0}"
                  v-for="(b, idx) in selectedEvent.eventBanners.filter(b => b.canPerform)">
            <v-card-text class="flex-display pa-0" :style="{'color': b.color}">
              <div class="banner-card-swatch" :style="{'background-color': b.bgColor}"></div>
              <div :style="{'background-color': b.bgColor + 20}" class="one-hunned">
                <pre class="app-pre-wrapper px-3 py-2">{{ b.content }}</pre>
              </div>
            </v-card-text>
          </v-card>
        </div>
        <div v-if="selectedEvent && selectedEvent.eventActions && selectedEvent.eventActions.length > 0">
          <div class="action-subheader albatross-header-3">
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
        </div>
        <div v-for="action in filteredActions" :key="action.id" class="d-inline-block ma-1">
          <ActionButton
              :action-result="action"
              :can-perform-action="action.canPerform"
              :complete-action="validateActionRequirements"
              :follow-multiple-links="followMultipleLinks"
          />
        </div>
      </div>
      <div v-if="selectedEvent.hasAttachmentTypesAssigned" class="px-6">
        <v-toolbar flat :color="isMobile ? 'white' : 'grey lighten-4'" class="cfg-detail-header">
          <v-toolbar-title class="headline-small">
            Event Documents
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                variant="text"
                color="primary"
                class="px-0"
                @click="collapsedAttachments = !collapsedAttachments"
                :prepend-icon="collapsedAttachments ? 'mdi-chevron-up' : 'mdi-chevron-down'"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-row>
          <v-col cols="12" class="text-left py-0 px-0 pb-4" v-if="!collapsedAttachments">
            <AttachmentsFolderList :object-type-id="6"
                                   :allow-upload="!isUploadReadonly"
                                   :small-title="true"
                                   is-card
                                   hide-empty
                                   title="Uploaded Documents"/>
            <AttachmentsFolderList :object-type-id="6"
                                   :load-linked="true"
                                   :small-title="true"
                                   is-card
                                   hide-empty
                                   title="Linked Documents"/>
          </v-col>
        </v-row>
      </div>
      <div class="fixed-toolbar">
        <v-toolbar flat :color="isMobile ? 'white' : 'grey lighten-4'" class="cfg-name-toolbar event-details-header px-6">
          <v-toolbar-title class="headline-small">
            Event Details
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                variant="text"
                color="primary"
                size="small"
                @click="setSplitColumnValue()"
                v-if="!isMobile"
                class="px-0"
                :prepend-icon="!projectStore.manualColumnSplit ? 'mdi-format-columns' : 'mdi-format-align-justify'"
            ></a-btn>
            <div>
              <a-btn
                  class="ml-2 mt-1"
                  :class="{'mt-3': !isMobile}"
                  id="qa-save-fields-button"
                  @click="checkFieldsForUnique"
                  :disabled="!userCanEdit || getIsEventReadonly()"
                  :icon="isMobile"
                  color="primary"
                  prepend-icon="save"
                  :text="!isMobile ? 'Save Fields' : ''"
              ></a-btn>
            </div>
          </v-toolbar-items>
        </v-toolbar>
      </div>
      <ConfirmationDialog v-if="conflictingEvents != null && conflictingEvents.length > 0" :open-dialog="conflictingEvents != null&& conflictingEvents.length > 0" @confirm="saveEventDetails(true)" @close-dialog="conflictingEvents = null; fieldsSaving = false">
        <template v-if="conflictingEvents.length > 1" v-slot:title>Conflicts</template>
        <template v-else v-slot:title>Conflict</template>
        Resource <b>{{conflictingEvents[0].resourceName}}</b>
        has another event on their calendar for:
        <br><br>
        <ol>
          <li v-for="conflictingEvent in conflictingEvents">
            <b>{{conflictingEvent?.start | formatDate('timestamp', 'MMMM DD, YYYY, h:mm A')}}
              - {{conflictingEvent?.end | formatDate('timestamp', 'MMMM DD, YYYY, h:mm A')}}</b>.
            <b></b>
            <br>
            <b>Existing Event:</b> {{ conflictingEvent?.eventName }} ({{ conflictingEvent?.projectName }}, ID: {{ conflictingEvent?.projectId }})
            <br><br>
          </li>
        </ol>
        <template v-slot:no>Cancel</template>
        <template v-slot:yes>Schedule Anyway</template>

      </ConfirmationDialog>
      <div class="error-text pb-4 px-6" v-if="eventActionMissingRequirements">
        {{ saveErrorMsg }}
      </div>
      <v-card class="pa-4 square-card mb-2"
              v-if="selectedEvent.uniqueBehaviorTypeId === 1 && (!project.postalCode || !project.companyStateId)">
        A state and postal code are required on the project to continue with scheduling. Please return to the
        project screen and update.
      </v-card>

      <v-form ref="eventFieldForm" class="px-6" v-else>
        <div class="albatross-header-4 d-flex align-baseline">Overview
          <a small text color="anchor" v-if="userStore.userHasFeature('SCHEDULE')"
             class="px-0 d-flex align-baseline" target="_blank"
             :href="`/schedule?projectProcessStepEventId=${ppsEventId}&projectProcessStepId=${projectProcessStepId}`">
            <span color="anchor" class="albatross-header-5 pl-2 scheduler-button-text">Open Scheduler</span>
            <v-icon color="anchor" class="scheduler-button-icon">mdi-open-in-new</v-icon>
          </a>
        </div>
        <v-card class="square-card px-4 pt-4 mt-4">

          <a-autocomplete
              v-model="selectedEvent.companyEventStatusTypeId"
              :items="companyEventStatuses"
              label="Event Status"
              :disabled="!userIsAdmin || isEventReadonly"
              item-title="eventStatusType"
              item-value="id"
              @input="[statusChanged = true, defaultValuesChanged = true]"
          ></a-autocomplete>
          <a-btn
              color="primary"
              v-if="selectedEvent.uniqueBehaviorTypeId === 1 && !uniqueAlreadyHasValue"
              class="mb-4 text-capitalize"
              :hidden="uniqueAlreadyHasValue"
              id="qa-round-robin-button"
              @click="toggleRoundRobinView"
              :text="toggleViewButtonText"
          ></a-btn>
          <!--show startTime, endTime, and resource fields-->
          <v-container v-if="!showRoundRobin" class="px-4" :class="{'pt-0': selectedEvent.uniqueBehaviorTypeId !== 1}">
            <div v-if="!uniqueAlreadyHasValue && selectedEvent.uniqueBehaviorTypeId === 1" class="title-large pt-1">Manual Assignment</div>
            <v-row>
              <v-col :cols="projectStore.manualColumnSplit ? 6 : 12" class="py-0" :class="{'pt-2': selectedEvent.uniqueBehaviorTypeId === 1}">
                <DatetimePickerInput
                    v-model="selectedEvent.startTime"
                    :timezone="timezone"
                    :disabled="uniqueAlreadyHasValue || showRoundRobin || getDefaultFieldReadOnly(selectedEvent.startTimeWhiteListedPositions, selectedEvent.startTimeReadOnly, selectedEvent.startTimeReadOnlyAllow)"
                    :readonly="uniqueAlreadyHasValue || getDefaultFieldReadOnly(selectedEvent.startTimeWhiteListedPositions, selectedEvent.startTimeReadOnly, selectedEvent.startTimeReadOnlyAllow)"
                    :required="actionRequiresStart && !selectedEvent.startTime && !eventSaveOverrideRequired"
                    v-if="!getDefaultFieldHidden(selectedEvent.startTimeHiddenWhiteListedPositions, selectedEvent.startTimeHidden, selectedEvent.startTimeHiddenAllow)"
                    :type="'timestamp'"
                    :format="'MMMM DD, YYYY, h:mm A'"
                    label="Start Time"
                    :change-callback="startTimeChanged"
                />
              </v-col>
              <v-col :cols="projectStore.manualColumnSplit ? 6 : 12" class="py-0" :class="{'pt-2': selectedEvent.uniqueBehaviorTypeId === 1}">
                <DatetimePickerInput
                    v-model="selectedEvent.endTime"
                    :timezone="timezone"
                    :disabled="uniqueAlreadyHasValue || getDefaultFieldReadOnly(selectedEvent.endTimeWhiteListedPositions, selectedEvent.endTimeReadOnly, selectedEvent.endTimeReadOnlyAllow)"
                    :readonly="uniqueAlreadyHasValue || getDefaultFieldReadOnly(selectedEvent.endTimeWhiteListedPositions, selectedEvent.endTimeReadOnly, selectedEvent.endTimeReadOnlyAllow)"
                    v-if="!getDefaultFieldHidden(selectedEvent.endTimeHiddenWhiteListedPositions, selectedEvent.endTimeHidden, selectedEvent.endTimeHiddenAllow)"
                    :required="actionRequiresEnd && !selectedEvent.endTime && !eventSaveOverrideRequired"
                    :type="'timestamp'"
                    :format="'MMMM DD, YYYY, h:mm A'"
                    label="End Time"
                    :change-callback="endTimeChanged"
                />
              </v-col>
            </v-row>
            <a-autocomplete
                v-if="selectedEvent && selectedEvent.availableResources && !getDefaultFieldHidden(selectedEvent.resourceHiddenWhiteListedPositions, selectedEvent.resourceHidden, selectedEvent.resourceHiddenAllow)"
                v-model="selectedEvent.resourceId"
                :items="selectedEvent.availableResources"
                :disabled="uniqueAlreadyHasValue || getDefaultFieldReadOnly(selectedEvent.resourceWhiteListedPositions, selectedEvent.resourceReadOnly, selectedEvent.resourceReadOnlyAllow)"
                :readonly="uniqueAlreadyHasValue || getDefaultFieldReadOnly(selectedEvent.resourceWhiteListedPositions, selectedEvent.resourceReadOnly, selectedEvent.resourceReadOnlyAllow)"
                :rules="getResourceRequirement()"
                label="Resource"
                item-title="name"
                item-value="id"
                @input="defaultValuesChanged = true"
            ></a-autocomplete>
          </v-container>

          <div v-if="selectedEvent.uniqueBehaviorTypeId === 1 && showRoundRobin" class="qa-show-round-robin">
            <v-toolbar flat color="transparent">
              <v-toolbar-title>Lead Allocation</v-toolbar-title>
            </v-toolbar>
            <v-card-text class="py-0">
              <v-card-text class="pt-0" v-if="userIsScheduler && !schedulerCanEdit && !showRemoteSearch && !userIsAdmin">
                You do not have access to schedule projects in this Postal Code
              </v-card-text>
              <v-row class="pb-3 px-0 one-hunned" v-else>
                <v-col :cols="(projectStore.manualColumnSplit && timeSlots.length > 0 && availabilityDateField.dateValue && !dateValueChanged) ? 6 : 12" class="pb-0 pt-2">
                  <CustomValueInput
                      :readonly="!userCanEdit"
                      :min-date="minDate"
                      :callback="checkAvailabilityDate"
                      :field="availabilityDateField"
                      :show-field-name="false"
                  />
                </v-col>
                <v-col :cols="projectStore.manualColumnSplit ? 6 : 12" class="pb-0 pt-2" v-if="availabilityDateField.dateValue && !dateValueChanged">
                  <a-select v-if="timeSlots.length > 0"
                            v-model="selectedTimeSlot"
                            class="qa-round-robin-time-select"
                            :items="timeSlots"
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
                            label="Select an Available Time Slot"
                            return-object
                  >
                    <template v-slot:selection="{ item, index }">
                      {{ item.scheduledStartTime | formatDate('timestamp') }}
                    </template>
                    <template v-slot:item="{ props, item }">
                        {{ item.scheduledStartTime | formatDate('timestamp') }}
                    </template>
                  </a-select>
                  <div v-else-if="searchedTimeSlots">No Times
                    Available for the
                    Selected Date
                  </div>
                </v-col>
                <div class="text-right flex-display flex-wrap justify-end one-hunned" v-if="availabilityDateField.dateValue">
                  <a-btn
                      color="primary"
                      class="text-capitalize mr-2 mb-4"
                      :outlined="!!selectedTimeSlot.scheduledStartTime"
                      :loading="remoteSearchLoading"
                      :disabled="inPersonSearchLoading"
                      v-if="showRemoteSearch || userIsAdmin"
                      id="qa-round-robin-search-remote"
                      @click="getAvailableTimeSlots(true)"
                      text="Search Remote Appt. Slots"
                  ></a-btn>
                  <a-btn
                      color="primary"
                      class="text-capitalize mr-2 mb-4"
                      :outlined="!!selectedTimeSlot.scheduledStartTime"
                      :loading="inPersonSearchLoading"
                      v-if="schedulerCanEdit || userIsAdmin"
                      :disabled="remoteSearchLoading"
                      id="qa-round-robin-search"
                      @click="getAvailableTimeSlots(false)"
                      text="Search In-person Appt. Slots"
                  ></a-btn>
                  <a-btn
                      color="primary"
                      class="text-capitalize mb-4"
                      v-if="availabilityDateField.dateValue"
                      :disabled="!selectedTimeSlot.scheduledStartTime"
                      @click="saveCloserAppointment"
                      id="qa-round-robin-save"
                      text="Save Appointment"
                  ></a-btn>
                </div>
              </v-row>
            </v-card-text>

          </div>
        </v-card>
        <v-col
            v-if="selectedEvent && selectedEvent.id"
            class="pt-0 px-0"
            v-for="(cfg, index) in selectedEvent.customFieldGroups"
            :key="cfg.id"
        >
          <v-toolbar color="transparent" class="elevation-0 cfg-name-toolbar">
            <v-toolbar-title class="albatross-header-4">
              {{ cfg.groupName }}
            </v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
            </v-toolbar-items>
          </v-toolbar>
          <v-card class="px-4 square-card" v-if="cfg.customFieldValues && cfg.customFieldValues.length > 0">
            <v-row>
              <v-col :cols="projectStore.manualColumnSplit && cfg.customFieldValues && cfg.customFieldValues.length > 1 ? 6 : 12" class="pb-0 pt-2">
                <CustomValueInput
                    v-for="(field, idx) in getCustomFieldValuesToDisplay(cfg.customFieldValues, 1)"
                    :key="idx"
                    :required="field.required && !eventSaveOverrideRequired"
                    :callback="populateDirtyCfvs"
                    :readonly="getFieldReadOnly(field)"
                    :field="field"
                    :use-field-ancillary-name="true"
                    :show-field-name="false"
                />
              </v-col>
              <v-col cols="6" v-if="projectStore.manualColumnSplit" class="pb-0 pt-2">
                <CustomValueInput
                    v-for="(field, idx) in getCustomFieldValuesToDisplay(cfg.customFieldValues, 2)"
                    :key="idx"
                    :required="field.required && !eventSaveOverrideRequired"
                    :callback="populateDirtyCfvs"
                    :readonly="getFieldReadOnly(field)"
                    :field="field"
                    :use-field-ancillary-name="true"
                    :show-field-name="false"
                />
              </v-col>
            </v-row>
          </v-card>
        </v-col>
      </v-form>


    </div>
  </v-main>
  <v-main v-else>
    <SpinnerInline centered :size="50" color="primary"/>
  </v-main>
</template>

<script setup>

import {
  getRequest,
  logError,

  getRequestWithParams,
  putRequest,
  postRequest,
  deleteRequest,
  followLink
} from '@/helpers/helpers'

import {getAssignedToEvent} from '@/services/eventStatusTypeService'
import {getEventCustomFieldReadOnly, getEventDefaultFieldReadOnly, getEventDefaultFieldHidden} from "@/services/customFieldService";
import CustomValueInput from '@/views/flow/components/CustomValueInput'
import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
import constants from '@/helpers/constants'
import moment from 'moment-timezone'
import {DateTime} from 'luxon'
import SpinnerInline from '@/components/SpinnerInline'
import {getStatusClass} from '@/services/eventStatusTypeService'
import ConfirmationDialog from '@/components/ConfirmationDialog'
import AttachmentsFolderList from '@/views/flow/components/AttachmentsFolderList'
import ActionButton from "./ActionButton";
import { useProjectStore } from '@/stores/ProjectStore.js'

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'
import { onBeforeRouteLeave, onBeforeRouteUpdate } from 'vue-router/composables'

const projectStore = useProjectStore()
const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const vuetify = vueInstance.$vuetify

const props = defineProps({
  project: Object,
  splitValueColumns: Boolean
})
const { project, splitValueColumns } = toRefs(props)

const selectedEvent = ref({})
const projectMismatch = ref(false)
const defaultValuesChanged = ref(false)
const statusChanged = ref(false)
const unsavedFieldsModal = ref(false)
const navigationOverride = ref(false)
const toPath = ref(null)
const conflictingEvents = ref(null)
const query = ref({})
const attemptedAction = ref({})
const companyEventStatuses = ref([])
const saveErrorMsg = ref('')
const eventActionMissingRequirements = ref(false)
const menuOpen = ref(false)
const dirtyCfvs = ref([])
const requiredRules = ref(constants.BASIC_REQUIRED_RULE)
const eventSaveOverrideRequired = ref(false)
const collapsedAttachments = ref(false)
const actionRequiresStart = ref(false)
const actionRequiresEnd = ref(false)
const actionRequiresResource = ref(false)
const roundRobinNumberOfDays = ref(7)
const timeSlots = ref([])
const selectedTimeSlot = ref({})
const schedulerCanEdit = ref(false)
const showRemoteSearch = ref(false)
const inPersonSearchLoading = ref(false)
const remoteSearchLoading = ref(false)
const mostRecentSearchWasRemote = ref(false)
const schedulerLoading = ref(true)
const closerApptOverride = ref(false)
const minDate = ref(moment().format('YYYY-MM-DDTHH:mm:ssZ'))
const closerApptSaved = ref(false)
const searchedTimeSlots = ref(false)
const showRoundRobin = ref(false)
const uniqueAlreadyHasValue = ref(false)
const availabilityDateField = ref({id: -1, fieldName: 'Select a Date', dataTypeId: 1, dateValue: null})
const dateValueChanged = ref(false)
const showUnperformableActions = ref(false)
const eventDetailsLoading = ref(true)
const isEventReadonly = ref(false)
const isUploadReadonly = ref(false)
const showDeleteDialog = ref(false)
const ppseFieldsContainer = ref(null)
const eventFieldForm = ref(null)

const emit = defineEmits(['refresh-upcoming-events', 'refresh-project-status', 'refresh-upcoming-pps'])

onMounted(async() => {
  await loadAllPageDetails()
})

const projectId = computed(() => {
  return parseInt(route.params.projectId)
})
const projectProcessStepId = computed(() => {
  return parseInt(route.params.processStepId)
})
const ppsEventId = computed(() => {
  return parseInt(route.params.ppsEventId)
})

onBeforeRouteUpdate(async (to, from, next) => {
  // called when the route that renders this component is about to be updated via router-view update
  if (navigationOverride.value || (dirtyCfvs.value.length === 0 && !defaultValuesChanged.value)) {
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
  if (to.path === '/login' || navigationOverride.value || (dirtyCfvs.value.length === 0 && !defaultValuesChanged.value)) {
    //set overide to false before navigation or else the confirmation dialog doesn't work if the next screen is also a pps
    navigationOverride.value = false
    next()
  } else {
    toPath.value = to.path
    query.value = to.query
    unsavedFieldsModal.value = true
  }
})

watch(eventActionMissingRequirements, async() => {
  vueInstance.$nextTick(() => {
    eventFieldForm.value.validate()
  })
})

watch(ppsEventId, async() => {
  // reset the selected item
  projectProcessStepId.value = parseInt(route.params.processStepId)
  ppsEventId.value = parseInt(route.params.ppsEventId)
  loadAllPageDetails()
})


const timezone = computed(() => {
  return userStore.timezone.value
})
const userIsAdmin = computed(() => {
  return userStore.userHasFeatureAccessLevel('EVENTS', 'ADMIN')
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('EVENTS', 'EDIT')
})
const userCanManage = computed(() => {
  return userStore.userHasFeatureAccessLevel('EVENTS', 'MANAGE')
})
const userCanAdd = computed(() => {
  return userStore.userHasFeatureAccessLevel('EVENTS', 'ADD')
})
const userIsScheduler = computed(() => {
  return userStore.details.userPositions?.some(p => p.scheduler)
})
const filteredActions = computed(() => {
  if (!selectedEvent.value?.eventActions) {
    return []
  }

  if (showUnperformableActions.value) {
    return selectedEvent.value.eventActions
  } else {
    return selectedEvent.value.eventActions.filter(a => a.canPerform === true)
  }
})
const toggleViewButtonText = computed(() => {
  if(showRoundRobin.value){
    return 'Manually Assign Resources'
  } else {
    return 'Round Robin'
  }
})
const isMobile = computed(() => {
  return vuetify.breakpoint.smAndDown
})

const goToPath = (path, query) => {
  unsavedFieldsModal.value = false
  router.push({path, query})
}
const setSplitColumnValue = () => {
  //flip the flag
  projectStore.manualColumnSplit = !projectStore.manualColumnSplit
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
const  loadAllPageDetails = async() => {
  eventDetailsLoading.value = true
  //if you add a new item to requests make sure it returns the request status
  const requests = [getEventDetails()]
  try {
    await Promise.all(requests).then((statusVals) => {
      let success = true
      statusVals.forEach(status => {
        if (status !== 200) {
          success = false
        }
      })
      if (success) {
        //this was causing issues if you moved too quickly between events
        eventDetailsLoading.value = false
      }
    })
  } catch (e) {
    console.error('*** ERROR ***', e)

  }
}
const closeEventWindow = () => {
  selectedEvent.value = {}
}
const getResourceRequirement = () => {
  if (actionRequiresResource.value && !selectedEvent.value.resourceId && !eventSaveOverrideRequired.value) {
    return requiredRules.value
  }
}
const followMultipleLinks = (action) => {
  let params = {
    projectId: projectId.value,
    ppsId: projectProcessStepId.value,
    ppseId: ppsEventId.value
  }

  action?.childLinks?.forEach(link => {
    followLink(this, link.url, params)
  })
}
const validateActionRequirements = async (action) => {
  attemptedAction.value = action
  eventActionMissingRequirements.value = false
  eventSaveOverrideRequired.value = false
  actionRequiresStart.value = action?.requireStartTime //this is no longer required to be true
  actionRequiresEnd.value = action?.requireEndTime
  actionRequiresResource.value = action?.requireResource
  //will only be used if there is an error shown here
  saveErrorMsg.value = 'Additional fields are required to perform the selected action.'

  let cfHasMissing = needsRequiredField(action.requiredFields)
  if ((actionRequiresStart.value && !selectedEvent.value.startTime) ||
      (actionRequiresEnd.value && !selectedEvent.value.endTime) ||
      (actionRequiresResource.value && !selectedEvent.value.resourceId) || cfHasMissing) {
    eventActionMissingRequirements.value = true

  } else {
    //if there wasn't a required field then run the event
    eventActionMissingRequirements.value = false
    await doEventAction(action)
  }
}
const needsRequiredField = (requiredFields) => {
  let fieldValueMissing = false

  selectedEvent.value?.customFieldGroups?.forEach(cfg => {
    cfg?.customFieldValues?.forEach(cf => {
      let match = requiredFields.find(rf => rf.customFieldGroupAssignmentId === cf.customFieldGroupAssignmentId)
      if (match) {
        if ( // check each data type to see if it has a value
            (cf.dataTypeId === 1 && null == cf.dateValue) ||
            (cf.dataTypeId === 2 && null == cf.timestampValue) ||
            (cf.dataTypeId === 3 && null == cf.booleanValue) ||
            (cf.dataTypeId === 4 && null == cf.numericValue) ||
            ((cf.dataTypeId === 5 || cf.dataTypeId === 13) && null == cf.textValue) ||
            (cf.dataTypeId === 6 && null == cf.intValue) ||
            (cf.dataTypeId === 7 && (null == cf.intArrayValue || cf.intArrayValue.length === 0)) ||
            (cf.dataTypeId === 8 && null == cf.intValue) ||
            (cf.dataTypeId === 9 && null == cf.intValue)
        ) {
          cf.required = true
          fieldValueMissing = true
          eventActionMissingRequirements.value = true
        }
      } else {
        cf.required = false
      }
    })
  })
  return fieldValueMissing
}
const getStatusesAssignedToEvent = async() => {
  try {
    const {data} = await getAssignedToEvent(selectedEvent.value.eventId)
    companyEventStatuses.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Data')

  }
}
const userCanScheduleLeadAllocation = async() => {
  //we only have to check this if the user is a scheduler otherwise we just use the userCanEdit value
  if (userIsScheduler.value) {
    schedulerLoading.value = true
    try {
      const {data} = await getRequestWithParams(`/roundRobin/userCanSchedule`, {
        params: {
          postalCode: project.value.postalCode
        }
      })
      schedulerCanEdit.value = data
    } catch (e) {
      logError(e)
      appStore.showSnack('ERROR', 'Error Checking Scheduler Round Robin')

    } finally {
      schedulerLoading.value = false
    }
  }
}
const userCanScheduleRemoteLeadAllocation = async() => {
  //we only have to check this if the user is a scheduler otherwise we just use the userCanEdit value
  if (userIsScheduler.value) {
    schedulerLoading.value = true
    try {
      const {data} = await getRequest(`/roundRobin/userCanScheduleRemote`)
      showRemoteSearch.value = data
    } catch (e) {
      logError(e)
      appStore.showSnack('ERROR', 'Error Checking Scheduler Round Robin')

    } finally {
      schedulerLoading.value = false
    }
  }
}
const doEventAction = async (action) => {
  appStore.loading = true
  try {
    let params = {
      id: selectedEvent.value.id,
      startTime: selectedEvent.value.startTime,
      endTime: selectedEvent.value.endTime,
      resourceId: selectedEvent.value.resourceId,
      saveVersion: selectedEvent.value.saveVersion,
      companyEventStatusTypeId: selectedEvent.value.companyEventStatusTypeId,
      customFieldValues: dirtyCfvs.value
    }

    const {data} = await postRequest(`/projectProcessStep/${projectProcessStepId.value}/event/${selectedEvent.value.id}/action/${action.id}/perform`, params)

    appStore.showSnack('SUCCESS', 'Action Completed')


    //calls fn that tells the upcoming events to update
    //we dont know if an event action will trigger other changes so we have to refresh everything all the time
    emit('refresh-project-status')
    emit('refresh-upcoming-pps')
    emit('refresh-upcoming-events')

    //set this because running an action also saves fields so it needs to be reset
    defaultValuesChanged.value = false

    //if there are links returned, open them
    data?.childFunctionReturnedStrings?.forEach(rs => {
      //the date stringify guarantees a new tab opens every time
      window.open(rs, JSON.stringify(new Date()))
    })

    if (data?.processStepStatusTypeId !== 1) {
      //set navigation override so we dont get the unsaved fields popup
      navigationOverride.value = true
      //if ps root status is not active then go back to project screen
      router.push({name: 'projectDetails', params: {projectId: projectId.value}})
    } else if (data?.eventStatusTypeId !== 1) {
      //set navigation override so we dont get the unsaved fields popup
      navigationOverride.value = true
      //if ps root status is active but event root status is not then go back to ps
      let path = `/project/${projectId.value}/processStep/${projectProcessStepId.value}`
      router.push(path)
    } else {
      //stay on the screen and refresh values
      selectedEvent.value = data
    }
    appStore.loading = false

  } catch (e) {
    console.error('*** ERROR ***', e)
    let saveMismatch = e.data?.message === 'Save Version Mismatch'
    let msg = saveMismatch ? `Cannot save changes, this event has been updated by another user. Click <a class="white--text underline" href="">here</a> to refresh.` : 'Error Performing Event'
    appStore.showSnack('ERROR', msg, saveMismatch)

    appStore.loading = false
  }
}
const getRoundRobinNumDays = async  () => {
  //need to load the round robin Number of days into future for this project
  const {data} = await getRequestWithParams(`/roundRobin/byPostalCode`, {
    params: {
      projectId: projectId.value,
      postalCode: project.value.postalCode
    }
  })
  roundRobinNumberOfDays.value = data.schedulableFutureDays || 7
}
const endTimeChanged = ()  => {
  defaultValuesChanged.value = true
}
const startTimeChanged = ()  => {
  defaultValuesChanged.value = true
  //if it is the closer event then auto populate the end time with (start time + 1 hour)
  if (selectedEvent.value?.uniqueBehaviorTypeId === 1 && selectedEvent.value?.startTime != null) {
    selectedEvent.value.endTime = moment.utc(selectedEvent.value.startTime).add(90, 'm').format('YYYY-MM-DDTHH:mm:ssZ')
  }
}
const userIsWhitelisted = () => {
  if(selectedEvent.value?.readonlyWhiteListedPositions) {
    for (let wlp of selectedEvent.value?.readonlyWhiteListedPositions) {
      let match = userStore.details.userPositions.find(up => up.positionId === wlp.positionId)
      if (match) {
        return true //if the user has a position that matches any of the whiteList positions, the user should see the event
      }
    }
    return false //if we go through all the whiteList positions and haven't found a match, the user should not see the event
  }
}
const isEventEditableByThisUserIgnoringReadOnly = () => {
  //can the user edit the field if the readonly setting is false
  // if events admin/manager then they can edit any event fields regardless of event/process step status
  return userIsAdmin.value || userCanManage.value || (userCanEdit.value && selectedEvent.value.eventStatusTypeId === 1 && selectedEvent.value.processStepStatusTypeId === 1)
}
const isButtonEditableByThisUserIgnoringReadOnly = () => {
  return userIsAdmin.value || userCanManage.value || userCanEdit.value
}
const getIsEventReadonly = ()  => {
  return !userStore.isSystemAdmin && (
      (selectedEvent.value?.readonly && !userIsWhitelisted())
      || !isEventEditableByThisUserIgnoringReadOnly()
  )
}
const getIsUploadReadonly = ()  => {
  return !userStore.isSystemAdmin && (
      (selectedEvent.value?.readonly && !userIsWhitelisted())
      || !isButtonEditableByThisUserIgnoringReadOnly()
  )
}
const getFieldReadOnly =  (field)  => {
  if (null != field) {
    // read only if either the field or the event is read only or the user cannot edit
    //had to remove the fullAdmin thing because events can now have ancillary fields which need to always be readonly regardless of permissions
    return !userCanEdit.value || getEventCustomFieldReadOnly(field) || isEventReadonly.value
  }
  return false
}
const getDefaultFieldReadOnly =  (wlp, readOnlyFieldValue, allowFlag)  => {
  //full Admin is never read only
  // read only if either the field or the event is read only
  return (!userStore.isSystemAdmin && getEventDefaultFieldReadOnly(wlp, readOnlyFieldValue, allowFlag)) || isEventReadonly.value
}
const getDefaultFieldHidden =  (wlp, hiddenFieldValue, hiddenFlag)  => {
  return getEventDefaultFieldHidden(wlp, hiddenFieldValue, hiddenFlag)
}
const populateDirtyCfvs = (field) => {
  let match = dirtyCfvs.value.find(f => (null !== f.id && f.id === field.id) || f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId)
  if (!match && field?.id !== -1) {
    dirtyCfvs.value.push(field)
  }
}
const getEventDetails = async () => {
  try {
    projectMismatch.value = false
    const {
      data,
      status
    } = await getRequest(`/projectProcessStep/${projectProcessStepId.value}/event/${ppsEventId.value}`)
    if (data && data.projectId && data.projectId !== projectId.value) {
      projectMismatch.value = true
      eventDetailsLoading.value = false
      appStore.showSnack('ERROR', `Invalid Request: Project Mismatch`)

    } else {
      selectedEvent.value = data
      //this verifies whether the event had a start time when the page loaded, if not then we allow all users to delete
      selectedEvent.value.allowAllUserDeletion = data.startTime === null
      //have to reset the pps stuff too in case they just go directly to the url

      projectStore.pps = {
        projectProcessStepId: selectedEvent.value.projectProcessStepId,
        processStepId: selectedEvent.value.processStepId,
        processStepName: selectedEvent.value.processStepName
      }
      window.document.title = project.value?.id ? `${project.value.projectName} - ${selectedEvent.value.eventName}`
          : `${selectedEvent.value.eventName}`
      projectStore.ppsEvent = selectedEvent.value
      projectStore.linkLabel = `${selectedEvent.value.eventName} (${selectedEvent.value.id})`
      projectStore.linkId = selectedEvent.value.id
      isEventReadonly.value = getIsEventReadonly()
      isUploadReadonly.value = getIsUploadReadonly()
      if (data.uniqueBehaviorTypeId === 1) {
        uniqueAlreadyHasValue.value = null != selectedEvent.value.startTime || null != selectedEvent.value.endTime || null != selectedEvent.value.resourceId
        getRoundRobinNumDays()
        userCanScheduleLeadAllocation()
        userCanScheduleRemoteLeadAllocation()
      }
      //this was causing an error if you clicked too fast between events
      if (data.id) {
        await getStatusesAssignedToEvent()
      }
      return status
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    let msg = e?.data?.message || 'Error Retrieving Details'
    appStore.showSnack('ERROR', msg)

  }
}
const deleteEvent = async  () => {
  const ppseId = selectedEvent.value.id
  appStore.loading = true
  selectedEvent.value.archived = true
  try {
    await deleteRequest(`/projectProcessStep/${projectProcessStepId.value}/event/${ppseId}`)
    //set navigation override so that if there were unsaved fields it won't ask you to try and save
    navigationOverride.value = true
    emit('refresh-upcoming-events')
    //go to the process step
    router.push(`/project/${projectId.value}/processStep/${projectProcessStepId.value}`)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Deleting Event')

    appStore.loading = false
  }
}
const checkForSchedulingConflicts = ()=> {
  saveEventDetails(false);
}
const saveEventDetails = async(forceSave) => {
  eventSaveOverrideRequired.value = true
  eventActionMissingRequirements.value = false
  appStore.loading = true
  try {
    let params = {
      id: selectedEvent.value.id,
      startTime: selectedEvent.value.startTime,
      endTime: selectedEvent.value.endTime,
      resourceId: selectedEvent.value.resourceId,
      saveVersion: selectedEvent.value.saveVersion,
      //we only send up the status if it changed. sql handles whether to save the value or not
      companyEventStatusTypeId: statusChanged.value ? selectedEvent.value.companyEventStatusTypeId : null,
      customFieldValues: dirtyCfvs.value,
      forceSave: (forceSave || (selectedEvent.value.companyEventStatusTypeId === 4))
    }
    const {data} = await putRequest(`/projectProcessStep/${projectProcessStepId.value}/event/${selectedEvent.value.id}/${params.forceSave}`, params)
    statusChanged.value = false
    dirtyCfvs.value = []
    ppseFieldsContainer.value.$el.scrollTop = 0
    selectedEvent.value = data
    appStore.showSnack('SUCCESS', 'Fields Saved')

    emit('refresh-upcoming-events')
    if (data.uniqueBehaviorTypeId === 1) {
      uniqueAlreadyHasValue.value = null != selectedEvent.value.startTime || null != selectedEvent.value.endTime || null != selectedEvent.value.resourceId
      getRoundRobinNumDays()
    }
  } catch (e) {
    if(e.status == 409){
      conflictingEvents.value = e.data;
    }
    else {
      logError(e)
      let saveMismatch = e.data?.message === 'Save Version Mismatch'
      let msg = saveMismatch ? `<div class="text-center">Cannot Save Changes. <br/>This event has been updated by another user. <br/>Click <a class="white--text underline" href="">here</a> to refresh.</div>` : 'Error Performing Event'
      appStore.showSnack('ERROR', msg, saveMismatch)

    }
  } finally {
    appStore.loading = false
  }
}
const toggleRoundRobinView = () => {
  if(!showRoundRobin.value) {
    // if clicking to open round robin, clear out any manually set dates
    selectedEvent.value.resourceId = null
    selectedEvent.value.startTime = null
    selectedEvent.value.endTime = null
  } else {
    availabilityDateField.value.dateValue = null
    selectedTimeSlot.value = {}
  }
  showRoundRobin.value = !showRoundRobin.value
}
const getAvailableTimeSlots = async(remote) => {
  //reset this list every search in case there is an error or no results it doesn't confuse the user
  timeSlots.value = []
  mostRecentSearchWasRemote.value = remote
  try {
    remoteSearchLoading.value = remote
    inPersonSearchLoading.value = !remote
    selectedTimeSlot.value = {}
    searchedTimeSlots.value = false

    let params = {
      projectId: projectId.value,
      startTime: moment(availabilityDateField.value.dateValue).startOf('d').utc().format('YYYY-MM-DDTHH:mm:ssZ'),
      endTime: moment(availabilityDateField.value.dateValue).endOf('d').utc().format('YYYY-MM-DDTHH:mm:ssZ'),
      availableDate: availabilityDateField.value.dateValue,
      remote: remote
    }
    const {data} = await getRequestWithParams(`/availability/timeSlots`, {params})
    searchedTimeSlots.value = true
    timeSlots.value = data
    remoteSearchLoading.value = false
    inPersonSearchLoading.value = false
    dateValueChanged.value = false
  } catch (e) {
    logError(e)
    remoteSearchLoading.value = false
    inPersonSearchLoading.value = false
    let errorMsg = e.data ? e.data.message : 'Error Retrieving Time Slots'
    appStore.showSnack('ERROR', errorMsg)

  }
}
const saveCloserAppointment = async() => {
  try {
    let body = {
      projectId: projectId.value,
      projectProcessStepId: projectProcessStepId.value,
      projectProcessStepEventId: selectedEvent.value.id, // i think?
      // startTime: moment(availabilityDateField.value.dateValue).startOf('d').utc().format('YYYY-MM-DDTHH:mm:ssZ'),
      // endTime: moment(availabilityDateField.value.dateValue).endOf('d').utc().format('YYYY-MM-DDTHH:mm:ssZ'),
      appointmentTime: selectedTimeSlot.value.scheduledStartTime,
      users: selectedTimeSlot.value.users,
      remote: mostRecentSearchWasRemote.value,
      customFieldValues: dirtyCfvs.value
    }
    appStore.loading = true
    const {data} = await postRequest(`/availability/setCloserAppointment`, body)
    if (data) {
      // customFieldGroups.value = data
      // setCfgValues()
      closerApptSaved.value = true
      showRoundRobin.value = false
      availabilityDateField.value.dateValue = null
      timeSlots.value = []
      selectedTimeSlot.value = {}
      //set the some values that may have updated when setting the closer appt event
      selectedEvent.value.startTime = data.appointmentStartTime
      selectedEvent.value.endTime = data.appointmentEndTime
      selectedEvent.value.resourceId = data.userPositionId
      selectedEvent.value.resource = data.userFullName
      selectedEvent.value.companyEventStatusTypeId = data.companyEventStatusTypeId
      selectedEvent.value.eventActions = data.eventActions
      uniqueAlreadyHasValue.value = true
      //reset the error messages:
      eventActionMissingRequirements.value = false
      saveErrorMsg.value = ''
      showUnperformableActions.value = true

    }
  } catch (e) {
    logError(e)
    let msg = e?.data?.message ?? 'Unable to Set Closer Appointment'
    appStore.showSnack('ERROR', msg)

  } finally {
    appStore.loading = false
  }
}
const checkAvailabilityDate = () => {
  //these values all need reset every time the date selected changes so they dont use a bad date/time combo
  dateValueChanged.value = true
  selectedTimeSlot.value = {}
  timeSlots.value = []
  if (availabilityDateField.value.dateValue !== null) {
    // Limit user to selecting availability dates < 8 days out
    const selectedDate = DateTime.fromISO(availabilityDateField.value.dateValue)
    const cappedDate = DateTime.local().set({
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0
    }).plus({days: roundRobinNumberOfDays.value})
    if (selectedDate > cappedDate) {
      availabilityDateField.value.dateValue = null
      appStore.showSnack('ERROR', `You can only schedule appointments ${roundRobinNumberOfDays.value} days in advance`)

    } else {
      populateDirtyCfvs(availabilityDateField.value)
    }
  }
}
const checkFieldsForUnique = () => {
  let validSave = true
  let startTime = selectedEvent.value.startTime
  let endTime = selectedEvent.value.endTime

  //if is for closer appt
  if (selectedEvent.value.uniqueBehaviorTypeId === 1) {
    if (!startTime || !endTime || !selectedEvent.value.resourceId) {
      validSave = false
      eventActionMissingRequirements.value = true
      actionRequiresEnd.value = !endTime
      actionRequiresResource.value = !selectedEvent.value.resourceId
      saveErrorMsg.value = 'Additional fields are required to save this event.'
    } else if (startTime && endTime && !moment(endTime).isAfter(startTime)) {
      validSave = false
      eventActionMissingRequirements.value = true
      saveErrorMsg.value = 'End time must be after start time'
    }
  } else if (null != selectedEvent.value.startTime) {
    //for all other types just compare start to end if end not null
    if (startTime && endTime && !moment(endTime).isAfter(startTime)) {
      validSave = false
      eventActionMissingRequirements.value = true
      saveErrorMsg.value = 'End time must be after start time'
    }
  }
  //per judson, dont require start time anymore
  // else {
  //   //only startTime is required to save fields
  //   validSave = false
  //   actionRequiresEnd.value = false
  //   actionRequiresResource.value = false
  //   eventActionMissingRequirements.value = true
  //   saveErrorMsg.value = 'Start Time is required to save the event fields'
  //   //dont do this for now. makes the page look weird after save
  //   // document.getElementById('event-header').scrollIntoView()
  // }

  //after everything, only save if valid
  if (validSave) {
    eventActionMissingRequirements.value = false
    defaultValuesChanged.value = false
    checkForSchedulingConflicts();
  }
}
const filterProjectProcessStepEvents = () => {
  return projectProcessStepEvents.value ? projectProcessStepEvents.value.filter(ppse => {
    return !ppse.archived
  }) : []
}
</script>

<style lang="scss">
.event-button .v-btn__content {
  //max-width: 100%;
  width: 100%;
  white-space: normal;
}

#event-header .v-toolbar__content {
  display: flex;
  align-items: flex-start;
}

.event-details-header {
  z-index: 10;
}

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


</style>
<style lang="scss" scoped>

.cfg-detail-header {
  padding-left: 0;
  padding-right: 0;
}

.scheduler-button-text {
  text-transform: capitalize;
  text-decoration: underline;
}

.scheduler-button-icon {
  text-decoration: none;
  font-size: 12px;
  color: var(--v-anchor-base);
}

.action-subheader {
  width: 186px;
  margin-top: 20px;
}

.padding-left-1 {
  padding-left: 1px; //keeps the Event Details toolbar from covering the border on the left panel
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
}

.action-button-name {
  display: block;
}

.action-button-subtitle {
  display: block;
  font-size: 10px;
}

.banner-card-swatch {
  min-height: 100%;
  width: 30px;
}

.action-button-subtitle-date {
  text-transform: lowercase;
}

</style>
