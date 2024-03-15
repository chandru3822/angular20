<template>
  <v-container id="proposals-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar class="elevation-1">
          <v-toolbar-title>Proposals</v-toolbar-title>
        </v-toolbar>
        <v-toolbar class="white elevation-1 mt-3">
          <v-row class="justify-space-between align-center">
            <v-col cols="12" lg="6">
              <v-text-field
                  class="mt-5"
                  prepend-inner-icon="search"
                  text
                  label="Search projects..."
                  v-model="searchQuery"
                  @input="searchProjects"
              />
            </v-col>
          </v-row>
        </v-toolbar>

        <v-divider/>

        <v-data-table
            class="elevation-1 fix-column-width-bug"
            :headers="headers"
            :items="projects"
            fixed-header
            :options.sync="options"
            disable-sort
            :footer-props="footerProps"
            :server-items-length="totalProjects"
            :loading="isProjectsLoading"
        >

          <template #no-data>
            <span class="default-text-color">No available projects</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available projects</span>
          </template>

          <template #item="{item}">
            <tr class="clickable"
                @click="router.push({name: 'proposalDesigns', params: {projectId: item.id}})">
              <td class="text-left">{{item.id}}</td>
              <td class="text-left">{{item.projectName}}</td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>

import {logError, getRequestWithParams} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import debounce from 'lodash.debounce'

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

const options = ref({itemsPerPage: 100})
const headers = ref([
  {text: 'ID', value: 'id', show: true},
  {text: 'Name', value: 'projectName', show: true},
])
const footerProps = ref({
  'items-per-page-options': [25, 50, 100],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const projects = ref([])
const searchQuery = ref('')
const totalProjects = ref(0)
const isProjectsLoading = ref(false)

onMounted(() => {
  getProposalProjects()
})

const getProposalProjects = async () => {
  const {page, itemsPerPage} = options.value
  try {
    isProjectsLoading.value = true
    const {data} = await getRequestWithParams(`/project/search`, {
      params: {
        query: searchQuery.value,
        page: page - 1,
        size: itemsPerPage
      }
    })
    projects.value = data.content
    totalProjects.value = data.totalElements
  } catch (e) {
    logError(e)
  } finally {
    isProjectsLoading.value = false
  }
}
const searchProjects = debounce((query) => {
  getProposalProjects()
}, 500)
</script>

<style scoped lang="scss">
@import "@/styles/main.scss";

::v-deep {
  .v-data-table__wrapper {
    height: calc(100vh - 290px);
    min-height: 300px;
  }
}

tr:nth-of-type(even) {
  @extend .shaded-row;
}
</style>
