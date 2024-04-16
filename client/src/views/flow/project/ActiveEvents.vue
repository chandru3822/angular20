<template>
  <SidePanelExpansionPanel v-if="userStore.userHasFeatureAccessLevel('PROCESS_STEPS', 'VIEW')"
                           header="Active Events"
                           id="qa-active-events-expansion"
                           :section-expanded="sectionExpanded"
                           :is-loading="activeEventsLoading"
                           @click="toggleCollapseExpand">
    <template v-slot:tool-btn>
      <a-btn
          v-if="userStore.userHasFeatureAccessLevel('PROCESS_STEPS', 'VIEW')"
          variant="text"
          size="small"
          color="primary"
          @click.native.stop
          :to="`/project/${projectId}/events`"
          class="pa-2 mx-2"
          max-width="48px"
          prepend-icon="mdi-format-list-bulleted"
      ></a-btn>
    </template>
    <template v-slot:expanded-content>
      <ActiveEventSnippet class="px-3"
                          @refresh-upcoming-events="getEvents()"
                          :events="events"
                          :projectId="projectId"/>
      <v-col
          v-if="userStore.userHasFeatureAccessLevel('PROCESS_STEPS', 'VIEW')"
          cols="12"
          class="text-left pt-0 albatross-body-3"
      >
      </v-col>
    </template>
  </SidePanelExpansionPanel>
</template>

<script setup>

import {getRequest, logError} from '@/helpers/helpers'
import EventSnippet from '@/views/flow/project/EventSnippet'
import SpinnerInline from '@/components/SpinnerInline'
import ActiveEventSnippet from '@/views/flow/project/ActiveEventSnippet'
import SidePanelExpansionPanel from '@/components/SidePanelExpansionPanel.vue'
import { useProjectStore } from '@/stores/ProjectStore.js'

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()
const projectStore = useProjectStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store


const props = defineProps({
  project: Object,
  updateKey: Number
})
const { project, updateKey } = toRefs(props)

watch(updateKey, () => {
  getEvents()
})

const events = ref([])
const customFieldGroups = ref([])
const menuOpen = ref(false)
const activeEventsLoading = ref(false)
const eventSearch = ref('')
const eventsExpanded = ref(false)

onMounted(() => {
  getEvents()
})

const projectId = computed(() => {
  return parseInt(route.params.projectId)
})
const sectionExpanded = computed(() => {
  return projectStore.activeEventDropdown
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('PROJECTS', 'EDIT')
})
const companyId = computed(() => {
  return userStore.details.companyId
})
const filteredEvents = computed(() => {
  return eventSearch.value === '' ? eventsByName.value : eventsByName.value.filter(psn => psn.eventName.toLowerCase().includes(eventSearch.value.toLowerCase()))
})
const eventsByName = computed(() => {
  const names = [...new Set(events.value.map(e => e.eventName))]

  return names.map(eventName => {
    return {
      eventName,
      events: events.value.filter(step => step.eventName === eventName)
    }
  })
})

const getEvents = async () => {
  try {
    activeEventsLoading.value = true
    const {data} = await getRequest(`/project/${projectId.value}/activeEvents`, null, [])
    events.value = data
  } catch (e) {
    logError(e)
  } finally {
    activeEventsLoading.value = false
  }
}
const toggleCollapseExpand = () => {
  projectStore.activeEventDropdown = !projectStore.activeEventDropdown
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
