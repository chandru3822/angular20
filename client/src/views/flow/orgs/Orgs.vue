<template>
  <v-container id="orgs-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">Organizations</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text to="/newOrg" color="primary">
              <v-icon>add</v-icon>
              <span v-if="!IS_MOBILE">Add Organization</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-toolbar color="white" class="elevation-1 mt-3">
          <v-text-field
              class="mt-5"
              prepend-inner-icon="search"
              text
              label="Search orgs..."
              v-model="search"
              @input="debounceGetOrgs"
          ></v-text-field>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text v-if="totalOrgs <= 100000" @click="exportOrgs">Export</v-btn>
            <v-dialog
                v-model="dialog"
                width="500"
                v-else
            >
              <template v-slot:activator="{ on }">
                <v-btn text v-on="on">
                  Export
                </v-btn>
              </template>

              <v-card>
                <v-card-title>
                  Export
                </v-card-title>

                <v-card-text>
                  You are attempting to export {{totalOrgs | currency('', 0)}} results.
                  This can take 1-2 minutes.
                  We recommend that you cancel and filter the result set before exporting.
                </v-card-text>

                <v-divider></v-divider>

                <v-card-actions>
                  <div class="flex-grow-1"></div>
                  <v-btn
                      color="grey"
                      text
                      @click="dialog = false"
                  >
                    Cancel
                  </v-btn>
                  <v-btn
                      color="primary"
                      text
                      @click="exportOrgs"
                  >
                    Continue Anyway
                  </v-btn>
                </v-card-actions>
              </v-card>
            </v-dialog>
          </v-toolbar-items>
        </v-toolbar>
        <v-data-table
            :headers="headers"
            :items="orgs"
            :fixed-header="true"
            :options.sync="options"
            disable-sort
            :mobile-breakpoint="0"
            :footer-props="footerProps"
            :loading="dataLoading"
            :server-items-length="totalOrgs"
            class="elevation-1 fix-column-width-bug org-table"
        >
          <template #no-data>
            No available organizations
          </template>

          <template #no-results>
            No available organizations
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}" @click="clickRow(item.id)">
              <td class="text-left">{{item.orgName}}</td>
              <td class="text-left">{{item.orgType}}</td>
              <td class="text-left">{{item.parentOrgName}}</td>
              <td class="text-left">{{item.active ? 'Yes' : 'No'}}</td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import { getRequest, deleteRequest, putRequest, postRequest, getRequestWithParams, getSnackbar, IS_MOBILE } from '@/helpers/helpers'
  import Snackbar from '@/components/Snackbar.vue'
  import debounce from 'lodash.debounce'
  import { saveAs } from 'file-saver'

  export default {
    name: 'Orgs',
    components: {
      Snackbar
    },
    data () {
      return {
        snackbar: {},
        IS_MOBILE,
        delay: 500,
        dialog: false,
        orgs: [],
        headers: [
          { text: 'Organization', value: 'orgName', show: true },
          { text: 'Type', value: 'orgType', show: true },
          { text: 'Parent', value: 'parentOrgName', show: true },
          { text: 'Active', value: 'activeFlag', show: true}
        ],
        descending: true,
        footerProps: {
          'items-per-page-options': [25, 50, 100, 1000],
          'items-per-page-text': IS_MOBILE ? '' : 'Rows per page:'
        },
        options: {
          itemsPerPage: 100
        },
        totalOrgs: 0,
        dataLoading: true,
        search: ''
      }
    },
    computed: {},
    watch: {
      options: {
        handler () {
          this.getOrgs()
        },
        deep: true,
      },
    },
    methods: {
      clickRow(id){
        this.$router.push({name: 'org', params: {id}})
      },
      debounceGetOrgs: debounce( function () {
        this.dataLoading = true
        this.getOrgs()
      }, 500),
      async getOrgs() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const { sortBy, sortDesc, page, itemsPerPage } = this.options
        try {
          const {data} = await getRequestWithParams(`/org/search`, { params: {
              query: this.search,
              page: page - 1,
              size: itemsPerPage
            }})
          this.orgs = data.content
          this.totalOrgs = data.totalElements
          this.dataLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Organizations')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async exportOrgs () {
        this.dialog = false
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequestWithParams(`/org/exportOrgs`, { params: {
              query: this.search
            }})
          let blob = new Blob([data], {
            type: 'text/csv;charset=utf-8'
          });
          saveAs(blob, "organizations.csv");
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Exporting Organizations')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    async created () {}
  }
</script>

<style lang="scss">
  #orgs-container .v-data-table__wrapper {
    height: calc(100vh - 290px);
    min-height: 300px;
  }
</style>

<style lang="scss" scoped>
  #orgs-container {
    margin-top: -15px;
    padding-left: 0;
    padding-right: 0;
    padding-top: 0;
  }

  .org-table {
    margin-top: 2px;
  }
</style>
