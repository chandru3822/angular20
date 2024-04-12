<template>
  <v-row no-gutters id="project-details-container" class="py-0 relative height-one-hunned overflow-y-auto">
    <v-col cols="12" lg="12" class="text-left pt-0">
      <v-col class="py-0" v-if="userStore.userHasFeatureAccessLevel('PROCESS_STEPS', 'VIEW')">
        <v-row>
          <v-toolbar color="transparent" class="elevation-0">
            <v-toolbar-title class="albatross-header-3">Active Process Steps</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
              <AddProcessStep
                  v-if="project.processId && userStore.userHasFeatureAccessLevel('PROCESS_STEPS', 'ADD')"
                  class="d-inline-block"
                  :project-id="projectId"
                  :process-id="project.processId"
                  @step-added="getProcessSteps"
              />
            </v-toolbar-items>
          </v-toolbar>

          <v-col cols="12" v-if="isProcessStepsLoading">
            <SpinnerInline :size="20" color="primary"/>
          </v-col>

          <v-col cols="12" v-else class="pt-0">
            <TableActiveProjectProcessStepSnippet
                :steps="processSteps.filter(step => step.processStepStatusTypeId === 1)"
                :projectId="projectId"
                :contactId="project.contactId"/>
          </v-col>
        </v-row>
      </v-col>


      <v-fade-transition v-if="userStore.userHasFeatureAccessLevel('PROCESS_STEPS', 'VIEW')">
        <v-col
            v-show="!isProcessStepsExpanded"
            cols="12"
            class="text-right pt-0"
        >
        <span @click="isProcessStepsExpanded = true" class="clickable primary--text">
          Expand All Process Steps <v-icon color="primary">mdi-menu-down</v-icon>
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
              <span @click="isProcessStepsExpanded = false" class="clickable primary--text">
                Collapse All Process Steps <v-icon color="primary">mdi-menu-up</v-icon>
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
              <SpinnerInline :size="20" color="primary"/>
            </v-col>

            <v-col cols="12" class="pt-0" v-else>
              <a-text-field placeholder="Filter..."
                            hide-details
                            variant="outlined"
                            type="search"
                            class=""
                            v-model="stepsSearch"></a-text-field>

              <template v-for="step in filteredProcessSteps">
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

<script setup>

import {getRequest, logError} from '@/helpers/helpers'
import TableActiveProjectProcessStepSnippet from '@/views/flow/project/TableActiveProjectProcessStepSnippet'
import ProjectProcessStepSnippet from '@/views/flow/project/ProjectProcessStepSnippet'
import SpinnerInline from '@/components/SpinnerInline'
import orderBy from 'lodash.orderby'
import AddProcessStep from '@/views/flow/components/AddProcessStep'

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const props = defineProps({
  project: Object
})
const { project } = toRefs(props)

const projectId = computed(() => {
  return parseInt(route.params.projectId)
})

const processSteps = ref([])
const customFieldGroups = ref([])
const menuOpen = ref(false)
const isProcessStepsLoading = ref(false)
const stepsSearch = ref('')
const isProcessStepsExpanded = ref(true)

onMounted(() => {
  getProcessSteps()
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('PROJECTS', 'EDIT')
})
const userHasEventsFeature = computed(() => {
  return userStore.userHasFeature('EVENTS')
})
const filteredProcessSteps = computed(() => {
  return stepsSearch.value === '' ? processStepsByName.value : processStepsByName.value.filter(psn => psn.processStepName.toLowerCase().includes(stepsSearch.value.toLowerCase()) )
})
const companyId = computed(() => {
  return userStore.details.companyId
})
const processStepsByName = computed(() => {
  const names = [...new Set(processSteps.value.map(step => step.processStepName))]
  return names.map(processStepName => {
    return {
      processStepName,
      processSteps: orderBy(processSteps.value.filter(step => step.processStepName === processStepName), 'projectProcessStepId', 'desc')
    }
  })
})

const getProcessSteps = async () => {
  try {
    isProcessStepsLoading.value = true
    const {data} = await getRequest(`/project/${projectId.value}/processSteps`)
    processSteps.value = data
    window.document.title = `${project.value.projectName} - Process Steps`
  } catch (e) {
    logError(e)
  } finally {
    isProcessStepsLoading.value = false
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

}
</style>
