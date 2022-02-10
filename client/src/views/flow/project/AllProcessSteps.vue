<template>
  <v-row no-gutters id="project-details-container" class="py-0 relative height-one-hunned overflow-y-auto">
    <v-col cols="12" lg="12" class="text-left pt-0">
      <v-col class="py-0" v-if="$store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'VIEW')">
        <v-row>
          <v-toolbar color="transparent" class="elevation-0">
            <v-toolbar-title class="albatross-header-3">Active Process Steps</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
              <AddProcessStep
                v-if="project.processId && $store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'ADD')"
                class="d-inline-block"
                :project-id="projectId"
                :process-id="project.processId"
                @step-added="getProcessSteps"
              />
            </v-toolbar-items>
          </v-toolbar>

          <v-col cols="12" v-if="isProcessStepsLoading">
            <SpinnerInline :size="20" color="primaryCustom"/>
          </v-col>

          <v-col cols="12" v-else class="pt-0">
            <TableActiveProjectProcessStepSnippet
              :steps="processSteps.filter(step => step.processStepStatusTypeId === 1)"
              :projectId="projectId"
              :contactId="project.contactId"/>
          </v-col>
        </v-row>
      </v-col>


      <v-fade-transition v-if="$store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'VIEW')">
        <v-col
          v-show="!isProcessStepsExpanded"
          cols="12"
          class="text-right pt-0"
        >
        <span @click="isProcessStepsExpanded = true" class="clickable">
          Expand All Process Steps <v-icon>mdi-menu-down</v-icon>
        </span>
        </v-col>
      </v-fade-transition>

      <v-expand-transition>
        <v-col v-show="isProcessStepsExpanded">
          <v-row>
            <v-col cols="12">
              <v-row class="justify-space-around align-center">
                <v-col class="text-left pb-0">
                  <h3>All Process Steps</h3>
                </v-col>
                <v-col class="text-right pb-0">
              <span @click="isProcessStepsExpanded = false" class="clickable">
                Collapse All Process Steps <v-icon>mdi-menu-down</v-icon>
              </span>
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
                <h4 class="text-left work-type-header">{{step.processStepName}}</h4>
                <ProjectProcessStepSnippet
                  :key="step.processStepName"
                  :steps="step.processSteps"
                  :projectId="projectId"
                  :contactId="project.contactId"/>
              </template>
            </v-col>

          </v-row>
        </v-col>
      </v-expand-transition>
    </v-col>

  </v-row>
</template>

<script>

import {getRequest, logError} from '@/helpers/helpers'
import TableActiveProjectProcessStepSnippet from '@/views/flow/project/TableActiveProjectProcessStepSnippet'
import ProjectProcessStepSnippet from '@/views/flow/project/ProjectProcessStepSnippet'
import SpinnerInline from '@/components/SpinnerInline'

import AddProcessStep from '@/views/flow/components/AddProcessStep'

export default {
  name: 'ActiveProcessSteps',
  components: {
    SpinnerInline,
    TableActiveProjectProcessStepSnippet,
    ProjectProcessStepSnippet,
    AddProcessStep,
  },
  props: {
    project: Object
  },
  data () {
    return {
      projectId: parseInt(this.$route.params.projectId),
      processSteps: [],
      customFieldGroups: [],
      menuOpen: false,
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('PROJECTS', 'EDIT'),
      userHasEventsFeature: this.$store.getters.userHasFeature('EVENTS'),
      isProcessStepsLoading: false,
      snackbar: {},
      stepsSearch: '',
      isProcessStepsExpanded: true,
      companyId: this.$store.state.user.details.companyId,
    }
  },
  created () {
    this.getProcessSteps()
  },
  computed: {
    processStepsByName () {
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
    filteredProcessSteps () {
      return this.stepsSearch === '' ? this.processStepsByName : this.processStepsByName.filter(psn => psn.processStepName.toLowerCase().includes(this.stepsSearch.toLowerCase()) )
    },
    getProcessSteps: async function () {
      try {
        this.isProcessStepsLoading = true
        const {data} = await getRequest(`/project/${this.projectId}/processSteps`)
        this.processSteps = data
        window.document.title = `${this.project.projectName} - Process Steps`
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
