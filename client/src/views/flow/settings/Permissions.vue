<template>
  <v-container id="permissions-container">
    <v-row class="fill-height" align="center" justify="start">
      <v-col class="shrink" cols="12">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">Permissions</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" v-if="$store.getters.hasPermission('SYSTEM_ADMIN')" @click="addPermission = !addPermission">
              <v-icon>add</v-icon>
              Add Permission
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card class="mt-2 pa-4"flat v-if="addPermission">
          Add Permission
          <v-text-field text
                        label="Name"
                        placeholder=" "
                        v-model="newPermission.permissionName"></v-text-field>
          <v-text-field text
                        label="Code"
                        placeholder=" "
                        v-model="newPermission.permissionCode"></v-text-field>
          <v-btn color="primary" class="white--text mr-3" @click="savePermission(newPermission)"
                 :disabled="!newPermission.permissionName || !newPermission.permissionCode">Save</v-btn>
          <v-btn @click="newPermission = {}; addPermission = !addPermission">Cancel</v-btn>
        </v-card>
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
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.permissionName}}</td>
              <td class="text-left" v-if="$store.getters.hasPermission('SYSTEM_ADMIN')">{{item.permissionCode}}</td>
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
  import orderBy from 'lodash.orderby'
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
        addPermission: false,
        newPermission: {},
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
      if(this.$store.getters.hasPermission('SYSTEM_ADMIN')) {
        this.headers.push({ text: 'Permission Code', value: 'permissionCode'})
      }
    },
    methods: {
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
      },
      async savePermission (p) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await putRequest(`/permission`, p)
          this.addPermission = false
          this.newPermission = {}
          this.permissions.push(data)
          this.permissions = orderBy(this.permissions, [a => a.permissionName.toLowerCase()])
          this.snackbar = getSnackbar('SUCCESS', 'Permission Saved')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Permission')
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

