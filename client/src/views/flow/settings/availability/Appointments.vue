<template>
  <v-container v-if="orgId || userId" id="appointment-container">
    <v-row>
      <v-col>
        <v-btn v-if="!addNew && $store.getters.userHasFeatureAccessLevel('AVAILABILITY', 'ADD')" @click="addNew = !addNew" class="mb-3">
          Add Appointment
        </v-btn>
        <v-card v-if="addNew" flat class="px-3">
          <v-card-title>Add Schedule</v-card-title>
          <v-text-field
            v-model="newAppt.description"
            counter="50"
            label="Description"
          ></v-text-field>
          <DatetimePickerInput
            v-model="newAppt.startTime"
            :timezone="this.timezone"
            :type="newAppt.allDay ? dateType : timestampType"
            :format="newAppt.allDay ? dateFormat : timestampFormat"
            :label="newAppt.allDay ? 'Start Date' : 'Start Time'"
          />
          <DatetimePickerInput
            v-model="newAppt.endTime"
            :timezone="this.timezone"
            :type="newAppt.allDay ? dateType : timestampType"
            :format="newAppt.allDay ? dateFormat : timestampFormat"
            :label="newAppt.allDay ? 'End Date' : 'End Time'"
          />
          <v-checkbox
            v-model="newAppt.allDay"
            label="All Day"
          ></v-checkbox>
          <v-checkbox
            v-model="newAppt.repeat"
            label="Repeat"
          ></v-checkbox>

          <!-- i need the item id to be able to update the recurrence string on the callback -->
          <RRule v-if="newAppt.repeat"
                 :recurrence="newAppt.recurrence"
                 :item-id="newAppt.id"
                 :readonly="false"
                 :max-occurrences="100"
                 :recurrence-callback="recurrenceCallback"
          ></RRule>

          <div v-if="saveError" class="error--text mt-3">
            {{saveErrorMsg}}
          </div>
          <div v-if="newSaveError" class="error--text mt-3">
            {{newSaveErrorMsg}}
          </div>
          <v-card-actions>
            <v-card-actions>
              <v-btn color="secondary" @click="[newAppt = {}, addNew = false]">Cancel</v-btn>
              <v-btn color="primaryCustom"  @click="saveAppt(newAppt)" class="white--text"
                     :disabled="!newAppt.startTime || !newAppt.endTime || !newAppt.description || newAppt.description.length > 50">
                Save
              </v-btn>
            </v-card-actions>
          </v-card-actions>
        </v-card>

        <v-data-table
          v-if="!addNew"
          :headers="headers"
          :items="filterAppointments()"
          :fixed-header="true"
          single-expand
          :expanded.sync="expanded"
          :options.sync="options"
          :loading="dataLoading"
          :footer-props="footerProps"
          :server-items-length="totalAppointments"
          disable-sort
          class="elevation-1 appointment-table"
        >
          <template #no-data>
            No available appointments
          </template>

          <template #no-results>
            No available appointments
          </template>

          <template #expanded-item="{ headers, item: appt }">
            <td :colspan="headers.length" class="pa-4 text-left" :class="{'shaded-row': selectedIndex % 2}">
              <v-card flat color="transparent" class="px-3">
                <!-- no edits allowed to recurring events for now -->
                <v-text-field
                  v-model="appt.description"
                  counter="50"
                  :readonly="appt.recurringEventId != null"
                  :disabled="appt.recurringEventId != null"
                  label="Description"
                ></v-text-field>
                <DatetimePickerInput
                  v-model="appt.startTime"
                  :timezone="timezone"
                  :readonly="appt.recurringEventId != null"
                  :type="appt.allDay ? dateType : timestampType"
                  :format="appt.allDay ? dateFormat : timestampFormat"
                  :label="appt.allDay ? 'Start Date' : 'Start Time'"
                />
                <DatetimePickerInput
                  v-model="appt.endTime"
                  :timezone="timezone"
                  :readonly="appt.recurringEventId != null"
                  :type="appt.allDay ? dateType : timestampType"
                  :format="appt.allDay ? dateFormat : timestampFormat"
                  :label="appt.allDay ? 'End Date' : 'End Time'"
                />
                <v-checkbox
                  v-model="appt.allDay"
                  label="All Day"
                  :readonly="appt.recurringEventId != null"
                  :disabled="appt.recurringEventId != null"
                ></v-checkbox>
                <!-- for now i am not going to allow them to change a non-recurring event to be a recurring event. they would just have to delete the non recurring one and make a new recurring one                -->
                <v-checkbox
                  v-model="appt.repeat"
                  :readonly="true"
                  :disabled="true"
                  label="Repeat"
                ></v-checkbox>

                <!-- i need the item id to be able to update the recurrence string on the callback -->
                <RRule v-if="appt.repeat"
                       :recurrence="appt.recurrence"
                       :item-id="appt.id"
                       :readonly="true"
                       :max-occurrences="100"
                       :recurrence-callback="recurrenceCallback"
                ></RRule>

                <div v-if="saveError" class="error--text mt-3">
                  {{saveErrorMsg}}
                </div>

                <v-card-actions>
                  <v-card-actions>
                    <v-btn color="primaryCustom"  @click="saveAppt(appt)" class="white--text"
                           :disabled="saveError || !appt.startTime || !appt.endTime || !appt.description || appt.description.length > 50">
                      Save
                    </v-btn>
                  </v-card-actions>
                </v-card-actions>
              </v-card>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.startTime | formatDate(item.allDay ? 'timestampAsDate' : 'timestamp')}} - {{item.endTime | formatDate(item.allDay ? 'timestampAsDate' : 'timestamp')}}</td>
              <td class="text-left">{{item.description}}</td>
              <td><input type="checkbox" :disabled="true" v-model="item.allDay"></td>
              <td class="text-left">
                <v-btn small text @click="[expanded = [item], selectedIndex = index, saveError = false]"
                       v-if="!expanded.includes(item) && userCanEdit">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text @click="expanded = []"
                       v-if="expanded.includes(item)">cancel
                </v-btn>
                <v-dialog v-model="item.deleteConfirm" max-width="500px" v-if="$store.getters.userHasFeatureAccessLevel('AVAILABILITY', 'DELETE')">
                  <template #activator="{ on }">
                    <v-btn v-on="on" small text>
                      <v-icon>delete</v-icon>
                    </v-btn>
                  </template>
                  <v-card>
                    <v-card-title>
                      <span class="headline">Confirm</span>
                    </v-card-title>
                    <v-card-text v-if="item.recurringEventId">
                      Do you want to delete all occurrences or this one only?<br>
                      <strong>{{ item.startTime | formatDate(item.allDay ? 'date' : 'timestamp') }} - {{ item.endTime | formatDate(item.allDay ? 'date' : 'timestamp') }}</strong>
                    </v-card-text>
                    <v-card-text v-else>
                      Are you sure you want to archive this appointment?<br>
                      <strong>{{ item.startTime | formatDate(item.allDay ? 'date' : 'timestamp') }} - {{ item.endTime | formatDate(item.allDay ? 'date' : 'timestamp') }}</strong>
                    </v-card-text>
                    <v-card-actions>
                      <v-spacer></v-spacer>
                      <v-btn color="secondaryButton mr-3" text @click="item.deleteConfirm = false">Cancel</v-btn>
                      <div v-if="item.recurringEventId">
                        <v-btn color="primaryCustom" class="white--text mr-2"
                               @click="deleteAppointment(item, false)">One Only</v-btn>
                        <v-btn color="brRed" class="white--text"
                               @click="deleteAppointment(item, true)">All Occurrences</v-btn>
                      </div>
                      <v-btn color="brRed" class="white--text" v-else
                             @click="deleteAppointment(item, false)">Yes</v-btn>
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

  import RRule from '@/components/RRule.vue'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import {getRequest, deleteRequest, putRequest, getRequestWithParams, postRequest, getSnackbar} from '@/helpers/helpers'
  import orderBy from "lodash.orderby"
  import moment from 'moment-timezone'
  import constants from "@/helpers/constants"

  const { VUE_APP_ENV } = process.env

  export default {
    name: 'Appointments',
    components: {

      RRule,
      DatetimePickerInput
    },
    props: {
      orgId: Number,
      userId: Number
    },
    watch: {
      'orgId': function () {
        //without these if statements the appointments will get reloaded twice when switching between org and user
        if(this.orgId != null) {
          // reset the schedule when new org selected
          this.appointments = []
          this.addNew = false
          this.newAppt = {}
          this.getAppointments()
        }
      },
      'userId': function () {
        if(this.userId != null) {
          // reset the appointments when new user selected
          this.appointments = []
          this.addNew = false
          this.newAppt = {}
          this.getAppointments()
        }
      }
    },
    data() {
      return {
        snackbar: {},
        VUE_APP_ENV,
        addNew: false,
        expanded: [],
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('AVAILABILITY', 'EDIT'),
        newAppt: {},
        appointments: [],
        saveError: false,
        saveErrorMsg: '',
        newSaveError: false,
        newSaveErrorMsg: '',
        dateType: 'date',
        options: {
          itemsPerPage: 100
        },
        footerProps: {
          'items-per-page-options': [25, 50, 100, 1000],
          'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
        },
        dataLoading: true,
        dateFormat: 'MMMM DD, YYYY',
        timestampType: 'timestamp',
        timestampFormat: 'MMMM DD, YYYY h:mm a',
        timezone: this.$store.state.user.details.timezone.value,
        headers: [
          { text: 'Appointments', value: 'appointment', show: true},
          { text: 'Description', value: 'description', show: true},
          { text: 'All Day', value: 'allDay', show: true},
          { text: '', value: 'icons', show: true}
        ],
      }
    },
    computed: {
      totalAppointments() {
        return this.appointments.filter(a => { return !a.archived}).length;
      },
    },
    created() {
      this.getAppointments()
      // if(VUE_APP_ENV === 'local') {
      //   //randa test stuff
      //   this.addNew = true
      //   this.newAppt = {
      //     description: 'hello world',
      //     startTime: '2020-10-28T19:00:00.000Z',
      //     endTime: '2020-10-28T21:00:00.000Z',
      //     repeat: true
      //   }
      // }
    },
    methods: {
      async getAppointments() {
        if(this.orgId || this.userId) {
          this.dataLoading = true
          this.$store.commit(AppMutations.SET_LOADING, true)
          const { sortBy, sortDesc, page, itemsPerPage } = this.options
          try {
            const {data} = await getRequestWithParams(`/availability/appointments`, { params: {
                userId: this.userId,
                orgId: this.orgId,
                page: page - 1 || 0,
                size: itemsPerPage
              }})
            this.appointments = data.content
            this.dataLoading = false
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.$store.commit(AppMutations.SET_LOADING, false)
            this.snackbar = getSnackbar('ERROR', 'Error Loading Appointments')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          }
        }
      },
      async saveAppt(appt) {
        if((!appt.allDay && appt.startTime >= appt.endTime) || (appt.allDay && appt.startTime > appt.endTime)) {
          this.saveError = true
          this.saveErrorMsg = '* Appointment End must be after Appointment Start'
        } else {
          try {
            this.$store.commit(AppMutations.SET_LOADING, true)
            if( appt.allDay) {
              appt.startTime = moment(appt.startTime).startOf('day').utc().format()
              appt.endTime = moment(appt.endTime).endOf('day').utc().format()
            }


            let params = {
              orgId: this.orgId,
              userId: this.userId,
              ...appt
            }
            const {data} = await postRequest(`/availability/appointment`, params)
            this.addNew = false
            this.expanded = []
            //if repeating appointment - reload appointments to get full list
            this.newAppt = {}
            if(appt.repeat) {
              await this.getAppointments()
            } else if(!appt.id) {
              //else if new appointment - push into appointments
              this.appointments.push(data)
              this.appointments = orderBy(this.appointments, [s => s.startDate])
              this.$store.commit(AppMutations.SET_LOADING, false)
            }
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.$store.commit(AppMutations.SET_LOADING, false)
            this.snackbar = getSnackbar('ERROR', 'Error Saving Appointment')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          }
        }
      },
      filterAppointments () {
        return this.appointments.filter(a => { return !a.archived})
      },
      async deleteAppointment(item, deleteAllRecurring) {
        this.$store.commit(AppMutations.SET_LOADING, true)

        try {
          let url = deleteAllRecurring ? `/availability/appointment/recurrence/${item.recurringEventId}` : `/availability/appointment/${item.id}`

          await deleteRequest(url)
          item.archived = true
          if(deleteAllRecurring) {
            //reload appointments if we deleted more than one
            await this.getAppointments()
          }
          this.snackbar = getSnackbar('SUCCESS', 'Appointment Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error deleting appointment')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteRecurring(item) {
        this.$store.commit(AppMutations.SET_LOADING, true)

        try {
          await deleteRequest(`/availability/appointment/${item.id}`)
          item.archived = true
          this.snackbar = getSnackbar('SUCCESS', 'Appointment Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error deleting appointment')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      recurrenceCallback(recurrenceString, endDate, count, endsType) {
        if(endsType === 'fixed' && count > 100) {
          this.newSaveError = true
          this.newSaveErrorMsg = 'Cannot exceed 100 repetitions'
        } else if(endsType === 'fixed' && count == null) {
          this.newSaveError = true
          this.newSaveErrorMsg = 'A occurrence count is required'
        } else if(endsType === 'date' && endDate == null) {
          this.newSaveError = true
          this.newSaveErrorMsg = 'An end date is required'
        } else if(endsType === 'date' && moment(endDate, 'YYYY-MM-DD').isAfter(moment().add(1, 'y').add(1, 'd'))) {
          this.newSaveError = true
          this.newSaveErrorMsg = 'Cannot exceed 1 year from today'
        } else {
          this.newSaveError = false
          this.newSaveErrorMsg = ''

          this.newAppt.recurringEventEndType = endsType === 0 ? null : endsType
          this.newAppt.recurrence = recurrenceString
          this.newAppt.recurringEndTime = endDate
        }
      }

    }
  }
</script>

<style lang="scss">
#appointment-container .v-data-table__wrapper {
  height: calc(100vh - 390px);
  min-height: 300px;
}
</style>

<style lang="scss" scoped>

</style>

