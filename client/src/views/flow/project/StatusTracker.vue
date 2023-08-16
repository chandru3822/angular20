<template>
  <v-row no-gutters id="project-status-tracker-container" class="py-0 relative height-one-hunned overflow-y-auto">
    <v-col cols="12" lg="12" class="pa-3">
      <div v-if="fieldsLoading" class="section-spinner">
        <SpinnerInline :size="50" :spinner-color="`primary`" :transparent="true" :centered="true"/>
      </div>
      <div v-else>
        Status: {{currentStatus.projectStatusType}}
        <div v-for="milestone in statusFields" class="mb-3">
          <div class="flex-display flex-align-items-center">
            <v-avatar :tile="false"
                      :size="35"
                      color="grey lighten-4"
                      class="account-img"
            >
              <img v-if="milestone.icon && milestone.icon.presignedUrl"
                   class="status-icon-grid" :src="milestone.icon.presignedUrl">
  <!--            todo: get a placeholder image here-->
              <img name="accountImg" v-else src="../../../assets/flow/user_img_placeholder.png">
            </v-avatar>
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
            <div>
              <v-checkbox
                          :label="field.fieldName"
                          color="green"
                          :ripple="false"
                          readonly
                          hide-details
                          v-model="field.fieldValue"
                          class="default-text-color d-inline-block"
              />
              <div v-if="field.fieldValue != null" class="d-inline-block ml-3">
    <!--        i dont think we have to handle ALL data types here. just the common ones, data view fields are pretty normalized -->
                <span v-if="field.dataTypeId === 1">{{field.fieldValue | formatDate('date', 'D MMM YYYY')}}</span>
                <span v-else-if="field.dataTypeId === 2">{{field.fieldValue | formatDate('timestamp', 'D MMM YYYY H:mm a')}}</span>
                <span v-else>{{field.fieldValue}}</span>
              </div>
            </div>
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
import {AppMutations} from "@/stores/AppStore";

export default {
  name: 'StatusTracker',
  components: {
    SpinnerInline
  },
  data() {
    return {
      constants,
      currentStatus: {},
      projectId: parseInt(this.$route.params.projectId),
      statusFields: [],
      fieldsLoading: true
    }
  },
  created() {
    this.getCurrentStatus()
    this.getStatusFields()
  },
  computed: {},
  methods: {
    async getCurrentStatus() {
      this.fieldsLoading = true
      try {
        const {data, status} = await getRequest(`/project/${this.projectId}/status`)
        this.currentStatus = data
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Current Project Status')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getStatusFields() {
      this.fieldsLoading = true
      try {
        const {data, status} = await getRequest(`/project/${this.projectId}/statusFields`)
        this.statusFields = data
        this.fieldsLoading = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Status Tracker Details')
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
