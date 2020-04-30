<template>
  <v-container v-if="orgId || userId">
    <v-row>
      <v-col>
        <v-btn v-if="!addNew" @click="setNew">
          Add Schedule
        </v-btn>
        <v-card v-if="addNew" flat class="px-3">
          <v-card-title>Add Schedule</v-card-title>
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
                <td class="text-left">
                  <DatetimePickerInput
                    v-model="item.startTime"
                    :timezone="timezone"
                    type="time"
                    format="h:mm a"
                    label="Start Time"
                  />
                </td>
                <td>
                  to
                </td>
                <td class="text-left">
                  <DatetimePickerInput
                    v-model="item.endTime"
                    :timezone="timezone"
                    type="time"
                    format="h:mm a"
                    label="End Time"
                  />
                </td>
                <td class="text-left px-0" width="150px">
                  <v-tooltip top v-if="index !== 6">
                    <template v-slot:activator="{ on }">
                      <v-btn text small v-on="on" @click="copyTimes(item, index, 'down')">
                        <v-icon>mdi-arrow-collapse-down</v-icon>
                      </v-btn>
                    </template>
                    <span>Copy Down</span>
                  </v-tooltip>
                  <v-btn text small v-else>
                  </v-btn>
                  <v-tooltip top v-if="index !== 0">
                    <template v-slot:activator="{ on }">
                      <v-btn text small v-on="on" @click="copyTimes(item, index, 'up')">
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
              <v-btn color="secondary" @click="[newSchedule = [], addNew = false]">Cancel</v-btn>
              <v-btn color="primaryCustom"  @click="saveSchedule(newSchedule, true)" class="white--text"
                     >
                Save
              </v-btn>
            </v-card-actions>
          </v-card-actions>
        </v-card>
        <v-data-table
          :headers="headers"
          :items="schedules"
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

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4 text-left" :class="{'shaded-row': selectedIndex % 2}">
              <v-card flat class="px-3">
                <DatetimePickerInput
                  v-model="item.startDate"
                  :timezone="timezone"
                  :type="'date'"
                  :format="'MMMM DD, YYYY'"
                  label="Start Date"
                />
                <DatetimePickerInput
                  v-model="item.endDate"
                  :timezone="timezone"
                  :type="'date'"
                  :format="'MMMM DD, YYYY'"
                  label="End Date"
                />

                <v-data-table
                  :items="item.resourceScheduleAvailability"
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
                      <td class="text-left">
                        <DatetimePickerInput
                          v-model="item.startTime"
                          :timezone="timezone"
                          type="time"
                          format="h:mm a"
                          label="Start Time"
                        />
                      </td>
                      <td>
                        to
                      </td>
                      <td class="text-left">
                        <DatetimePickerInput
                          v-model="item.endTime"
                          :timezone="timezone"
                          type="time"
                          format="h:mm a"
                          label="End Time"
                        />
                      </td>
                      <td class="text-left px-0" width="150px">

                        <v-tooltip top v-if="index !== 6">
                          <template v-slot:activator="{ on }">
                            <v-btn text small v-on="on" @click="copyTimes(item, index, 'down')">
                              <v-icon>mdi-arrow-collapse-down</v-icon>
                            </v-btn>
                          </template>
                          <span>Copy Down</span>
                        </v-tooltip>
                        <v-btn text small v-else>
                        </v-btn>
                        <v-tooltip top v-if="index !== 0">
                          <template v-slot:activator="{ on }">
                            <v-btn text small v-on="on" @click="copyTimes(item, index, 'up')">
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
                    <v-btn color="primaryCustom"  @click="saveSchedule(item, false)" class="white--text"
                           :disabled="!item.startDate || !item.endDate">
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
              <td class="text-left">
                <v-btn small text @click="[expanded = [item], selectedIndex = index]"
                       v-if="!expanded.includes(item)">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text @click="expanded = []"
                       v-if="expanded.includes(item)">cancel
                </v-btn>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import cloneDeep from 'lodash.clonedeep'
  import moment from 'moment'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import {getRequest, getRequestWithParams, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'Schedule',
    components: {
      Snackbar,
      DatetimePickerInput
    },
    props: {
      orgId: Number,
      userId: Number
    },
    data() {
      return {
        snackbar: {},
        addNew: false,
        selectedIndex: null,
        newSchedule: {},
        headers: [
          { text: 'Schedules', value: 'schedule', show: true},
          { text: '', value: 'icons', show: true}
        ],
        timezone: this.$store.state.user.details.timezone.value,
        schedules: [],
        expanded: [],
        workDays: [],
        saveError: false,
        saveErrorMsg: ''
      }
    },
    created() {
      //reload the data if they switch back from the appointments tab
      this.getSchedules()
      this.getWorkDays()
    },
    watch: {
      //we only have to watch one of the params cuz if userId gets set, then orgId will go null
      'orgId': function () {
        // reset the schedule when new user selected
        console.log('randaLogger', this.orgId)
        this.schedules = []
        this.getSchedules()
      }
    },
    methods: {
      async getSchedules() {
        if(this.orgId || this.userId) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            const {data} = await getRequestWithParams(`/availability`, { params: {
                userId: this.userId,
                orgId: this.orgId,
              }})
            data.forEach(d => {
              d.resourceScheduleAvailability.forEach(rsa => {
                console.log('start', rsa.startTime)
                console.log('start format', moment(rsa.startTime, 'hh:mm:ss').format('HH:mm'))
                console.log('end', rsa.endTime)
                console.log('end format', moment(rsa.endTime, 'hh:mm:ss').format('HH:mm'))

                rsa.startTime = moment(rsa.startTime, 'hh:mm:ss').format('HH:mm')
                rsa.endTime = moment(rsa.endTime, 'hh:mm:ss').format('HH:mm')
              })
            })
            this.schedules = data
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.$store.commit(AppMutations.SET_LOADING, false)
            this.snackbar = getSnackbar('ERROR', 'Error Loading Schedules')
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
        }
      },
      async saveSchedule(s, isNew) {

        console.log('randaLogger s', s)
        console.log('randaLogger s1', s.resourceScheduleAvailability[0].startTime)
        console.log('randaLogger s2', moment(s.resourceScheduleAvailability[0].startTime))
        console.log('randaLogger s3', moment(s.resourceScheduleAvailability[0].startTime, 'HH:mm:ss A Z'))
        console.log('randaLogger s4', moment(s.resourceScheduleAvailability[0].startTime, 'HH:mm:ss A Z').toDate())
        console.log('randaLogger s5', moment(s.resourceScheduleAvailability[0].startTime, 'HH:mm:ss A Z').utc())
        console.log('randaLogger s6', moment(s.resourceScheduleAvailability[0].startTime, 'HH:mm:ss A Z').utc().toDate())

        s.resourceScheduleAvailability[0].startTime = moment(s.resourceScheduleAvailability[0].startTime, 'HH:mm:ss A Z').toDate()
        s.resourceScheduleAvailability[0].endTime = moment(s.resourceScheduleAvailability[0].endTime, 'HH:mm:ss A Z').toDate()

        // do validations: todo: add the rest of them
        if(s.startDate >= s.endDate) {
          this.saveError = true
          this.saveErrorMsg = '* Schedule End Date cannot be before Start Date'
        } else {
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            let params = {
              orgId: this.orgId,
              userId: this.userId,
              startDate: s.startDate,
              endDate: s.endDate,
              resourceScheduleAvailability: s.id == null
                ? s.resourceScheduleAvailability.filter(rsa => { return rsa.startTime != null || rsa.endTime != null })
                : s.resourceScheduleAvailability
            }
            const {data} = await postRequest(`/availability`, params)
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.$store.commit(AppMutations.SET_LOADING, false)
            this.snackbar = getSnackbar('ERROR', 'Error Saving Schedule')
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
              startTime: null,
              endTime: null
            })
          })
        }
      },
      copyTimes(day, index, direction) {
        let dayToUpdate = null
        if(direction === 'down') {
          dayToUpdate = this.newSchedule.resourceScheduleAvailability[index + 1]
        } else {
          dayToUpdate = this.newSchedule.resourceScheduleAvailability[index - 1]
        }
        if(dayToUpdate) {
          this.$set(dayToUpdate, 'startTime', day.startTime)
          this.$set(dayToUpdate, 'endTime', day.endTime)
        }
      }
    }
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>

</style>

