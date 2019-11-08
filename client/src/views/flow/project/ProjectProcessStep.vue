<template>
<v-row>
  <v-col class="text-left">
    <router-link :to="`/project/${projectId}`">Back</router-link>
    <h3></h3>
  </v-col>

  <v-col cols="12" class="text-left">
    <h1>{{ processStep.name }}</h1>
  </v-col>

  <v-col cols="12" lg="6" xl="6" class="text-left">
    <h3>Actions</h3>

    <v-row>
      <v-col v-for="action in processStep.actions" :key="action.id">
        <ActionButton
          v-if="action.actionTypeId === 2"
          :actionId="action.id"
          :projectProcessStep="stepId"
          :label="action.actionName"
        />
      </v-col>
    </v-row>

    <!-- todo: @humes just putting this here so i can test scheduling.  feel free to do what you want with it. i dont even know if this is the right spot -->
    <v-row>
      <v-btn text @click="randaSaveCustomFields">Save</v-btn>
      <div class="mt-4" v-for="(cfg, index) in customFieldGroups" :key="index">
        <v-toolbar color="transparent" class="elevation-0">
          <v-toolbar-title>{{cfg.groupName}}</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <!--              <v-btn text @click="saveUser">Save</v-btn>-->
          </v-toolbar-items>
        </v-toolbar>
        <v-card class="pa-4">
          <CustomValueInput v-for="(cf, index) in cfg.customFieldValues" :key="index" :readonly="false" :field="cf"></CustomValueInput>
        </v-card>
      </div>
    </v-row>
  </v-col>
  <Snackbar :snackbar="snackbar"></Snackbar>
</v-row>
</template>

<script>

import {getRequest, logError, getSnackbar, getRequestWithParams, putRequest} from '@/helpers/helpers'
import ActionButton from './ActionButton'
import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
import {AppMutations} from '@/stores/AppStore'
import Snackbar from '@/components/Snackbar.vue'

export default {
  name: 'ProjectProcessStep',
  components: {
    ActionButton,
    Snackbar,
    CustomValueInput
  },
  data () {
    return {
      snackbar: {},
      projectId: this.$route.params.projectId,
      stepId: this.$route.params.processStepId,
      processStep: {},
      customFieldGroups: [],
      isProcessStepLoading: true
    }
  },
  created () {
    this.getProcessStep()
    this.getCustomFieldGroups()
  },
  methods: {
    getProcessStep: async function() {
      try {
        const {data} = await getRequest(`/projectProcessStep/${this.stepId}`)
        this.processStep = data
      } catch (e) {
        logError(e)
      } finally {
        this.isProcessStepLoading = false
      }
    },
    async getCustomFieldGroups() {
      // @humes - maybe you have this data on the process step. i didnt even look
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequestWithParams(`/customFieldValues/project/${this.projectId}/processStep`, { params: {
            projectProcessStepId: this.stepId
          }})
        this.customFieldGroups = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Custom Fields')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async randaSaveCustomFields() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      this.processStep.customFieldGroups = this.customFieldGroups
      try {
        await putRequest(`/projectProcessStep`, this.processStep)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Custom Fields')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
  }
}
</script>

<style lang="scss" scoped>

</style>
