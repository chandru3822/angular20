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
        <AccessControl v-if="userAccessLoaded" :companyFeatures="userCompanyFeatures || []" :callback="this.companyFeatureCallback"></AccessControl>
      </v-col>
    </v-row>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import AccessControl from '@/views/flow/settings/components/AccessControl.vue'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'UserAccess',
    components: {
      Snackbar,
      AccessControl
    },
    data() {
      return {
        snackbar: {},
        userId: this.$route.params.id,
        features: [],
        userAccessLoaded: false,
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
      async getUserCompanyFeatures() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/feature/user/${this.userId}`)
          this.userCompanyFeatures = data
          this.userAccessLoaded = true
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
      companyFeatureCallback (newValue) {
        this.userCompanyFeatures = newValue
      },
    }
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>

</style>

