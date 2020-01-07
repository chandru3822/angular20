<template>
<v-row>
  <v-col cols="12" lg="6">

    <v-col v-if="isFieldsLoading">
      <SpinnerInline :size="20" color="primary"/>
    </v-col>

    <v-col v-else v-for="group in customFieldGroups" :key="group.customFieldId">
      <ProjectFieldGroup :group="group"/>
    </v-col>

    <v-col>
      <v-row>
        <v-col cols="12">
          <h3 class="text-left">Active Process Steps</h3>
        </v-col>

        <v-col cols="12" v-if="isProcessStepsLoading">
          <SpinnerInline :size="20" color="primary"/>
        </v-col>

        <v-col cols="12" v-else>
          <ActiveProjectProcessStepSnippet :steps="processSteps.filter(step => step.processStepStatusTypeId === 1)" :projectId="projectId"/>
        </v-col>
      </v-row>
    </v-col>

    <v-col>
      <v-row>
        <v-col cols="12">
          <h3 class="text-left">All Process Steps</h3>
        </v-col>

        <v-col cols="12" v-if="isProcessStepsLoading">
          <SpinnerInline :size="20" color="primary"/>
        </v-col>

        <v-col cols="12" v-else>
          <template v-for="workType in processStepsByWorkType">
            <h4 class="text-left">{{workType.workType}}</h4>
            <ProjectProcessStepSnippet :steps="workType.processSteps" :projectId="projectId"/>
          </template>
        </v-col>

      </v-row>
    </v-col>

    <v-col>
      <v-row>
        <Attachments :projectId="projectId"/>
      </v-row>
    </v-col>
  </v-col>

  <v-col cols="12" lg="6" class="text-left">

    <NotesAndActivity
      :showNotes="true"
      :showActivity="false"
      :notes="notes"
      :primaryId="parseInt(projectId)"
      type="Project"
    />
  </v-col>

  <Snackbar :snackbar="snackbar"/>
</v-row>
</template>

<script>

import {getRequest, logError, getRequestWithParams, getSnackbar} from '@/helpers/helpers'
import ProjectFieldGroup from '@/views/flow/project/ProjectFieldGroup'
import ActiveProjectProcessStepSnippet from '@/views/flow/project/ActiveProjectProcessStepSnippet'
import ProjectProcessStepSnippet from '@/views/flow/project/ProjectProcessStepSnippet'
import SpinnerInline from '@/components/SpinnerInline'
import Attachments from '@/views/flow/components/Attachments'
import NotesAndActivity from '@/views/flow/components/NotesAndActivity'
import Snackbar from '@/components/Snackbar.vue'

export default {
  name: 'ProjectOverview',
  components: {
    SpinnerInline,
    ProjectFieldGroup,
    ActiveProjectProcessStepSnippet,
    ProjectProcessStepSnippet,
    Attachments,
    NotesAndActivity,
    Snackbar
  },
  data () {
    return {
      projectId: parseInt(this.$route.params.projectId),
      processSteps: [],
      customFieldGroups: [],
      isProcessStepsLoading: true,
      isFieldsLoading: true,
      notes: [],
      snackbar: {}
    }
  },
  created () {
    this.getFieldGroups()
    this.getProcessSteps()
    this.getNotes()
  },
  computed: {
    processStepsByWorkType () {
      const workTypes = [...new Set(this.processSteps.map(step => step.workType))]

      return workTypes.map(workType => {
        return {
          workType,
          processSteps: this.processSteps.filter(step => step.workType === workType)
        }
      })
    }
  },
  methods: {
    getProcessSteps: async function () {
      try {
       const {data} = await getRequest(`/project/${this.projectId}/processSteps`)
       this.processSteps = data
     } catch (e) {
       logError(e)
     } finally {
       this.isProcessStepsLoading = false
     }
    },
    getFieldGroups: async function () {
      try {
        const {data} = await getRequest(`/customFieldValues/project/${this.projectId}`)
        this.customFieldGroups = data
      } catch (e) {
        logError(e)
      } finally {
        this.isFieldsLoading = false
      }
    },
    getNotes: async function () {
      try {
        const {data} = await getRequestWithParams(`/note/getProjectNotes`, {
          params: {
            primaryId: this.projectId
          }
        })
        this.notes = data
      } catch {
        console.log('done gone boom')
      }
    }
  }
}
</script>

<style lang="scss" scoped>

</style>
