<template>
  <v-container v-if="orgId || userId" id="appointment-container">
    <v-row>
      <v-col>
        <AlbatrossButton v-if="!addNew && store.getters.userHasFeatureAccessLevel('AVAILABILITY', 'ADD')"
                         @click="addNew = !addNew" color="primary" class="mb-3" text="ADD APPOINTMENT"/>
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
            :timezone="timezone"
            :type="newAppt.allDay ? dateType : timestampType"
            :format="newAppt.allDay ? dateFormat : timestampFormat"
            :label="newAppt.allDay ? 'Start Date' : 'Start Time'"
          />
          <DatetimePickerInput
            v-model="newAppt.endTime"
            :timezone="timezone"
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
              <AlbatrossButton variant="text"
                               color="primary"
                               @click="[newAppt = {}, addNew = false]"
                               text="CANCEL"
              />
              <AlbatrossButton color="primary"
                               @click="saveAppt(newAppt)" class="white--text"
                               :disabled="!newAppt.startTime || !newAppt.endTime || !newAppt.title || newAppt.title.length > 50"
                               text="SAVE"
              />
            </v-card-actions>
          </v-card-actions>
        </v-card>

        <v-data-table
          v-if="!addNew"
          :headers="headers"
          :items="filterAppointments"
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
            <span class="default-text-color">No available appointments</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available appointments</span>
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
                    <AlbatrossButton
                      color="primary"
                      @click="saveAppt(appt)"
                      class="white--text"
                      :disabled="saveError || !appt.startTime || !appt.endTime || !appt.title || appt.title.length > 50"
                      text="SAVE"
                    />
                  </v-card-actions>
                </v-card-actions>
              </v-card>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.startTime | formatDate(item.allDay ? 'date' : 'timestamp')}} - {{item.endTime | formatDate(item.allDay ? 'date' : 'timestamp')}}</td>
              <td class="text-left">{{item.title}}</td>
              <td><input type="checkbox" :disabled="true" v-model="item.allDay"></td>
              <td class="text-left">
                <AlbatrossButton
                  size="small"
                  variant="text"
                  color="primary"
                  @click="[expanded = [item], selectedIndex = index, saveError = false]"
                  v-if="!expanded.includes(item) && userCanEdit"
                  prepend-icon="edit"
                />
                <AlbatrossButton size="small" variant="text" color="primary" @click="expanded = []"
                       v-if="expanded.includes(item)" text="CANCEL"/>
                <AlbatrossButton size="small" variant="text" color="primary"
                       v-if="store.getters.userHasFeatureAccessLevel('AVAILABILITY', 'DELETE')"
                       @click="[itemToDelete=item, showDeleteDialog=true]"
                       prepend-icon="delete"
                />
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

