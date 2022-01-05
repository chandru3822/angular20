<template>
  <v-container>
    <v-toolbar flat class="app-toolbar">
      <v-toolbar-title class="app-title">Apps</v-toolbar-title>
      <v-spacer></v-spacer>
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

export default {
  name: 'AppDownloads',
  mixins: [Vue2Filters.mixin],
  components: {
    AppList
  },
  data() {
    return {
      snackbar: {},
      constants,
      apps: [],
      headers: [
        {text: 'Filename', value: 'filename', show: true},
        {text: 'Version', value: 'version', show: true},
        {text: 'Created', value: 'dateCreated', show: true},
        {text: '', value: 'icons', show: true},
      ],
    }
  },
  created() {},
  methods: {}
}
</script>
