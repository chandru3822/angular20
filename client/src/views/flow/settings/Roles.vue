<template>
  <v-container id="roles-container">
    <v-row class="fill-height" align="center" justify="start">
      <v-col class="shrink" cols="12">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">Roles</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text to="/settings/role" color="primary">
              <v-icon>add</v-icon>
              Add Role
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-data-table
            :headers="headers"
            :items="filterRoles()"
            :fixed-header="true"
            disable-sort
            :items-per-page="-1"
            hide-default-footer
            :loading="dataLoading"
            class="elevation-1 fix-column-width-bug roles-table"
        >
          <template #no-data>
            No available roles
          </template>

          <template #no-results>
            No available roles
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}" @click="">
              <td class="text-left">{{item.roleName}}</td>
              <!-- icon column -->
              <td class="text-right">
                <v-btn text @click="clickRow(item.id)">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-dialog
                    v-model="item.deleteConfirm"
                    width="500">
                  <template v-slot:activator="{ on }">
                    <v-btn text v-on="on">
                      <v-icon>delete</v-icon>
                    </v-btn>
                  </template>
                  <v-card>
                    <v-card-title
                        class="headline grey lighten-2"
                        primary-title
                    >
                      Confirm
                    </v-card-title>

                    <v-card-text>
                      Are you sure you want to delete this role: <strong>{{ item.roleName }}</strong>?
                    </v-card-text>

                    <v-divider></v-divider>

                    <v-card-actions>
                      <v-spacer></v-spacer>
                      <v-btn
                          @click="item.deleteConfirm = false">
                        No
                      </v-btn>
                      <v-btn
                          color="primary"
                          text
                          @click="item.archived = true; deleteRole(item.id)">
                        Yes
                      </v-btn>
                    </v-card-actions>
                  </v-card>
                </v-dialog>
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
  import {getRequest, getRequestWithParams, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import debounce from 'lodash.debounce'

  export default {
    name: 'Roles',
    components: {
      Snackbar
    },
    data() {
      return {
        delay: 500,
        dialog: false,
        snackbar: {},
        roles: [],
        descending: true,
        dataLoading: true,
        headers: [
          {text: 'Role Name', value: 'roleName', show: true},
          { text: null, value: 'icons', show: true }
        ],
      }
    },
    created () {
      this.getRoles()
    },
    methods: {
      clickRow(id) {
        this.$router.push({name: 'role', params: {id: id}})
      },
      async getRoles() {
        try {
          const {data} = await getRequest(`/role`)
          this.roles = data
          this.dataLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Roles')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteRole(id) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/role/${id}`)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Role')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterRoles () {
        return this.roles.filter(r => { return !r.archived})
      },
    }
  }
</script>

<style lang="scss">
  #roles-container .v-data-table__wrapper {
    height: calc(100vh - 400px);
    min-height: 300px;
  }
</style>

<style lang="scss" scoped>
  #roles-container {
    margin-top: -15px;
    padding-left: 0;
    padding-right: 0;
    padding-top: 0;
  }

  .roles-table {
    margin-top: 2px;
  }

</style>

