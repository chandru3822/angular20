<template>
  <v-container id="roles-container">
    <v-row class="fill-height" align="center" justify="start">
      <v-col class="shrink" cols="12">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">
            <span v-if="roleId">Update Role</span>
            <span v-else>New Role</span>
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text :disabled="!role.roleName" @click="saveRole" color="primary">
              <v-icon>save</v-icon>
              Save
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat class="mt-2 pa-5">
          <v-text-field v-model="role.roleName"
                        placeholder="Enter a value"
                        required
                        label="Role Name">
          </v-text-field>
          <h3>Access Control</h3>
          <v-data-table
              :headers="headers"
              :items="role.companyFeatures"
              :fixed-header="true"
              :items-per-page="-1"
              hide-default-footer
              disable-sort
              class="elevation-1 mt-1"
          >
            <template #no-data>
              No available fields
            </template>

            <template #no-results>
              No available fields
            </template>

            <template #item="{ item, index }">
              <tr :class="{ 'shaded-row': index % 2 }">
                <td class="text-left">{{ item.featureName }}</td>
                <td v-for="acl in item.accessControl">
                  <input type="checkbox" v-model="acl.enabled">
                </td>
              </tr>
            </template>

          </v-data-table>
        </v-card>
      </v-col>
    </v-row>

  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {handleHidingGlobalLoader, getRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'Role',

    data() {
      return {
        snackbar: {},
        role: {},
        roleId: this.$route.params.id,
        features: [],
        accessControlList: [],
        headers: [
          { text: 'Feature', value: 'featureName', show: true },
        ],
      }
    },
    created () {
      if(this.roleId) {
        this.getRole()
      } else {
        this.getFeatures()
      }
    },
    methods: {
      async saveRole() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          if(this.roleId) {
            const {status} = await putRequest(`/role/`, this.role)
            this.$router.push({name: 'role', params: {id: this.roleId}})
            handleHidingGlobalLoader(this, status)
          } else {
            const {data, status} = await postRequest(`/role/`, this.role)
            this.roleId = data.id
            this.$router.push({name: 'role', params: {id: this.roleId}})
            handleHidingGlobalLoader(this, status)
          }
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Role')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }

      },
      populateHeaders () {
        //todo. not my favorite
        this.role.companyFeatures[0]?.accessControl?.forEach(acl => {
          this.headers.push({
            text: acl.accessLevel,
            value: acl.accessCode,
            show: true
          })
        })
      },
      async getFeatures() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/feature/withAccess`)
          this.role.companyFeatures = data
          this.populateHeaders()
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Features')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getRole() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/role/${this.roleId}`)
          this.role = data
          this.populateHeaders()
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Role')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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

