<template>
  <v-row id="project-details-container" class="mx-6">
    <v-col cols="12" lg="12" class="text-left py-0 px-0">
      <v-expansion-panels flat class="py-0" v-if="$store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'VIEW')">
        <v-expansion-panel>
          <v-expansion-panel-header color="transparent" flat class="px-0 project-section-header" height="auto">
            <div class="label-large">Active Process Steps</div>
            <v-spacer></v-spacer>
              <AddProcessStep
                v-if="project.processId && $store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'ADD')"
                class="d-inline-block"
                :admin="$store.getters.isFullAdmin"
                :project-id="projectId"
                :process-id="project.processId"
                :contact-id="project.contactId"
                @step-added="getProcessSteps"
              />
          </v-expansion-panel-header>

          <v-expansion-panel-content cols="12" class="py-0">
            <SpinnerInline v-if="isProcessStepsLoading" :size="20" color="primary"/>
            <ActiveProjectProcessStepSnippet v-else class="px-4"
              :steps="processSteps"
              :projectId="projectId"
              :contactId="project.contactId"/>
            <v-col
                v-if="$store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'VIEW')"
                cols="12"
                class="text-left pt-0"
            >
              <router-link class="albatross-body-3" :to="`/project/${projectId}/processSteps`">View All</router-link>
            </v-col>
          </v-expansion-panel-content>
        </v-expansion-panel>
      </v-expansion-panels>
    </v-col>
  </v-row>
</template>

<script>

import {getRequest, logError} from '@/helpers/helpers'
import ActiveProjectProcessStepSnippet from '@/views/flow/project/ActiveProjectProcessStepSnippet'
import ProjectProcessStepSnippet from '@/views/flow/project/ProjectProcessStepSnippet'
import SpinnerInline from '@/components/SpinnerInline'

import AddProcessStep from '@/views/flow/components/AddProcessStep'

export default {
  name: 'ActiveProcessSteps',
  components: {
    SpinnerInline,
    ActiveProjectProcessStepSnippet,
    ProjectProcessStepSnippet,
    AddProcessStep,
  },
  props: {
    project: Object,
    updateKey: Number
  },
  watch: {
    updateKey: function () {
      this.getProcessSteps()
    },
  },
  data() {
    return {
      projectId: parseInt(this.$route.params.projectId),
      processSteps: [],
      sectionExpanded: this.$route.path.includes('processStep'),
      customFieldGroups: [],
      menuOpen: false,
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('PROJECTS', 'EDIT'),
      userHasEventsFeature: this.$store.getters.userHasFeature('EVENTS'),
      isProcessStepsLoading: false,
      snackbar: {},
      stepsSearch: '',
      isProcessStepsExpanded: false,
      companyId: this.$store.state.user.details.companyId,
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
        const {data} = await getRequest(`/project/${this.projectId}/upcomingProcessSteps`)
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
#project-details-container {
  margin-top: -15px;
  padding-left: 0;
  padding-right: 0;
  padding-top: 0;
}

.project-header {
  border-bottom: solid 1px #EAEAF4
}

.project-title {
  font-size: 20px;
}

.project-subtitle {
  font-size: 15px;
}

.work-type-header {
  &:not(:first-child) {
    padding-top: 20px;
  }
}
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
