<template>
  <v-container v-if="orgId || userId" id="appointment-container">
    <v-row>
      <v-col>
        <a-btn v-if="!addNew && userStore.userHasFeatureAccessLevel('AVAILABILITY', 'ADD')"
               id="qa-add-appointment-button"
                         @click="addNew = !addNew" color="primary" class="mb-3" text="ADD APPOINTMENT"/>
        <v-card v-if="addNew" flat class="px-3">
          <v-card-title>Add Appointment</v-card-title>
          <a-text-field
              id="qa-new-appt-title"
            v-model="newAppt.title"
            :maxlength="50"
            counter
            placeholder=" "
            label="Title"
          ></a-text-field>
          <a-text-field
              id="qa-new-appt-description"
            v-model="newAppt.description"
            placeholder=" "
            label="Description (optional)"
          ></a-text-field>
          <a-text-field
              id="qa-new-appt-location"
            v-model="newAppt.location"
            placeholder=" "
            label="Location (optional)"
          ></a-text-field>
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
              id="qa-new-appt-all-day"
            v-model="newAppt.allDay"
            label="All Day"
          ></v-checkbox>
          <v-checkbox
              id="qa-new-appt-repeat"
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
              <a-btn variant="text"
                               color="primary"
                               @click="[newAppt = {}, addNew = false]"
                               text="CANCEL"
              />
              <a-btn color="primary"
                     id="qa-new-appt-save-button"
                               @click="saveAppt(newAppt, false)" class="white--text"
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
                <a-text-field
                  v-model="appt.title"
                  :maxlength="50"
                  counter
                  label="Title"
                ></a-text-field>
                <a-text-field
                  v-model="appt.description"
                  label="Description (optional)"
                ></a-text-field>
                <a-text-field
                  v-model="appt.location"
                  placeholder=" "
                  label="Location (optional)"
                  @input="appt.reloadCoordinates = true"
                ></a-text-field>
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
                    <a-btn
                      color="primary"
                      @click="[itemToSave = appt, appt.repeat ? showSaveDialog = true : saveAppt(appt, false)]"
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
                <a-btn
                  size="small"
                  variant="text"
                  color="primary"
                  @click="[expanded = [item], selectedIndex = index, saveError = false]"
                  v-if="!expanded.includes(item) && userCanEdit"
                  prepend-icon="edit"
                />
                <a-btn size="small" variant="text" color="primary" @click="expanded = []"
                       v-if="expanded.includes(item)" text="CANCEL"/>
                <a-btn size="small" variant="text" color="primary"
                       v-if="userStore.userHasFeatureAccessLevel('AVAILABILITY', 'DELETE')"
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
    <MultiOptionDialog :open-dialog="showSaveDialog"
                       :options="saveOptions"
                       title="Save Appointment(s)"
                       @option-0="saveAppt(itemToSave, false)"
                       @option-1="saveAppt(itemToSave, true)"
                       @cancel="closeSaveDialog">
      {{itemToSaveString}}<br>
      <strong>{{ itemToSaveDateString }}</strong>
    </MultiOptionDialog>
  </v-container>
</template>

