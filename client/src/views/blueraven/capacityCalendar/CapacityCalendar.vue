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
import {onMounted, ref} from "vue";
import * as constants from "constants";
import timeGridPlugin from "@fullcalendar/timegrid";
import dayGridPlugin from "@fullcalendar/daygrid";
import moment from "moment";
import {getRequestWithParams, putRequestWithRequestParams} from "@/helpers/helpers.js";
import {useAppStore} from "@/stores/AppStore.js";
import cloneDeep from "lodash.clonedeep";

const appStore = useAppStore()
const capacityCalendar = ref(null)
const editMode = ref(false)
const capacityScheduleChanged = ref([])

const calendarOptions = ref({
  initialView:'timeGridWeek',
  // events:[
  //   {
  //     id: 'a',
  //     title: 'my event',
  //     start: '2024-11-12T15:00:00.000+00:00',
  //     end: '2024-11-12T15:30:00.000+00:00'
  //   },
  //   {
  //     id: 'b',
  //     title: 'my event',
  //     start: '2024-11-13T15:00:00.000+00:00',
  //     end: '2024-11-13T15:30:00.000+00:00'
  //   },
  // ],
  eventSources:[
    (info, successCallback, failureCallback) => getCapacitySchedule(info, successCallback, failureCallback)
  ],
  eventColor: 'transparent',
  eventDisplay:'background',
  plugins:[
      dayGridPlugin, timeGridPlugin
  ],
  headerToolbar:{
    left: 'prev,customCurrentWeek,next',
    center: 'title',
    right: 'customEdit'
  },
  customButtons:{
    customCurrentWeek:{
      text:'Current Week'
    },
    customEdit:{
      text:'Edit',
      click: function(mouseEvent, htmlElement) {
        if(editMode.value === true){
          saveCapacities()
        }
        editMode.value = !editMode.value
        htmlElement.childNodes[0].nodeValue = editMode.value ? 'Save' : 'Edit'
      }
    }
  },
  dayHeaderFormat:{ weekday: 'short', month: 'short', day: 'numeric', omitCommas: true },
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

const getDateLabel = (date) => {
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
    debugger

    const {data} = await getRequestWithParams(
        '/virtualResourceCapacity/capacityScheduleForRange', {params: params})
    let events = cloneDeep(data)
debugger
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
  debugger
  const duplicate = capacityScheduleChanged.value.find(s => s.id === input.id)
  if(duplicate){
    capacityScheduleChanged.value = capacityScheduleChanged.value.filter(s => s.id !== input.id);
  }
  capacityScheduleChanged.value.push(input);
}

const saveCapacities = async() => {
  debugger
  appStore.loading = true
  try {
    let params = {
      orgId: 4548
    }

    const {data} = await putRequestWithRequestParams('/virtualResourceCapacity/maxCapacityList', capacityScheduleChanged.value, params, null)
    appStore.loading = false
  } catch(e){
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Saving Schedule')
    appStore.loading = false
  }
}
onMounted(async () => {
  const calendarApi = capacityCalendar.value.getApi()
  calendarApi.render()
})
</script>

<template>
<div id="scheduling-capacity-calendar-container" class="one-hunned height-one-hunned pa-6">
  <FullCalendar ref="capacityCalendar" id="scheduling-capacity-calendar" :options="calendarOptions">
    <template v-slot:slotLabelContent="{date}">
      {{getDateLabel(date)}}
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
        <div class="capacity-col label-medium grey--text text--darken-2 d-flex justify-center align-center">
          {{ event.extendedProps.maxCapacity || 0}}
        </div>
        <div class="booked-col label-medium grey--text text--darken-2 d-flex justify-center align-center">
          {{ event.extendedProps.currentlyBooked }}
        </div>
      </div>
      <div v-else class="capacity-booked-grid">
        <div class="capacity-col edit-mode label-medium grey--text text--darken-2 d-flex justify-center align-center">
          <a-text-field :value="event.extendedProps.maxCapacity" type="number" placeholder="0" @input="v => addInputToChangedSchedule({id: event.id, start: moment.utc(event.start).toString(), end: moment.utc(event.end).toString(), maxCapacity:Number(v)  })"></a-text-field>
        </div>
      <div class="booked-col edit-mode label-medium grey--text text--darken-2 d-flex justify-center align-center">
        {{ event.extendedProps.currentlyBooked }}
      </div>
      </div>

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

  th{
    background-color: var(--v-grey-lighten3);
  }

  #scheduling-capacity-calendar > div.fc-view-harness > div > table > tbody > tr > td > div > div > div > div.fc-timegrid-cols > table > tbody > tr > td.fc-day.fc-timegrid-col > div > div.fc-timegrid-col-bg > div > div > div > div > div {
    max-width: 50px;
  }
  #scheduling-capacity-calendar > div.fc-view-harness > div > table > tbody > tr > td > div > div > div > div.fc-timegrid-cols > table > tbody > tr > td.fc-day.fc-timegrid-col > div > div.fc-timegrid-col-bg > div > div > div > div > div > div > div.v-input__slot > div > input {
    text-align: center;
  }
}
</style>
