<template>
  <v-container id="orgs-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">Organizations</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text to="/newOrg" color="primaryCustom" v-if="$store.getters.userHasFeatureAccessLevel('ORGS', 'ADD')">
              <v-icon>add</v-icon>
              <span v-if="!constants.IS_MOBILE">Add Organization</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-toolbar color="white" class="elevation-1 mt-3">
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="exportCsv">
              <v-icon v-if="constants.IS_MOBILE">mdi-cloud-download</v-icon>
              <span v-else>Export</span>
            </v-btn>
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
            class="elevation-1 fix-column-width-bug org-table"
        >
          <template #no-data>
            No available organizations
          </template>

          <template #no-results>
            No available organizations
          </template>

          <template v-slot:body.prepend>
            <tr>
              <td>
                <v-text-field dense outlined hide-details
                              v-model="search.org"
                              @blur="setLocalStorage"
                              placeholder="Organization"></v-text-field>
              </td>
              <td>
                <v-text-field dense outlined hide-details
                              v-model="search.type"
                              @blur="setLocalStorage"
                              placeholder="Type"></v-text-field>
              </td>
              <td>
                <v-text-field dense outlined hide-details
                              v-model="search.parent"
                              @blur="setLocalStorage"
                              placeholder="Parent"></v-text-field>
              </td>
              <td>
                <v-text-field dense outlined hide-details
                              @blur="setLocalStorage"
                              v-model="search.active" placeholder="Active"></v-text-field>
              </td>
            </tr>
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}" @click="clickRow(item.id)">
              <td class="text-left">{{item.orgName}}</td>
              <td class="text-left">{{item.orgType}}</td>
              <td class="text-left">{{item.parentOrgName}}</td>
              <td class="text-left">{{item.activeFlag ? 'Yes' : 'No'}}</td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>

  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {  handleHidingGlobalLoader, getRequestWithParams, getSnackbar } from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import { saveAs } from 'file-saver'

  export default {
    name: 'Orgs',

    data () {
      return {
        initialLoad: true,
        snackbar: {},
        constants,
        delay: 500,
        dialog: false,
        orgs: [],
        orgFilter: this.$route.params.orgFilter ? this.$route.params.orgFilter : '',
        headers: [
          { text: 'Organization', value: 'orgName', show: true,
            filter: value => {
              if (!this.search.org) {
                return true
              } else {
                return value.toLowerCase().includes(this.search.org.toLowerCase())
              }
            }
          },
          { text: 'Type', value: 'orgType', show: true,
            filter: value => {
              if (!this.search.type) {
                return true
              } else {
                return value.toLowerCase().includes(this.search.type.toLowerCase())
              }
            }},
          { text: 'Parent', value: 'parentOrgName', show: true,
            filter: value => {
              if (!this.search.parent) {
                return true
              } else {
                return value && value.toLowerCase().includes(this.search.parent.toLowerCase())
              }
            }},
          { text: 'Active', value: 'activeFlag', show: true,
            filter: value => {
              if (!this.search.active) {
                return true
              } else {
                let stringValue = value ? 'Yes' : 'No'
                return stringValue.toLowerCase().includes(this.search.active.toLowerCase())
              }
            }}
        ],
        descending: true,
        footerProps: {
          'items-per-page-options': [25, 50, 100, 1000],
          'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
        },
        options: {
          itemsPerPage: 100
        },
        totalOrgs: 0,
        dataLoading: true,
        search: {
          org: '',
          type: '',
          parent: '',
          active: ''
        }
      }
    },
    computed: {},
    watch: {
      options: {
        handler () {
          if(!this.initialLoad) {
            this.getOrgs()
          }
        },
        deep: true,
      },
    },
    beforeRouteEnter(to, from, next) {
      //if coming to this page from the project details - use the previously used searchQuery
      next((vm) => {
        if(from?.fullPath.includes('/org/')) {
          let localOrgSearch = localStorage.getItem('orgSearch')
          if(localOrgSearch !== null) {
            vm.search = JSON.parse(localStorage.getItem('orgSearch'))
          }
        } else {
          localStorage.removeItem('orgSearch')
        }
        vm.getOrgs()
      });
    },
    methods: {
      setLocalStorage () {
        localStorage.setItem('orgSearch', JSON.stringify(this.search))
      },
      clickRow(id){
        this.$router.push({name: 'org', params: {id}})
      },
      filterResults(value, search, item) {
      },
      async getOrgs() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const { sortBy, sortDesc, page, itemsPerPage } = this.options
        try {
          const {data, status} = await getRequestWithParams(`/org`)
          this.orgs = data
          this.initialLoad = false
          this.dataLoading = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Organizations')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      exportCsv() {
        let csv = ''

        this.headers.forEach(h => csv += `${h.text},`)
        csv = `${csv.slice(0, -1)}\n`

        this.orgs.forEach(o => {

          let addRow = true
          this.headers.forEach(h => {
            if (!h.filter(o[h.value])) {
              addRow = false
            }
          })

          if (addRow) {
            this.headers.forEach(h => csv += `${o[h.value]},`)
            csv = `${csv.slice(0, -1)}\n`
          }
        })

        const blob = new Blob([csv], {type: 'text/csv;charset=utf-8'})
        saveAs(blob, 'Orgs.csv')
      }
    },
    async created () {
      if (this.orgFilter) {
        this.search = this.orgFilter
      }
    }
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
