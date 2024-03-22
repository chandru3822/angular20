<template>
  <SidePanelExpansionPanel header="Details" :section-expanded="sectionExpanded" @click="toggleCollapseExpand">
    <template v-if="!hideAdminBtn" v-slot:tool-btn>
      <a-btn
          variant="text"
          size="small"
          color="primary"
          class="pa-0 mx-2"
          html-style="max-width: 34px"
          v-if="userStore.userHasFeatureAccessLevel('PROJECTS', 'ADMIN') || userStore.userHasFeatureAccessLevel('PROJECTS', 'DELETE')"
          :to="`/projectAdmin/${projectId}/processSteps`"
          @click.native.stop
          prepend-icon="mdi-cog"
      ></a-btn>
    </template>
    <template v-slot:expanded-content>
      <v-card outlined v-for="tab in tabs"
              class="mb-2 pa-2 elevation-0 body-large"
              :class="{'active-tab': tabIsActive(tab)}"
              @click="changeTabs(tab, true)">
        {{ tab.tabName }}
      </v-card>
    </template>
  </SidePanelExpansionPanel>
</template>
<script setup>

import {getRequestWithParams, logError} from '@/helpers/helpers'
import SidePanelExpansionPanel from "@/components/SidePanelExpansionPanel.vue";
import { useProjectStore } from '@/stores/ProjectStorePinia.js'

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
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
const vuetify = vueInstance.$vuetify

const props = defineProps({
  project: Object,
  tabChangeCallback: Function,
  hideAdminBtn: Boolean,
})
const { project, hideAdminBtn } = toRefs(props)

const tabsLoading = ref(true)
const selectedTab = ref({})
const tabs = ref([])

const projectId = computed(() => {
  return parseInt(route.params.projectId)
})

onMounted(() => {
  getProjectTabs()
})

const sectionExpanded = computed(()  => {
  return projectStore.projectDetailsDropdown
})
const isMobile = computed(() => {
  return vuetify.breakpoint.smAndDown
})

const changeTabs = (tab, buttonClicked)  => {
  if(tab.customPath) {
    router.push(tab.customPath)
  } else {
    selectedTab.value = tab
    props.tabChangeCallback(selectedTab.value, buttonClicked)
  }
}
const tabIsActive = (tab)  => {
  if(tab.customPath) {
    return route.path === tab.customPath
  } else {
    return tab.id === selectedTab.value.id && route.name === 'projectDetails'
  }
}
const getProjectTabs = async () => {
  tabsLoading.value = true
  try {
    let params = {
      projectId: projectId.value
    }
    const {data} = await getRequestWithParams(`/objectTypeTab/project`, {params})
    tabs.value = data
    tabs.value.push({
      archived: false,
      companyObjectTypeId: 1,
      displayOrder: tabs.value.length,
      id: -1,
      tabName: 'Uploaded and Linked Documents',
      uniqueIdentifier: 'tab_documents'
    })
    tabs.value.push({
      archived: false,
      companyObjectTypeId: 1,
      displayOrder: tabs.value.length + 1,
      id: -2,
      customPath: `/project/${ projectId.value }/workQueues`,
      tabName: 'Current Work Queues',
      uniqueIdentifier: 'tab_work_queues'
    })
    selectedTab.value = tabs.value?.length > 0 ? data[0] : {}
    props.tabChangeCallback(selectedTab.value)
  } catch (e) {
    logError(e)
  } finally {
    tabsLoading.value = false
  }
}
const toggleCollapseExpand = () => {
  projectStore.projectDetailsDropdown = !projectStore.projectDetailsDropdown
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
#project-details-container div.v-expansion-panel-content__wrap{
  padding:0;
}
</style>
