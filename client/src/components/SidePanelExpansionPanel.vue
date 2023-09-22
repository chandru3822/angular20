<template>
  <v-row id="side-panel-expansion-panel-container" class="mx-6">
    <v-col cols="12" lg="12" class="text-left py-0 px-0">
      <v-expansion-panels flat class="py-0" :value="sectionExpanded ? 0 : null" v-if="$store.getters.userHasFeatureAccessLevel('PROCESS_STEPS', 'VIEW')">
        <v-expansion-panel>
          <v-expansion-panel-header color="transparent" flat class="px-0 project-section-header" height="auto">
            <div class="label-large">{{header}}</div>
            <v-spacer></v-spacer>
            <slot name="tool-btn"></slot>
          </v-expansion-panel-header>
          <v-expansion-panel-content cols="12" class="py-0 pb-4">
            <SpinnerInline v-if="isLoading" centered :size="20" color="primary"/>
            <slot name="expanded-content" class="px-0" v-else>Nothing to see here.</slot>
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
  name: 'SidePanelExpansionPanel',
  components: {
    SpinnerInline,
    ActiveProjectProcessStepSnippet,
    ProjectProcessStepSnippet,
    AddProcessStep,
  },
  props: {
    header: String,
    sectionExpanded: {
      type: Boolean,
      default: false
    },
    isLoading: Boolean,
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
      sectionExpanded: this.$route.path.includes('processStep') ? 0 : null,
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
#side-panel-expansion-panel-container div.v-expansion-panel-content__wrap{
  padding:0;
}
</style>

<style scoped lang="scss">

</style>
