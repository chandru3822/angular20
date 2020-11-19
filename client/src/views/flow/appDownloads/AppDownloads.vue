<template>
  <v-container>
    <v-toolbar flat class="app-toolbar">
      <v-toolbar-title class="app-title">Apps</v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
      </v-toolbar-items>
    </v-toolbar>
    <v-row>
      <v-col cols="12" md="6">
        <AppList :apps="apps" :user-can-edit="userCanEdit" :is-ios="true"></AppList>
      </v-col>
      <v-col cols="12" md="6">
        <AppList :apps="apps" :user-can-edit="userCanEdit" :is-ios="false"></AppList>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import {getRequest, deleteRequest, putRequest, postRequest, getRequestWithParams, getSnackbar} from '@/helpers/helpers'
import Vue2Filters from "vue2-filters";
import constants from '@/helpers/constants'
import AppList from '@/views/flow/appDownloads/AppList'

export default {
  name: 'AppDownloads',
  mixins: [Vue2Filters.mixin],
  components: {
    AppList
  },
  data () {
    return {
      snackbar: {},
      constants,
      apps: [],
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
      headers: [
        {text: 'Filename', value: 'filename', show: true},
        {text: 'Version', value: 'version', show: true},
        {text: 'Created', value: 'dateCreated', show: true},
        {text: '', value: 'icons', show: true},
      ],
    }
  },
  created () {
    this.getApps()
  },
  methods: {
    async getApps() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequestWithParams(`/app`)
        this.apps = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Apps')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteApp(item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await deleteRequest(`/app/${item.id}`)
        item.archived = true
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Apps')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    getFilteredApps(isIos) {
      let sourceId = isIos ? 1 : 3
      //plist: 1 = prod, 2= uat
      //apk: 3 = prod, 4= uat
      return this.apps.filter(a => {
        return this.userCanEdit ? a.sourceId === sourceId && !a.archived : a.sourceId === sourceId && a.show && !a.archived
      })
    },
    getVersion (filename) {
      let match = filename.match(/\b-(\d*.\d*.\d*)-(\d*)/)
      let version = null
      if(match && this.userCanEdit) {
        version = match[1] + ' (' + match[2] + ')'
      } else if (match) {
        version = match[1]
      }
      return match ? version : 'N/A'
    }
  }
}
</script>

<style lang="scss" scoped>

</style>

