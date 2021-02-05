<template>
  <v-container id="projects-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar class="elevation-1" width="100%">
          <v-toolbar-title>Projects</v-toolbar-title>

          <v-spacer/>

          <v-autocomplete
            v-if="$store.getters.userHasFeature('SMARTLIST')"
            v-model="selectedSmartlistId"
            :items="smartlists"
            item-text="name"
            item-value="id"
            class="smartlist-selector pt-3"
          />
        </v-toolbar>

        <v-toolbar
          v-if="selectedSmartlistId === 0"
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

          <!--                <v-btn-->
          <!--                    text-->
          <!--                    :disabled="isProjectsLoading && !totalProjects > 0"-->
          <!--                    @click="showConfirmDialog = true"-->
          <!--                >-->
          <!--                    Export-->
          <!--                </v-btn>-->
        </v-toolbar>

        <v-divider/>
        <v-data-table
          v-if="selectedSmartlistId === 0"
          class="elevation-1 fix-column-width-bug"
          :headers="headers"
          :items="projects"
          fixed-header
          :options.sync="options"
          disable-sort
          :mobile-breakpoint="0"
          :footer-props="footerProps"
          :server-items-length="totalProjects"
          :loading="isProjectsLoading"
        >

          <template #no-data>
            No available projects
          </template>

          <template #no-results>
            No available projects
          </template>

          <template #item="{item: project}">
            <tr class="clickable"
                @click="$router.push({name: 'projectDetails', params: {projectId: project.id}})">
              <td class="text-left">{{project.id}}</td>
              <td class="text-left">{{project.projectName}}</td>
              <td class="text-left">{{project.stateAbbreviation}}</td>
              <td class="text-left">{{project.projectStatusType}}</td>
              <td class="text-left">{{project.dateCreated | formatDate('date')}}</td>
            </tr>
          </template>
        </v-data-table>

        <SmartlistTable
          class="mt-3"
          v-else
          :smartlistId="selectedSmartlistId"
          @row-selected="goToSelectedProject"
        />
      </v-col>
    </v-row>

    <ExportDialog
      :show="showConfirmDialog"
      :totalItems="totalProjects"
      @cancel="showConfirmDialog = false"
      @confirm="[showConfirmDialog = false, generateReport()]"
    />

  </v-container>
</template>

<script>

  import {logError, getRequestWithParams, getSnackbar} from '@/helpers/helpers'
  import {AppMutations} from '@/stores/AppStore'
  import constants from '@/helpers/constants'
  import debounce from 'lodash.debounce'
  import saveAs from 'file-saver'
  import SmartlistTable from '@/components/SmartlistTable'
  import ExportDialog from '@/components/ExportDialog'


  export default {
    name: 'Projects',
    components: {
      SmartlistTable,
      ExportDialog,
    },
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
        isProjectsLoading: false,
        showConfirmDialog: false,
        selectedSmartlistId: 0,
        smartlists: [{id: 0, name: 'Default View'}],
        snackbar: {}
      }
    },
    watch: {
      options: {
        handler() {
          if(!this.initialLoad) {
            this.getProjects()
          }
        }
      }
    },
    created() {
      if (this.$store.getters.userHasFeature('SMARTLIST')) {
        this.getSharedSmartlists()
      }
    },
    methods: {
      async getProjects() {
        const {page, itemsPerPage} = this.options
        try {
          this.isProjectsLoading = true
          const {data} = await getRequestWithParams(`/project/search`, {
            params: {
              query: this.searchQuery,
              page: page - 1,
              size: itemsPerPage
            }
          })
          this.projects = data.content
          this.totalProjects = data.totalElements
          this.initialLoad = false
        } catch (e) {
          logError(e)
        } finally {
          this.isProjectsLoading = false
        }
      },
      async getSharedSmartlists() {
        try {
          const {data} = await getRequestWithParams(`/smartlist/shared`, {params: {objectTypeId: 1}})
          this.smartlists = [...this.smartlists, ...data]
        } catch (e) {
          logError(e)
        }
      },
      searchProjects: debounce(function () {
        //don't allow searchQuery to be null - causes issues
        this.searchQuery = this.searchQuery || ''
        localStorage.setItem('projectSearch', this.searchQuery)
        this.getProjects()
      }, 500),
      async generateReport() {
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          const {data} = await getRequestWithParams(`/project/generate`, {params: {query: this.searchQuery}})
          let report = new Blob([data], {type: constants.CSV_BLOB_TYPE})
          saveAs(report, 'projects.csv')
        } catch (e) {
          logError(e)
        } finally {
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      goToSelectedProject(selectedRow) {
        this.$router.push({name: 'projectDetails', params: {projectId: selectedRow.project_id}})
      }
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

  .smartlist-selector {
    max-width: 350px;
  }
</style>
