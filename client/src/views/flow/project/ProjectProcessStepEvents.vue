<template>
  <v-main class="events-container">
    <v-toolbar color="transparent" class="elevation-0 cfg-name-toolbar">
      <v-toolbar-title>
        Event Details
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
      </v-toolbar-items>
    </v-toolbar>
    <v-card class="pa-4 square-card">
      <div v-if="!selectedEvent.id">
        <div v-for="pse in processStepEvents" class="mb-2">
          <v-btn color="primaryCustom" class="white--text pl-2" @click="addEvent(pse)">
            <v-icon color="white" class="mr-2">add</v-icon>
            {{pse.eventName}}
          </v-btn>
        </div>
        <v-data-table
          :headers="headers"
          :items="projectProcessStepEvents"
          :items-per-page="-1"
          :mobile-breakpoint="0"
          hide-default-footer
          hide-default-header
          class="elevation-0"
        >
          <template #no-data>
            No events
          </template>

          <template #no-results>
            No events
          </template>

          <template #item="{ item }">
            <tr  class="clickable text-left" :class="{'shaded-row': projectProcessStepEvents.indexOf(item) % 2}"
              @click="[selectedEvent = item, getEventCfgs(item)]">
              <td class="text-left">{{ item.eventName }}</td>
              <td class="text-left">{{ item.eventStatusType }}</td>
            </tr>
          </template>

        </v-data-table>
      </div>
      <div v-else>
        <v-toolbar color="transparent" class="elevation-0 cfg-name-toolbar">
          <v-toolbar-title>
            {{selectedEvent.eventName}}
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text class="pl-1 pr-2 mb-2" @click="selectedEvent = {}">
              <v-icon>close</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <br/>
        {{selectedEvent}}
      </div>
    </v-card>
  </v-main>
</template>

<script>

  import {getRequest, logError, getSnackbar, getRequestWithParams, putRequest, postRequest} from '@/helpers/helpers'
  import {AppMutations} from '@/stores/AppStore'

  export default {
    name: 'ProjectProcessStepEvents',
    components: {},
    props: {
      projectProcessStepEvents: Array,
    },
    data() {
      return {
        snackbar: {},
        selectedEvent: {},
        ppsEventCfgs: [],
        timezone: this.$store.state.user.details.timezone.value,
        projectId: this.$route.params.projectId,
        projectProcessStepId: this.$route.params.processStepId,
        processStepId: this.$route.query.processStepId,
        processStepEvents: [],
        headers: [
          { text: 'Event', value: 'eventName', show: true },
          { text: 'Status', value: 'eventStatusType', show: true },
        ],
      }
    },
    async created() {
      await this.getProcessStepEvents()
    },
    computed: {},
    methods: {
      addEvent: async function (pse) {
        try {
          const {data} = await postRequest(`/projectProcessStep/${this.projectProcessStepId}/event`, pse)
          this.selectedEvent = data
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Event')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      getProcessStepEvents: async function () {
        //this gets the events assigned to the process step so we know which ADD buttons to show
        try {
          const {data} = await getRequest(`/processStep/${this.processStepId}/event`)
          this.processStepEvents = data
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Details')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      getEventCfgs: async function (ppsEvent) {
        try {
          const {data} = await getRequest(`/processStep/${this.processStepId}/event`)
          this.ppsEventCfgs = data
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Details')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    }
  }
</script>

<style lang="scss">

</style>
<style lang="scss" scoped>
.events-container {

}
</style>
