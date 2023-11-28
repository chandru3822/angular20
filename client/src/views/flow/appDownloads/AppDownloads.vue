<template>
  <v-container>
    <v-toolbar flat class="app-toolbar">
      <v-toolbar-title class="app-title">Apps</v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <v-menu v-if="isAdmin"
            v-model="buildMenu"
            bottom
            offset-y
            min-width="350"
            :close-on-content-click="false"
        >
          <template #activator="{on}">
            <v-btn v-on="on" text color="primary">
              Build App
            </v-btn>
          </template>

          <v-card class="pa-5">
            <!--    cant change this part cuz the steps used are different depending on if the user is an admin or not -->
            <v-autocomplete v-model="newBuild.branch"
                            :items="branches"
                            label="Branch"
                            placeholder="Select one..."
            />
            <v-autocomplete v-model="newBuild.dataSource"
                            :items="dataSources"
                            label="Pointed At Data Source"
                            placeholder="Select one..."
            />
            <v-text-field v-model="newBuild.version"
                          persistent-hint
                          hint="example 2.0.1"
                          placeholder="Version..."/>

            <v-btn class="mt-3"
                :disabled="!newBuild.branch || !newBuild.dataSource || !newBuild.version"
                @click="testBuild"
            >
              Start Build
            </v-btn>
          </v-card>
        </v-menu>
      </v-toolbar-items>
    </v-toolbar>
    <v-row>
      <v-col cols="12" md="6">
        <AppList :apps="apps" :is-ios="true"></AppList>
      </v-col>
      <v-col cols="12" md="6">
        <AppList :apps="apps" :is-ios="false"></AppList>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import Vue2Filters from "vue2-filters";
import constants from '@/helpers/constants'
import AppList from '@/views/flow/appDownloads/AppList'
import {getSnackbar, handleHidingGlobalLoader, putRequest, postRequest } from "@/helpers/helpers";
import {AppMutations} from "@/stores/AppStore";

export default {
  name: 'AppDownloads',
  mixins: [Vue2Filters.mixin],
  components: {
    AppList
  },
  data() {
    return {
      snackbar: {},
      newBuild: {
        version: '0.0.0'
      },
      constants,
      buildMenu: false,
      apps: [],
      is7oaksAdmin: this.$store.getters.isFullAdmin,
      isAdmin: this.$store.getters.userHasFeatureAccessLevel('APP_DOWNLOADS', 'ADMIN'),
      branches: ['stage', 'uat', 'master'],
      dataSources: ['stage', 'uat', 'prod', 'flux'],
      headers: [
        {text: 'Filename', value: 'filename', show: true},
        {text: 'Version', value: 'version', show: true},
        {text: 'Created', value: 'dateCreated', show: true},
        {text: '', value: 'icons', show: true},
      ],
    }
  },
  created() {
    if(this.is7oaksAdmin) {
      this.branches.push('develop')
    }
  },
  methods: {
    async testBuild() {
      try {
        let params = {
          version: this.newBuild.version,
          branch: this.newBuild.branch,
          dataSource: this.newBuild.dataSource
        }
        const {status} = await postRequest(`/bitrise/build`, params, 'blueraven')
        this.snackbar = getSnackbar('SUCCESS', 'Build Succeeded')
        this.buildMenu = false
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Building App')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
  }
}
</script>
