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
              @click="[selectedEvent = item, getEventCfgs(item), getEventDetails(item)]">
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
          <div>
            <v-autocomplete
              v-model="selectedEvent.companyEventStatusTypeId"
              :items="companyEventStatuses"
              label="Event Status"
              item-text="eventStatusType"
              item-value="id"
            ></v-autocomplete>
          </div>
          <v-spacer></v-spacer>
          <v-toolbar-items>

            <v-btn text class="pl-1 pr-2 mb-2" @click="[selectedEvent = {}, eventDetails = {}]">
              <v-icon>close</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <div class="error-text" v-if="eventActionMissingRequirements">
          The following fields are required to perform the selected action.
        </div>
        <v-form ref="eventFieldForm">
          <DatetimePickerInput
            v-model="eventDetails.startTime"
            :timezone="this.timezone"
            :type="'timestamp'"
            :format="'MMMM DD, YYYY, h:mm A'"
            label="Start Time"
          />
          <DatetimePickerInput
            v-model="eventDetails.endTime"
            :timezone="this.timezone"
            :type="'timestamp'"
            :format="'MMMM DD, YYYY, h:mm A'"
            label="End Time"
          />
          <v-autocomplete
            v-model="eventDetails.resourceId"
            :items="eventDetails.availableResources"
            label="Resource"
            item-text="name"
            item-value="id"
          ></v-autocomplete>

          <v-col
            v-if="selectedEvent && selectedEvent.id"
            class="pt-0"
            v-for="(cfg, index) in selectedEvent.customFieldGroups"
            :key="cfg.id"
          >
            <v-toolbar color="transparent" class="elevation-0 cfg-name-toolbar">
              <v-toolbar-title>
  <!--              <v-btn small text v-if="cfg.eventId && $store.getters.userHasFeature('SCHEDULE')"-->
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
              <CustomValueInput
                v-for="(field, idx) in cfg.customFieldValues"
                :key="idx"
                :required="field.required"
                :callback="populateDirtyCfvs"
                :readonly="getReadOnly(field)"
                :field="field"
              />
            </v-card>
          </v-col>
        </v-form>
        <v-btn class="white--text mr-2 mb-2 save-btn"
               @click="[saveEventDetails(), updateFieldGroups(), eventActionMissingRequirements = false]"
               color="primaryButton"
        >Save Event</v-btn>
        <v-btn class="white--text save-btn mb-2 mr-2"
               color="primaryButton"
               @click="[attemptedAction = action, validateActionRequirements(action)]"
                v-for="(action, i) in eventDetails.eventActions"
                :key="i">
          {{action.actionName}}
        </v-btn>
        {{reqFieldsTemp}}
        <v-row>
          <Attachments :project-process-step-event-id="selectedEvent.id" :event-id="selectedEvent.eventId" :project-process-step-id="projectProcessStepId" />
        </v-row>
      </div>
    </v-card>
  </v-main>
</template>

<script>

  import {getRequest, logError, getSnackbar, getRequestWithParams, putRequest, postRequest} from '@/helpers/helpers'
  import {AppMutations} from '@/stores/AppStore'
  import {getCompanyEventStatusTypes} from '@/services/eventStatusTypeService'
  import {getCustomFieldReadOnly} from "@/services/customFieldService";
  import CustomValueInput from '@/views/flow/components/CustomValueInput'
  import Attachments from '@/views/flow/components/Attachments'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'

  export default {
    name: 'ProjectProcessStepEvents',
    components: {
      CustomValueInput,
      Attachments,
      DatetimePickerInput
    },
    props: {
      projectProcessStepEvents: Array,
    },
    data() {
      return {
        snackbar: {},
        selectedEvent: {},
        attemptedAction: {},
        reqFieldsTemp: [],
        companyEventStatuses: [],
        eventActionMissingRequirements: false,
        eventDetails: {},
        dirtyCfvs: [],
        timezone: this.$store.state.user.details.timezone.value,
        projectId: this.$route.params.projectId,
        userIsAdmin: this.$store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'ADMIN'),
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'EDIT'),
        projectProcessStepId: parseInt(this.$route.params.processStepId),
        processStepId: this.$route.query.processStepId,
        processStepEvents: [],
        headers: [
          { text: 'Event', value: 'eventName', show: true },
          { text: 'Status', value: 'eventStatusType', show: true },
        ],
        doTest: false
      }
    },
    async created() {
      this.getCompanyEventStatusTypes()
      await this.getProcessStepEvents()
    },
    // watch: {
    //   doTest: function () {
    //     this.$nextTick(() => {
    //       console.log('WHY TF', this.$refs.eventFieldForm.validate())
    //       this.eventActionMissingRequirements = this.$refs.eventFieldForm.validate()
    //     })
    //   }
    // },
    computed: {},
    methods: {
      // getFieldRequired(field) {
      //   console.log('attempt',this.attemptedAction)
      //   if(this.attemptedAction?.id && this.attemptedAction?.reqFields?.length > 0) {
      //     console.log('randaLogger', field)
      //     return true
      //   }
      //   return false
      // },
      validateActionRequirements: async function (action) {
        // this.reqFieldsTemp = action.requiredFields
        // if(action?.requiredFields?.length > 0) {
        //   let test = false
        //   this.selectedEvent?.customFieldGroups?.forEach(cfg => {
        //     cfg?.customFieldValues?.forEach(cf => {
        //       let match = action?.requiredFields?.find(rf => rf.customFieldGroupAssignmentId === cf.customFieldGroupAssignmentId)
        //       if(match) {
        //         cf.required = true
        //         test = true
        //       }
        //     })
        //   })
        // } else {
        //   this.eventActionMissingRequirements = false
        //   console.log('WE WOULD DO THE ACITON')
        // }
        this.doEventAction(action)
      },
      async getCompanyEventStatusTypes () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getCompanyEventStatusTypes()
          this.companyEventStatuses = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      doEventAction: async function (action) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await postRequest(`/projectProcessStep/${this.projectProcessStepId}/event/${this.selectedEvent.id}/action/perform`, action)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Performing Event')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      addEvent: async function (pse) {
        try {
          const {data} = await postRequest(`/projectProcessStep/${this.projectProcessStepId}/event`, pse)
          this.selectedEvent = data
          this.projectProcessStepEvents.push(data)
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
          this.selectedEvent.customFieldGroups = data
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Details')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      getEventDetails: async function (ppsEvent) {
        try {
          const {data} = await getRequest(`/projectProcessStep/${this.projectProcessStepId}/event/${ppsEvent.id}`)
          this.eventDetails = data
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Details')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveEventDetails() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await postRequest(`/projectProcessStep/${this.projectProcessStepId}/event/${this.eventDetails.id}`, this.eventDetails)
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Default Fields')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } finally {
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async updateFieldGroups() {
        if(this.dirtyCfvs?.length > 0) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          // this.processStep.customFieldGroups = this.customFieldGroups
          try {
            // const {data} = await putRequest(`/projectProcessStep`, this.processStep)
            // save dirty custom field values
            this.$refs.eventFieldForm.resetValidation()
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
