<template>
  <v-container v-if="orgId || userId">
    <v-row>
      <v-col>
        <v-btn v-if="!addNew && userCanAdd" @click="setNew" class="mb-3">
          Add Schedule
        </v-btn>
        <v-card v-if="addNew" flat class="px-3">
          <v-card-title>Add New Schedule</v-card-title>
          <DatetimePickerInput
            v-model="newSchedule.startDate"
            :timezone="this.timezone"
            :type="'date'"
            :format="'MMMM DD, YYYY'"
            label="Start Date"
          />
          <DatetimePickerInput
            v-model="newSchedule.endDate"
            :timezone="this.timezone"
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
              No available days
            </template>

            <template #no-results>
              No available days
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
                      {{ data.item.scheduleName }} {{ buildTimeString(data.item)}}
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
                      <v-btn text small v-on="on" v-if="userCanEdit" @click="copyTimes(newSchedule, item, index, 'down')">
                        <v-icon>mdi-arrow-collapse-down</v-icon>
                      </v-btn>
                    </template>
                    <span>Copy Down</span>
                  </v-tooltip>
                  <v-btn text small v-else>
                  </v-btn>
                  <v-tooltip top v-if="index !== 0">
                    <template v-slot:activator="{ on }">
                      <v-btn text small v-on="on" v-if="userCanEdit" @click="copyTimes(newSchedule, item, index, 'up')">
                        <v-icon>mdi-arrow-collapse-up</v-icon>
                      </v-btn>
                    </template>
                    <span>Copy Up</span>
                  </v-tooltip>
                  <v-btn text small v-else>
                  </v-btn>
                  <v-btn text small @click="[item.startTime = null, item.endTime = null]">
                    <v-icon>close</v-icon>
                  </v-btn>
                </td>

              </tr>
            </template>
          </v-data-table>
          <div v-if="saveError" class="error--text mt-3">
            {{saveErrorMsg}}
          </div>
          <v-card-actions>
            <v-card-actions>
              <v-btn color="secondary" @click="[newSchedule = {}, addNew = false]">Cancel</v-btn>
              <v-btn color="primaryCustom"  @click="saveSchedule(newSchedule, true)" class="white--text"
                     :disabled="!newSchedule.startDate">
                Save
              </v-btn>
            </v-card-actions>
          </v-card-actions>
        </v-card>
        <v-data-table
          v-if="!addNew"
          :headers="headers"
          :items="filterSchedules()"
          :fixed-header="true"
          :items-per-page="-1"
          single-expand
          :expanded.sync="expanded"
          hide-default-footer
          disable-sort
          class="elevation-1 mt-1"
        >
          <template #no-data>
            No available schedules
          </template>

          <template #no-results>
            No available schedules
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
                    No available days
                  </template>

                  <template #no-results>
                    No available days
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
                            {{ data.item.scheduleName }} {{ buildTimeString(data.item)}}
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
                            <v-btn text small v-on="on" @click="copyTimes(schedule, item, index, 'down')">
                              <v-icon>mdi-arrow-collapse-down</v-icon>
                            </v-btn>
                          </template>
                          <span>Copy Down</span>
                        </v-tooltip>
                        <v-btn text small v-else>
                        </v-btn>
                        <v-tooltip top v-if="index !== 0 && userCanEdit">
                          <template v-slot:activator="{ on }">
                            <v-btn text small v-on="on" @click="copyTimes(schedule, item, index, 'up')">
                              <v-icon>mdi-arrow-collapse-up</v-icon>
                            </v-btn>
                          </template>
                          <span>Copy Up</span>
                        </v-tooltip>

                        <v-btn text small v-else>
                        </v-btn>
                        <v-btn text small @click="[item.startTime = null, item.endTime = null]" v-if="userCanEdit">
                          <v-icon>close</v-icon>
                        </v-btn>
                      </td>

                    </tr>
                  </template>
                </v-data-table>
                <div v-if="saveError" class="error--text mt-3">
                  {{saveErrorMsg}}
                </div>
                <v-card-actions>
                  <v-card-actions>
                    <v-btn color="primaryCustom"  @click="saveSchedule(schedule, false)" class="white--text"
                           v-if="userCanEdit || userCanAdd"
                           :disabled="!schedule.startDate">
                      Save
                    </v-btn>
                  </v-card-actions>
                </v-card-actions>
              </v-card>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.startDate | formatDate('date')}} - {{item.endDate | formatDate('date')}}</td>
              <td class="text-right">
                <v-btn small text @click="[expanded = [item], selectedIndex = index]"
                       v-if="!expanded.includes(item)">
                  <v-icon v-if="userCanEdit">edit</v-icon>
                  <v-icon v-else>mdi-chevron-down</v-icon>
                </v-btn>
                <v-btn small text @click="expanded = []"
                       v-if="expanded.includes(item)">cancel
                </v-btn>
                <v-dialog v-model="item.deleteConfirm" max-width="500px" v-if="userCanDelete">
                  <template #activator="{ on }">
                    <v-btn v-on="on" small text :disabled="cannotDeleteSchedule(item)">
                      <v-icon>delete</v-icon>
                    </v-btn>
                  </template>
                  <v-card>
                    <v-card-title>
                      <span class="headline">Confirm</span>
                    </v-card-title>
                    <v-card-text>
                      Are you sure you want to archive this schedule?<br>
                      <strong>{{ item.startDate | formatDate('date') }} - {{ item.endDate | formatDate('date') }}</strong>
                    </v-card-text>
                    <v-card-actions>
                      <v-spacer></v-spacer>
                      <v-btn color="secondaryButton" text @click="item.deleteConfirm = false">No</v-btn>
                      <v-btn color="brRed" class="white--text"
                             @click="archiveSchedule(item)">Yes</v-btn>
                    </v-card-actions>
                  </v-card>
                </v-dialog>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>

  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import cloneDeep from 'lodash.clonedeep'
  import moment from 'moment'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import {getRequest, getRequestWithParams, postRequest, getSnackbar, deleteRequest} from '@/helpers/helpers'

  export default {
    name: 'Schedule',
    components: {

      DatetimePickerInput
    },
    props: {
      orgId: Number,
      userId: Number,
      useSlotSchedule: Boolean
    },
    data() {
      return {
        snackbar: {},
        addNew: false,
        userCanAdd: this.$store.getters.userHasFeatureAccessLevel('AVAILABILITY', 'ADD'),
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('AVAILABILITY', 'EDIT'),
        userCanDelete: this.$store.getters.userHasFeatureAccessLevel('AVAILABILITY', 'DELETE'),
        selectedIndex: null,
        newSchedule: {},
        allowedMinutesStep: m => m % 30 === 0,
        headers: [
          { text: 'Schedules', value: 'schedule', show: true},
          { text: '', value: 'icons', show: true}
        ],
        timezone: this.$store.state.user.details.timezone.value,
        schedules: [],
        expanded: [],
        workDays: [],
        slotSchedules: [],
        saveError: false,
        saveErrorMsg: ''
      }
    },
    created() {
      //reload the data if they switch back from the appointments tab
      this.getSchedules()
      this.getWorkDays()
      if(this.useSlotSchedule) {
        this.getSlotSchedules()
      }
    },
    watch: {
      'orgId': function () {
        //without these if statements the schedule will get reloaded twice when switching between org and user
        if(this.orgId != null) {
          // reset the schedule when new org selected
          this.schedules = []
          this.newSchedule = {}
          this.addNew = false
          this.getSchedules()
        }
      },
      'userId': function () {
        if(this.userId != null) {
          // reset the schedule when new user selected
          this.schedules = []
          this.newSchedule = {}
          this.addNew = false
          this.getSchedules()
        }
      }
    },
    methods: {
      changeExcludedSlots(item, slotId) {
        if(item.excludedResourceSlotTimeIds.includes(slotId)) {
          //remove it if already in
          item.excludedResourceSlotTimeIds = item.excludedResourceSlotTimeIds.filter(e => e !== slotId)
        } else {
          //else add it
          item.excludedResourceSlotTimeIds.push(slotId)
        }
      },
      getMatchingSlots(resourceSlotScheduleId) {
        return this.slotSchedules.find(ss => ss.id === resourceSlotScheduleId)?.slotTimes
      },
      buildTimeString(schedule) {
        let timeString = '['
        schedule?.slotTimes?.forEach((st,idx) => {
          timeString += (this.$filters.formatDateZoneless(st.startTime) + '-' + this.$filters.formatDateZoneless(st.endTime) + (idx === schedule.slotTimes.length - 1 ? '' : ', '))
        })
        timeString += ']'
        return timeString
      },
      async getSchedules() {
        if(this.orgId || this.userId) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            const {data} = await getRequestWithParams(`/availability`, { params: {
                userId: this.userId,
                orgId: this.orgId,
              }})
            this.schedules = data
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.$store.commit(AppMutations.SET_LOADING, false)
            this.snackbar = getSnackbar('ERROR', 'Error Loading Schedules')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          }
        }
      },
      async getWorkDays() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequestWithParams(`/availability/workDays`)
          this.workDays = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.$store.commit(AppMutations.SET_LOADING, false)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Work Days')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },
      async getSlotSchedules() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/availability/slotSchedules`)
          this.slotSchedules = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.$store.commit(AppMutations.SET_LOADING, false)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Schedules')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },
      async saveSchedule(sched, isNew) {
        //clone the schedule so the times don't change on the screen, they only change for the save to the db
        let s = cloneDeep(sched)

        // filter out empties that dont need saved
        s.resourceScheduleAvailability = s.resourceScheduleAvailability ? s.resourceScheduleAvailability.filter(rsa => { return rsa.id != null || (rsa.resourceSlotScheduleId != null || rsa.startTime != null || rsa.endTime != null) }) : []
        // modify the times for saving to db
        // s.resourceScheduleAvailability.forEach(rsa => {
        //   rsa.startTime = rsa.startTime != null ? moment(rsa.startTime, 'HH:mm:ss A Z').toDate() : null
        //   rsa.endTime = rsa.endTime != null ? moment(rsa.endTime, 'HH:mm:ss A Z').toDate() : null
        // })


        // do validations: todo: add the rest of them (make sure dates of schedules can't overlap)
        if(moment(s.startDate).isBefore(moment(), 'd')) {
          this.saveError = true
          this.saveErrorMsg = '* Start Date cannot be before today.'
        } else if(s.endDate !== null && new Date(s.startDate) > new Date(s.endDate)) {
          this.saveError = true
          this.saveErrorMsg = '* Schedule End Date cannot be before Start Date'
        }
        // else if (!s.resourceScheduleAvailability || s.resourceScheduleAvailability.length === 0) {
        //   this.saveError = true
        //   this.saveErrorMsg = '* Schedule must include at least one day of availability'
        // }
        else {
          //check that no end times are before start times
          let timeOverlap, invalidStarts, invalidEnds = false
          s.resourceScheduleAvailability.forEach(rsa => {
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
            this.saveError = true
            this.saveErrorMsg = '* All work days with an end time must also have a start time'
          } else if(invalidEnds) {
            this.saveError = true
            this.saveErrorMsg = '* All work days with a start time must also have an end time'
          } else if(timeOverlap) {
            this.saveError = true
            this.saveErrorMsg = '* End times must be after start times'
          } else {
            //check that no other schedules overlap this one
            let scheduleOverlap = false
            let unEndingScheduleBeforeOthers = false
            this.schedules.forEach(sd => {
              if(s.id !== sd.id && ((new Date(s.startDate) >= new Date(sd.startDate) && new Date(s.startDate) <= new Date(sd.endDate)) ||
                 (new Date(s.endDate) >= new Date(sd.startDate) && new Date(s.endDate) <= new Date(sd.endDate)))) {
                scheduleOverlap = true
              }
              if(!s.endDate && s.startDate < sd.startDate) {
                unEndingScheduleBeforeOthers = true
              }
            })

            if(scheduleOverlap) {
              this.saveError = true
              this.saveErrorMsg = '* Schedule dates cannot overlap other schedules'
            } else if(unEndingScheduleBeforeOthers) {
              this.saveError = true
              this.saveErrorMsg = '* A schedule without an end date cannot be created before any other existing schedule'
            } else {
              this.saveError = false
              this.saveErrorMsg = ''
              this.$store.commit(AppMutations.SET_LOADING, true)
              try {
                let formattedTimestamps = cloneDeep(s.resourceScheduleAvailability)
                formattedTimestamps.forEach(ft => {
                  ft.startTime = ft.startTime != null ? moment.utc(ft.startTime, 'hh:mm:ss').format('HH:mm:ss') : null
                  ft.endTime = ft.endTime != null ? moment.utc(ft.endTime, 'hh:mm:ss').format('HH:mm:ss') : null
                })
                let params = {
                  id: s.id,
                  orgId: this.orgId,
                  userId: this.userId,
                  startDate: s.startDate,
                  endDate: s.endDate,
                  resourceScheduleAvailability: formattedTimestamps
                }
                const {data} = await postRequest(`/availability`, params)
                //with the changes we made to the datetimepickerinput i dont think we need this code anymore
                //update the returned formatting to match required input
                // data.resourceScheduleAvailability.forEach(rsa => {
                //   rsa.startTime = rsa.startTime != null ? moment.utc(rsa.startTime, 'hh:mm:ss').tz(this.timezone).format('HH:mm') : null
                //   rsa.endTime = rsa.endTime != null ? moment.utc(rsa.endTime, 'hh:mm:ss').tz(this.timezone).format('HH:mm') : null
                // })
                this.schedules = data
                this.newSchedule = {}
                this.addNew = false
                this.expanded = []
                this.$store.commit(AppMutations.SET_LOADING, false)
              } catch (e) {
                console.error('*** ERROR ***', e)
                this.$store.commit(AppMutations.SET_LOADING, false)
                this.snackbar = getSnackbar('ERROR', 'Error Saving Schedule')
                this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
              }
            }
          }

        }
      },
      setNew() {
        this.addNew = !this.addNew
        if(this.addNew) {
          this.newSchedule.resourceScheduleAvailability = []
          this.workDays.forEach(wd => {
            this.newSchedule.resourceScheduleAvailability.push({
              dayOfWeekId: wd.id,
              dayOfWeek: wd.dayOfWeek,
              excludedResourceSlotTimeIds: [],
              startTime: null,
              endTime: null,
              resourceSlotScheduleId: null
            })
          })
        }
      },
      copyTimes(schedule, day, index, direction) {
        let dayToUpdate = null
        if(direction === 'down') {
          dayToUpdate = schedule.resourceScheduleAvailability[index + 1]
        } else {
          dayToUpdate = schedule.resourceScheduleAvailability[index - 1]
        }
        if(dayToUpdate) {
          this.$set(dayToUpdate, 'startTime', day.startTime)
          this.$set(dayToUpdate, 'endTime', day.endTime)
        }
      },
      cannotDeleteSchedule(item) {
        //per judson request - cannot delete schedules that have a start date prior to or equal to today
        return moment(item.startDate) <= moment()
      },
      async archiveSchedule(item) {
        this.$store.commit(AppMutations.SET_LOADING, true)

        try {
          await deleteRequest(`/availability/${item.id}`)
          item.archived = true
          //remove it from the schedules list so they can recreate one with the same dates
          this.schedules = this.schedules.filter(s => { return s.id !== item.id })
          this.snackbar = getSnackbar('SUCCESS', 'Schedule Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error deleting schedule')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterSchedules () {
        return this.schedules.filter(s => { return !s.archived})
      },
    }
  }
</script>
