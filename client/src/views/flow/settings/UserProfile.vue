<template>
  <v-layout row wrap class="custom-field-group-container">
    <v-flex xs-12>
      <v-toolbar color="white" class="elevation-1">
        <v-toolbar-title class="app-title">User Profile</v-toolbar-title>
      </v-toolbar>
      <v-container>
        <div class="pt-5">
          Changing the timezone in the account menu should change this value:
        </div>
        <div class="pt-5 font-weight-bold">
          {{ timeValue | formatDate('timestamp', $store.state.user.details.timezone) }}
        </div>

      </v-container>
    </v-flex>
  </v-layout>
</template>


<script>
import {mapState} from 'vuex'
import {AppMutations} from '@/stores/AppStore'
import {getRequest, deleteRequest, putRequest, postRequest} from '@/helpers/helpers'

export default {
  name: 'UserProfile',
  data () {
    return {
      timeValue: '2014-06-01T12:00:00Z'
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
