<template>
  <v-container v-if="orgId || userId">
    <v-row>
      <v-col>
        <AlbatrossButton color="primary" v-if="!addNew && userCanAdd" @click="setNew" class="mb-3" text="ADD SCHEDULE"/>
        <v-card v-if="addNew" flat class="px-3">
          <v-card-title>Add New Schedule</v-card-title>
          <DatetimePickerInput
            v-model="newSchedule.startDate"
            :timezone="timezone"
            :type="'date'"
            :format="'MMMM DD, YYYY'"
            label="Start Date"
          />
          <DatetimePickerInput
            v-model="newSchedule.endDate"
            :timezone="timezone"
            :type="'date'"
            :format="'MMMM DD, YYYY'"
            label="End Date"
          />
          <v-data-table
            :items="newSchedule.resourceScheduleAvailability"
            :fixed-header="true"
            :items-per-page="-1"
            hide-default-header
            hide-default-footer
            disable-sort
            class="elevation-1 mt-1"
          >
            <template #no-data>
              <span class="default-text-color">No available days</span>
            </template>

            <template #no-results>
              <span class="default-text-color">No available days</span>
            </template>

            <template #header="{ props: {} }">
              <thead class="v-data-table-header">
                <tr>
                  <th>Work Day</th>
                  <th :colspan="4">Hours</th>
                </tr>
              </thead>
            </template>

            <template #item="{ item, index }">
              <tr class="clickable" :class="{'shaded-row': index % 2}">
                <td class="text-left">{{item.dayOfWeek}}</td>
                <td class="text-left" v-if="useSlotSchedule">
                  <v-select
                    v-model="item.resourceSlotScheduleId"
                    :items="slotSchedules"
                    label="Schedule"
                    item-text="scheduleName"
                    item-value="id"
                    clearable
                    @change="[item.startTime = null, item.endTime = null]"
                  >
                    <template slot="item" slot-scope="data">
                      <!-- HTML that describes how select should render items when the select is open -->
                      {{ data.item.scheduleName }}
                    </template>
                  </v-select>

                  <v-card v-if="item.resourceSlotScheduleId" flat color="transparent" class="mb-4">
                    <div v-for="(slot, idx) in getMatchingSlots(item.resourceSlotScheduleId)" :key="idx">
                      <input type="checkbox"
                             @change="changeExcludedSlots(item, slot.id)"
                             :checked="!item.excludedResourceSlotTimeIds.includes(slot.id)">
                      {{slot.startTime | formatDateZoneless()}} - {{slot.endTime | formatDateZoneless()}}
                    </div>
                  </v-card>
                </td>
                <td class="text-left" v-else>
                  <DatetimePickerInput
                    v-model="item.startTime"
                    :timezone="timezone"
                    type="time"
                    format="h:mm a"
                    label="Start Time"
                  />
                  <div class="d-inline-block px-3 align-self-center">to</div>
                  <DatetimePickerInput
                    v-model="item.endTime"
                    :timezone="timezone"
                    type="time"
                    format="h:mm a"
                    label="End Time"
                  />
                </td>
                <td class="text-left px-0" width="150px"  v-if="!useSlotSchedule">
                  <v-tooltip top v-if="index !== 6">
                    <template v-slot:activator="{ on }">
                      <AlbatrossButton
                        variant="text"
                        size="small"
                        color="primary"
                        :activation-handler="on"
                        v-if="userCanEdit"
                        @click="copyTimes(newSchedule, item, index, 'down')"
                        prepend-icon="mdi-arrow-collapse-down"
                      />
                    </template>
                    <span>Copy Down</span>
                  </v-tooltip>
                  <AlbatrossButton variant="text" size="small" v-else/>
                  <v-tooltip top v-if="index !== 0">
                    <template v-slot:activator="{ on }">
                      <AlbatrossButton
                        variant="text"
                        size="small"
                        color="primary"
                        :activation-handler="on"
                        v-if="userCanEdit"
                        @click="copyTimes(newSchedule, item, index, 'up')"
                        prepend-icon="mdi-arrow-collapse-up"
                      />
                    </template>
                    <span>Copy Up</span>
                  </v-tooltip>
                  <AlbatrossButton variant="text" size="small" v-else/>
                  <AlbatrossButton variant="text" size="small" color="primary" @click="[item.startTime = null, item.endTime = null]" prepend-icon="close"/>
                </td>

              </tr>
            </template>
          </v-data-table>
          <div v-if="saveError" class="error--text mt-3">
            {{saveErrorMsg}}
          </div>
          <v-card-actions>
            <v-card-actions>
              <AlbatrossButton variant="text" color="primary" @click="[newSchedule = {}, addNew = false]" text="CANCEL"/>
              <AlbatrossButton color="primary"  @click="saveSchedule(newSchedule, true)" class="white--text"
                     :disabled="!newSchedule.startDate" text="SAVE"/>
            </v-card-actions>
          </v-card-actions>
        </v-card>
        <v-data-table
          v-if="!addNew"
          :headers="headers"
          :items="filterSchedules"
          :fixed-header="true"
          :items-per-page="-1"
          single-expand
          :expanded.sync="expanded"
          hide-default-footer
          disable-sort
          class="elevation-1 mt-1"
        >
          <template #no-data>
            <span class="default-text-color">No available schedules</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available schedules</span>
          </template>

          <template #expanded-item="{ headers, item: schedule }">
            <td :colspan="headers.length" class="pa-4 text-left" :class="{'shaded-row': selectedIndex % 2}">
              <v-card flat color="transparent" class="px-3">
                <DatetimePickerInput
                  v-model="schedule.startDate"
                  :timezone="timezone"
                  :readonly="!userCanEdit"
                  :disabled="!userCanEdit"
                  :type="'date'"
                  :format="'MMMM DD, YYYY'"
                  input-format="HH:mm:ss"
                  label="Start Date"
                />
                <DatetimePickerInput
                  v-model="schedule.endDate"
                  :timezone="timezone"
                  :readonly="!userCanEdit"
                  :disabled="!userCanEdit"
                  :type="'date'"
                  :format="'MMMM DD, YYYY'"
                  input-format="HH:mm:ss"
                  label="End Date"
                />

                <v-data-table
                  :items="schedule.resourceScheduleAvailability"
                  :fixed-header="true"
                  :items-per-page="-1"
                  hide-default-header
                  hide-default-footer
                  disable-sort
                  class="elevation-1 mt-1"
                >
                  <template #no-data>
                    <span class="default-text-color">No available days</span>
                  </template>

                  <template #no-results>
                    <span class="default-text-color">No available days</span>
                  </template>

                  <template #header="{ props: {} }">
                    <thead class="v-data-table-header">
                    <tr>
                      <th>Work Day</th>
                      <th :colspan="4">{{ useSlotSchedule ? 'Schedule' : 'Hours'}}</th>
                    </tr>
                    </thead>
                  </template>

                  <template #item="{ item, index }">
                    <tr class="clickable" :class="{'shaded-row': index % 2}">
                      <td class="text-left">{{item.dayOfWeek}}</td>
                      <td class="text-left" v-if="useSlotSchedule">
                        <v-select
                          v-model="item.resourceSlotScheduleId"
                          :items="slotSchedules"
                          label="Schedule"
                          item-text="scheduleName"
                          item-value="id"
                          clearable
                          @change="item.startTime = null, item.endTime = null"
                        >
                          <template slot="item" slot-scope="data">
                            <!-- HTML that describes how select should render items when the select is open -->
                            {{ data.item.scheduleName }}
                          </template>
                        </v-select>
                        <v-card v-if="item.resourceSlotScheduleId" flat color="transparent" class="mb-4">
                          <div v-for="(slot, idx) in getMatchingSlots(item.resourceSlotScheduleId)" :key="idx">
                            <input type="checkbox"
                                   @change="changeExcludedSlots(item, slot.id)"
                                   :checked="!item.excludedResourceSlotTimeIds.includes(slot.id)">
                            {{slot.startTime | formatDateZoneless()}} - {{slot.endTime | formatDateZoneless()}}
                          </div>
                        </v-card>
                      </td>
                      <td class="text-left" v-else>
                        <div class="flex-display">
                          <DatetimePickerInput
                            v-model="item.startTime"
                            :timezone="timezone"
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
                            type="time"
                            format="h:mm a"
                            :allowed-minutes="allowedMinutesStep"
                            input-format="HH:mm:ss"
                            label="Start Time"
                            class="d-inline-block"
                          />
                          <div class="d-inline-block px-3 align-self-center">to</div>
                          <DatetimePickerInput
                            v-model="item.endTime"
                            :timezone="timezone"
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
                            type="time"
                            format="h:mm a"
                            :allowed-minutes="allowedMinutesStep"
                            input-format="HH:mm:ss"
                            label="End Time"
                            class="d-inline-block"
                          />
                        </div>
                      </td>
                      <td class="text-left px-0" width="150px" v-if="!useSlotSchedule">

                        <v-tooltip top v-if="index !== 6 && userCanEdit">
                          <template v-slot:activator="{ on }">
                            <AlbatrossButton variant="text" size="small" color="primary" :activation-handler="on"
                                             @click="copyTimes(schedule, item, index, 'down')"
                                             prepend-icon="mdi-arrow-collapse-down"
                            />
                          </template>
                          <span>Copy Down</span>
                        </v-tooltip>
                        <AlbatrossButton variant="text" size="small" v-else/>
                        <v-tooltip top v-if="index !== 0 && userCanEdit">
                          <template v-slot:activator="{ on }">
                            <AlbatrossButton variant="text" color="primary" size="small" :activation-handler="on"
                                             @click="copyTimes(schedule, item, index, 'up')"
                                             prepend-icon="mdi-arrow-collapse-up"/>
                          </template>
                          <span>Copy Up</span>
                        </v-tooltip>

                        <AlbatrossButton variant="text" size="small" v-else/>
                        <AlbatrossButton variant="text" size="small" color="primary"
                                         @click="[item.startTime = null, item.endTime = null]" v-if="userCanEdit"
                                         prepend-icon="close"
                        />
                      </td>

                    </tr>
                  </template>
                </v-data-table>
                <div v-if="saveError" class="error--text mt-3">
                  {{saveErrorMsg}}
                </div>
                <v-card-actions>
                  <v-card-actions>
                    <AlbatrossButton color="primary"  @click="saveSchedule(schedule, false)" class="white--text"
                           v-if="userCanEdit || userCanAdd"
                           :disabled="!schedule.startDate" text="SAVE"/>
                  </v-card-actions>
                </v-card-actions>
              </v-card>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.startDate | formatDate('date')}} - {{item.endDate | formatDate('date')}}</td>
              <td class="text-right">
                <AlbatrossButton size="small" variant="text" color="primary"
                                 @click="[expanded = [item], selectedIndex = index]"
                                 v-if="!expanded.includes(item)"
                                 :prepend-icon="userCanEdit ? 'edit' : 'mdi-chevron-down'"
                />
                <AlbatrossButton size="small"
                                 variant="text"
                                 color="primary"
                                 @click="expanded = []"
                                 v-if="expanded.includes(item)"
                                 text="CANCEL"
                />
                <AlbatrossButton size="small"
                                 variant="text"
                                 color="primary"
                                 :disabled="cannotDeleteSchedule(item)"
                                 @click="[itemToDelete=item, showDeleteDialog=true]"
                                 prepend-icon="delete"
                />
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
<ConfirmationDialog :open-dialog="showDeleteDialog"
                             @confirm="archiveSchedule"
                             @close-dialog="closeDeleteDialog">
  Are you sure you want to archive this schedule?<br>
  <strong>{{ scheduleToDeleteString }}</strong>
