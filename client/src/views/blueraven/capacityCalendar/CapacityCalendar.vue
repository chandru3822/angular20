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
import {getRequestWithParams} from "@/helpers/helpers.js";
import {useAppStore} from "@/stores/AppStore.js";
import cloneDeep from "lodash.clonedeep";

const appStore = useAppStore()
const capacityCalendar = ref(null)

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
      text:'Edit'
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
      startTime:moment.utc(info.start),
      endTime: moment.utc(info.end),
    }
    debugger
    const {data} = await getRequestWithParams(
        '/virtualResourceCapacity/capacityScheduleForRange', {params: params})
    console.log(data)
    let events = cloneDeep(data)
    events.forEach((event, index) => event.id = index);
    successCallback(events)
    appStore.loading = false
  } catch(e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Capacity Calendar')
    failureCallback(e)
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
    <template v-slot:eventContent>
      <div class="capacity-booked-grid">
        <div class="capacity-col label-medium grey--text text--darken-2 d-flex justify-center align-center">0</div>
        <div class="booked-col label-medium grey--text text--darken-2 d-flex justify-center align-center">0</div>
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
  background-color: rgba(68, 134, 195, .1) //using rgba instead of primary-lighten9 because if you use a color with 100% opacity, the column lines are covered up
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
    border-right: var(--v-grey-lighten1) solid 1px;
  }

  th{
    background-color: var(--v-grey-lighten3);
  }
}
</style>
