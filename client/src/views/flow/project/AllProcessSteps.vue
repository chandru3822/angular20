<template>
  <v-row id="project-details-container" class="mt-2">
    <v-col cols="12" lg="12" class="text-left pt-0">
      <v-row>
        <v-col cols="12">
          <v-row class="justify-space-around align-center">
            <v-col class="text-left pb-0">
              <h3>All Process Steps</h3>
            </v-col>
          </v-row>
          <v-row>
            <v-col cols="12" class="pt-0">
              <v-divider/>
            </v-col>
          </v-row>
        </v-col>

        <v-col cols="12" v-if="isProcessStepsLoading">
          <SpinnerInline :size="20" color="primaryCustom"/>
        </v-col>

        <v-col cols="12" class="pt-0" v-else>
          <v-text-field placeholder="Filter..."
                        hide-details
                        outlined
                        type="search"
                        class=""
                        v-model="stepsSearch"></v-text-field>

          <template v-for="step in filteredProcessSteps()">
            <h4 class="text-left work-type-header">{{ step.processStepName }}</h4>
            <ProjectProcessStepSnippet
              :key="step.processStepName"
              :steps="step.processSteps"
              :projectId="projectId"
              :contactId="project.contactId"/>
          </template>
        </v-col>

      </v-row>
    </v-col>

  </v-row>
</template>

<script>

import {getRequest, logError} from '@/helpers/helpers'
import SpinnerInline from '@/components/SpinnerInline'
import ProjectProcessStepSnippet from '@/views/flow/project/ProjectProcessStepSnippet'

export default {
  name: 'AllProcessSteps',
  components: {
    SpinnerInline,
    ProjectProcessStepSnippet
  },
  props: {
    project: Object
  },
  data() {
    return {
      projectId: parseInt(this.$route.params.projectId),
      isProcessStepsLoading: true,
      stepsSearch: '',
      processSteps: [],
    }
  },
  created() {
    this.getProcessSteps()
  },
  computed: {
    processStepsByName() {
      const names = [...new Set(this.processSteps.map(step => step.processStepName))]

      return names.map(processStepName => {
        return {
          processStepName,
          processSteps: this.processSteps.filter(step => step.processStepName === processStepName)
        }
      })
    }
  },
  methods: {
    filteredProcessSteps() {
      return this.stepsSearch === '' ? this.processStepsByName : this.processStepsByName.filter(psn => psn.processStepName.toLowerCase().includes(this.stepsSearch.toLowerCase()))
    },
    getProcessSteps: async function () {
      try {
        this.isProcessStepsLoading = true
        const {data} = await getRequest(`/project/${this.projectId}/processSteps`)
        this.processSteps = data
      } catch (e) {
        logError(e)
      } finally {
        this.isProcessStepsLoading = false
      }
    },
  }
}
</script>

<style lang="scss" scoped>
</style>

<style lang="scss">
.process-step-toolbar .v-toolbar__content {
  padding-left: 10px !important;
}

.manage-btn {

  margin-left: 12px;

  & > .v-btn__content {
    color: white !important;
  }
}
</style>
