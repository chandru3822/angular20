<template>
  <v-container v-if="orgId || userId">
    <v-row>
      <v-col>
        <v-btn v-if="!addNew" @click="addNew = !addNew">
          Add Appointment
        </v-btn>
        <v-card v-if="addNew" flat class="px-3">
          <v-card-title>Add Schedule</v-card-title>
          <DatetimePickerInput
            v-model="newAppt.startDate"
            :timezone="this.timezone"
            :type="newAppt.allDay ? dateType : timestampType"
            :format="'MMMM DD, YYYY'"
            label="Start Time"
          />
          <DatetimePickerInput
            v-model="newAppt.endDate"
            :timezone="this.timezone"
            :type="newAppt.allDay ? dateType : timestampType"
            :format="'MMMM DD, YYYY'"
            label="End Time"
          />
          <v-checkbox
            v-model="newAppt.allDay"
            label="All Day"
          ></v-checkbox>
        </v-card>
      </v-col>
    </v-row>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'Appointments',
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
        newAppt: {},
        dateType: 'date',
        timestampType: 'timestamp',
        timezone: this.$store.state.user.details.timezone.value,
      }
    },
    methods: {}
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>

</style>

