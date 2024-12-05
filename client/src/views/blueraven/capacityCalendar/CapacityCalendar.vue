<script setup>
/*
*@name CapacityCalendar
*@author jess
*@date 11/12/24
*
*@description
*
*/
import FullCalendar from "@fullcalendar/vue";
import {onMounted, ref, watch} from "vue";
import constants from '@/helpers/constants'
import timeGridPlugin from "@fullcalendar/timegrid";
import dayGridPlugin from "@fullcalendar/daygrid";
import moment from "moment";
import {getRequestWithParams, putRequestWithRequestParams, postRequestWithRequestParams} from "@/helpers/helpers.js";
import {useAppStore} from "@/stores/AppStore.js";
import cloneDeep from "lodash.clonedeep";
import EditCapacityItem from "@/views/blueraven/capacityCalendar/EditCapacityItem.vue";
import ConfirmationDialog from "@/components/ConfirmationDialog.vue";

const appStore = useAppStore()
const capacityCalendar = ref(null)
const editMode = ref(false)
const capacityScheduleChanged = ref([])
const showConfirmDialog = ref(false)
const dialogBodyText = ref('The following time slot is currently overbooked, with bookings exceeding the allowed capacity.')
const dialogBodyDates = ref([])
const dialogShowMore = ref(false)

const calendarOptions = ref({
  plugins:[
    dayGridPlugin, timeGridPlugin
  ],
  schedulerLicenseKey: constants.FULL_CALENDAR_LICENSE_KEY,
  initialView:'timeGridWeek',
  //events
  eventSources:[
    (info, successCallback, failureCallback) => getCapacitySchedule(info, successCallback, failureCallback)
  ],
  eventColor: 'transparent',
  eventDisplay:'background',
  //headers
  headerToolbar:{
    left: 'customDuplicateWeek prev,customCurrentWeek,next',
    center: 'title',
    right: 'customCancel customEdit'
  },
  customButtons:{
    customCurrentWeek:{
      text:'Current Week',
      click: () => {
        let calendarApi = capacityCalendar.value.getApi()
        calendarApi.gotoDate(new Date())
      }
    },
    customDuplicateWeek:{
      text:'Auto Fill (Duplicate Previous Week)',
      click: () => {
        duplicateWeek()
      }
    },
    customEdit:{
      text:'Edit',
      click: async function(mouseEvent, htmlElement) {
        if(editMode.value === true){
          startSave()
        }
        else {
          editMode.value = true


        }
      }
    },
    customCancel:{
      text:'Cancel',
      click: () => {
        clearEditData()
      }
    }
  },
  dayHeaderFormat:{ weekday: 'short', month: 'short', day: 'numeric', omitCommas: true },
  //slots
  slotLabelFormat:{
    hour:'numeric',
    minute:'2-digit'
  },
  slotLabelInterval:"00:30:00",
  slotLabelClassNames:["text-left", "pa-4"],
  slotMinTime:"06:00:00",
  slotMaxTime:"22:00:00",
  allDaySlot: false
})

watch(editMode, () =>{
  console.log('editMode', editMode.value)
  switchCalendarEditMode()
})

const switchCalendarEditMode = () => {
  if(editMode.value){
    //hide the calendar nav buttons
    document.getElementsByClassName('fc-prev-button')[0]?.classList.add('hidden')
    document.getElementsByClassName('fc-customCurrentWeek-button')[0]?.classList.add('hidden')
    document.getElementsByClassName('fc-next-button')[0]?.classList.add('hidden')

    //show the cancel and duplicate week buttons
    document.getElementsByClassName('fc-customDuplicateWeek-button')[0]?.classList.remove('hidden')
    document.getElementsByClassName('fc-customCancel-button')[0]?.classList.remove('hidden')
  } else {
    //show the calendar nav buttons
    document.getElementsByClassName('fc-prev-button')[0]?.classList.remove('hidden')
    document.getElementsByClassName('fc-customCurrentWeek-button')[0]?.classList.remove('hidden')
    document.getElementsByClassName('fc-next-button')[0]?.classList.remove('hidden')

    //hide the cancel and duplicate week buttons
    document.getElementsByClassName('fc-customDuplicateWeek-button')[0]?.classList.add('hidden')
    document.getElementsByClassName('fc-customCancel-button')[0]?.classList.add('hidden')
  }
  document.getElementsByClassName('fc-customEdit-button')[0].childNodes[0].nodeValue = editMode.value ? 'Save' : 'Edit'

}

