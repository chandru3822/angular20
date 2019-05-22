<template>
<v-container grid-list-xl>
  <v-layout row wrap>
    <v-flex xs4>
      <v-sheet color="#fff" class="elevation-2 text-xs-left pa-4 br-10">
        <h2>Preferences</h2>
        <v-subheader>User Profile</v-subheader>
        <v-subheader>Account</v-subheader>
        <h2>Custom UI Components</h2>
        <v-subheader>
          <router-link to="/settings/customFields">Custom Fields</router-link>
        </v-subheader>
        <v-subheader>
          <router-link to="/settings/attachments">Attachments</router-link>
        </v-subheader>
        <v-subheader>
          <router-link to="/settings/links">Links</router-link>
        </v-subheader>
      </v-sheet>
    </v-flex>
    <v-flex xs8>
      <v-sheet color="#fff" class="elevation-2 text-xs-left pa-4 br-10">
        <router-view class="router-view"/>
      </v-sheet>
    </v-flex>
  </v-layout>
</v-container>
</template>

<script>
import {mapState} from 'vuex'
import {AppMutations} from '@/stores/AppStore'

export default {
  name: 'Settings',
  data () {
    return {

    }
  },
  computed: {
  },
  methods: {

  },
  async created () {

  }
}
</script>

<style scoped lang="scss">

</style>