</ConfirmationDialog>
  </v-container>
</template>

<script setup>
  import {AppMutations} from '@/stores/AppStore'
  import cloneDeep from 'lodash.clonedeep'
  import moment from 'moment'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import {handleHidingGlobalLoader, getRequest, getRequestWithParams, postRequest, getSnackbar, deleteRequest} from '@/helpers/helpers'
  import ConfirmationDialog from "@/components/ConfirmationDialog";

  import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";
  import {getCurrentInstance, onMounted, ref, toRefs, computed, watch, defineProps} from "vue";
  import { useUserStore } from '@/stores/UserStorePinia.js'

  const vueInstance = getCurrentInstance().proxy
  const snackbar = vueInstance.$snackbar
  const store = vueInstance.$store
  const userStore = useUserStore()

  const props = defineProps({
    orgId: Number,
    userId: Number,
    useSlotSchedule: Boolean
  })
  const { orgId, userId } = toRefs(props)


  const addNew = ref(false)
  const userCanAdd = ref(userStore.userHasFeatureAccessLevel('AVAILABILITY', 'ADD'))
  const userCanEdit = ref(userStore.userHasFeatureAccessLevel('AVAILABILITY', 'EDIT'))
  const userCanDelete = ref(userStore.userHasFeatureAccessLevel('AVAILABILITY', 'DELETE'))
  const userIsAdmin = ref(userStore.userHasFeatureAccessLevel('AVAILABILITY', 'ADMIN'))
  const selectedIndex = ref(null)
  const newSchedule = ref({})
  const allowedMinutesStep = ref(m => m % 30 === 0)
  const headers = ref([
    { text: 'Schedules', value: 'schedule', show: true},
    { text: '', value: 'icons', show: true}
  ])
  const timezone = ref(userStore.details.timezone?.value)
  const schedules = ref([])
  const expanded = ref([])
  const workDays = ref([])
  const slotSchedules = ref([])
  const saveError = ref(false)
  const saveErrorMsg = ref('')
  const currentlyInDST = ref(moment().isDST())
  const showDeleteDialog = ref(false)
  const itemToDelete = ref(null)

  const scheduleToDeleteString = computed(() => {
    return itemToDelete.value ?
    `${vueInstance.$filters.formatDate(itemToDelete.value.startDate, 'date') || ''} - ${vueInstance.$filters.formatDate(itemToDelete.value.endDate, 'date') || ''}`
        : ''
  })

  onMounted(() =>{
    //reload the data if they switch back from the appointments tab
    getSchedules()
    getWorkDays()
    if(props.useSlotSchedule) {
      getSlotSchedules()
    }
  })

  watch(orgId, () => {
    //without these if statements the schedule will get reloaded twice when switching between org and user
    if(orgId.value != null) {
      // reset the schedule when new org selected
      schedules.value =  []
      newSchedule.value = {}
      addNew.value = false
      getSchedules()
    }
  })
  watch(userId, () => {
    if(userId.value != null) {
      // reset the schedule when new user selected
      schedules.value = []
      newSchedule.value = {}
      addNew.value = false
      getSchedules()
      if(props.useSlotSchedule) {
        getSlotSchedules()
      }
    }
  })
  const changeExcludedSlots = (item, slotId)  => {
    if(item.excludedResourceSlotTimeIds.includes(slotId)) {
      //remove it if already in
      item.excludedResourceSlotTimeIds = item.excludedResourceSlotTimeIds.filter(e => e !== slotId)
    } else {
      //else add it
      item.excludedResourceSlotTimeIds.push(slotId)
    }
  }
  const getMatchingSlots = (resourceSlotScheduleId)  => {
    return slotSchedules.value.find(ss => ss.id === resourceSlotScheduleId)?.slotTimes
  }
  const buildTimeString = (schedule)  => {
    let timeString = '['
    schedule?.slotTimes?.forEach((st,idx) => {
      timeString += (vueInstance.$filters.formatDateZoneless(st.startTime) + '-' + vueInstance.$filters.formatDateZoneless(st.endTime) + (idx === schedule.slotTimes.length - 1 ? '' : ', '))
    })
    timeString += ']'
    return timeString
  }
  const getSchedules = async () => {
    if(orgId.value || userId.value) {
      store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequestWithParams(`/availability`, { params: {
            userId: userId.value,
            orgId: orgId.value,
          }}, null, [])
        data?.forEach(sched => {
          sched?.resourceScheduleAvailability?.forEach(day => {
            //if the day was saved during DST, but now is NOT DST, then subtract an hour
            if(day.daylightSavings && !currentlyInDST.value) {
              day.startTime = day.startTime == null ? null : moment.utc(day.startTime, 'HH:mm:ss').add(1, 'h').format('HH:mm:ss')
              day.endTime = day.endTime == null ? null : moment.utc(day.endTime, 'HH:mm:ss').add(1, 'h').format('HH:mm:ss')
            } else if (!day.daylightSavings && currentlyInDST.value) {
              //else if the day was NOT saved during DST, but now IS DST, then add an hour
              day.startTime = day.startTime == null ? null : moment.utc(day.startTime, 'HH:mm:ss').subtract(1, 'h').format('HH:mm:ss')
              day.endTime = day.endTime == null ? null : moment.utc(day.endTime, 'HH:mm:ss').subtract(1, 'h').format('HH:mm:ss')
            }
          })
        })
        schedules.value = data
        handleHidingGlobalLoader(vueInstance, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        store.commit(AppMutations.SET_LOADING, false)
        snackbar('ERROR', 'Error Loading Schedules')

      }
    }
  }
  const getWorkDays = async () => {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {data, status} = await getRequestWithParams(`/availability/workDays`)
      workDays.value = data
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      store.commit(AppMutations.SET_LOADING, false)
      snackbar('ERROR', 'Error Loading Work Days')

    }
  }
  const getSlotSchedules = async () => {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      let params = {
        userId: props.userId
      }
      const {data, status} = await getRequestWithParams('/availability/slotSchedules', {params})
      slotSchedules.value = data

      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      store.commit(AppMutations.SET_LOADING, false)
      snackbar('ERROR', 'Error Loading Schedules')

    }
  }
  const saveSchedule = async (sched) => {
    //clone the schedule so the times don't change on the screen, they only change for the save to the db
    let s = cloneDeep(sched)

    // filter out empties that don't need saved
    s.resourceScheduleAvailability = s.resourceScheduleAvailability ? s.resourceScheduleAvailability.filter(rsa => { return rsa.id != null || (rsa.resourceSlotScheduleId != null || rsa.startTime != null || rsa.endTime != null) }) : []
    // modify the times for saving to db
    // s.resourceScheduleAvailability.forEach(rsa => {
    //   rsa.startTime = rsa.startTime != null ? moment(rsa.startTime, 'HH:mm:ss A Z').toDate() : null
    //   rsa.endTime = rsa.endTime != null ? moment(rsa.endTime, 'HH:mm:ss A Z').toDate() : null
    // })


    // do validations: todo: add the rest of them (make sure dates of schedules can't overlap)
    if(moment(s.startDate).isBefore(moment(), 'd')) {
      saveError.value = true
      saveErrorMsg.value = '* Start Date cannot be before today.'
    } else if(s.endDate !== null && new Date(s.startDate) > new Date(s.endDate)) {
      saveError.value = true
      saveErrorMsg.value = '* Schedule End Date cannot be before Start Date'
    }
    // else if (!s.resourceScheduleAvailability || s.resourceScheduleAvailability.length === 0) {
    //   saveError.value = true
    //   saveErrorMsg.value = '* Schedule must include at least one day of availability'
    // }
    else {
      //check that no end times are before start times
      let timeOverlap, invalidStarts, invalidEnds = false
      s.resourceScheduleAvailability.forEach(rsa => {
        rsa.daylightSavings = currentlyInDST.value
        if(rsa.startTime == null && rsa.endTime != null) {
          //this ensures that no daily schedules have an end time w/o a start time
          invalidStarts = true
        } else if(rsa.endTime == null && rsa.startTime != null) {
          //this ensures that no daily schedules have a start time w/o an end time
          invalidEnds = true
        } else if( moment( moment().format('MM-DD-YYYY') + ' ' + moment(moment.utc(rsa.startTime, 'HH:mm:ss.SSSZ').toDate()).format('HH:mm')).toDate()
              >= moment( moment().format('MM-DD-YYYY') + ' ' + moment(moment.utc(rsa.endTime, 'HH:mm:ss.SSSZ').toDate()).format('HH:mm')).toDate()) {
          //this is janky because if they set a time from 5pm - 11pm MST that is 11pm - 5am UTC so the end time is before the start time, i think this fixes that
          // i transform each selected local time into today's date, even if it would be a different date in utc. then compare, but never save the values that way
          timeOverlap = true
        }
        // if(rsa.startTime >= rsa.endTime) {
        //   timeOverlap = true
        // }
      })

      if(invalidStarts) {
        saveError.value = true
        saveErrorMsg.value = '* All work days with an end time must also have a start time'
      } else if(invalidEnds) {
        saveError.value = true
        saveErrorMsg.value = '* All work days with a start time must also have an end time'
      } else if(timeOverlap) {
        saveError.value = true
        saveErrorMsg.value = '* End times must be after start times'
      } else {
        //check that no other schedules overlap this one
        let scheduleOverlap = false
        let unEndingScheduleBeforeOthers = false
        schedules.value.forEach(sd => {
          if(s.id !== sd.id && ((new Date(s.startDate) >= new Date(sd.startDate) && new Date(s.startDate) <= new Date(sd.endDate)) ||
             (new Date(s.endDate) >= new Date(sd.startDate) && new Date(s.endDate) <= new Date(sd.endDate)))) {
            scheduleOverlap = true
          }
          if(!s.endDate && s.startDate < sd.startDate) {
            unEndingScheduleBeforeOthers = true
          }
        })

        if(scheduleOverlap) {
          saveError.value = true
          saveErrorMsg.value = '* Schedule dates cannot overlap other schedules'
        } else if(unEndingScheduleBeforeOthers) {
          saveError.value = true
          saveErrorMsg.value = '* A schedule without an end date cannot be created before any other existing schedule'
        } else {
          saveError.value = false
          saveErrorMsg.value = ''
          store.commit(AppMutations.SET_LOADING, true)
          try {
            let formattedTimestamps = cloneDeep(s.resourceScheduleAvailability)
            formattedTimestamps.forEach(ft => {
              ft.startTime = ft.startTime != null ? moment.utc(ft.startTime, 'hh:mm:ss').format('HH:mm:ss') : null
              ft.endTime = ft.endTime != null ? moment.utc(ft.endTime, 'hh:mm:ss').format('HH:mm:ss') : null
            })
            let params = {
              id: s.id,
              orgId: orgId.value,
              userId: userId.value,
              startDate: s.startDate,
              endDate: s.endDate,
              resourceScheduleAvailability: formattedTimestamps
            }
            const {data, status} = await postRequest(`/availability`, params)
            //with the changes we made to the datetimepickerinput i dont think we need this code anymore
            //update the returned formatting to match required input
            // data.resourceScheduleAvailability.forEach(rsa => {
            //   rsa.startTime = rsa.startTime != null ? moment.utc(rsa.startTime, 'hh:mm:ss').tz(timezone.value).format('HH:mm') : null
            //   rsa.endTime = rsa.endTime != null ? moment.utc(rsa.endTime, 'hh:mm:ss').tz(timezone.value).format('HH:mm') : null
            // })
            schedules.value = data
            newSchedule.value = {}
            addNew.value = false
            expanded.value = []
            handleHidingGlobalLoader(vueInstance, status)
          } catch (e) {
            console.error('*** ERROR ***', e)
            store.commit(AppMutations.SET_LOADING, false)
            snackbar('ERROR', 'Error Saving Schedule')

          }
        }
      }

    }
  }
  const setNew = ()  => {
    addNew.value = !addNew.value
    if(addNew.value) {
      newSchedule.value.resourceScheduleAvailability = []
      workDays.value.forEach(wd => {
        newSchedule.value.resourceScheduleAvailability.push({
          dayOfWeekId: wd.id,
          dayOfWeek: wd.dayOfWeek,
          excludedResourceSlotTimeIds: [],
          startTime: null,
          endTime: null,
          resourceSlotScheduleId: null
        })
      })
    }
  }
  const copyTimes = (schedule, day, index, direction)  => {
    let dayToUpdate = null
    if(direction === 'down') {
      dayToUpdate = schedule.resourceScheduleAvailability[index + 1]
    } else {
      dayToUpdate = schedule.resourceScheduleAvailability[index - 1]
    }
    if(dayToUpdate) {
      vueInstance.$set(dayToUpdate, 'startTime', day.startTime)
      vueInstance.$set(dayToUpdate, 'endTime', day.endTime)
    }
  }
  const cannotDeleteSchedule = (item)  => {
    //per judson request - cannot delete schedules that have a start date prior to or equal to today (unless they have admin permission)
    return !userIsAdmin.value && moment(item.startDate) <= moment()
  }
  const archiveSchedule = async () => {
    const item = itemToDelete.value
    store.commit(AppMutations.SET_LOADING, true)

    try {
      const {status} = await deleteRequest(`/availability/${item.id}`)
      item.archived = true
      //remove it from the schedules list so they can recreate one with the same dates
      schedules.value = schedules.value.filter(s => { return s.id !== item.id })
      snackbar('SUCCESS', 'Schedule Deleted')

      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error deleting schedule')

      store.commit(AppMutations.SET_LOADING, false)
    }
    closeDeleteDialog()
  }
  const filterSchedules = computed(() => {
    return schedules.value.filter(s => { return !s.archived})
  })
  const closeDeleteDialog = () => {
    showDeleteDialog.value = false
    itemToDelete.value = null
  }
</script>
