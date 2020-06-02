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
                label="Search proposals..."
                v-model="searchQuery"
                @input="searchProposals"
              />
            </v-col>
          </v-row>
        </v-toolbar>

        <v-divider/>

        <v-data-table
          class="elevation-1 fix-column-width-bug"
          :headers="headers"
          :items="proposals"
          fixed-header
          :options.sync="options"
          disable-sort
          :footer-props="footerProps"
          :server-items-length="totalProposals"
          :loading="isProposalsLoading"
        >

          <template #no-data>
            No available proposals
          </template>

          <template #no-results>
            No available proposals
          </template>

          <template #item="{item: proposal}">
            <tr class="clickable"
                @click="$router.push({name: 'modify', params: {proposalId: proposal.id}})">
              <td class="text-left">{{proposal.projectId}}</td>
              <td class="text-left">{{proposal.customerName}}</td>
              <td class="text-left">{{proposal.dateCreated | formatDate('date')}}</td>
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
    name: "Search",
    data () {
      return {
        options: {
          itemsPerPage: 100
        },
        headers: [
          {text: 'ID', value: 'projectId', show: true},
          {text: 'Name', value: 'customerName', show: true},
          {text: 'Date Created', value: 'dateCreated', show: true}
        ],
        footerProps: {
          'items-per-page-options': [25, 50, 100],
          'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
        },
        proposals:[],
        searchQuery: '',
        totalProposals: 0,
        isProposalsLoading: false,
      }
    },
    watch: {
      options: {
        handler () {
          this.getProposals()
        }
      }
    },
    methods: {
      async getProposals () {
        const {page, itemsPerPage} = this.options
        try {
          this.isProposalsLoading = true
          const {data} = await getRequestWithParams(`/propTool/proposal/search`, {
            params: {
              query: this.searchQuery,
              page: page - 1,
              size: itemsPerPage
            }
          })
          this.proposals = data.content
          this.totalProposals = data.totalElements
        } catch (e) {
          logError(e)
        } finally {
          this.isProposalsLoading = false
        }
      },
      searchProposals: debounce(function () {
        this.getProposals()
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
