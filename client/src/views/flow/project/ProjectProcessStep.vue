<template>
<v-row>
  <v-col class="text-left">
    <router-link :to="`/project/${projectId}`">Back</router-link>
  </v-col>

  <v-col cols="12" class="text-left">
    <h3>{{ processStep.name }}</h3>
  </v-col>

  <v-col cols="12" lg="6" class="text-left">

    <v-col v-if="isProjectFieldsLoading" class="text-center">
      <SpinnerInline :size="20" color="primary"/>
    </v-col>

<!--    project field groups -->
    <v-col
      v-else
      class="mt-4"
      v-for="(group, index) in projectFieldGroups"
      :key="index"
    >
      <v-toolbar color="transparent" class="elevation-0">
        <v-toolbar-title>{{group.groupName}}</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-btn
            v-if="index === 0"
            text
            @click="updateProjectFieldGroups">Save Project Fields</v-btn>
        </v-toolbar-items>
      </v-toolbar>
      <v-card class="pa-4 text-left">
        <CustomValueInput
          v-for="(field, idx) in group.customFieldValues"
          :key="idx"
          :readonly="field.ancillaryCustomFieldGroupAssignmentId !== null"
          :showFieldName="false"
          :field="field"
        />
      </v-card>
    </v-col>

<!--    process field groups -->
    <v-col
      class="mt-4"
      v-for="(cfg, index) in customFieldGroups"
      :key="index"
    >
      <v-toolbar color="transparent" class="elevation-0">
        <v-toolbar-title>{{cfg.groupName}}</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-btn
            v-if="index === 0"
            text
            @click="updateFieldGroups"
          >Save Process Fields</v-btn>
        </v-toolbar-items>
      </v-toolbar>
      <v-card class="pa-4">
        <CustomValueInput
          v-for="(cf, idx) in cfg.customFieldValues"
          :key="idx"
          :readonly="false"
          :field="cf"
        />
      </v-card>
    </v-col>

    <v-toolbar color="transparent" class="elevation-0">
      <v-toolbar-title>Actions</v-toolbar-title>
    </v-toolbar>
    <v-col v-for="action in processStep.actions" :key="action.id">
      <ActionButton
        v-if="action.actionTypeId === 2"
        :actionId="action.id"
        :projectProcessStepId="projectProcessStepId"
        :label="action.actionName"
        :handleOnComplete="handleActionCompleted"
        :handleOnCompleteError="handleOnCompleteError"
      />
    </v-col>

    <!-- todo: @humes just putting this here so i can test scheduling.  feel free to do what you want with it. i dont even know if this is the right spot -->
    <!-- @TODO: @randa, Uncommenting for now until I can add it in programatically. How do we not hardcode the processStepid and projectId vals? (they harcoded for testing?)   -->
<!--    <v-row>-->
<!--      <v-col cols="12">-->

<!--        <h3>Links</h3>-->

<!--        <v-btn :to="{name: 'schedule', query: { processStepId: 1, projectId: 171704 } }">-->
<!--          Test link to schedule screen-->
<!--        </v-btn>-->
<!--      </v-col>-->
<!--    </v-row>-->

    <v-row>
      <Attachments :projectProcessStepId="parseInt(projectProcessStepId)" :processStepId="parseInt(processStepId)"/>
    </v-row>
  </v-col>

  <v-col cols="12" lg="6" class="text-left">
    <NotesAndActivity
      :showNotes="true"
      :showActivity="false"
      :notes="notes"
      :primaryId="parseInt(projectProcessStepId)"
      type="ProjectProcessStep"
    />
  </v-col>

  <Snackbar :snackbar="snackbar"></Snackbar>
</v-row>
</template>

<script>

import {getRequest, logError, getSnackbar, getRequestWithParams, putRequest, postRequest} from '@/helpers/helpers'
import ActionButton from './ActionButton'
import {AppMutations} from '@/stores/AppStore'
import Snackbar from '@/components/Snackbar.vue'
import Attachments from '@/views/flow/components/Attachments'
import NotesAndActivity from '@/views/flow/components/NotesAndActivity'
import CustomValueInput from '@/views/flow/components/CustomValueInput'
import SpinnerInline from '@/components/SpinnerInline'

export default {
  name: 'ProjectProcessStep',
  components: {
    ActionButton,
    Snackbar,
    Attachments,
    NotesAndActivity,
    CustomValueInput,
    SpinnerInline
  },
  data () {
    return {
      snackbar: {},
      projectId: this.$route.params.projectId,
      projectProcessStepId: this.$route.params.processStepId,
      processStepId: this.$route.query.processStepId,
      processStep: {},
      projectFieldGroups: [],
      customFieldGroups: [],
      isProcessStepLoading: true,
      isProjectFieldsLoading: false,
      notes: []
    }
  },
  created () {
    this.getProcessStep()
    this.getProjectFieldGroups()
    this.getCustomFieldGroups()
    this.getNotes()
  },
  methods: {
    getProcessStep: async function() {
      try {
        const {data} = await getRequest(`/projectProcessStep/${this.projectProcessStepId}`)
        this.processStep = data
      } catch (e) {
        logError(e)
      } finally {
        this.isProcessStepLoading = false
      }
    },
    async getProjectFieldGroups() {
      try {
        this.isProjectFieldsLoading = true
        const {data} = await getRequest(`/customFieldValues/project/${this.projectId}`)
        this.projectFieldGroups = data
      } catch (e) {
        logError(e)
      } finally {
        this.isProjectFieldsLoading = false
      }
    },
    async getCustomFieldGroups() {
      //@TODO: @humes, make this use local loading so entire screen isn't blocked waiting
      //this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequestWithParams(`/customFieldValues/project/${this.projectId}/processStep`, { params: {
            projectProcessStepId: this.projectProcessStepId
          }})
        this.customFieldGroups = data
        // this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Custom Fields')
        // this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getNotes() {
      try {
        const {data} = await getRequestWithParams(`/note/getProjectProcessStepNotes`, {
          params: {
            primaryId: this.projectProcessStepId
          }
        })
        this.notes = data
      } catch {
        console.log('suck')

      }
    },
    async updateProjectFieldGroups() {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data} = await postRequest(`/customFieldValues/project/${this.projectId}`, this.customFieldGroups)
        this.customFieldGroups = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Update Project Fields')
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async updateFieldGroups() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      this.processStep.customFieldGroups = this.customFieldGroups
      try {
        await putRequest(`/projectProcessStep`, this.processStep)
        this.$store.commit(AppMutations.SET_LOADING, false)
        this.$root.$emit('projectProcessStep:checkAction')
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Custom Fields')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    handleActionCompleted () {
      this.$router.push({
        name: 'project',
        params: {
          projectId: this.projectId
        }
      })
    },
    handleOnCompleteError (actionId) {
      logError(`Failed to complete action with actionId: ${actionId}`)
      this.snackbar = getSnackbar('ERROR', 'Unable to Complete Action')
    }
  }
}
</script>

<style lang="scss" scoped>

</style>
