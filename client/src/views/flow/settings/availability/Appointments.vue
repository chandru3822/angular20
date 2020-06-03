<template>
  <v-container v-if="orgId || userId">
    <v-row>
      <v-col>
        <v-btn v-if="!addNew">
          Add Appointment
        </v-btn>
        <v-card v-if="addNew" flat class="px-3">
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
      }
    },
    methods: {}
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>

</style>

