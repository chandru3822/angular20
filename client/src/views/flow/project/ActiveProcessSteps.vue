<template>
  <SidePanelExpansionPanel v-if="userStore.userHasFeatureAccessLevel('PROCESS_STEPS', 'VIEW')"
                           header="Active Process Steps"
                           :section-expanded="sectionExpanded"
                           :is-loading="isProcessStepsLoading"
                           @click="toggleCollapseExpand"
  >
    <template v-slot:tool-btn>
      <v-btn text small color="primary" class="pa-2 mx-2" @click.stop :to="`/project/${projectId}/processSteps`"><v-icon :size="20">mdi-format-list-bulleted</v-icon></v-btn>
    </template>
    <template v-slot:expanded-content>
      <ActiveProjectProcessStepSnippet class="px-3"
                                       :steps="processSteps"
                                       :projectId="projectId"
                                       :contactId="project.contactId"/>
      <v-row
          v-if="userStore.userHasFeatureAccessLevel('PROCESS_STEPS', 'VIEW')"
          class="text-left pt-0 px-0"
      >
        <v-col class="px-3 py-0">
          <AddProcessStep
              title="Add Process Step"
              v-if="project.processId && userStore.userHasFeatureAccessLevel('PROCESS_STEPS', 'ADD') && !hideAddBtn"
              class="d-inline-block"
              :admin="userStore.isSystemAdmin"
              :project-id="projectId"
              :process-id="project.processId"
              :contact-id="project.contactId"
              @step-added="getProcessSteps"
              :outlined="true"
          />
        </v-col>
      </v-row>
    </template>
  </SidePanelExpansionPanel>
</template>

<script>
import {getRequest, logError} from '@/helpers/helpers'
import ActiveProjectProcessStepSnippet from '@/views/flow/project/ActiveProjectProcessStepSnippet'
import ProjectProcessStepSnippet from '@/views/flow/project/ProjectProcessStepSnippet'
import SpinnerInline from '@/components/SpinnerInline'
import AddProcessStep from '@/views/flow/components/AddProcessStep'
import SidePanelExpansionPanel from '@/components/SidePanelExpansionPanel.vue'
import { useUserStore } from '@/stores/UserStorePinia.js'
import { mapStores } from 'pinia'
import { useProjectStore } from '@/stores/ProjectStorePinia.js'

export default {
  name: 'ActiveProcessSteps',
  components: {
    SidePanelExpansionPanel,
    SpinnerInline,
    ActiveProjectProcessStepSnippet,
    ProjectProcessStepSnippet,
    AddProcessStep,
  },
  props: {
    project: Object,
    updateKey: Number,
    hideAddBtn: {
      type: Boolean,
      default: false
    }
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
      customFieldGroups: [],
      menuOpen: false,
      isProcessStepsLoading: false,
      snackbar: {},
      stepsSearch: '',
      isProcessStepsExpanded: false,
    }
  },
  created() {
    this.getProcessSteps()
  },
  computed: {
    ...mapStores(useUserStore, useProjectStore),
    sectionExpanded() {
      return this.projectStore.activePpsDropdown
    },
    userCanEdit() {
      return this.userStore.userHasFeatureAccessLevel('PROJECTS', 'EDIT')
    },
    userHasEventsFeature() {
      return this.userStore.userHasFeature('EVENTS')
    },
    companyId() {
      return this.userStore.details.companyId
    },
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
    toggleCollapseExpand(){
      this.projectStore.activePpsDropdown = !this.projectStore.activePpsDropdown
    }
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
