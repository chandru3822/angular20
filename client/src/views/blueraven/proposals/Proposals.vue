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
            No available projects
          </template>

          <template #no-results>
            No available projects
          </template>

          <template #item="{item}">
            <tr class="clickable"
                @click="$router.push({name: 'proposalDesigns', params: {projectId: item.projectId}})">
              <td class="text-left">{{item.projectId}}</td>
              <td class="text-left">{{item.projectName}}</td>
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

  export default {
    name: "Proposals",
    data () {
      return {
        options: {
          itemsPerPage: 100
        },
        headers: [
          {text: 'ID', value: 'projectId', show: true},
          {text: 'Name', value: 'projectName', show: true},
        ],
        footerProps: {
          'items-per-page-options': [25, 50, 100],
          'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
        },
        projects:[],
        searchQuery: '',
        totalProjects: 0,
        isProjectsLoading: false,
      }
    },
    watch: {
      options: {
        handler () {
          this.getProposalProjects()
        }
      }
    },
    methods: {
      async getProposalProjects () {
        const {page, itemsPerPage} = this.options
        try {
          this.isProjectsLoading = true
          const {data} = await getRequestWithParams(`/proposal/projects`, {
            params: {
              query: this.searchQuery,
              page: page - 1,
              size: itemsPerPage
            }
          }, 'blueraven')
          this.projects = data.content
          this.totalProjects = data.totalElements
        } catch (e) {
          logError(e)
        } finally {
          this.isProjectsLoading = false
        }
      },
      searchProjects: debounce(function () {
        this.getProposalProjects()
      }, 500)
    }
  }
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
