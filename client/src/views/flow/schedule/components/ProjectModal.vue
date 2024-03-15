<script setup>
/*
*@name ProjectModal
*@author jess
*@date 2/23/24
*
*@description
*
*/
import {getCurrentInstance, computed, ref, watch} from "vue";
import {AppMutations} from "@/stores/AppStore.js";
import {handleHidingGlobalLoader, postRequest} from "@/helpers/helpers.js";
import DatetimePickerInput from "@/components/DatetimePickerInput.vue";
import ConfirmationDialog from "@/components/ConfirmationDialog.vue";
import {getCancelledCompanyStatusTypesAssignedToPpsEvent} from "@/services/eventStatusTypeService.js";
import {ScheduleMutations} from "@/stores/ScheduleStore.js";
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";
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

const emit = defineEmits(['toggleProjectMapPin'])

const props = defineProps({
  project:Object,
  timezone:Object,
  resourceFromCalendar:Object,
})
const show = ref(true)
const fieldsSaving = ref(false)
const conflictingEvents = ref()
const saveInvalid = ref(true)
const confirmUnschedule = ref(false)
const cancelledCompanyEventStatuses = ref()

const userCanEdit = computed(() => {
  return  userStore.userHasFeatureAccessLevel('EVENTS', 'EDIT')
})
const timezoneFriendly = computed(() => {
  return  userStore.timezone?.value
})

watch(() => props.resourceFromCalendar, () => {
  if(props.resourceFromCalendar.id) {
    scheduleCalendarResourceToProject(props.resourceFromCalendar)
  } else {
    props.project.resource = null
    setSelectedResourceInStore(null)
    validateSaveEvent()
  }
})

const setSelectedResourceInStore = (resourceId) => {
  if(resourceId){
    store.commit(ScheduleMutations.SET_SELECTED_RESOURCE_ID, resourceId)
    let snackbar = createSnackbar('Resource assigned')
    store.commit(AppMutations.SHOW_SNACK, snackbar)
  }
  else {
    store.commit(ScheduleMutations.SET_SELECTED_RESOURCE_ID, null)
    snackbar(createSnackbar('Resource unassigned'))
  }
}

//this snackbar is different from others so we built it here
const createSnackbar = (text) => {
  return {
    y: 'bottom',
    x: null,
    mode: '',
    timeout: 5000,
    text: text,
    color: 'grey darken-3',
    fontClass: 'secondary--text',
    enabled: true
  }
}

const openInNewTab = (path) => {
  let routerData = router.resolve({path})
  window.open(routerData.href, '_blank')
}

const eventIsSameDay = () => {
  if(!props.project.start){
    return false
  }
  const start = new Date(props.project.start)
  const end = new Date(props.project.end)
  return start.getDate() === end.getDate() && start.getMonth() === end.getMonth() && start.getFullYear() === end.getFullYear()
}

const getResources = async(item) => {
  appStore.loading = true
  try {
    item.resources = []
    let params = {
      companyId: item.companyId,
      systemListId: item.systemListId,
      systemListOptionIds: item.systemListOptionIds,
      resourceId: item.resourceId
    }
    const {data, status} = await postRequest(`/schedule/projectResources`, params, null, [])
    item.resources = data || []
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Resources')
    appStore.loading = false
  }
}

const scheduleCalendarResourceToProject = (resource) => {
  props.project.resource = props.project.resources.find( r => r.id === resource.extendedProps.orgId)
  if(!props.project.resource) {
    props.project.resource = resource.extendedProps?.userPositions?.find(up => {
      return  props.project.resources.find(r => r.id === up.id)
    })
  }
  setSelectedResourceInStore(props.project.resource.id)
  validateSaveEvent()
}

