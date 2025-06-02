<template>
  <v-container id="projects-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar class="elevation-1 toolbar-z-index-override" width="100%">
          <v-toolbar-title>Projects</v-toolbar-title>
        </v-toolbar>

        <v-card
            class="white elevation-1 mt-3  pt-1 square-card" flat
        >
          <SuperSearch
            class="px-3"
            :filter-options="headers"
            v-model="searchQuery"
            @click:clear="searchProjects"
            :keyup.enter="closeKeyboard"
            @updateQuery="setSearchQuery"
          />
          <v-divider/>
          <v-spacer/>
          <v-data-table
              class="elevation-1 table-striped clickable"
              :headers="headers"
              :items="projects"
              fixed-header
              ref="pageableTable"
              :page.sync="page"
              :options.sync="options"
              disable-sort
              :footer-props="footerProps"
              :server-items-length="totalProjects"
              :loading="isProjectsLoading"
              :class="{'fix-column-width-bug': !isMobile}"

          >

            <template v-if="totalProjects !== 10000" v-slot:footer.prepend>
              <div class="default-text-color">
                Page {{ page }} of {{ totalPages }} |
                Showing {{ startIndex }}–{{ endIndex }} of {{ totalProjects }} results
              </div>
            </template>

            <template #no-data>
              <span class="default-text-color">No available projects</span>
            </template>

            <template #no-results>
              <span class="default-text-color">No available projects</span>
            </template>

            <template #item.id="{item: project, index}" class="text-left py-0 pl-4 clickable">
              <router-link :to="`${getRoute(project)}`" class="router-link-td elevation-0 square-card">
                <span v-if="searchQuery?.length > 0" :inner-html.prop="project?.id?.toString() | searchHighlight(searchQuery)"></span>
                <span v-else>{{project?.id}}</span>
              </router-link>
            </template>
            <template #item.projectName="{item: project, index}" class="text-left text--black clickable">
              <router-link :to="`${getRoute(project)}`" class="router-link-td elevation-0 square-card">
                <span v-if="searchQuery?.length > 0" :inner-html.prop="project.projectName | searchHighlight(searchQuery, columnFilterName === 'projectName')"></span>
                <span v-else>{{project.projectName}}</span>
              </router-link>
            </template>
            <template #item.projectStatusType="{item: project, index}" class="text-left clickable">
              <router-link :to="`${getRoute(project)}`" class="router-link-td elevation-0 square-card">
                <span v-if="searchQuery?.length > 0" :inner-html.prop="project.projectStatusType | searchHighlight(searchQuery)"></span>
                <span v-else>{{project.projectStatusType}}</span>
              </router-link>
            </template>
            <template #item.street1="{item: project, index}" class="text-left clickable">
              <router-link :to="`${getRoute(project)}`" class="router-link-td elevation-0 square-card">
                <span v-if="searchQuery?.length > 0" :inner-html.prop="project.street1 | searchHighlight(searchQuery)"></span>
                <span v-else>{{project.street1}}</span>
              </router-link>
            </template>
            <template #item.city="{item: project, index}" class="text-left clickable">
              <router-link :to="`${getRoute(project)}`" class="router-link-td elevation-0 square-card">
                <span v-if="searchQuery?.length > 0" :inner-html.prop="project.city | searchHighlight(searchQuery)"></span>
                <span v-else>{{project.city}}</span>
              </router-link>
            </template>
            <template #item.stateAbbreviation="{item: project, index}" class="text-left clickable">
              <router-link :to="`${getRoute(project)}`" class="router-link-td elevation-0 square-card">
                <span v-if="searchQuery?.length > 0" :inner-html.prop="project.stateAbbreviation | searchHighlight(searchQuery)"></span>
                <span v-else>{{project.stateAbbreviation}}</span>
              </router-link>
            </template>
            <template #item.postalCode="{item: project, index}" class="text-left clickable">
              <router-link :to="`${getRoute(project)}`" class="router-link-td elevation-0 square-card">
                <span v-if="searchQuery?.length > 0" :inner-html.prop="project?.postalCode?.toString() | searchHighlight(searchQuery)"></span>
                <span v-else>{{project?.postalCode}}</span>
              </router-link>
            </template>
            <template #item.contact.phone="{item: project, index}" class="text-left clickable">
              <router-link :to="`${getRoute(project)}`" class="router-link-td elevation-0 square-card">
                <div>
                  <span v-if="searchQuery?.length > 0 && project.contact.phone" :inner-html.prop="reformatPhone(project.contact.phone) | searchHighlight(reformatPhone(searchQuery))"></span>
                  <span v-if="searchQuery?.length === 0 && project.contact.phone"> {{ reformatPhone(project.contact.phone) }} </span>
                  <br v-if="project.contact.phone && project.contact.mobile">
                  <span v-if="searchQuery?.length > 0 && project.contact.mobile" :inner-html.prop="reformatPhone(project.contact.mobile) | searchHighlight(reformatPhone(searchQuery))"></span>
                  <span v-if="searchQuery?.length === 0 && project.contact.mobile"> {{ reformatPhone(project.contact.mobile) }} </span>
                </div>
              </router-link>
            </template>
            <template #item.dateCreated="{item: project, index}" class="text-left clickable">
              <span class="clickable">
                <router-link :to="`${getRoute(project)}`" class="router-link-td elevation-0 square-card">
                  <span v-if="searchQuery?.length > 0" :inner-html.prop="project.dateCreated | formatDate('timestamp', 'MM/DD/YYYY') | searchHighlight(searchQuery)"></span>
                  <span v-else>{{project.dateCreated | formatDate('timestamp', 'MM/DD/YYYY')}}</span>
                </router-link>
              </span>
            </template>
            <template #item.contact.email="{item: project, index}" class="text-left clickable">
              <span class="clickable">
                <router-link :to="`${getRoute(project)}`" class="router-link-td elevation-0 square-card">
                  <span v-if="searchQuery?.length > 0" :inner-html.prop="project.contact.email | searchHighlight(searchQuery)" class="wrap-email"></span>
                  <span v-else class="wrap-email">{{project.contact.email }}</span>
                </router-link>
              </span>
            </template>
          </v-data-table>
        </v-card>
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
import SuperSearch from "@/components/SuperSearch.vue";
import {useStickyStore} from "@/stores/StickyStore.js";

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const stickyStore = useStickyStore()

