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
    <div v-if="!addNewEvent">
      <div v-for="pse in processStepEvents" class="mb-2">
        <v-btn color="primaryCustom" class="white--text pl-2" @click="[newEvent.eventId = pse.id, addNewEvent = true]">
          <v-icon color="white" class="mr-2">add</v-icon>
          {{pse.eventName}}
        </v-btn>
      </div>
    </div>
    <div v-else>
      event details adding stuff here
      <br/>
      {{newEvent}}
      <br/>
      <v-btn @click="[addNewEvent = false, newEvent = {}]">
        Cancel
      </v-btn>
    </div>
  </v-main>
</template>

<script>

  import {getRequest, logError, getSnackbar, getRequestWithParams, putRequest, postRequest} from '@/helpers/helpers'
  import {AppMutations} from '@/stores/AppStore'

  export default {
    name: 'ProjectProcessStepEvents',
    components: {},
    data() {
      return {
        snackbar: {},
        addNewEvent: false,
        newEvent: {},
        timezone: this.$store.state.user.details.timezone.value,
        projectId: this.$route.params.projectId,
        projectProcessStepId: this.$route.params.processStepId,
        processStepId: this.$route.query.processStepId,
        processStepEvents: []
      }
    },
    async created() {
      await this.getProcessStepEvents()
    },
    computed: {},
    methods: {
      getProcessStepEvents: async function () {
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
    }
  }
</script>

<style lang="scss">

</style>
<style lang="scss" scoped>
.events-container {

}
</style>
