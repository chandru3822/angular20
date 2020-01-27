<template>
  <v-container>
    <v-row class="text-left">
      <v-col>
        <v-toolbar flat color="transparent" class="app-toolbar">
          Access Control
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="saveUserAccess" color="primary">
              <v-icon>save</v-icon>
              Save
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-data-table
            :headers="headers"
            :items="userCompanyFeatures"
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
      </v-col>
    </v-row>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'UserAccess',
    components: {
      Snackbar
    },
    data() {
      return {
        snackbar: {},
        userId: this.$route.params.id,
        features: [],
        userCompanyFeatures: [],
        headers: [
          { text: 'Feature', value: 'featureName', show: true },
        ],
      }
    },
    created () {
      this.getUserCompanyFeatures()
    },
    methods: {
      populateHeaders () {
        //todo. not my favorite
        this.userCompanyFeatures[0]?.accessControl?.forEach(acl => {
          this.headers.push({
            text: acl.accessLevel,
            value: acl.accessCode,
            show: true
          })
        })
      },
      async getUserCompanyFeatures() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/feature/user/${this.userId}`)
          this.userCompanyFeatures = data
          this.populateHeaders()
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving User Access Details')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveUserAccess() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await putRequest(`/feature/user/${this.userId}`, this.userCompanyFeatures)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving User Access Details')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }

      },
    }
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>

</style>