const getTimeSlotLabel = (date) => {
  let dateText = `${moment(date, "hh:mm").format("h:mma").toString()}`
  const endDate = moment(date, "hh:mm").add(30, 'minutes').format("h:mma").toString()
  dateText += `-${endDate}`
  return dateText
}

const getCapacitySchedule = async(info, successCallback, failureCallback) =>{
  appStore.loading = true
  try{
    let params = {
      orgId:4548,
      startTime: info.start,
      endTime: info.end
    }

    const {data} = await getRequestWithParams(
        '/virtualResourceCapacity/capacityScheduleForRange', {params: params})
    let events = cloneDeep(data)
    events.forEach((event, index) => {
      event.id = index
      event.start = moment.utc(event.start).format()
      event.end = moment.utc(event.end).format()
      event.extendedProps = {
        maxCapacity: event.maxCapacity,
        currentlyBooked: event.currentlyBooked
      }
    });
    successCallback(events)
    appStore.loading = false
  } catch(e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Capacity Calendar')
    failureCallback(e)
    appStore.loading = false
  }
}

const addInputToChangedSchedule = (input) => {
  const duplicate = capacityScheduleChanged.value.find(s => s.id === input.id)
  if(duplicate){
    capacityScheduleChanged.value = capacityScheduleChanged.value.filter(s => s.id !== input.id);
  }
  capacityScheduleChanged.value.push(input);
}

const startSave = () => {
  let count = 0
  dialogBodyDates.value
  for(var c of capacityScheduleChanged.value){
    if(c.maxCapacity < c.currentlyBooked){
      count++
      dialogBodyDates.value.push(c.start)
    }
  }
  if(count > 0) {
    showConfirmDialog.value = true
    if(count > 1){
      dialogBodyText.value = 'The following time slots are currently overbooked, with bookings exceeding the allowed capacity.'
    }
  }
  else {
    saveCapacities()
  }
}

const clearEditData = () =>{
  editMode.value = false
  capacityScheduleChanged.value = []
  dialogBodyDates.value = []
}

const saveCapacities = async() => {
  appStore.loading = true
  try {
    let params = {
      orgId: 4548
    }
    const {data} = await putRequestWithRequestParams('/virtualResourceCapacity/maxCapacityList', capacityScheduleChanged.value, params, null)
    const calendarApi = capacityCalendar.value.getApi()
    calendarApi.refetchEvents()
    appStore.showSnack('SUCCESS', 'Scheduled Saved')
    clearEditData()
    appStore.loading = false
  } catch(e){
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Saving Schedule')
    appStore.loading = false
  }
}

const capacityRule = (value) => {
  return value >= props.booked
}
const positiveCapacity = (value) => {
  return value > 0
}

const clickEditSaveBtn = async function() {
  if (editMode.value === true) {
    await saveCapacities()
  } else {
    editMode.value = true
  }
}

const duplicateWeek = async () => {
  const calendarApi = capacityCalendar.value.getApi()
  const start = calendarApi.view.activeStart
  const end = calendarApi.view.activeEnd
  try {
    let params = {
      orgId: 4548,
      currentWeekStartTime: start,
      currentWeekEndTime: end
    }
    const {data} = await postRequestWithRequestParams('/virtualResourceCapacity/duplicateWeek', null, params);
    calendarApi.refetchEvents()
    editMode.value = false
    appStore.showSnack('SUCCESS', 'Week Duplicated')
    appStore.loading = false

  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Duplicating Week')
    appStore.loading = false
  }

}

onMounted(async () => {
  const calendarApi = capacityCalendar.value.getApi()
  calendarApi.render()
  switchCalendarEditMode()
})
</script>

