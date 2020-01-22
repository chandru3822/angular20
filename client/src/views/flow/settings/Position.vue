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
            <v-btn text :disabled="!position.position || !position.orgTypeId" @click="savePosition" color="primary">
              <v-icon>save</v-icon>
              Save
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat class="mt-2 pa-5">
          <v-text-field v-model="position.position"
                        placeholder="Enter a value"
                        required
                        label="Position Name">
          </v-text-field>
          <v-select
              v-model="position.orgTypeId"
              :items="orgTypes"
              label="Organization Type"
              item-text="orgType"
              item-value="id"
          ></v-select>
          <h3>Access Control</h3>
          <v-data-table
              :headers="headers"
              :items="position.companyFeatures"
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
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import {getOrgTypes} from '@/services/orgService'
  import {getRequest, getRequestWithParams, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'Position',
    components: {
      Snackbar
    },
    data() {
      return {
        snackbar: {},
        position: {},
        orgTypes: [],
        positionId: this.$route.params.id,
        features: [],
        accessControlList: [],
        headers: [
          { text: 'Feature', value: 'featureName', show: true },

        ],
      }
    },
    created () {
      if(this.positionId) {
        this.getPosition()
      } else {
        this.getFeatures()
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
      populateHeaders () {
        //todo. not my favorite
        this.position.companyFeatures[0]?.accessControl?.forEach(acl => {
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
          const {data} = await getRequest(`/feature/withAccess`)
          this.position.companyFeatures = data
          this.populateHeaders()
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Features')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getPosition() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/position/${this.positionId}`)
          this.position = data
          this.populateHeaders()
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Position')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
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

