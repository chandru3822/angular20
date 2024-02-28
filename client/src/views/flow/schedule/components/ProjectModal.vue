<script setup>
/*
*@name ProjectModal
*@author jess
*@date 2/23/24
*
*@description
*
*/
import {getCurrentInstance, ref} from "vue";
import {AppMutations} from "@/stores/AppStore.js";
import {getSnackbar, handleHidingGlobalLoader, postRequest} from "@/helpers/helpers.js";
import DatetimePickerInput from "@/components/DatetimePickerInput.vue";

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const router = vueInstance.$router

const emit = defineEmits(['toggleProjectMapPin'])

const props = defineProps({
  project:Object,
  timezone:String,
})
const show = ref(true)
const userCanEdit = ref(store.getters.userHasFeatureAccessLevel('EVENTS', 'EDIT'))
const fieldsSaving = ref(false)
const conflictingEvents = ref()
const saveInvalid = ref(true)

// import { watch } from 'vue'
// watch(props.project, () => {
//   //do stuff
//   debugger
// })

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
    let snackbar = getSnackbar('SUCCESS', 'Successfully Scheduled Project')
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

</script>

<template>
<v-card id="map-project-modal" :class="{'pb-4': !userCanEdit}" elevation="10">
<!--  title and subtitle always show, even when collapsed-->
  <v-card-title class="d-flex align-start">
    <span class="label-large pr-1 break-word max-width-half">{{project.projectName}}</span>
    <v-spacer/>
    <v-btn class="mx-2" icon small color="primary" @click="emit('toggleProjectMapPin')">
      <v-icon v-if="project.pinned">mdi-map-marker</v-icon>
      <v-icon v-else>mdi-map-marker-off</v-icon>
    </v-btn>
    <v-btn
        icon small color="primary"
        @click="show = !show"
    >
      <v-icon>{{ show ? 'mdi-chevron-down' : 'mdi-chevron-up' }}</v-icon>
    </v-btn>
  </v-card-title>
  <v-card-subtitle class="primary--text pt-2 pb-3">
    {{project.eventName}} <v-icon small @click="openInNewTab(`/project/${project.projectId}/processStep/${project.projectProcessStepId}/event/${project.projectProcessStepEventId}`)" class="anchor">mdi-open-in-new</v-icon>
  </v-card-subtitle>
  <!-- ------------------- -->

  <!-- Everything below only shows when expanded -->
  <div v-show="show">
    <!--  When the event hasn't been scheduled  -->
    <div v-if="userCanEdit && project.processStepStatusTypeId === 1 && project.eventStatusTypeId === 1">
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
                        @input="validateSaveEvent()"
                        class="pb-2"
        />
        <DatetimePickerInput
            v-model="project.start"
            :timezone="timezone"
            :readonly="project.startFieldReadOnly"
            :type="'timestamp'"
            :format="'MMMM DD, YYYY, h:mm A'"
            label="Start Time"
            hide-details
            @input="validateSaveEvent()"
        />
        <div class="body-small grey--text text--darken-2 py-2">*Scheduling in US/Mountain Time</div>
        <DatetimePickerInput
            v-model="project.end"
            :timezone="timezone"
            :readonly="project.endFieldReadOnly || !userCanEdit || project.processStepStatusTypeId !== 1 || project.eventStatusTypeId !== 1"
            :type="'timestamp'"
            :format="'MMMM DD, YYYY, h:mm A'"
            label="End Time"
            hide-details
            @input="validateSaveEvent()"
        />
        <div class="body-small grey--text text--darken-2 py-2">*Scheduling in US/Mountain Time</div>
      </v-card-text>
      <v-card-actions class="pb-4 px-4">
        <v-btn color="primary" width="100%"
               :disabled="fieldsSaving || saveInvalid"
               @click="[fieldsSaving = true, checkForSchedulingConflicts()]"
        >Schedule</v-btn>
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
        <v-btn color="primary" small text class="text-capitalize">Unschedule</v-btn>
      </v-card-actions>
    </div>
<!-- ------------------- -->
  </div>
  <ConfirmationDialog v-if="conflictingEvents != null" :open-dialog="conflictingEvents != null && conflictingEvents.length > 0" @confirm="scheduleProject(true)" @close-dialog="cancelDialog()">
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
</style>
