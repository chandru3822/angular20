<template>
  <v-row no-gutters id="project-details-wq-container" class="py-0 relative overflow-y-auto">
    <v-col cols="12" lg="12" class="pa-3">
      <v-toolbar color="transparent" class="elevation-0 project-wq-toolbar">
        <v-toolbar-title class="albatross-header-3">Current Work Queues</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <a-btn
              color="primary"
              variant="text"
              @click="expandCurrent = !expandCurrent"
              :prepend-icon="!expandCurrent ? 'mdi-chevron-down' : 'mdi-chevron-up'"
          ></a-btn>
        </v-toolbar-items>
      </v-toolbar>

      <v-card class="square-card" v-if="expandCurrent">
        <v-data-table
            :headers="headers"
            :items="currentWorkQueues"
            :fixed-header="true"
            disable-sort
            hide-default-footer
            :items-per-page="-1"
            :loading="dataLoading"
            dense
            class="elevation-1 table-striped"
        >

          <template #no-data>
            No current work queues
          </template>

          <template #no-results>
            No current work queues
          </template>

          <template #item.workQueueCategory="{item}" class="text-left">{{ item.workQueueCategory }}</template>
          <template #item.workQueueType="{item}" class="text-left">{{ item.workQueueType }}</template>
          <template #item.daysInQueue="{item}" class="text-left">{{ item.daysInQueue }}</template>
          <template #item.processStepName="{item}" class="text-left">{{ item.processStepName }}</template>
          <template #item.eventName="{item}" class="text-left">{{ item.eventName }}</template>

        </v-data-table>
      </v-card>

      <v-toolbar color="transparent" class="elevation-0 mt-6 project-wq-toolbar">
        <v-toolbar-title class="albatross-header-3">Historic Work Queues</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <a-btn
              color="primary"
              variant="text"
              @click="expandHistoric = !expandHistoric"
              :prepend-icon="!expandHistoric ? 'mdi-chevron-down' : 'mdi-chevron-up'"
          ></a-btn>
        </v-toolbar-items>
      </v-toolbar>
      <v-card class="square-card" v-if="expandHistoric">
        <v-data-table
            :headers="headers"
            :items="historicWorkQueues"
            :fixed-header="true"
            disable-sort
            :items-per-page="-1"
            hide-default-footer
            :loading="dataLoading"
            dense
            class="elevation-1 table-striped"
        >

          <template #no-data>
            No current work queues
          </template>

          <template #no-results>
            No current work queues
          </template>

          <template #item.workQueueCategory="{item}" class="text-left">{{ item.workQueueCategory }}</template>
          <template #item.workQueueType="{item}" class="text-left">{{ item.workQueueType }}</template>
          <template #item.daysInQueue="{item}" class="text-left">{{ item.daysInQueue }}</template>
          <template #item.processStepName="{item}" class="text-left">{{ item.processStepName }}</template>
          <template #item.eventName="{item}" class="text-left">{{ item.eventName }}</template>

        </v-data-table>
      </v-card>
    </v-col>
  </v-row>
</template>

<script setup>

import {getRequest, logError} from '@/helpers/helpers'
import TableActiveProjectProcessStepSnippet from '@/views/flow/project/TableActiveProjectProcessStepSnippet'
import ProjectProcessStepSnippet from '@/views/flow/project/ProjectProcessStepSnippet'
import SpinnerInline from '@/components/SpinnerInline'
import AddProcessStep from '@/views/flow/components/AddProcessStep'
import constants from "@/helpers/constants";

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'

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

const workQueueHistory = ref([])
const expandHistoric = ref(true)
const expandCurrent = ref(true)
const dataLoading = ref(false)
const headers = ref([
  {text: 'WQ Category', value: 'workQueueCategory', show: true},
  {text: 'WQ Type', value: 'workQueueType', show: true},
  {text: 'Days in Queue', value: 'daysInQueue', show: true},
  {text: 'Process Step Name', value: 'processStepName', show: true},
  {text: 'Event Name', value: 'eventName', show: true}
])
const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 500],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const options = ref({itemsPerPage: 100})

const projectId = computed(() => {
  return parseInt(route.params.projectId)
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('PROJECTS', 'EDIT')
})
const companyId = computed(() => {
  return userStore.details.companyId
})
const currentWorkQueues = computed(() => {
  return workQueueHistory.value.filter(wqh => wqh.status === 'Currently in Queue')
})
const historicWorkQueues = computed(() => {
  return workQueueHistory.value.filter(wqh => wqh.status === 'Work Queue History')
})

onMounted(() => {
  getWorkQueueHistory()
})

const getWorkQueueHistory = async () => {
  try {
    dataLoading.value = true
    const {data} = await getRequest(`/project/${projectId.value}/workQueueHistory`)
    workQueueHistory.value = data
    window.document.title = `${project.value.projectName} - Work Queues`
  } catch (e) {
    logError(e)
  } finally {
    dataLoading.value = false
  }
}
</script>

<style lang="scss" scoped>
#project-details-wq-container {
  margin-top: -15px;
  padding-left: 0;
  padding-right: 0;
  padding-top: 0;
  height: calc(100vh - 192px);

  @media (min-width: 960px) {
    height: 100%;
  }
}
</style>

<style lang="scss">
//#project-details-wq-container .v-data-table__wrapper {
//  max-height: calc(100vh - 270px);
//  min-height: 300px;
//}

.project-wq-toolbar .v-toolbar__content {
  padding: 4px 0 !important;
}
</style>
