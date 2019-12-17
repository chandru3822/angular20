<template>
  <v-container id="roles-container">
    <v-row class="fill-height" align="center" justify="start">
      <v-col class="shrink" cols="12">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">Roles</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text to="/newRoles" color="primary">
              <v-icon>add</v-icon>
              Add Role
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-data-table
            :headers="headers"
            :items="roles"
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
            <tr class="clickable" :class="{'shaded-row': index % 2}" @click="clickRow(item.id)">
              <td class="text-left">{{item.roleName}}</td>
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
        ],
      }
    },
    created () {
      this.getRoles()
    },
    methods: {
      clickRow(id) {
        this.$router.push({name: 'roles', params: {id: id}})
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
      }
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

