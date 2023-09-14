<template>
  <v-row no-gutters id="project-status-tracker-container" class="py-0 relative height-one-hunned overflow-y-auto">
    <v-col cols="12" lg="12" class="pa-3">
<!--      <div v-if="fieldsLoading" class="section-spinner">-->
<!--        <SpinnerInline :size="50" :spinner-color="`primary`" :transparent="true" :centered="true"/>-->
<!--      </div>-->
      <div>
        Status: {{currentStatus.projectStatusType}}
        <div v-for="(milestone, idx) in milestones" class="mb-3">
          <div class="flex-display flex-align-items-center">
            <StatusTrackerIcon :clickable="false"
                               :milestone="milestone"
                               :current-status-id="currentStatus.companyProjectStatusTypeId"
            ></StatusTrackerIcon>
            <span class="ml-2" :class="{'active-status': milestone.id === currentStatus.companyProjectStatusTypeId}">{{milestone.projectStatusType}}</span>
            <v-spacer></v-spacer>
            <v-tooltip left>
              <template v-slot:activator="{ on, attrs }">
                <v-btn icon color="primary" v-bind="attrs"
                       v-on="on"><v-icon>mdi-information</v-icon></v-btn>
              </template>
              <span>description: {{ milestone.description }} .....needs work</span>
            </v-tooltip>
          </div>
        <v-card class="px-3 mt-2 ml-10 pb-3" v-if="milestone.assignedFields?.length > 0">
          <div v-for="field in milestone.assignedFields">
            <StatusTrackerItem :field="field"
            ></StatusTrackerItem>
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

</style>

<style lang="scss">

</style>