const getCancelledCompanyEventStatuses = async () => {
  try {
    const {data} = await getCancelledCompanyStatusTypesAssignedToPpsEvent(props.project.projectProcessStepId, props.project.projectProcessStepEventId)
    cancelledCompanyEventStatuses.value = data
    if(data?.length === 1) {
      props.project.cancelledCompanyStatusType = data[0]
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error fetching process step statuses')
  }
}


const validateSaveEvent = () => {
  saveInvalid.value = !!(!props.project || !props.project.start || !props.project.end
      || !props.project.resource || !props.project.resource.id || (props.project.start >= props.project.end) ||
      //if all 3 fields are read only, dont let them save
      (props.project.startFieldReadOnly && props.project.endFieldReadOnly && props.project.resourceFieldReadOnly));
  console.log('save invalid?', saveInvalid.value)
}
const checkForSchedulingConflicts = async() => {
  await scheduleProject(false);
}
const cancelDialog = async() => {
  conflictingEvents.value = null
  fieldsSaving.value = false
  // $refs.value.calendar.getEvents(false, true)
}
const scheduleProject = async(forceSave) => {
  props.project.resourceId = props.project.resource.id
  props.project.resourceName = props.project.resource.name
  props.project.forceSave = forceSave
  appStore.loading = true
  try {
    const {status} = await postRequest(`/schedule/saveEvent`, props.project)
    //if saved successfully then increase the "saveVersion" so they can make a 2nd change too
    props.project.saveVersion++
    // this tells the calendar to reload the events after a save (probably could just push the result into the existing records somehow but that was way harder)
    // this.$refs.calendar.getEvents(false, true) todo: figure out what this should change to
    handleHidingGlobalLoader(vueInstance, status)
    fieldsSaving.value = false
    snackbar('SUCCESS', 'Successfully Scheduled Project')
  } catch (e) {
    if(e.status === 409){
      conflictingEvents.value = e.data;
      fieldsSaving.value = false
      appStore.loading = false
    }
    else {
      console.error('*** ERROR ***', e)
      let saveMismatch = e.data?.message === 'Save Version Mismatch'
      let msg = saveMismatch ? 'Error Scheduling Project. This event has been update by another user. Please refresh to see the latest data.' : 'Error Scheduling Project'
      snackbar('ERROR', msg)
      fieldsSaving.value = false
      appStore.loading = false
    }
  }
}

const cancelProjectProcessStepEvent = async() => {
  try {
    const {status} = await postRequest(`/projectProcessStep/${props.project.projectProcessStepId}/event/${props.project.projectProcessStepEventId}/status`, props.project.cancelledCompanyStatusType)
    props.project.eventStatusTypeId = props.project?.cancelledCompanyStatusType?.id
    handleHidingGlobalLoader(vueInstance, status)
    snackbar('SUCCESS', 'Successfully Unscheduled Event')
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Unscheduling Event')
    appStore.loading = false
  }
}

</script>

<template>
<v-card id="map-project-modal" :class="{'pb-4': !userCanEdit}" elevation="10">
<!--  title and subtitle always show, even when collapsed-->
  <v-card-title class="d-flex align-start">
    <span class="label-large pr-1 break-word max-width-half">{{project.projectName}}</span>
    <v-spacer/>
    <AlbatrossButton class="mx-2" icon size="small" color="primary" @click="emit('toggleProjectMapPin')">
      <v-icon v-if="project.pinned">mdi-map-marker</v-icon>
      <v-icon v-else>mdi-map-marker-off</v-icon>
    </AlbatrossButton>
    <AlbatrossButton
        icon size="small" color="primary"
        @click="show = !show"
    >
      <v-icon>{{ show ? 'mdi-chevron-down' : 'mdi-chevron-up' }}</v-icon>
    </AlbatrossButton>
  </v-card-title>
  <v-card-subtitle @click="openInNewTab(`/project/${project.projectId}/processStep/${project.projectProcessStepId}/event/${project.projectProcessStepEventId}`)" class="clickable anchor--text pt-2 pb-3">
    {{project.eventName}} <v-icon small class="anchor">mdi-open-in-new</v-icon>
  </v-card-subtitle>
  <!-- ------------------- -->

  <!-- Everything below only shows when expanded -->
  <div v-show="show">
    <!--  When the event hasn't been scheduled  -->
    <div v-if="userCanEdit && project.processStepStatusTypeId === 1 && project.editableInSchedule">
      <v-card-text class="py-0">
        <v-autocomplete v-model="project.resource"
                        :items="project.resources"
                        :label="project.resourceFieldName  || 'Resource'"
                        placeholder=" "
                        return-object
                        clearable
                        hide-details
                        dense
                        item-text="name"
                        item-value="id"
                        @input="[validateSaveEvent(), setSelectedResourceInStore(project.resource?.id)]"
                        @click:clear="setSelectedResourceInStore(null)"
                        class="pb-2"
                        :active="!!resourceFromCalendar"
        />              <!--setting the 'active' prop this way forces the value to appear when when click the schedule button on the calendar-->
        <DatetimePickerInput
            v-model="project.start"
            :timezone="timezone.value"
            :readonly="project.startFieldReadOnly"
            :type="'timestamp'"
            :format="'MMMM DD, YYYY, h:mm A'"
            label="Start Time"
            hide-details
            @input="validateSaveEvent()"
        />
        <div class="body-small grey--text text--darken-2 py-2">*Scheduling in {{timezoneFriendly}}</div>
        <DatetimePickerInput
            v-model="project.end"
            :timezone="timezone.value"
            :readonly="project.endFieldReadOnly || !userCanEdit || project.processStepStatusTypeId !== 1 || project.eventStatusTypeId !== 1"
            :type="'timestamp'"
            :format="'MMMM DD, YYYY, h:mm A'"
            label="End Time"
            hide-details
            @input="validateSaveEvent()"
        />
        <div class="body-small grey--text text--darken-2 py-2">*Scheduling in {{timezoneFriendly}}</div>
      </v-card-text>
      <v-card-actions class="pb-4 px-4">
        <AlbatrossButton color="primary" html-style="width:100%" class="body-medium"
               :disabled="fieldsSaving || saveInvalid"
               @click="[fieldsSaving = true, checkForSchedulingConflicts()]"
        >Schedule</AlbatrossButton>
      </v-card-actions>
    </div>
<!-- ------------------- -->
    <div v-else>
      <v-card-text class="py-0 body-large">
        Scheduled for
        <span v-if="eventIsSameDay()">{{project.start | formatDate('timestamp','MMMM DD YYYY, h:mm a')}} - {{project.end | formatDate('timestamp','h:mm a')}}</span>
        <span v-else> {{project.startDate | formatDate('timestamp','MMMM DD YYYY, h:mm a')}} - {{project.end | formatDate('timestamp','MMMM DD YYYY, h:mm a')}}</span>
        with {{project.resourceName}}
        <div class="body-small grey--text text--darken-2 py-2">*Scheduling in US/Mountain Time</div>
      </v-card-text>
      <v-card-actions v-if="userCanEdit" class="pt-1 pb-4 px-4">
        <v-spacer/>
        <AlbatrossButtonSecondary v-if="project.editableInSchedule" @click="[confirmUnschedule = true, getCancelledCompanyEventStatuses()]" color="primary" size="small" >Unschedule</AlbatrossButtonSecondary>
      </v-card-actions>
    </div>
<!-- ------------------- -->
  </div>
  <ConfirmationDialog v-if="conflictingEvents != null" :open-dialog="conflictingEvents?.length > 0" @confirm="scheduleProject(true)" @close-dialog="cancelDialog()">
    <template v-if="conflictingEvents.length > 1" v-slot:title>Conflicts</template>
    <template v-else v-slot:title>Conflict</template>
    Resource <b>{{project.resourceName}}</b>
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
  <ConfirmationDialog :open-dialog="confirmUnschedule" @close-dialog="confirmUnschedule = false" @confirm="cancelProjectProcessStepEvent">
    <template v-slot:title>Unschedule</template>
    Are you sure you want to unschedule and remove {{project.projectName}} {{project.eventName}} event from {{project.resourceName}}’s calendar?
    <v-autocomplete
        v-model="project.companyEventStatusTypeId"
        :items="cancelledCompanyEventStatuses"
        label="Event's new status"
        :disabled="false"
        item-text="eventStatusType"
        item-value="id"
        @input="[statusChanged = true, defaultValuesChanged = true]"
        class="mt-2"
    />
    <template v-slot:yes>Unschedule</template>
  </ConfirmationDialog>
</v-card>
</template>

<style scoped lang="scss">
#map-project-modal {
  position: absolute;
  bottom: 24px;
  right: 24px;
  width: 280px;
  z-index: 10;
}
</style>