const vuetify = vueInstance.$vuetify

const initialLoad = ref(true)
const pageableTable = ref(null)
const options = ref({itemsPerPage: 100})
const headers = ref([
  {text: 'ID', value: 'id', show: true, width: '75px'},
  {text: 'Name', value: 'projectName', show: true},
  {text: 'Stage', value: 'projectStatusType', show: true, width: '200px'},
  {text: 'Street', value: 'street1', show: true},
  {text: 'City', value: 'city', show: true, width: '150px'},
  {text: 'State', value: 'stateAbbreviation', show: true, width: '75px'},
  {text: 'Zip', value: 'postalCode', show: true, width: '100px'},
  {text: 'Phone', value: 'contact.phone', show: true, width: '150px'},
  {text: 'Email', value: 'contact.email', show: true},
  {text: 'Date Created', value: 'dateCreated', show: true, width: '125px'},
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
const columnFilterName = ref('')

const useSavedFilters = computed(() => {
  return route.params.useSavedFilters
})
// Pagination
const itemsPerPage = computed(() => options.value.itemsPerPage || 10);
const totalPages = computed(() =>
  Math.ceil(totalProjects.value / itemsPerPage.value)
)
const startIndex = computed(() =>
  totalProjects.value === 0 ? 0 : (page.value - 1) * itemsPerPage.value + 1
)
const endIndex = computed(() => {
  const end = page.value * itemsPerPage.value
  return end > totalProjects.value ? totalProjects.value : end
})

const reformatPhone = (phoneNumber) => {
  return phoneNumber.replace(/\D/g, '')
}

const formatDateString = (dateString) => {
  // transform date format MM/DD/YYYY -> YYYY-DD-MM
  if (columnFilterName.value === 'dateCreated') {
    const matches = dateString.split('/')
    if (matches.length === 3) {
      console.log(matches[2].concat('-', matches[1], '-', matches[0]))
      return matches[2].concat('-', matches[0], '-', matches[1])
    } else if (matches.length === 2) {
      console.log(matches[0].concat('-', matches[1]))
      return matches[0].concat('-', matches[1])
    } else {
      return dateString
    }
  }
  return dateString

}

const setSearchQuery = (newValue, columnName="") => {
  searchQuery.value = newValue?.trim()
  if (columnName !== "") {
    columnFilterName.value = headers.value.find(f => f.text.toLowerCase() === columnName.replace(":", ''))?.value
  } else {
    columnFilterName.value = ''
  }

  searchProjects()
}
onMounted(() => {
  if (stickyStore.projectSearchString === "") {
    getProjects()
  } else {
    searchProjects()
  }
})

watch(page, async() => {
  let table = pageableTable.value;
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
  return vuetify.breakpoint.mdAndDown
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
        query: formatDateString(searchQuery.value),
        page: page - 1,
        size: itemsPerPage,
        searchColumn: columnFilterName.value
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
  console.log(searchQuery.value)
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
    height: calc(100vh - 300px);
    min-height: 300px;
  }
}

tr:nth-of-type(even) {
  @extend .shaded-row;
}

.wrap-email {
  word-break: break-word;
  min-width: 100px;
}
</style>
