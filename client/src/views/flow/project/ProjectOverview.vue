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


        <v-col v-if="isProcessStepsLoading">
          <SpinnerInline :size="20" color="primary"/>
        </v-col>

        <v-col v-else>
          <ProjectActiveProcessStep :steps="processSteps" :projectId="projectId"/>
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
</v-row>
</template>

<script>

import {getRequest, logError, getRequestWithParams} from '@/helpers/helpers'
import ProjectFieldGroup from '@/views/flow/project/ProjectFieldGroup'
import ProjectActiveProcessStep from '@/views/flow/project/ProjectActiveProcessStep'
import SpinnerInline from '@/components/SpinnerInline'
import Attachments from '@/views/flow/components/Attachments'
import NotesAndActivity from '@/views/flow/components/NotesAndActivity'

export default {
  name: 'ProjectOverview',
  components: {
    SpinnerInline,
    ProjectFieldGroup,
    ProjectActiveProcessStep,
    Attachments,
    NotesAndActivity
  },
  data () {
    return {
      projectId: parseInt(this.$route.params.projectId),
      processSteps: [],
      customFieldGroups: [],
      isProcessStepsLoading: true,
      isFieldsLoading: true,
      notes: []
    }
  },
  created () {
    this.getFieldGroups()
    this.getProcessSteps()
    this.getNotes()
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
