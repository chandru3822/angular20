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


const props = defineProps({
  project:Object,
  timezone:String,
})
const show = ref(true)
const userCanEdit = ref(true)


import { watch } from 'vue'
watch(props.project, () => {
  //do stuff
  debugger
})

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
    handleHidingGlobalLoader(this, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    let snackbar = getSnackbar('ERROR', 'Error Retrieving Resources')
    store.commit(AppMutations.SHOW_SNACK, snackbar)
    store.commit(AppMutations.SET_LOADING, false)
  }
}

</script>

<template>
<v-card id="map-project-modal" :class="{'pb-4': !userCanEdit}">
<!--  title and subtitle always show, even when collapsed-->
  <v-card-title class="d-flex align-start">
    <span class="label-large pr-1 break-word max-width-half">{{project.projectName}}</span>
    <v-spacer/>
    <v-btn class="mx-2" icon small color="primary" @click="togglePinToMap">
      <v-icon v-if="pinned">mdi-map-marker</v-icon>
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
    <div v-if="!project.start">
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
            :readonly="project.startFieldReadOnly || !userCanEdit || project.processStepStatusTypeId !== 1 || project.eventStatusTypeId !== 1"
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
        <v-btn color="primary" width="100%">Schedule</v-btn>
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
