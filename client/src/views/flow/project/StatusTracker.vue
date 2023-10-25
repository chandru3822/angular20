<template>
  <v-row no-gutters id="project-status-tracker-container" class="py-0 relative height-one-hunned overflow-y-auto">
    <v-col cols="12" lg="12" class="pa-3">
<!--      <div v-if="fieldsLoading" class="section-spinner">-->
<!--        <SpinnerInline :size="50" :spinner-color="`primary`" :transparent="true" :centered="true"/>-->
<!--      </div>-->
      <div>

        <div class="headline-small stage-header">
          Current Stage:
          <span :class="{'cancelled-text': cancelled}">{{currentStatus.projectStatusType}}
          </span>
        </div>
        <div v-for="(milestone, idx) in milestones" class="mb-3 stage-section">
          <div class="flex-display flex-align-items-center">
            <StatusTrackerIcon :clickable="false"
                               :milestone="milestone"
                               :current-status-id="currentStatus.companyProjectStatusTypeId"
            ></StatusTrackerIcon>
            <span class="ml-2 label-large" :class="{'active-status': milestone.id === currentStatus.companyProjectStatusTypeId}">{{milestone.projectStatusType}}</span>

            <v-tooltip left>
              <template v-slot:activator="{ on, attrs }">
                <v-btn icon class="information-icon"  color='grey-base' v-bind="attrs"
                       v-on="on"><v-icon size="18">mdi-information</v-icon></v-btn>
              </template>
              <span>{{ milestone.description }}</span>
            </v-tooltip>
          </div>
<!--        <v-card class="px-3 mt-2 ml-10 pb-3" v-if="milestone.assignedFields?.length > 0">-->
          <div v-for="field in milestone.assignedFields">
            <v-card class="px-3 mt-2 ml-10 pb-3" v-if="milestone.assignedFields?.length > 0">
            <StatusTrackerItem :field="field" :cancelled="cancelled"
            ></StatusTrackerItem>
            </v-card>
          </div>
        </v-card>
        </div>
      </div>
    </v-col>
  </v-row>
</template>

<script>

import {getRequest, getSnackbar, handleHidingGlobalLoader, logError} from '@/helpers/helpers'
import constants from "@/helpers/constants";
import SpinnerInline from '@/components/SpinnerInline'
import StatusTrackerIcon from '@/views/flow/project/StatusTrackerIcon'
import StatusTrackerItem from '@/views/flow/project/StatusTrackerItem'
import {AppMutations} from "@/stores/AppStore";

export default {
  name: 'StatusTracker',
  components: {
    SpinnerInline,
    StatusTrackerIcon,
    StatusTrackerItem,
  },
  props: {
    milestones: [],
  },
  data() {
    return {
      constants,
      currentStatus: {},
      projectId: parseInt(this.$route.params.projectId),
      cancelled: false
    }
  },
  created() {
    this.getCurrentStatus()
  },
  computed: {},
  methods: {
    async getCurrentStatus() {
      try {
        const {data, status} = await getRequest(`/project/${this.projectId}/status`)
        this.currentStatus = data
        if(this.currentStatus.projectStatusType == 'Cancelled'){
          this.cancelled = true;
        }
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Current Project Status')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
  }
}
</script>

<style lang="scss" scoped>
.active-status {
  color: blue;
}

.cancelled-text{
  color: var(--v-error-base);
}

.information-icon{
  //color: var(--v-grey-base);
  color: blue;
  width: 50px;
}

.stage-header{
  padding-top: 24px;
  padding-bottom: 16px;
}

.stage-section{
  margin-bottom: 24px !important;
}

</style>

<style lang="scss">

</style>
