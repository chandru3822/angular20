<template>
  <SidePanelExpansionPanel v-if="userStore.userHasFeatureAccessLevel('PROCESS_STEPS', 'VIEW')"
                           header="Active Process Steps"
                           :section-expanded="sectionExpanded"
                           :is-loading="isProcessStepsLoading"
                           @click="toggleCollapseExpand"
  >
    <template v-slot:tool-btn>
      <a-btn
          variant="text"
          size="small"
          color="primary"
          class="pa-2 mx-2"
          @click.native.stop
          :to="`/project/${projectId}/processSteps`"
          prepend-icon="mdi-format-list-bulleted"
      ></a-btn>
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

<script setup>
import {getRequest, logError} from '@/helpers/helpers'
import ActiveProjectProcessStepSnippet from '@/views/flow/project/ActiveProjectProcessStepSnippet'
import ProjectProcessStepSnippet from '@/views/flow/project/ProjectProcessStepSnippet'
import SpinnerInline from '@/components/SpinnerInline'
import AddProcessStep from '@/views/flow/components/AddProcessStep'
import SidePanelExpansionPanel from '@/components/SidePanelExpansionPanel.vue'
import { useProjectStore } from '@/stores/ProjectStore.js'

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const projectStore = useProjectStore()
const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const props = defineProps({
  project: Object,
  updateKey: Number,
  hideAddBtn: {
    type: Boolean,
    default: false
  }
})
const { project, updateKey, hideAddBtn } = toRefs(props)

watch(updateKey, () => {
  getProcessSteps()
})

const projectId = computed(() => {
  return parseInt(route.params.projectId)
})
const processSteps = ref([])
const customFieldGroups = ref([])
const menuOpen = ref(false)
const isProcessStepsLoading = ref(false)
const stepsSearch = ref('')
const isProcessStepsExpanded = ref(false)

onMounted(() => {
  getProcessSteps()
})

const filteredProcessSteps = computed(() => {
  return stepsSearch.value === '' ? processStepsByName.value : processStepsByName.value.filter(psn => psn.processStepName.toLowerCase().includes(stepsSearch.value.toLowerCase()))
})
const sectionExpanded = computed(() => {
  return projectStore.activePpsDropdown
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('PROJECTS', 'EDIT')
})
const userHasEventsFeature = computed(() => {
  return userStore.userHasFeature('EVENTS')
})
const companyId = computed(() => {
  return userStore.details.companyId
})
const processStepsByName = computed(() => {
  const names = [...new Set(processSteps.value.map(step => step.processStepName))]
  return names.map(processStepName => {
    return {
      processStepName,
      processSteps: processSteps.value.filter(step => step.processStepName === processStepName)
    }
  })
})

const getProcessSteps = async () => {
  try {
    isProcessStepsLoading.value = true
    const {data} = await getRequest(`/project/${projectId.value}/upcomingProcessSteps`)
    processSteps.value = data
  } catch (e) {
    logError(e)
  } finally {
    isProcessStepsLoading.value = false
  }
}
const toggleCollapseExpand = () => {
  projectStore.activePpsDropdown = !projectStore.activePpsDropdown
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

}
</style>