<template>
<div id="scheduling-capacity-calendar-container" class="one-hunned height-one-hunned pa-6">
  <ConfirmationDialog :open-dialog="showConfirmDialog" @close-dialog="showConfirmDialog = false"
                      @confirm="[showConfirmDialog = false, saveCapacities()]">
    <template v-slot:title>Do you want to save capacity change?</template>
    <template v-slot:yes>Yes, continue to save</template>
    <template v-slot:no>No, do not save changes</template>
    <div class="pb-3 body-large">{{dialogBodyText}}</div>
    <div v-for="(date, index) in dialogBodyDates" class="body-medium">
      <span v-if="index < 5 || dialogShowMore">{{ date  | formatDate('timestamp', 'ddd MMM D') }}, {{ getTimeSlotLabel(date) }}</span>
    </div>
    <a-btn v-if="dialogBodyDates.length > 5" variant="text" @click="dialogShowMore=!dialogShowMore">{{dialogShowMore ? 'Show Less' : 'Show More'}}</a-btn>
  </ConfirmationDialog>
  <FullCalendar ref="capacityCalendar" id="scheduling-capacity-calendar" :options="calendarOptions">
    <template v-slot:slotLabelContent="{date}">
      {{ getTimeSlotLabel(date) }}
    </template>
    <template v-slot:dayHeaderContent="{date}">
      <div class="one-hunned grey--text text--darken-2">
        <div class="text-uppercase">{{ date | formatDate('date','ddd') }}</div>
        <div>{{ date | formatDate('date', 'MMM D')}}</div>
      <div class="capacity-booked-grid-header">
        <div class="capacity-col label-small grey--text text--darken-2">Capacity</div>
        <div class="booked-col label-small grey--text text--darken-2">Booked</div>
      </div>
      </div>
    </template>
    <template v-slot:eventContent="{event}">
      <div v-if="!editMode" class="capacity-booked-grid">
        <div class="capacity-col label-medium  d-flex justify-center align-center" :class="{'error--text capacity-exceeded': event.extendedProps.maxCapacity < event.extendedProps.currentlyBooked}">
          {{ event.extendedProps.maxCapacity || 0}}
        </div>
        <div class="booked-col label-medium grey--text text--darken-2 d-flex justify-center align-center">
          {{ event.extendedProps.currentlyBooked }}
        </div>
      </div>
      <EditCapacityItem v-else :max-capacity="event.extendedProps.maxCapacity" :booked=" event.extendedProps.currentlyBooked" @input="v => addInputToChangedSchedule({id: event.id, start: moment.utc(event.start).toString(), end: moment.utc(event.end).toString(), maxCapacity:Number(v), currentlyBooked: event.extendedProps.currentlyBooked})"/>

    </template>
  </FullCalendar>
</div>
</template>

<style scoped lang="scss">
.capacity-booked-grid-header{
  display:grid;
  grid-template-columns: 1fr 1fr;
  border-top: var(--v-grey-lighten1) solid 1px;
  width:100%;
}

.capacity-booked-grid {
  display:grid;
  grid-template-columns: 1fr 1fr;
  width:100%;
  height:100%;
}
</style>
<style lang="scss">
#scheduling-capacity-calendar-container {
  .fc-timegrid-slots tr:nth-child(2 n + 1) > td {
  background-color: rgba(68, 134, 195, .09) //using rgba instead of primary-lighten9 because if you use a color with 100% opacity, the column lines are covered up
}
  .fc-col-header-cell-cushion{
    padding:4px 0 0 0;
  }
  th.fc-col-header-cell.fc-day > div > a {
    display:block;
    height:fit-content;
  }

  .capacity-col, .booked-col{
    padding: 12px;
  }
  .capacity-col {
    border-right: var(--v-grey-lighten2) solid 1px;
  }
  .capacity-col.edit-mode, .booked-col.edit-mode {
    padding: unset;
    overflow:hidden;
  }
  .capacity-col.edit-mode {
    margin-bottom: -4px;
  }

  .capacity-col.capacity-exceeded {
    border: var(--v-error-base) solid 2px;
    margin: -1px;
  }

  th{
    background-color: var(--v-grey-lighten3);
  }

  //selects the input field in edit mode to limit the width
  #scheduling-capacity-calendar > div.fc-view-harness > div > table > tbody > tr > td > div > div > div > div.fc-timegrid-cols > table > tbody > tr > td.fc-day.fc-timegrid-col > div > div.fc-timegrid-col-bg > div > div > div > div > div {
    max-width: 50px;
  }
  #scheduling-capacity-calendar > div.fc-view-harness > div > table > tbody > tr > td > div > div > div > div.fc-timegrid-cols > table > tbody > tr > td.fc-day.fc-timegrid-col > div > div.fc-timegrid-col-bg > div > div > div > div > div > div > div.v-input__slot > div > input {
    text-align: center;
  }

  .hidden{
    display: none;
  }
}
</style>
