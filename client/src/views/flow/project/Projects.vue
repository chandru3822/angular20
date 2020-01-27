<template>
<v-container id="projects-container">
  <v-row>
    <v-col cols="12">
      <v-toolbar class="elevation-1">
        <v-toolbar-title>Projects</v-toolbar-title>
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

        <template #item="{item: project, index}">
          <tr class="clickable" @click="$router.push({name: 'projectOverview', params: {projectId: project.id}})">
            <td class="text-left">{{project.id}}</td>
            <td class="text-left">{{project.projectName}}</td>
            <td class="text-left">{{project.processName}}</td>
            <td class="text-left">{{project.statusType}}</td>
            <td class="text-left">{{project.dateCreated | formatDate('date')}}</td>
          </tr>
        </template>
      </v-data-table>
    </v-col>
  </v-row>
</v-container>
</template>

<script>

import {logError, getRequestWithParams, IS_MOBILE} from '@/helpers/helpers'
import debounce from 'lodash.debounce'

export default {
  name: "Projects",
  data () {
    return {
      options: {
        itemsPerPage: 100
      },
      headers: [
        {text: 'ID', value: 'id', show: true},
        {text: 'Name', value: 'projectName', show: true},
        {text: 'Process', value: 'processName', show: true},
        {text: 'Status', value: 'statusType', show: true},
        {text: 'Date Created', value: 'dateCreated', show: true}
      ],
      footerProps: {
        'items-per-page-options': [25, 50, 100],
        'items-per-page-text': IS_MOBILE ? '' : 'Rows per page:'
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
        this.getProjects()
      }
    }
  },
  methods: {
    async getProjects () {
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
      } catch (e) {
        logError(e)
      } finally {
        this.isProjectsLoading = false
      }
    },
    searchProjects: debounce(function () {
      this.getProjects()
    }, 500)
  }
}
</script>

<style lang="scss">
#projects-container .v-data-table__wrapper {
  height: calc(100vh - 290px);
  min-height: 300px;
}
</style>

<style scoped lang="scss">

@import "@/styles/main.scss";

tr:nth-of-type(even) {
  @extend .shaded-row;
}
</style>
