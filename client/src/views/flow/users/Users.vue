<template>
  <v-container id="users-container">
    <v-row>
      <v-col xs-12>
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
              <th v-for="header in headers" :key="header.text" class="py-2">
                {{ header.text }}
                <v-select v-model="filters.orgs[header.level]"
                          :items="header.orgs"
                          v-if="header.orgFilter"
                          item-text="orgName"
                          return-object
                          outlined
                          height="25px"
                ></v-select>
                <v-select v-model="filters.statuses"
                          :items="statuses"
                          v-else-if="header.statusFilter"
                          multiple
                          item-text="userStatusType"
                          item-value="id"
                          outlined
                          height="25px"
                          @blur="getUsers()"
                ></v-select>
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
              <td class="text-left">{{item.firstName}}</td>
              <td class="text-left">{{item.lastName}}</td>
              <td class="text-left">{{item.email}}</td>
              <td class="text-left">{{item.phoneNumber}}</td>
              <td class="text-left">{{item.userStatusType}}</td>
              <td class="text-left" v-for="f in orgFilters">
                {{f.title}}
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
        orgFilters: [],
        statuses: [],
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
          { text: 'First Name', value: 'firstName', show: true },
          { text: 'Last Name', value: 'lastName', show: true },
          { text: 'Email', value: 'email', show: true },
          { text: 'Phone', value: 'phone', show: true },
          { text: 'Status', value: 'userStatusType', statusFilter: true, show: true },
        ],
        // search: '',
        filters: {
          search: '',
          firstName: '',
          lastName: '',
          email: '',
          phone: '',
          orgs: {},
          statuses: [1]
        }
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
      this.getOrgFilters()
    },
    methods: {
      clickRow(id){
        this.$router.push({name: 'user', params: {id}})
      },
      debounceGetUsers: debounce( function () {
        this.getUsers()
      }, 500),
      async getUsers () {
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
            page: page - 1,
            size: itemsPerPage
          }
          const {data} = await postRequest(`/user/search`, params)
          this.users = data.content
          this.totalUsers = data.totalElements
          this.dataLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Users')
          this.$store.commit(AppMutations.SET_LOADING, false)
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
      async getOrgFilters () {
        try {
          const {data} = await getRequest(`/org/filters`)
          this.orgFilters = data
          this.orgFilters.forEach(f => {
            this.headers.push({
              text: f.title,
              value: f.title,
              sortable: false,
              show: true,
              level: f.orgLevelId,
              orgFilter: true,
              orgs: f.orgs,
              width: '200px'
            })
          })
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Org Filters')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
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
    }
  }
</script>

<style lang="scss">
  #users-container .v-data-table__wrapper {
    height: calc(100vh - 400px);
    min-height: 300px;
  }
  .filter-input .v-input__slot{
    height: 25px !important;
    min-height: 25px !important;
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


</style>