<script setup>
  import {AppMutations} from '@/stores/AppStore'

  import RRule from '@/components/RRule.vue'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import { handleHidingGlobalLoader, deleteRequest, getRequestWithParams, postRequest, getSnackbar} from '@/helpers/helpers'
  import orderBy from 'lodash.orderby'
  import moment from 'moment-timezone'
  import constants from '@/helpers/constants'
  import MultiOptionDialog from '@/components/MultiOptionDialog'
  import { DateTime } from 'luxon'

  import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";
  import {getCurrentInstance, onMounted, ref, computed, watch, defineProps} from "vue";

  const vueInstance = getCurrentInstance().proxy
  const snackbar = vueInstance.$snackbar
  const store = vueInstance.$store
  const route = vueInstance.$route

  const { VITE_ENV } = import.meta.env

  const props = defineProps({
    orgId: Number,
    userId: Number
  })
  watch('orgId', () => {
    //without these if statements the appointments will get reloaded twice when switching between org and user
    if(props.orgId != null) {
      // reset the schedule when new org selected
      appointments.value = []
      addNew.value = false
      newAppt.value = {}
      getAppointments()
    }
  })
  watch('userId', () => {
    if(props.userId != null) {
      // reset the appointments when new user selected
      appointments.value = []
      addNew.value = false
      newAppt.value = {}
      getAppointments()
    }
  })
  const addNew = ref(false)
  const expanded = ref([])
  const userCanEdit = ref(store.getters.userHasFeatureAccessLevel('AVAILABILITY', 'EDIT'))
  const newAppt = ref({})
  const appointments = ref([])
  const saveError = ref(false)
  const saveErrorMsg = ref('')
  const newSaveError = ref(false)
  const newSaveErrorMsg = ref('')
  const dateType = ref('date')
  const options = ref({
    itemsPerPage: 100
  })
  const footerProps = ref({
    'items-per-page-options': [25, 50, 100, 1000],
    'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
  })
  const dataLoading = ref(true)
  const dateFormat = ref('MMMM DD, YYYY')
  const timestampType = ref('timestamp')
  const timestampFormat = ref('MMMM DD, YYYY h:mm a')
  const timezone = ref(store.state.user.details.timezone.value)
  const headers = ref([
    { text: 'Appointments', value: 'appointment', show: true},
    { text: 'Title', value: 'title', show: true},
    { text: 'All Day', value: 'allDay', show: true},
    { text: '', value: 'icons', show: true}
  ])
  const showDeleteDialog = ref(false)
  const itemToDelete = ref(null)

  const totalAppointments = computed(() => {
    return appointments.value.filter(a => { return !a.archived}).length;
  })
  const itemToDeleteDateString = computed(() => {
    return itemToDelete.value ?
        `${vueInstance.$filters.formatDate(itemToDelete.value.startTime, itemToDelete.value.allDay ? 'date' : 'timestamp') || ''} - ${vueInstance.$filters.formatDate(itemToDelete.value.endTime, itemToDelete.value.allDay ? 'date' : 'timestamp') || ''}`
        : ''
  })
  const itemToDeleteString = computed(() => {
    if(itemToDelete.value) {
      return itemToDelete.value.recurringEventId ? "Do you want to delete all occurrences or this one only?"
          : "Are you sure you want to archive this appointment?"
    }
    return ''
  })
  const deleteOptions = computed(() => {
    if(itemToDelete.value) {
      return itemToDelete.value.recurringEventId ? ['one only', 'all occurrences']
          : ['confirm']
    }
    return null
  })
  onMounted(() => {
    getAppointments()
  })
  const getAppointments = async () => {
    if(props.orgId || props.userId) {
      dataLoading.value = true
      store.commit(AppMutations.SET_LOADING, true)
      const { page, itemsPerPage } = options.value
      try {
        const {data, status} = await getRequestWithParams(`/availability/appointments`, { params: {
            userId: props.userId,
            orgId: props.orgId,
            page: page - 1 || 0,
            size: itemsPerPage
          }})
        appointments.value = data.content
        dataLoading.value = false
        handleHidingGlobalLoader(vueInstance, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        store.commit(AppMutations.SET_LOADING, false)
        snackbar('ERROR', 'Error Loading Appointments')

      }
    }
  }
  const saveAppt = async (appt) => {
    if((!appt.allDay && appt.startTime >= appt.endTime) || (appt.allDay && appt.startTime > appt.endTime)) {
      saveError.value = true
      saveErrorMsg.value = '* Appointment End must be after Appointment Start'
    } else {
      if(appt.repeat) {
        // All day appointments don't have an attached timezone
        //@TODO: ask randa if it's ok we only set these for non all-day recurring appointments
        if (!appt.allDay) {
          //if it is a repeating appt, then save the current users timezone and offset (required for adjusting DST later)
          appt.originTimezone = timezone.value
          appt.originTimezoneOffset = moment.tz(moment.utc(appt.startTime), timezone.value).utcOffset() * 60
        }
      } else {
        //clear out recurrence fields if not repeat when saved
        appt.recurrence = null
        appt.recurringEventType = null
      }
      try {
        store.commit(AppMutations.SET_LOADING, true)

        if(appt.allDay) {
          appt.startTime = DateTime.fromISO(appt.startTime, {zone: 'utc'}).set({hour: 0, minute: 0, second: 0}).toISO()
          appt.endTime = DateTime.fromISO(appt.endTime, {zone: 'utc'})
                                 .set({hour: 0, minute: 0, second: 0})
                                 .plus({days: 1})
                                 .toISO()
        }

        //if the local date and the utc date are different, set the startTimeOffsetDay to true so the server knows what to do
        let localAndUtcSame = moment(moment(appt.startTime).format('YYYY-MM-DD')).isSame(moment(appt.startTime).utc().format('YYYY-MM-DD'))

        let params = {
          orgId: props.orgId,
          userId: props.userId,
          ...appt,
          startTimeOffsetDay: !localAndUtcSame && !appt.allDay,
        }
        const {data, status} = await postRequest(`/availability/appointment`, params)
        addNew.value = false
        expanded.value = []
        //if repeating appointment - reload appointments to get full list
        newAppt.value = {}
        if(appt.repeat || appt.allDay) {
          await getAppointments()
        } else if(!appt.id) {
          //else if new appointment - push into appointments
          appointments.value.push(data)
          appointments.value = orderBy(appointments.value, [s => s.startDate])
        }
        handleHidingGlobalLoader(vueInstance, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        store.commit(AppMutations.SET_LOADING, false)
        snackbar('ERROR', 'Error Saving Appointment')
      }
    }
  }
  const filterAppointments = computed(() => {
    return appointments.value.filter(a => { return !a.archived}).map(a => {
      if (a.allDay) {
        const endTime = DateTime.fromISO(a.endTime, {zone: 'utc'})
                            .minus({days: 1})
                            .toISO()
        return {...a, endTime}
      }
      return a
    })
  })
  const deleteAppointment = async (deleteAllRecurring) => {
    const item = itemToDelete.value
    store.commit(AppMutations.SET_LOADING, true)

    try {
      let url = deleteAllRecurring ? `/availability/appointment/recurrence/${item.recurringEventId}` : `/availability/appointment/${item.id}`

      const {status} = await deleteRequest(url)
      item.archived = true
      itemToDelete.value.archived = true
      if(deleteAllRecurring) {
        //reload appointments if we deleted more than one
        await getAppointments()
      }
      snackbar('SUCCESS', 'Appointment Deleted')

      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error deleting appointment')

      store.commit(AppMutations.SET_LOADING, false)
    }
    closeDeleteDialog()
  }
  const deleteRecurring = async (item) => {
    store.commit(AppMutations.SET_LOADING, true)

    try {
      const {status} = await deleteRequest(`/availability/appointment/${item.id}`)
      item.archived = true
      snackbar('SUCCESS', 'Appointment Deleted')

      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error deleting appointment')

      store.commit(AppMutations.SET_LOADING, false)
    }
  }
  const recurrenceCallback =(recurrenceString, endDate, count, endsType) => {
    if(endsType === 'fixed' && count > 100) {
      newSaveError.value = true
      newSaveErrorMsg.value = 'Cannot exceed 100 repetitions'
    } else if(endsType === 'fixed' && count == null) {
      newSaveError.value = true
      newSaveErrorMsg.value = 'A occurrence count is required'
    } else if(endsType === 'date' && endDate == null) {
      newSaveError.value = true
      newSaveErrorMsg.value = 'An end date is required'
    } else if(endsType === 'date' && moment(endDate, 'YYYY-MM-DD').isAfter(moment().add(1, 'y').add(1, 'd'))) {
      newSaveError.value = true
      newSaveErrorMsg.value = 'Cannot exceed 1 year from today'
    } else {
      newSaveError.value = false
      newSaveErrorMsg.value = ''

      newAppt.value.recurringEventEndType = endsType === 0 ? null : endsType
      newAppt.value.recurrence = recurrenceString
      newAppt.value.recurringEndTime = endDate
    }
  }
  const closeDeleteDialog =()=> {
    showDeleteDialog.value = false
    itemToDelete.value = null
  }
</script>

<style lang="scss">
#appointment-container .v-data-table__wrapper {
  height: calc(100vh - 390px);
  min-height: 300px;
}
</style>
