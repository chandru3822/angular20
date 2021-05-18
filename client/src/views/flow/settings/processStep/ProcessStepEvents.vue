<template>
  <v-container class="pt-0">
    <v-row>
      <v-col cols="12" class="pt-0 px-0">
        <v-toolbar flat class="req-header-bar">
          <v-toolbar-title class="app-title">Events</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn @click="[getAvailableEvents()]" text v-if="userCanAdd">
              <v-icon v-if="!addNewEvent">add</v-icon>
              {{ addNewEvent ? 'Cancel' : 'Add Event'}}
            </v-btn>
            <v-btn text @click="expandEvents = !expandEvents">
              <v-icon v-if="!expandEvents">mdi-chevron-down</v-icon>
              <v-icon v-else>mdi-chevron-up</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-row v-if="addNewEvent">
          <v-col cols="12">
            <v-select v-model="newEvent.eventId"
                      :items="availableEvents"
                      label="Select Event"
                      item-value="id"
                      item-text="eventName"
            ></v-select>
          </v-col>
        </v-row>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
  import Vue2Filters from 'vue2-filters'
  import {AppMutations} from '@/stores/AppStore'
  import {
    getRequest,
    deleteRequest,
    putRequest,
    postRequest,
    getRequestWithParams,
    getSnackbar
  } from '@/helpers/helpers'

  export default {
    name: 'ProcessStepEvents',
    mixins: [Vue2Filters.mixin],
    data() {
      return {
        snackbar: {},
        expandEvents: true,
        processStepId: this.$route.params.id,
        userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
        headers: [
          {text: 'ID', value: 'requirementNbr', width: '65px', show: true},
          {text: 'Type', value: 'processStepRequirementType', show: true},
          {text: 'Details', value: 'custom', show: true},
          {text: 'Operator', value: 'operatorType', show: true},
          {text: 'Value', value: 'requirementValue', show: true},
          {text: null, value: 'icons', show: true}
        ],
        addNewEvent: false,
        newEvent: {},
        events: [],
        availableEvents: []
      }
    },
    computed: {},
    async created() {
      await this.getEvents()
    },
    methods: {
      async getEvents() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/processStep/${this.processStepId}/event`)
          this.events = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getAvailableEvents() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/processStep/${this.processStepId}/event/available`)
          this.availableEvents = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterEvents() {
        return this.events.filter(e => {
          return !e.archived
        })
      },
    }

  }
</script>

<style scoped lang="scss">

</style>
