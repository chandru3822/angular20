<template>
  <v-container id="permissions-container">
    <v-row class="fill-height" align="center" justify="start">
      <v-col class="shrink" cols="12">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">Permissions</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text to="/newPermissions" color="primary">
              <v-icon>add</v-icon>
              Add Permission
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-data-table
            :headers="headers"
            :items="permissions"
            :fixed-header="true"
            disable-sort
            :items-per-page="-1"
            hide-default-footer
            :loading="dataLoading"
            class="elevation-1 fix-column-width-bug permissions-table"
        >
          <template #no-data>
            No available permissions
          </template>

          <template #no-results>
            No available permissions
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}" @click="clickRow(item.id)">
              <td class="text-left">{{item.permissionName}}</td>
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
  import {saveAs} from 'file-saver'

  export default {
    name: 'Permissions',
    components: {
      Snackbar
    },
    data() {
      return {
        delay: 500,
        dialog: false,
        snackbar: {},
        permissions: [],
        descending: true,
        dataLoading: true,
        headers: [
          {text: 'Permission Name', value: 'permissionName', show: true},
        ],
      }
    },
    created () {
      this.getPermissions()
    },
    methods: {
      clickRow(id) {
        this.$router.push({name: 'permissions', params: {id: id}})
      },
      async getPermissions() {
        try {
          const {data} = await getRequest(`/permission`)
          this.permissions = data
          this.dataLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Permissions')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    }
  }
</script>

<style lang="scss">
  #permissions-container .v-data-table__wrapper {
    height: calc(100vh - 400px);
    min-height: 300px;
  }
</style>

<style lang="scss" scoped>
  #permissions-container {
    margin-top: -15px;
    padding-left: 0;
    padding-right: 0;
    padding-top: 0;
  }

  .permissions-table {
    margin-top: 2px;
  }

</style>

