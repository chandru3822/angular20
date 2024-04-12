<template>
  <v-row no-gutters id="project-details-container" class="py-0 relative height-one-hunned overflow-y-auto">
    <v-col cols="12" lg="12" class="text-left pt-0">
      <v-col class="py-0" v-if="userStore.userHasFeatureAccessLevel('PROCESS_STEPS', 'VIEW')">
        <v-row>
          <v-toolbar color="transparent" class="elevation-0">
            <v-toolbar-title class="albatross-header-3">Active Events</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
            </v-toolbar-items>
          </v-toolbar>

          <v-col cols="12" v-if="activeEventsLoading">
            <SpinnerInline :size="20" color="primary"/>
          </v-col>

          <v-col cols="12" v-else class="pt-0">
            <TableActiveEventSnippet
                :events="getActiveEvents(events)"
                :projectId="projectId"/>
          </v-col>
        </v-row>
      </v-col>

      <v-fade-transition v-if="userStore.userHasFeatureAccessLevel('PROCESS_STEPS', 'VIEW')">
        <v-col
            v-show="!eventsExpanded"
            cols="12"
            class="text-right pt-0"
        >
        <span @click="eventsExpanded = true" class="clickable primary--text">
          Expand All Events <v-icon color="primary">mdi-menu-down</v-icon>
        </span>
        </v-col>
      </v-fade-transition>

      <v-expand-transition>
        <v-col v-show="eventsExpanded">
          <v-row>
            <v-col cols="12">
              <v-row class="justify-space-around align-center">
                <v-col class="text-left pb-0">
                  <h3>All Events</h3>
                </v-col>
                <v-col class="text-right pb-0">
              <span @click="eventsExpanded = false" class="clickable primary--text">
                Collapse All Events <v-icon color="primary">mdi-menu-up</v-icon>
              </span>
                </v-col>
              </v-row>
              <v-row>
                <v-col cols="12" class="pt-0">
                  <v-divider/>
                </v-col>
              </v-row>
            </v-col>

            <v-col cols="12" v-if="activeEventsLoading">
              <SpinnerInline :size="20" color="primary"/>
            </v-col>

            <v-col cols="12" class="pt-0" v-else>
              <a-text-field placeholder="Filter..."
                            hide-details
                            variant="outlined"
                            type="search"
                            class=""
                            v-model="eventSearch"></a-text-field>

              <template v-for="event in filteredEvents">
                <h4 class="text-left work-type-header">{{event.eventName}}</h4>
                <EventSnippet
                    :key="event.eventName"
                    :events="event.events"
                    :projectId="projectId"/>
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
import EventSnippet from '@/views/flow/project/EventSnippet'
import SpinnerInline from '@/components/SpinnerInline'
import TableActiveEventSnippet from '@/views/flow/project/TableActiveEventSnippet'

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
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

const events = ref([])
const customFieldGroups = ref([])
const menuOpen = ref(false)
const activeEventsLoading = ref(false)
const eventSearch = ref('')
const eventsExpanded = ref(true)

onMounted(() => {
  getEvents()
})

const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('PROJECTS', 'EDIT')
})
const companyId = computed(() => {
  return userStore.details.companyId
})
const filteredEvents = computed(() => {
  return eventSearch.value === '' ? eventsByName.value : eventsByName.value.filter(psn => psn.eventName.toLowerCase().includes(eventSearch.value.toLowerCase()) )
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

const getActiveEvents = (events) => {
  return events.filter(event => {
    return event.eventStatusTypeId === 1
  })
}
const getEvents = async () => {
  try {
    activeEventsLoading.value = true
    const {data} = await getRequest(`/project/${projectId.value}/events`)
    events.value = data
    window.document.title = `${project.value.projectName} - Events`
  } catch (e) {
    logError(e)
  } finally {
    activeEventsLoading.value = false
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
