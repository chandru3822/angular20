<template>
  <v-container id="users-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">Users</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text to="/newUser" color="primary">
              <v-icon>add</v-icon>
              Add User
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-toolbar color="white" class="elevation-1 mt-3">
          <v-text-field
              class="mt-5"
              prepend-inner-icon="search"
              text
              label="Search users..."
              v-model="filters.search"
              @input="debounceGetUsers"
          ></v-text-field>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="handleOrgFilterChange(true)">Reset Filters</v-btn>
            <v-btn text v-if="totalUsers <= 100000" @click="exportUsers">Export</v-btn>
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
                  You are attempting to export {{totalUsers | currency('', 0)}} results.
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
                      @click="exportUsers"
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
            :items="users"
            :fixed-header="true"
            :options.sync="options"
            disable-sort
            :footer-props="footerProps"
            :loading="dataLoading"
            :server-items-length="totalUsers"
            hide-default-header
            :calculate-widths="true"
            class="elevation-1 fix-column-width-bug user-table"
        >
          <template #no-data>
            No available users
          </template>

          <template #no-results>
            No available users
          </template>

          <template #header="{ props: { headers } }">
            <thead class="v-data-table-header">
            <tr>
              <th v-for="header in headers" :key="header.text" class="py-2"
                  :class="{'filter-header-non-select': !header.orgFilter && !header.statusFilter}"
                  :style="{width: header.width ? header.width : 'auto',
                          'padding-bottom': !header.orgFilter && !header.statusFilter ? '13px !important' : ''}">
                {{ header.text }}
                <v-select v-model="filters.orgs[header.level]"
                          :items="header.orgs"
                          v-if="header.orgFilter"
                          item-text="orgName"
                          item-value="id"
                          return-object
                          multiple
                          placeholder="Select..."
                          height="35px"
                          outlined
                          class="user-filter-select"
                          @change="handleOrgFilterChange(false, header.level)"
                >
                  <template
                      slot="selection"
                      slot-scope="{ item, index }"
                  >
                    <v-chip small v-if="index === 0 && filters.orgs[header.level] && filters.orgs[header.level].length < 2">
                      <span>{{ item.orgName }}</span>
                    </v-chip>
                    <span
                        v-if="index === 1 && filters.orgs[header.level] && filters.orgs[header.level].length >= 2"
                        class="primary--text caption"
                    >{{ filters.orgs[header.level].length }} selected</span>
                  </template>
                  <template #item="{ item }">
                    <div class="v-list-item__action">
                      <div class="v-simple-checkbox">
                        <div class="v-input--selection-controls__ripple primary--text">

                        </div>
                        <i v-if="itemChecked(header.level, item)" aria-hidden="true" class="v-icon notranslate material-icons theme--light">check_box</i>
                        <i v-else aria-hidden="true" class="v-icon notranslate material-icons theme--light">check_box_outline_blank</i>
                      </div>
                    </div>
                    <div v-if="header.showType">{{item.orgName}} ({{item.orgType}})</div>
                    <div v-else>{{item.orgName}}</div>
                  </template>
                </v-select>
                <v-select v-model="filters.statuses"
                          :items="statuses"
                          v-else-if="header.statusFilter"
                          multiple
                          item-text="userStatusType"
                          item-value="id"
                          outlined
                          placeholder="Select..."
                          height="35px"
                          class="user-filter-select"
                          @input="getUsers()"
                >
                  <v-list-item
                      slot="prepend-item"
                      ripple
                      @click="toggleSelectAllStatuses()"
                  >
                    <v-list-item-action>
                      <v-icon>{{ icon }}</v-icon>
                    </v-list-item-action>
                    <v-list-item-title>Select All</v-list-item-title>
                  </v-list-item>
                  <v-divider
                      slot="prepend-item"
                      class="mt-2"
                  ></v-divider>
                  <template
                      slot="selection"
                      slot-scope="{ item, index }"
                  >
                    <v-chip small v-if="index === 0 && filters.statuses.length < 2">
                      <span>{{ item.userStatusType }}</span>
                    </v-chip>
                    <span
                        v-if="index === 1 && filters.statuses.length >= 2"
                        class="primary--text caption"
                    >{{ filters.statuses.length }} selected</span>
                  </template>
                </v-select>
                <v-select v-model="filters.positions"
                          :items="positions"
                          v-else-if="header.positionFilter"
                          item-text="position"
                          item-value="id"
                          multiple
                          placeholder="Select..."
                          height="35px"
                          outlined
                          class="user-filter-select"
                          @input="getUsers()"
                >
                  <template
                      slot="selection"
                      slot-scope="{ item, index }"
                  >
                    <v-chip small v-if="index === 0 && filters.positions && filters.positions.length < 2">
                      <span>{{ item.position }}</span>
                    </v-chip>
                    <span
                        v-if="index === 1 && filters.positions && filters.positions.length >= 2"
                        class="primary--text caption"
                    >{{ filters.positions.length }} selected</span>
                  </template>
                </v-select>
                <v-text-field outlined
                              v-else
                              hide-details
                              class="filter-input"
                    v-model="filters[header.value]" @input="debounceGetUsers"></v-text-field>
              </th>
            </tr>
            </thead>
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}" @click="clickRow(item.id)">
              <td class="text-left user-column">{{item.firstName}}</td>
              <td class="text-left user-column">{{item.lastName}}</td>
              <td class="text-left user-column">{{item.email}}</td>
              <td class="text-left user-column">{{item.phoneNumber}}</td>
              <td class="text-left user-column">{{item.userStatusType}}</td>
              <td class="text-left user-column">{{item.position}}</td>
              <td class="text-left user-column" v-for="(f, index) in orgFilters" :key="index">
                {{getOrgNameForFilter(item.hierarchy, f.orgLevelId)}}
              </td>
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
  import Snackbar from '@/components/Snackbar.vue'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import debounce from 'lodash.debounce'
  import cloneDeep from 'lodash.clonedeep'
  import max from 'lodash.max'
  import { saveAs } from 'file-saver'

  export default {
    name: 'Users',
    components: {
      Snackbar
    },
    data () {
      return {
        delay: 500,
        dialog: false,
        snackbar: {},
        users: [],
        selectedLevel: null,
        masterOrgFilterList: [],
        orgFilters: [],
        statuses: [],
        positions: [],
        descending: true,
        footerProps: {
          'items-per-page-options': [25, 50, 100, 1000]
        },
        options: {
          itemsPerPage: 100
        },
        totalUsers: 0,
        dataLoading: true,
        headers: [
          { text: 'First Name', value: 'firstName', show: true, width: '125px' },
          { text: 'Last Name', value: 'lastName', show: true, width: '125px' },
          { text: 'Email', value: 'email', show: true, width: '275px' },
          { text: 'Phone', value: 'phone', show: true, width: '115px' },
          { text: 'Status', value: 'userStatusType', statusFilter: true, show: true, width: '175px' },
          { text: 'Position', value: 'position', positionFilter: true, show: true, width: '175px' },
        ],
        // search: '',
        filters: {
          search: '',
          firstName: '',
          lastName: '',
          email: '',
          phone: '',
          orgs: {},
          statuses: [1],
          positions: []
        }
      }
    },
    computed: {
      selectAll () {
        return this.filters.statuses.length === this.statuses.length
      },
      selectSome () {
        return this.filters.statuses.length > 0 && !this.selectAll
      },
      icon () {
        if (this.filters.statuses && this.statuses && this.filters.statuses.length === this.statuses.length) {
          return 'check_box'
        }
        if (this.selectSome) {
          return 'indeterminate_check_box'
        }
        return 'check_box_outline_blank'
      }
    },
    watch: {
      options: {
        handler () {
          this.getUsers()
        },
        deep: true,
      },
    },
    created () {
      this.getStatuses()
      this.getPositions()
      this.getOrgFilters(true)
    },
    methods: {
      clickRow(id){
        this.$router.push({name: 'user', params: {id}})
      },
      debounceGetUsers: debounce( function () {
        this.getUsers()
      }, 500),
      async getUsers () {
        if(this.filters.statuses && this.filters.statuses.length > 0) {
          this.dataLoading = true
          const { sortBy, sortDesc, page, itemsPerPage } = this.options
          try {
            const params = {
              search: this.filters.search,
              firstName: this.filters.firstName,
              lastName: this.filters.lastName,
              email: this.filters.email,
              phone: this.filters.phone,
              statuses: this.filters.statuses,
              positions: this.filters.positions,
              orgs: this.getOrgIdsForMax(),
              //todo: if this changes to allow primary only, secondary only, or both this flag the backend is ready to have that work using this flag (true, false, null)
              primaryFlag: true
            }

            const {data} = await postRequest(`/user/search?page=${page-1}&size=${itemsPerPage}`, params)
            this.users = data.content
            this.totalUsers = data.totalElements
            this.dataLoading = false
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving Users')
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        } else {
          this.users = []
        }
      },
      async exportUsers () {
        this.dialog = false
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const params = {
            search: this.filters.search,
            firstName: this.filters.firstName,
            lastName: this.filters.lastName,
            email: this.filters.email,
            phone: this.filters.phone,
            statuses: this.filters.statuses,
            positions: this.filters.positions,
          }
          const {data} = await postRequest(`/user/exportUsers`, params)
          let blob = new Blob([data], {
            type: 'text/csv;charset=utf-8'
          });
          saveAs(blob, "users.csv");
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Exporting Users')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getOrgFilters (initialLoad) {
        Object.keys(this.filters.orgs).forEach(key => {
          if (this.filters.orgs[key] && this.filters.orgs[key].length === 0) {
            delete this.filters.orgs[key]
          }
        })
        try {
          if(Object.keys(this.filters.orgs).length > 0) {
            //org filters have already been loaded. load their orgs again and repopulate the org list only
            const params = {
              orgs: this.getOrgIds()
            }
            const {data} = await postRequest(`/org/orgHierarchyFilter`, params)
            data.forEach(d => {
              let index = this.headers.findIndex(h => h.level === d.orgLevelId)
              if(d.orgLevelId === this.selectedLevel) {
                let masterIndex = this.masterOrgFilterList.findIndex(mf => mf.orgLevelId === d.orgLevelId)
                this.headers[index].orgs = this.masterOrgFilterList[masterIndex].orgs
              }else {
                //get index of the right header
                this.headers[index].orgs = d.orgs
              }
            })
          } else if(initialLoad) {
            //org filters not yet loaded. load them from main list
            const {data} = await getRequest(`/org/filters`)
            this.masterOrgFilterList = cloneDeep(data)
            this.orgFilters = cloneDeep(this.masterOrgFilterList)
            this.resetHeaderOrgs()
          } else {
            this.filters.orgs = {}
            this.orgFilters = cloneDeep(this.masterOrgFilterList)
            this.resetHeaderOrgs()
          }
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Org Filters')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      resetHeaderOrgs(){
        this.orgFilters.forEach(f => {
          let index = this.headers.findIndex(h => h.level === f.orgLevelId)
          if(index > -1) {
            this.headers[index].orgs = f.orgs
          } else {
            this.headers.push({
              text: f.levelName,
              value: f.levelName,
              sortable: false,
              show: true,
              level: f.orgLevelId,
              orgFilter: true,
              showType: f.showType,
              orgs: f.orgs,
              width: '225px'
            })
          }
        })
      },
      async getStatuses () {
        try {
          const {data} = await getRequest(`/user/statuses`)
          this.statuses = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving User Statuses')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getPositions () {
        try {
          const {data} = await getRequest(`/position`)
          this.positions = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Positions')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      toggleSelectAllStatuses () {
        this.$nextTick(() => {
          if (this.selectAll) {
            this.filters.statuses = []
            this.getUsers()
          } else {
            this.filters.statuses = this.statuses.map(s => s.id)
            this.getUsers()
          }
        })
      },
      getOrgNameForFilter(hierarchy, filterOrgLevelId) {
        const result = hierarchy?.find(({orgLevelId}) => orgLevelId === filterOrgLevelId)
        return result?.orgName ?? 'N/A'
      },
      getOrgIdsForMax(resetSelected) {
        let maxKey = max(Object.keys(this.filters.orgs))
        if(resetSelected){
          this.selectedLevel = parseInt(maxKey)
        }
        console.log('MAX KEY', maxKey)
        return this.filters.orgs && maxKey ? this.filters.orgs[maxKey].map(o => o.id) : []
      },
      getOrgIds() {
        if(this.filters.orgs && this.filters.orgs[this.selectedLevel] && this.filters.orgs[this.selectedLevel].length > 0){
          return this.filters.orgs ? this.filters.orgs[this.selectedLevel].map(o => o.id) : []
        } else {
          return this.getOrgIdsForMax(true)
        }
      },
      handleOrgFilterChange (reset, selectedLevel) {
        this.selectedLevel = selectedLevel
        if(reset) {
          this.filters.orgs = {}
          this.orgFilters = cloneDeep(this.masterOrgFilterList)
        }else {
          Object.keys(this.filters.orgs).forEach(k => {
            if(k > this.selectedLevel) {
              delete this.filters.orgs[k]
            }
          })
          //reload the filters
          this.getOrgFilters()
        }

        //reload the users
        this.getUsers()
      },
      itemChecked(level, item) {
        if(this.filters.orgs[level] && this.filters.orgs[level].length > 0){
          let match = this.filters.orgs[level].find(of => of.id === item.id)
          return match != null
        }else {
          return false;
        }
      }
    }
  }
</script>

<style lang="scss">
  #users-container .v-data-table__wrapper {
    height: calc(100vh - 290px);
    min-height: 300px;
  }
  .filter-input .v-input__slot{
    height: 35px !important;
    min-height: 35px !important;
  }
  .filter-header-non-select {
    padding-bottom: 12px !important;
  }

  .user-filter-select,
  .user-filter-select .v-input__control,
  .user-filter-select .v-input__control .v-input__slot,
  .user-filter-select .v-input__control .v-input__slot fieldset {
    height: 40px !important;
    min-height: 40px !important;
  }
  .user-filter-select .v-select__selections {
    padding: 0 0 5px 0 !important;
    height: 40px !important;
  }
  .user-filter-select .v-input__append-inner {
    margin-top: 5px !important;
  }
</style>

<style lang="scss" scoped>
  #users-container {
    margin-top: -15px;
    padding-left: 0;
    padding-right: 0;
    padding-top: 0;
  }
  .user-table {
    margin-top: 2px;
  }
  .user-column {
    overflow: hidden;
  }


</style>

