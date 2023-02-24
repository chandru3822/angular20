<template>
  <v-container id="projects-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar class="elevation-1 toolbar-z-index-override" width="100%">
          <v-toolbar-title>Projects</v-toolbar-title>
        </v-toolbar>

        <v-toolbar
          class="white elevation-1 mt-3"
        >
          <v-text-field
            class="pt-3"
            prepend-inner-icon="search"
            text
            clearable
            label="Search projects..."
            v-model="searchQuery"
            @input="searchProjects"
            @click:clear="searchProjects()"
          />

          <v-spacer/>
        </v-toolbar>

        <v-divider/>
        <v-data-table
          class="elevation-1 fix-column-width-bug"
          :headers="headers"
          :items="projects"
          fixed-header
          ref="pageable-table"
          :page.sync="page"
          :options.sync="options"
          disable-sort
          :mobile-breakpoint="0"
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

          <template #item="{item: project, index}">
            <tr class="clickable"  :class="{'shaded-row': index % 2}">
              <td class="text-left py-0 pl-4">
                <router-link class="router-link-td elevation-0 square-card" :to="`/project/${project.id}/details`">
                  {{project.id}}
                </router-link>
              </td>
              <td class="text-left text--black">
                <router-link class="router-link-td elevation-0 square-card" :to="`/project/${project.id}/details`">
                  {{project.projectName}}
                </router-link>
              </td>
              <td class="text-left">
                <router-link class="router-link-td elevation-0 square-card" :to="`/project/${project.id}/details`">
                  {{project.stateAbbreviation}}
                </router-link>
              </td>
              <td class="text-left">
                <router-link class="router-link-td elevation-0 square-card" :to="`/project/${project.id}/details`">
                  {{project.projectStatusType}}
                </router-link>
              </td>
              <td class="text-left">
                <router-link class="router-link-td elevation-0 square-card" :to="`/project/${project.id}/details`">
                  {{project.dateCreated | formatDate('timestamp', 'MM/DD/YYYY')}}
                </router-link>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>

  import {logError, getRequestWithParams} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import debounce from 'lodash.debounce'
  import axios from 'axios'

  export default {
    name: 'Projects',
    beforeRouteEnter(to, from, next) {
      //if coming to this page from the project details - use the previously used searchQuery
      next((vm) => {
        if(from?.fullPath.includes('/project/')) {
          vm.searchQuery = localStorage.getItem('projectSearch') || ''
        } else {
          localStorage.removeItem('projectSearch')
        }
        vm.getProjects()
      });
    },
    data() {
      return {
        initialLoad: true,
        options: {
          itemsPerPage: 100
        },
        headers: [
          {text: 'ID', value: 'id', show: true},
          {text: 'Name', value: 'projectName', show: true},
          {text: 'State', value: 'stateAbbreviation', show: true},
          {text: 'Status', value: 'projectStatusType', show: true},
          {text: 'Date Created', value: 'dateCreated', show: true}
        ],
        footerProps: {
          'items-per-page-options': [25, 50, 100],
          'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
        },
        projects: [],
        from: null,
        searchQuery: '',
        totalProjects: 0,
        page: 1,
        isProjectsLoading: false,
        showConfirmDialog: false,
        snackbar: {},
        source: null
      }
    },
    watch: {
      options: {
        handler() {
          if(!this.initialLoad) {
            this.getProjects()
          }
        }
      },
      page() {
        let table = this.$refs['pageable-table'];
        let wrapper = table.$el.querySelector('div.v-data-table__wrapper');

        this.$vuetify.goTo(table); // to table
        this.$vuetify.goTo(table, {container: wrapper}); // to header
      }
    },
    methods: {
      goToRoute(projectId) {
        this.$router.push({name: 'projectDetails', params: {projectId: projectId}})
      },
      async getProjects() {
        const {page, itemsPerPage} = this.options

        if(this.source){
          this.source.cancel();
        }
        const CancelToken = axios.CancelToken;
        this.source = CancelToken.source();

        try {
          this.isProjectsLoading = true
          const {data} = await getRequestWithParams(`/project/search`, {
            source: this.source,
            cancelToken: this.source.token,
            params: {
              query: this.searchQuery,
              page: page - 1,
              size: itemsPerPage
            }
          }, null, [])
          this.projects = data.content || []
          this.totalProjects = data.totalElements
          this.initialLoad = false
        } catch (e) {
          logError(e)
        } finally {
          this.isProjectsLoading = false
        }
      },
      searchProjects: debounce(function () {
        //don't allow searchQuery to be null - causes issues
        this.searchQuery = this.searchQuery || ''
        localStorage.setItem('projectSearch', this.searchQuery)
        this.getProjects()
      }, 500)
    }
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
