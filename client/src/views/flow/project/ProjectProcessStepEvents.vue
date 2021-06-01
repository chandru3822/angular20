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
        <br/>
        {{userIsAdmin}}
        <br/>
        <v-col
          v-if="selectedEvent && selectedEvent.id"
          class="pt-0"
          v-for="(cfg, index) in ppsEventCfgs"
          :key="index"
        >
          <v-toolbar color="transparent" class="elevation-0 cfg-name-toolbar">
            <v-toolbar-title>
<!--              <v-btn small text v-if="cfg.eventTypeId && $store.getters.userHasFeature('SCHEDULE')"-->
<!--                     :to="`/schedule?projectProcessStepId=${projectProcessStepId}`">-->
<!--                <v-icon>mdi-calendar</v-icon>-->
<!--              </v-btn>-->
              {{cfg.groupName}}
            </v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
            </v-toolbar-items>
          </v-toolbar>
          <v-card flat class="pa-3">
            {{cfg.customFieldValues[0]}}
            <CustomValueInput
              v-for="(field, idx) in cfg.customFieldValues"
              :key="idx"
              :callback="populateDirtyCfvs"
              :readonly="getReadOnly(field)"
              :field="field"
            />
          </v-card>
          <v-btn class="white--text mr-0 save-btn"
                 @click="updateFieldGroups"
                 color="primaryButton"
          >Save Event</v-btn>
        </v-col>
      </div>
    </v-card>
  </v-main>
</template>

<script>

  import {getRequest, logError, getSnackbar, getRequestWithParams, putRequest, postRequest} from '@/helpers/helpers'
  import {AppMutations} from '@/stores/AppStore'
  import {getCustomFieldReadOnly} from "@/services/customFieldService";
  import CustomValueInput from '@/views/flow/components/CustomValueInput'

  export default {
    name: 'ProjectProcessStepEvents',
    components: {
      CustomValueInput
    },
    props: {
      projectProcessStepEvents: Array,
    },
    data() {
      return {
        snackbar: {},
        selectedEvent: {},
        dirtyCfvs: [],
        ppsEventCfgs: [],
        timezone: this.$store.state.user.details.timezone.value,
        projectId: this.$route.params.projectId,
        userIsAdmin: this.$store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'ADMIN'),
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'EDIT'),
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
      getReadOnly: function (field) {
        // if process_step admin then they can edit any process step fields, otherwise idk???
        return (!this.userIsAdmin)
          || getCustomFieldReadOnly(this.$store, field)
          || !this.userCanEdit
      },
      populateDirtyCfvs(field) {
        let match = this.dirtyCfvs.find(f => (null !== f.id && f.id === field.id) || f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId)
        if(!match) {
          this.dirtyCfvs.push(field)
        }
      },
      getEventCfgs: async function (ppsEvent) {
        try {
          const {data} = await getRequest(`/customFieldValues/event/${ppsEvent.id}`)
          this.ppsEventCfgs = data
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Details')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async updateFieldGroups() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        // this.processStep.customFieldGroups = this.customFieldGroups
        try {
          // const {data} = await putRequest(`/projectProcessStep`, this.processStep)
          // save dirty custom field values
          console.log('randaLogger', this.dirtyCfvs)
          const {data} = await postRequest(`/customFieldValues/event/${this.selectedEvent.id}`, this.dirtyCfvs)
          this.dirtyCfvs = []
          this.customFieldGroups = data
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Custom Fields')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } finally {
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
