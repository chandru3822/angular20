<script setup>
/*
*@name ProjectModal
*@author jess
*@date 2/23/24
*
*@description
*
*/
import { computed, getCurrentInstance, onMounted, ref, watch } from 'vue'
import { AppMutations } from '@/stores/AppStore.js'
import { getRequest, getSnackbar, handleHidingGlobalLoader, postRequest } from '@/helpers/helpers.js'
import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
import ConfirmationDialog from '@/components/ConfirmationDialog.vue'
import { ScheduleMutations } from '@/stores/ScheduleStore.js'
import AlbatrossButton from '@/components/customVuetify/AlbatrossButton.vue'
import { getEventDefaultFieldReadOnly } from '@/services/customFieldService.js'

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const router = vueInstance.$router
const vuetify = vueInstance.$vuetify
const route = vueInstance.$route
const emit = defineEmits(['toggleProjectMapPin'])

const props = defineProps({
  project:Object,
  timezone:Object,
  resourceFromCalendar:Object,
})
const show = ref(vuetify.breakpoint.mdAndUp)
const userCanEdit = ref(store.getters.userHasFeatureAccessLevel('EVENTS', 'EDIT'))
const userCanManage = ref(store.getters.userHasFeatureAccessLevel('EVENTS', 'MANAGE'))
const userIsAdmin = ref(store.getters.userHasFeatureAccessLevel('EVENTS', 'ADMIN'))
const fieldsSaving = ref(false)
const conflictingEvents = ref()
const saveInvalid = ref(true)
const cancelledCompanyEventStatuses = ref()
const timezoneFriendly = ref(store.state.schedule.timezone.friendlyValue)
const event = ref(null)
const ppsId = ref(route.query.projectProcessStepId)
const ppsEventId = ref(route.query.projectProcessStepEventId)

watch(() => props.resourceFromCalendar, () => {
  if(props.resourceFromCalendar.id) {
    scheduleCalendarResourceToProject(props.resourceFromCalendar)
  } else {
    props.project.resource = null
    setSelectedResourceInStore(null)
    validateSaveEvent()
  }
})

watch(() => store.state.schedule.timezone.friendlyValue, (fv) => {
  timezoneFriendly.value = fv
})

const isUserWhitelisted = computed(() => {
	if(event.value?.readonlyWhiteListedPositions) {
		for (let wlp of event.value?.readonlyWhiteListedPositions) {
			let match = store.state.user.details.userPositions.find(up => up.positionId === wlp.positionId)
			if (match) {
				return true //if the user has a position that matches any of the whiteList positions, the user should see the event
			}
		}
		return false //if we go through all the whiteList positions and haven't found a match, the user should not see the event
	}
})

const isEventEditableByThisUserIgnoringReadOnly = computed(() => {
	//can the user edit the field if the readonly setting is false
	// if events admin/manager then they can edit any event fields regardless of event/process step status
	return userIsAdmin.value || userCanManage.value || (userCanEdit.value && event.value?.eventStatusTypeId === 1 && event.value?.processStepStatusTypeId === 1)
})

const isEventReadyOnly = computed(() => {
	return !store.getters.isFullAdmin && ((event.value?.readonly && !isUserWhitelisted.value) || !isEventEditableByThisUserIgnoringReadOnly.value)
})

//this logic comes from ProjectProcessStepEvent.vue. We want the readonly logic here to match that
const isResourceReadOnly = computed(() => {
	return (!store.getters.isFullAdmin &&
			getEventDefaultFieldReadOnly(store, event.value?.resourceWhiteListedPositions, event.value?.resourceReadOnly, event.value?.resourceReadOnlyAllow)) ||
		isEventReadyOnly.value
})

const isStartReadOnly = computed(() => {
	return (!store.getters.isFullAdmin &&
		getEventDefaultFieldReadOnly(store, event.value?.startTimeWhiteListedPositions, event.value?.startTimeReadOnly, event.value?.startTimeReadOnlyAllow)) ||
		isEventReadyOnly.value
})

const isEndReadOnly = computed(() => {
	return (!store.getters.isFullAdmin &&
			getEventDefaultFieldReadOnly(store, event.value?.endTimeWhiteListedPositions, event.value?.endTimeReadOnly, event.value?.endTimeReadOnlyAllow)) ||
		isEventReadyOnly.value
})

onMounted(async () => {
	try {
		const {data} = await getRequest(`/projectProcessStep/${ppsId.value}/event/${ppsEventId.value}`)
		event.value = data
	} catch (e) {
		let snackbar = getSnackbar('ERROR', 'Failed to fetch event details')
		store.commit(AppMutations.SHOW_SNACK, snackbar)
	}
})

