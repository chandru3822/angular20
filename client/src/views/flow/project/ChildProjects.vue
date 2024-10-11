<template>
  <SidePanelExpansionPanel :header="header" :section-expanded="sectionExpanded" @click="toggleCollapseExpand" id="qa-project-children-expansion">
    <template v-slot:tool-btn>
      <a-btn
          variant="text"
          size="small"
          color="primary"
          id="qa-child-projects-button"
          class="pa-2 mx-2"
          @click.native.stop
          :to="`/project/${projectId}/children`"
          prepend-icon="mdi-format-list-bulleted"
      ></a-btn>
    </template>
    <template v-slot:expanded-content>
      <v-card outlined v-for="(project, idx) in childProjects"
             :key="idx"
              class="mb-2 pa-2 elevation-0 body-large"
              @click="goToProject(project.id)">
        {{ project.projectName }}
      </v-card>

      <v-menu
          v-model="childProjectMenuOpen"
          v-if="userStore.userHasFeatureAccessLevel('PROJECTS', 'ADD')"
          bottom
          offset-y
          :close-on-content-click="false"
      >
        <template v-slot:activator="{ on: menu }">
          <a-btn
              :activation-handler="{ ...menu }"
              variant="outlined"
              id="qa-add-child-project-button"
              color="primary"
              class="one-hunned mt-2"
              text="Add Child Projects"
              prepend-icon="add"
          ></a-btn>
        </template>
        <v-card class="pa-5 body-large">
          Select a process to be used
          <a-select v-model="selectedProcess"
                    :items="childCompanyProcesses"
                    label="Process"
                    id="qa-process-selector"
                    placeholder="Select one..."
                    item-title="childProcessName"
                    return-object
                    class="mt-2 qa-process-selector"
          ></a-select>
          <a-text-field
              type="number"
              label="How many to add?"
              placeholder=""
              v-model.number="projectsToAddCount"></a-text-field>
          <a-btn
              variant="text"
              color="primary"
              class="body-medium"
              :disabled="!selectedProcess || !selectedProcess.childCompanyProcessId || projectsToAddCount == null || projectsToAddCount < 1"
              @click="addChildProjects"
              id="qa-add-project-button"
              text="Add Projects"
          ></a-btn>
        </v-card>
      </v-menu>
    </template>
  </SidePanelExpansionPanel>
</template>
<script setup>

import {
  getProjectPath,
  getRequest,
  handleHidingGlobalLoader,
  logError,
  postRequest,
  putRequest
} from '@/helpers/helpers'
import SidePanelExpansionPanel from "@/components/SidePanelExpansionPanel.vue";
import { useProjectStore } from '@/stores/ProjectStore.js'

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'

const projectStore = useProjectStore()
const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
 const vuetify = vueInstance.$vuetify

const props = defineProps({
  childProjects: Array,
  childCompanyProcesses: Array
})
const { childProjects, childCompanyProcesses } = toRefs(props)
const defaultProjectPage = ref(getProjectPath().pathSuffix)
const childProjectMenuOpen = ref(false)
// const availableProcesses = ref([])
const selectedProcess = ref(null)
const projectsToAddCount = ref(null)

const projectId = computed(() => {
  return parseInt(route.params.projectId)
})

const header = computed(() => {
  return childProjects?.length > 0 ? childProjects.value[0].objectCategory + ' Projects' : 'Child Projects'
})

const userPositionIds = computed(() => {
  return userStore.details.userPositions.map(p => p.positionId)
})

onMounted(async() => {
  selectedProcess.value = childCompanyProcesses.value?.length === 1 ? childCompanyProcesses.value[0] : {}
})

const sectionExpanded = computed(()  => {
  return projectStore.projectChildrenDropdown
})
const isMobile = computed(() => {
  return vuetify.breakpoint.smAndDown
})

const goToProject = (pId) => {
  let path = `/project/${pId}/${defaultProjectPage.value}`
  let routerData = router.resolve({path})
  window.open(routerData.href, '_blank')
}

const toggleCollapseExpand = () => {
  projectStore.projectChildrenDropdown = !projectStore.projectChildrenDropdown
}

const resetMenu = () => {
  childProjectMenuOpen.value = false
  projectsToAddCount.value = null
  selectedProcess.value = null
}

const addChildProjects = async() => {
  appStore.loading = true
  try {
    let params = {
      childCompanyProcessId: selectedProcess.value.childCompanyProcessId,
      childProjectCount: projectsToAddCount.value
    }
    const {data, status} = await postRequest(`/project/${projectId.value}/addChildren`, params)
    appStore.showSnack('SUCCESS', `Added ${projectsToAddCount.value} projects.`)
    resetMenu()
    //reload the screen because i dont want to have to pass it all back to the various screens they could be active on
    window.location.reload()
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Adding Projects')
  } finally {
    appStore.loading = false
  }
}

</script>

<style lang="scss" scoped>
//removes the blue-ish effect after you click one of these
.active-tab:focus::before {
  opacity: 0;
}

.active-tab {
  background-color: var(--v-primary-lighten9) ;
}

.active-tab-button {
  border: solid 1px var(--v-grey-lighten1);
  padding: 10px;
  margin-bottom: 10px;
}

</style>

<style lang="scss">
//removing this because it causes issues with the uploaded and linked documents expansion panels and I can't tell that it's actually doing anything for the project tabs
//#project-details-container div.v-expansion-panel-content__wrap{
//  padding:0;
//}
</style>
