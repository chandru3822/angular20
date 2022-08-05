<template>
  <v-container v-if="orgId || userId" id="appointment-container">
    <v-row>
      <v-col>
        <v-btn v-if="!addNew && $store.getters.userHasFeatureAccessLevel('AVAILABILITY', 'ADD')" @click="addNew = !addNew" color="primary" class="mb-3">
          Add Appointment
        </v-btn>
        <v-card v-if="addNew" flat class="px-3">
          <v-card-title>Add Schedule</v-card-title>
          <v-text-field
            v-model="newAppt.title"
            counter="50"
            placeholder=" "
            label="Title"
          ></v-text-field>
          <v-text-field
            v-model="newAppt.description"
            placeholder=" "
            label="Description (optional)"
          ></v-text-field>
          <v-text-field
            v-model="newAppt.location"
            placeholder=" "
            label="Location (optional)"
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
              <v-btn text color="primary" @click="[newAppt = {}, addNew = false]">Cancel</v-btn>
              <v-btn color="primary"  @click="saveAppt(newAppt)" class="white--text"
                     :disabled="!newAppt.startTime || !newAppt.endTime || !newAppt.title || newAppt.title.length > 50">
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
                <!-- NOTE: THERE WOULD BE A BIG ISSUE IF WE ALLOWED EDITING RECURRING EVENTS AND THEY WERE EDITED FROM 2 DIFFERENT TIMEZONES! YIKES! -->
                <v-text-field
                  v-model="appt.title"
                  counter="50"
                  :readonly="appt.recurringEventId != null"
                  :disabled="appt.recurringEventId != null"
                  label="Title"
                ></v-text-field>
                <v-text-field
                  v-model="appt.description"
                  :readonly="appt.recurringEventId != null"
                  :disabled="appt.recurringEventId != null"
                  label="Description (optional)"
                ></v-text-field>
                <v-text-field
                  v-model="appt.location"
                  placeholder=" "
                  label="Location (optional)"
                  @input="appt.reloadCoordinates = true"
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
                    <v-btn color="primary"  @click="saveAppt(appt)" class="white--text"
                           :disabled="saveError || !appt.startTime || !appt.endTime || !appt.title || appt.title.length > 50">
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
              <td class="text-left">{{item.title}}</td>
              <td><input type="checkbox" :disabled="true" v-model="item.allDay"></td>
              <td class="text-left">
                <v-btn small text color="primary" @click="[expanded = [item], selectedIndex = index, saveError = false]"
                       v-if="!expanded.includes(item) && userCanEdit">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text color="primary" @click="expanded = []"
                       v-if="expanded.includes(item)">cancel
                </v-btn>
                <v-btn small text color="primary"
                       v-if="$store.getters.userHasFeatureAccessLevel('AVAILABILITY', 'DELETE')"
                       @click="[itemToDelete=item, showDeleteDialog=true]"
                ><v-icon>delete</v-icon></v-btn>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <MultiOptionDialog :open-dialog="showDeleteDialog"
                       :options="deleteOptions"
                       @option-0="deleteAppointment(false)"
                       @option-1="deleteAppointment(true)"
                       @cancel="closeDeleteDialog">
      {{itemToDeleteString}}<br>
      <strong>{{ itemToDeleteDateString }}</strong>
    </MultiOptionDialog>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'

  import RRule from '@/components/RRule.vue'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import { handleHidingGlobalLoader, deleteRequest, getRequestWithParams, postRequest, getSnackbar} from '@/helpers/helpers'
  import orderBy from "lodash.orderby"
  import moment from 'moment-timezone'
  import constants from "@/helpers/constants"
  import MultiOptionDialog from "@/components/MultiOptionDialog";

  const { VUE_APP_ENV } = process.env

  export default {
    name: 'Appointments',
    components: {
      MultiOptionDialog,
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
      },
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
          { text: 'Title', value: 'title', show: true},
          { text: 'All Day', value: 'allDay', show: true},
          { text: '', value: 'icons', show: true}
        ],
        showDeleteDialog:false,
        itemToDelete: null
      }
    },
    computed: {
      totalAppointments() {
        return this.appointments.filter(a => { return !a.archived}).length;
      },
      itemToDeleteDateString (){
        return this.itemToDelete ?
            `${this.$filters.formatDate(this.itemToDelete.startTime, this.itemToDelete.allDay ? 'date' : 'timestamp') || ''} - ${this.$filters.formatDate(this.itemToDelete.endTime, this.itemToDelete.allDay ? 'date' : 'timestamp') || ''}`
            : ''
      },
      itemToDeleteString() {
        if(this.itemToDelete) {
          return this.itemToDelete.recurringEventId ? "Do you want to delete all occurrences or this one only?"
              : "Are you sure you want to archive this appointment?"
        }
            return ''
        },
      deleteOptions() {
        if(this.itemToDelete) {
          return this.itemToDelete.recurringEventId ? ['one only', 'all occurrences']
              : ['confirm']
        }
        return null
      }
    },
    created() {
      // if(VUE_APP_ENV === 'local') {
      //   //randa test stuff
      //   this.addNew = true
      //   this.newAppt = {
      //     title: 'hello world',
      //     description: 'hello description',
      //     startTime: '2020-12-28T19:00:00.000Z',
      //     endTime: '2020-12-28T21:00:00.000Z',
      //     repeat: false
      //   }
      // }
      this.getAppointments()
    },
    methods: {
      async getAppointments() {
        if(this.orgId || this.userId) {
          this.dataLoading = true
          this.$store.commit(AppMutations.SET_LOADING, true)
          const { page, itemsPerPage } = this.options
          try {
            const {data, status} = await getRequestWithParams(`/availability/appointments`, { params: {
                userId: this.userId,
                orgId: this.orgId,
                page: page - 1 || 0,
                size: itemsPerPage
              }})
            this.appointments = data.content
            this.dataLoading = false
            handleHidingGlobalLoader(this, status)
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
          if(appt.repeat) {
            //if it is a repeating appt, then save the current users timezone and offset (required for adjusting DST later)
            appt.originTimezone = this.timezone
            appt.originTimezoneOffset = moment.tz(moment.utc(appt.startTime), this.timezone).utcOffset() * 60
          } else {
            //clear out recurrence fields if not repeat when saved
            appt.recurrence = null
            appt.recurringEventType = null
          }
          try {
            this.$store.commit(AppMutations.SET_LOADING, true)
            if( appt.allDay) {
              appt.startTime = moment(appt.startTime).startOf('day').utc().format()
              appt.endTime = moment(appt.endTime).endOf('day').utc().format()
            }

            //if the local date and the utc date are different, set the startTimeOffsetDay to true so the server knows what to do
            let localAndUtcSame = moment(moment(appt.startTime).format('YYYY-MM-DD')).isSame(moment(appt.startTime).utc().format('YYYY-MM-DD'))

            let params = {
              orgId: this.orgId,
              userId: this.userId,
              ...appt,
              startTimeOffsetDay: !localAndUtcSame,
            }
            const {data, status} = await postRequest(`/availability/appointment`, params)
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
            }
            handleHidingGlobalLoader(this, status)
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
      async deleteAppointment(deleteAllRecurring) {
        const item = this.itemToDelete
        this.$store.commit(AppMutations.SET_LOADING, true)

        try {
          let url = deleteAllRecurring ? `/availability/appointment/recurrence/${item.recurringEventId}` : `/availability/appointment/${item.id}`

          const {status} = await deleteRequest(url)
          item.archived = true
          if(deleteAllRecurring) {
            //reload appointments if we deleted more than one
            await this.getAppointments()
          }
          this.snackbar = getSnackbar('SUCCESS', 'Appointment Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error deleting appointment')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
        this.closeDeleteDialog()
      },
      async deleteRecurring(item) {
        this.$store.commit(AppMutations.SET_LOADING, true)

        try {
          const {status} = await deleteRequest(`/availability/appointment/${item.id}`)
          item.archived = true
          this.snackbar = getSnackbar('SUCCESS', 'Appointment Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
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
      },
      closeDeleteDialog(){
        this.showDeleteDialog = false
        this.itemToDelete = null
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
