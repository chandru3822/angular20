<template>
  <v-card class="px-6 pt-4 square-card">
    <v-card-title
      class="albatross-header-3 text-capitalize pa-0"
      primary-title>
      Assign Project to {{planName}}
      <v-spacer></v-spacer>

    </v-card-title>
    <v-card-text class="">
      <v-text-field text
                    label="Enter Project ID to Add"
                    placeholder=" "
                    v-model.number="projectId"></v-text-field>
    </v-card-text>
    <v-card-actions>
      <v-spacer></v-spacer>
      <v-btn
        class="elevation-0 text-capitalize"
        @click="$emit('cancel')"
      >
        Close
      </v-btn>
      <v-btn class="ml-2" :disabled="!projectId" @click="saveProjectToPlan()">Save</v-btn>
    </v-card-actions>
  </v-card>
</template>

<script>
import {
  getRequest,
  getRequestWithParams,
  getSnackbar,
  handleHidingGlobalLoader, logError, postRequest, postRequestWithRequestParams,
  putRequest
} from "@/helpers/helpers";
import {AppMutations} from "@/stores/AppStore";
import {Actions} from "@/store";
import constants from "@/helpers/constants";

export default {
  name: "ProjectAssignmentModal",
  props: {
    override: Boolean,
    planId: Number,
    planName: String
  },
  components: {},
  data() {
    return {
      projectId: null,
      dataSaving: false
    }
  },
  created() {
  },
  computed: {},
  methods: {
    async saveProjectToPlan () {
      this.dataSaving = true
      try {
        let url = this.override ? `/commissionManagement/overrides/plan/${this.planId}/assignToPlan` : `/commissionManagement/${this.planId}/assignToPlan`
        await postRequestWithRequestParams(url, null, {projectId: this.projectId}, 'blueraven')
        this.snackbar = getSnackbar('SUCCESS', 'Project Assigned')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.projectId = null
        this.dataSaving = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.dataSaving = false
        let msg = e?.data?.message || 'Error Assigning Project to Plan'
        this.snackbar = getSnackbar('ERROR', msg)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
  }
}
</script>

<style scoped>

</style>
