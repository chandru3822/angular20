<template>
  <v-container id="projects-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar class="elevation-1 toolbar-z-index-override" width="100%">
          <v-toolbar-title>Projects</v-toolbar-title>
        </v-toolbar>

        <v-card
            class="white elevation-1 mt-3 px-3 pt-1 square-card"
        >
          <a-text-field
              class="pt-3"
              prepend-inner-icon="search"
              clearable
              label="Search projects..."
              v-model="searchQuery"
              @input="searchProjects"
              @click:clear="searchProjects()"
              :keyup.enter="closeKeyboard"
          />

          <v-spacer/>
        </v-card>

        <v-divider/>
        <v-data-table
            class="elevation-1 table-striped clickable"
            :headers="headers"
            :items="projects"
            fixed-header
            ref="pageable-table"
            :page.sync="page"
            :options.sync="options"
            disable-sort
            :footer-props="footerProps"
            :server-items-length="totalProjects"
            :loading="isProjectsLoading"
            :class="{'fix-column-width-bug': !isMobile}"
        >
          <template #no-data>
            <span class="default-text-color">No available projects</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available projects</span>
          </template>

          <template #item.id="{item: project, index}" class="text-left py-0 pl-4 clickable">
            <router-link :to="`${getRoute(project)}`" class="router-link-td elevation-0 square-card">
              {{project.id}}
            </router-link>
          </template>
          <template #item.projectName="{item: project, index}" class="text-left text--black clickable">
            <router-link :to="`${getRoute(project)}`" class="router-link-td elevation-0 square-card">
              {{project.projectName}}
            </router-link>
          </template>
          <template #item.stateAbbreviation="{item: project, index}" class="text-left clickable">
            <router-link :to="`${getRoute(project)}`" class="router-link-td elevation-0 square-card">
              {{project.stateAbbreviation}}
            </router-link>
          </template>
          <template #item.projectStatusType="{item: project, index}" class="text-left clickable">
            <router-link :to="`${getRoute(project)}`" class="router-link-td elevation-0 square-card">
              {{project.projectStatusType}}
            </router-link>
          </template>
          <template #item.dateCreated="{item: project, index}" class="text-left clickable">
            <span class="clickable">
              <router-link :to="`${getRoute(project)}`" class="router-link-td elevation-0 square-card">
                {{project.dateCreated | formatDate('timestamp', 'MM/DD/YYYY')}}
              </router-link>
            </span>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>

import {logError, getRequestWithParams, getProjectPath} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import debounce from 'lodash.debounce'
import axios from 'axios'
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

const vuetify = vueInstance.$vuetify

const initialLoad = ref(true)
const options = ref({itemsPerPage: 100})
const headers = ref([
  {text: 'ID', value: 'id', show: true},
  {text: 'Name', value: 'projectName', show: true},
  {text: 'State', value: 'stateAbbreviation', show: true},
  {text: 'Status', value: 'projectStatusType', show: true},
  {text: 'Date Created', value: 'dateCreated', show: true}
])
const footerProps = ref({
  'items-per-page-options': [25, 50, 100],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const projects = ref([])
const from = ref(null)
const searchQuery = ref('')
const totalProjects = ref(0)
const page = ref(1)
const isProjectsLoading = ref(false)
const showConfirmDialog = ref(false)
const source = ref(null)

const useSavedFilter = computed(() => {
  return route.params.useSavedFilter
})

onMounted(() => {
  if(useSavedFilter.value === 'true') {
    searchQuery.value = localStorage.getItem('projectSearch') || ''
  } else {
    localStorage.removeItem('projectSearch')
  }
  getProjects()
})

watch(page, async() => {
  let table = vueInstance.$refs['pageable-table'];
  let wrapper = table.$el.querySelector('div.v-data-table__wrapper');

  vuetify.goTo(table); // to table
  vuetify.goTo(table, {container: wrapper}); // to header
})

watch(
    () => options.value,
    () => {
      if(!initialLoad.value) {
        getProjects()
      }
    }
)

const isMobile = computed(() => {
  return vuetify.breakpoint.smAndDown
})
const getRoute = (project) => {
  const defaultProjectPage = getProjectPath().pathSuffix
  return `/project/${project.id}/${defaultProjectPage}`
}
const getProjects = async() => {
  const {page, itemsPerPage} = options.value

  if(source.value){
    source.value.cancel();
  }
  const CancelToken = axios.CancelToken;
  source.value = CancelToken.source();

  try {
    isProjectsLoading.value = true
    const {data} = await getRequestWithParams(`/project/search`, {
      source: source.value,
      cancelToken: source.value.token,
      params: {
        query: searchQuery.value,
        page: page - 1,
        size: itemsPerPage
      }
    }, null, [])
    projects.value = data.content || []
    totalProjects.value = data.totalElements
    initialLoad.value = false
  } catch (e) {
    logError(e)
  } finally {
    isProjectsLoading.value = false
  }
}
const searchProjects = debounce((query) => {
  //don't allow searchQuery to be null - causes issues
  searchQuery.value = searchQuery.value || ''
  localStorage.setItem('projectSearch', searchQuery.value)
  getProjects()
}, 500)
const closeKeyboard = () => {
  document.activeElement.blur()
}
</script>

<style lang="scss">
#projects-container .v-data-footer__pagination {
  display: none !important;
}
</style>
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
