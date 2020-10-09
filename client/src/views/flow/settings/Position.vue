<template>
  <v-container id="positions-container">
    <v-row class="fill-height" align="center" justify="start">
      <v-col class="shrink" cols="12">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">
            <span v-if="positionId">Update Position</span>
            <span v-else>New Position</span>
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text :disabled="!position.position || !position.orgTypeId" @click="savePosition" color="primaryCustom" v-if="userCanEdit || userCanEditAccessControl">
              <v-icon>save</v-icon>
              Save
            </v-btn>
            <v-btn text @click="$router.push('/settings/positions')">
              <v-icon>close</v-icon>
              Close
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat class="mt-2 pa-5">
          <v-text-field v-model="position.position"
                        placeholder="Enter a value"
                        required
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        label="Position Name">
          </v-text-field>
          <v-select
              v-model="position.orgTypeId"
              :items="orgTypes"
              :readonly="!userCanEdit"
              :disabled="!userCanEdit"
              label="Organization Type"
              item-text="orgType"
              item-value="id"
          ></v-select>
          <div class="mb-3">
            <label>Show in Scheduling Tool:</label>
            <input type="checkbox" :disabled="!userCanEdit" class="ml-3" v-model="position.schedulable">
          </div>
          <div v-if="$store.getters.isParent(parentId)">
            <label>Make Available in Children</label>
            <input type="checkbox" class="ml-3" v-model="position.availableToChildren">
          </div>
          <v-divider class="my-2"></v-divider>
          <h3>Access Control</h3>
          <AccessControl v-if="positionLoaded"
                         :user-can-edit="userCanEditAccessControl"
                         :companyFeatures="position.companyFeatures || []" :callback="this.companyFeatureCallback"></AccessControl>
        </v-card>

      </v-col>
    </v-row>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import {getOrgTypes} from '@/services/orgService'
  import AccessControl from '@/views/flow/settings/components/AccessControl.vue'
  import {getRequest, getRequestWithParams, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'Position',
    components: {
      Snackbar,
      AccessControl
    },
    watch: {
      'selectedRows': function () {
        this.alterEnabledFlagForRows()
      }
    },
    data() {
      return {
        snackbar: {},
        position: {},
        selectedRows: [],
        positionLoaded: false,
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
        userCanEditAccessControl: this.$store.getters.userHasFeatureAccessLevel('ACCESS_CONTROL', 'EDIT'),
        orgTypes: [],
        positionId: this.$route.params.id,
        features: [],
        accessControlList: [],
        parentId: this.$store.state.user.details.parentCompanyId,
        headers: [
          { text: 'Feature', value: 'featureName', show: true },

        ],
      }
    },
    created () {
      if(this.positionId) {
        this.getPosition()
      } else {
        this.positionLoaded = true
      }
      this.getOrgTypes()
    },
    methods: {
      async getOrgTypes () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getOrgTypes()
          this.orgTypes = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Org Types')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async savePosition() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          if(this.positionId) {
            const {data} = await putRequest(`/position/`, this.position)
            this.$router.push({name: 'position', params: {id: this.positionId}})
          } else {
            const {data} = await postRequest(`/position/`, this.position)
            this.positionId = data.id
            this.$router.push({name: 'position', params: {id: this.positionId}})
          }
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Position')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }

      },
      async getPosition() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/position/${this.positionId}`)
          this.position = data
          this.positionLoaded = true
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Position')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      companyFeatureCallback (newValue) {
        this.position.companyFeatures = newValue
      },
    }
  }
</script>

<style lang="scss">
  #positions-container .v-data-table__wrapper {
    height: calc(100vh - 400px);
    min-height: 300px;
  }
</style>

<style lang="scss" scoped>
  #positions-container {
    margin-top: -15px;
    padding-left: 0;
    padding-right: 0;
    padding-top: 0;
  }

  .positions-table {
    margin-top: 2px;
  }

</style>

