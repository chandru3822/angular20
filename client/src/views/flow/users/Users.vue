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
              v-model="search"
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
            class="elevation-1 fix-column-width-bug user-table"
        >
          <template #no-data>
            No available users
          </template>

          <template #no-results>
            No available users
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}" @click="clickRow(item.id)">
              <td class="text-left">{{item.firstName}}</td>
              <td class="text-left">{{item.lastName}}</td>
              <td class="text-left">{{item.email}}</td>
              <td class="text-left">{{item.phoneNumber}}</td>
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
        ],
        search: ''
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
    methods: {
      clickRow(id){
        this.$router.push({name: 'user', params: {id}})
      },
      debounceGetUsers: debounce( function () {
        this.dataLoading = true
        this.getUsers()
      }, 500),
      async getUsers () {
        const { sortBy, sortDesc, page, itemsPerPage } = this.options
        try {
          const {data} = await getRequest(`/user/search`, { params: {
              query: this.search,
              page: page - 1,
              size: itemsPerPage
            }})
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
          const {data} = await getRequest(`/user/exportUSERS`, { params: {
              query: this.search
            }})
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
      }
    }
  }
</script>

<style lang="scss">
  #users-container .v-data-table__wrapper {
    height: calc(100vh - 400px);
    min-height: 300px;
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