<script setup>


  import RRule from '@/components/RRule.vue'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import { handleHidingGlobalLoader, deleteRequest, getRequestWithParams, postRequest, getSnackbar} from '@/helpers/helpers'
  import orderBy from 'lodash.orderby'
  import moment from 'moment-timezone'
  import constants from '@/helpers/constants'
  import MultiOptionDialog from '@/components/MultiOptionDialog'
  import { DateTime } from 'luxon'


  import {getCurrentInstance, onMounted, toRefs, ref, computed, watch, defineProps} from "vue";
  import { useUserStore } from '@/stores/UserStore.js'
  import {useRoute} from "vue-router/composables"
  import { useAppStore } from '@/stores/AppStore.js'
  const appStore = useAppStore()

  const vueInstance = getCurrentInstance().proxy
     const store = vueInstance.$store
  const userStore = useUserStore()
  const route = useRoute()

  const { VITE_ENV } = import.meta.env

  const props = defineProps({
    orgId: Number,
    userId: Number
  })

  const { orgId, userId } = toRefs(props)


  watch(orgId, () => {
    //without these if statements the appointments will get reloaded twice when switching between org and user
    if(orgId.value != null) {
      // reset the schedule when new org selected
      appointments.value = []
      addNew.value = false
      newAppt.value = {}
      getAppointments()
    }
  })
  watch(userId, () => {
    if(userId.value != null) {
      // reset the appointments when new user selected
      appointments.value = []
      addNew.value = false
      newAppt.value = {}
      getAppointments()
    }
  })
  const addNew = ref(false)
  const expanded = ref([])
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
  const headers = ref([
    { text: 'Appointments', value: 'appointment', show: true},
    { text: 'Title', value: 'title', show: true},
    { text: 'All Day', value: 'allDay', show: true},
    { text: '', value: 'icons', show: true}
  ])
  const showDeleteDialog = ref(false)
  const showSaveDialog = ref(false)
  const itemToDelete = ref(null)
  const itemToSave = ref(null)

  const timezone = computed(() => {
    return  userStore.timezone.value
  })

  const userCanEdit = computed(() => {
    return userStore.userHasFeatureAccessLevel('AVAILABILITY', 'EDIT')
  })

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


  const itemToSaveDateString = computed(() => {
    return itemToSave.value ?
      `${vueInstance.$filters.formatDate(itemToSave.value.startTime, itemToSave.value.allDay ? 'date' : 'timestamp') || ''} - ${vueInstance.$filters.formatDate(itemToSave.value.endTime, itemToSave.value.allDay ? 'date' : 'timestamp') || ''}`
      : null
  })
  const itemToSaveString = computed(() => {
    if(itemToSave.value) {
      return itemToSave.value.recurringEventId ? "Do you want to save all occurrences of this appointment or this appointmnet only?"
        : null
    }
    return null
  })

  const saveOptions = computed(() => {
    if(itemToSave.value) {
      return itemToSave.value.recurringEventId ? ['one only', 'all occurrences']
        : ['confirm']
    }
    return null
  })
  onMounted(() => {
    getAppointments()
  })
  const getAppointments = async () => {
    if(orgId.value || userId.value) {
      dataLoading.value = true
      appStore.loading = true
      const { page, itemsPerPage } = options.value
      try {
        const {data, status} = await getRequestWithParams(`/availability/appointments`, { params: {
            userId: userId.value,
            orgId: orgId.value,
            page: page - 1 || 0,
            size: itemsPerPage
          }})
        appointments.value = data.content
        dataLoading.value = false
        handleHidingGlobalLoader(status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        appStore.loading = false
        appStore.showSnack('ERROR', 'Error Loading Appointments')

      }
    }
  }
  const saveAppt = (appt, saveRecurring = false) => {
    if((!appt.allDay && appt.startTime >= appt.endTime) || (appt.allDay && appt.startTime.split('T')[0] > appt.endTime.split('T')[0])) {
      saveError.value = true
      saveErrorMsg.value = '* Appointment End must be after Appointment Start'
    } else {
      if (saveRecurring === true) {
        appointments.value.filter((a) => a?.recurringEventId === appt?.recurringEventId).forEach((a) => saveApptHelper(appt, a))

      } else {
        saveApptHelper(appt, appt)
      }
      showSaveDialog.value = false
    }
  }
  const saveApptHelper = async (apptSource, dest) => {
    dest.title = apptSource.title
    dest.description = apptSource.description
    dest.location = apptSource.location
    const appt = dest
    if (appt.repeat) {
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
      appStore.loading = true

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
        orgId: orgId.value,
        userId: userId.value,
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
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.loading = false
      appStore.showSnack('ERROR', 'Error Saving Appointment')
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
    appStore.loading = true

    try {
      let url = deleteAllRecurring ? `/availability/appointment/recurrence/${item.recurringEventId}` : `/availability/appointment/${item.id}`

      const {status} = await deleteRequest(url)

      appointments.value?.forEach((a) => {
        if (a.id === itemToDelete.value.id) {
          a.archived = true
        }
      })

      if(deleteAllRecurring) {
        //reload appointments if we deleted more than one
        await getAppointments()
      }
      appStore.showSnack('SUCCESS', 'Appointment Deleted')

      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error deleting appointment')

      appStore.loading = false
    }
    closeDeleteDialog()
  }
  const deleteRecurring = async (item) => {
    appStore.loading = true

    try {
      const {status} = await deleteRequest(`/availability/appointment/${item.id}`)
      item.archived = true
      appStore.showSnack('SUCCESS', 'Appointment Deleted')

      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error deleting appointment')

      appStore.loading = false
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
  const closeSaveDialog =()=> {
      showSaveDialog.value = false
      itemToSave.value = null
  }
</script>

<style lang="scss">
#appointment-container .v-data-table__wrapper {
  height: calc(100vh - 390px);
  min-height: 300px;
}
</style>