const setSelectedResourceInStore = (resourceId) => {
  if(resourceId){
    store.commit(ScheduleMutations.SET_SELECTED_RESOURCE_ID, resourceId)
  }
  else {
    store.commit(ScheduleMutations.SET_SELECTED_RESOURCE_ID, null)
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
  store.commit(AppMutations.SET_LOADING, true)
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
    let snackbar = getSnackbar('ERROR', 'Error Retrieving Resources')
    store.commit(AppMutations.SHOW_SNACK, snackbar)
    store.commit(AppMutations.SET_LOADING, false)
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
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await postRequest(`/schedule/saveEvent`, props.project)
    //if saved successfully then increase the "saveVersion" so they can make a 2nd change too
    props.project.saveVersion++
    // this tells the calendar to reload the events after a save (probably could just push the result into the existing records somehow but that was way harder)
    // this.$refs.calendar.getEvents(false, true) todo: figure out what this should change to
    handleHidingGlobalLoader(vueInstance, status)
    fieldsSaving.value = false
    let snackbar = getSnackbar('SUCCESS', 'Job Scheduled')
    store.commit(AppMutations.SHOW_SNACK, snackbar)
  } catch (e) {
    if(e.status === 409){
      conflictingEvents.value = e.data;
      fieldsSaving.value = false
      store.commit(AppMutations.SET_LOADING, false)
    }
    else {
      console.error('*** ERROR ***', e)
      let saveMismatch = e.data?.message === 'Save Version Mismatch'
      let msg = saveMismatch ? 'Error Scheduling Project. This event has been update by another user. Please refresh to see the latest data.' : 'Error Scheduling Project'
      let snackbar = getSnackbar('ERROR', msg)
      fieldsSaving.value = false
      store.commit(AppMutations.SHOW_SNACK, snackbar)
      store.commit(AppMutations.SET_LOADING, false)
    }
  }
}

const cancelProjectProcessStepEvent = async() => {
  try {
    const {status} = await postRequest(`/projectProcessStep/${props.project.projectProcessStepId}/event/${props.project.projectProcessStepEventId}/status`, props.project.cancelledCompanyStatusType)
    props.project.eventStatusTypeId = props.project?.cancelledCompanyStatusType?.id
    handleHidingGlobalLoader(vueInstance, status)
    let snackbar = getSnackbar('SUCCESS', 'Successfully Unscheduled Event')
    store.commit(AppMutations.SHOW_SNACK, snackbar)
  } catch (e) {
    console.error('*** ERROR ***', e)
    let snackbar = getSnackbar('ERROR', 'Error Unscheduling Event')
    store.commit(AppMutations.SHOW_SNACK, snackbar)
    store.commit(AppMutations.SET_LOADING, false)
  }
}

</script>

<template>
<v-card id="map-project-modal" :class="{'pb-4': !userCanEdit}" elevation="10">
<!--  title and subtitle always show, even when collapsed-->
  <v-card-title class="d-flex align-start clickable"  @click="show = !show">
    <span class="label-large pr-1 break-word max-width-half">{{project.projectName}}</span>
    <v-spacer/>
    <AlbatrossButton class="mx-2" icon size="small" color="primary" @click.native.stop="emit('toggleProjectMapPin')">
      <v-icon v-if="project.pinned">mdi-map-marker</v-icon>
      <v-icon v-else>mdi-map-marker-off</v-icon>
    </AlbatrossButton>
    <AlbatrossButton
        icon size="small" color="primary"
    >
      <v-icon>{{ show ? 'mdi-chevron-down' : 'mdi-chevron-up' }}</v-icon>
    </AlbatrossButton>
  </v-card-title>
  <v-card-subtitle class="clickable anchor pt-2 pb-5">
    <span @click="openInNewTab(`/project/${project.projectId}/processStep/${project.projectProcessStepId}/event/${project.projectProcessStepEventId}`)">{{project.eventName}} <v-icon small class="anchor">mdi-open-in-new</v-icon></span>
  </v-card-subtitle>
  <!-- ------------------- -->

  <!-- Everything below only shows when expanded -->
  <div v-show="show">
    <!--  When the event hasn't been scheduled  -->
    <div v-if="userCanEdit && project.editableInSchedule">
      <v-card-text class="py-0">
        <v-autocomplete v-model="project.resource"
                        :items="project.resources"
                        :label="project.resourceFieldName  || 'Resource'"
						:disabled="isResourceReadOnly"
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
        >              <!--setting the 'active' prop this way forces the value to appear when when click the schedule button on the calendar-->

          <template v-slot:item="data">
            <div class="body-large">{{data.item.name}}</div>
          </template>
        </v-autocomplete>
        <DatetimePickerInput
            v-model="project.start"
            :timezone="timezone?.value"
            :readonly="isStartReadOnly"
            :type="'timestamp'"
            :format="'MMMM DD, YYYY, h:mm A'"
            label="Start Time"
            hide-details
            @input="validateSaveEvent()"
        />
        <div class="body-small grey--text text--darken-2 py-2">*Scheduling in {{timezoneFriendly}}</div>
        <DatetimePickerInput
            v-model="project.end"
            :timezone="timezone?.value"
            :readonly="isEndReadOnly"
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
    <div v-else-if="project.start || project.end">
      <v-card-text class="py-0 body-large">
        Scheduled for
        <span v-if="eventIsSameDay()">{{project.start | formatDate('timestamp','MMMM DD YYYY, h:mm a')}} - {{project.end | formatDate('timestamp','h:mm a')}}</span>
        <span v-else> {{project.startDate | formatDate('timestamp','MMMM DD YYYY, h:mm a')}} - {{project.end | formatDate('timestamp','MMMM DD YYYY, h:mm a')}}</span>
        with {{project.resourceName}}
        <div class="body-small grey--text text--darken-2 py-2">*Scheduling in US/Mountain Time</div>
      </v-card-text>
      <v-card-actions v-if="userCanEdit" class="pt-1 pb-4 px-4">
        <v-spacer/>
      </v-card-actions>
    </div>
    <div v-else>
      <v-card-text class="py-0 pb-4 body-large">
        This event hasn't been scheduled. Please use the project page to schedule.      </v-card-text>
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
.max-width-half{
  //okay yes, this is more than half but I don't feel like changing the name
  //it's so the name wraps instead of the buttons
  max-width: 70%;
}
</style>
