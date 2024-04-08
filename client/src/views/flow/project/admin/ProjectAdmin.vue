<template>
  <div id="project-admin-container">
    <v-toolbar flat color="#E3E3E3" class="project-header">
      <div class="app-title albatross-header-1">
        <router-link :to="`/project/${projectId}/${defaultProjectPage}`">{{ project.projectName }}</router-link>
      </div>
      <v-spacer></v-spacer>
      <a-btn
          color="primary"
          class="float-right mr-1"
          :icon="isMobile"
          @click="deleteProjectConfirm=true"
          prepend-icon="delete"
          :text="isMobile ? '' : 'Delete Project'"
      ></a-btn>
    </v-toolbar>
    <ConfirmationDialog
        :open-dialog="deleteProjectConfirm"
        @confirm="deleteProject"
        @close-dialog="deleteProjectConfirm = false"
    >
      <span class="error--text">WARNING:</span>
      This cannot be undone. Are you sure you want to delete this project?
    </ConfirmationDialog>
    <v-row>
      <v-col cols="12" class="relative">
        <a-btn
            variant="text"
            class="pl-1 pr-2 anchor"
            :to="`/project/${projectId}/${defaultProjectPage}`"
            color="unset"
            prepend-icon="arrow_left"
            text="Back to Project"
        ></a-btn>
        <v-tabs class="tabs-bar" v-model="activeTab">
          <v-tab v-for="(tab, index) in tabs" :key="index" :to="tab.path"
                 class="text-capitalize ma-0"
                 :style="{'margin-left': index === 0 ? '12px !important' : '0'}">
            {{ tab.label }}
          </v-tab>
        </v-tabs>
        <router-view :process-id="project.processId">
        </router-view>
      </v-col>

    </v-row>
  </div>
</template>

<script setup>

import ConfirmationDialog from "@/components/ConfirmationDialog.vue";
import {deleteRequest, getProjectPath, getRequest, logError} from "@/helpers/helpers";


import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
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
const vuetify = vueInstance.$vuetify

const defaultProjectPage = ref(getProjectPath().pathSuffix)
const projectId = ref(parseInt(route.params.projectId))
const project = ref({})
const deleteProjectConfirm = ref(false)
const activeTab = ref(null)

onMounted(async() => {
  await getProject()
})

const tabs = computed(() => {
  return [
    {
      id: 1,
      label: 'Process Steps',
      path: `/projectAdmin/${projectId.value}/processSteps`,
    },
    {
      id: 2,
      label: 'Tags',
      path: `/projectAdmin/${projectId.value}/tags`,
    }
  ]
})
const isMobile = computed(() => {
  return vuetify.breakpoint.smAndDown
})

const getProject = async () => {
  try {
    const {data} = await getRequest(`/project/${projectId.value}`)
    project.value = data
    window.document.title = `${project.value.projectName} - Admin`
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error fetching project')

  }
}
const deleteProject = async() => {
  try {
    appStore.loading = true
    await deleteRequest(`/project/${projectId.value}`)
    snackbar('SUCCESS', 'Project Deleted')

    router.push('/projects')
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error deleting project')

  } finally {
    appStore.loading = false
  }
}
</script>

<style scoped lang="scss">
#project-admin-container {
  width: 100%;
  height: 100%;
  max-height: 100% !important;
  padding: 0 !important;
  overflow-x:clip;
}

.tabs-bar {
  top: -12px;
  border-top: 1px solid #E6E6E6;
  border-bottom: 1px solid #E6E6E6;
  .v-tab:hover {
    color: var(--v-primary-base);
  }
}
</style>
