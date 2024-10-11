<template>
  <SidePanelExpansionPanel :header="parentProject.objectCategory" :section-expanded="sectionExpanded" @click="toggleCollapseExpand" id="qa-project-children-expansion">
    <template v-slot:expanded-content>
      <v-card outlined
              class="mb-2 pa-2 elevation-0 body-large"
              @click="goToProject(parentProject.id)">
        <div class="body-large" >{{ parentProject.projectName }} </div>
        <div class="body-small" :class="getStatusClass(parentProject.projectStatusTypeId)">{{ parentProject.projectStatusType }}</div>
      </v-card>
    </template>
  </SidePanelExpansionPanel>
</template>
<script setup>

import {getProjectPath, getRequestWithParams, logError} from '@/helpers/helpers'
import SidePanelExpansionPanel from "@/components/SidePanelExpansionPanel.vue";
import { useProjectStore } from '@/stores/ProjectStore.js'

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'
import {getStatusClass} from "@/services/processStepStatusTypeService.js";

const projectStore = useProjectStore()
const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
 const vuetify = vueInstance.$vuetify

const props = defineProps({
  parentProject: Object,
})
const { parentProject } = toRefs(props)
const defaultProjectPage = ref(getProjectPath().pathSuffix)

const projectId = computed(() => {
  return parseInt(route.params.projectId)
})

// const header = computed(() => {
//   return childProjects.value[0].objectCategory + " Projects"
// })

onMounted(() => {
})

const sectionExpanded = computed(()  => {
  return projectStore.projectParentDropdown
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
  projectStore.projectParentDropdown = !projectStore.projectParentDropdown
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
