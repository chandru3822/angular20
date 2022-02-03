<template>
  <v-main>
    <v-container class="fill-height">
      <v-row>
        <v-col cols="12">
          <v-card color="secondaryMaster" class="elevation-12">
            <v-toolbar dark color="primaryCustom">
              <v-toolbar-title>Site is Under Maintenance</v-toolbar-title>
            </v-toolbar>
            <v-card-text class="login-card-text">
              please check back later
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>

    </v-container>
  </v-main>
</template>

<script>
  import constants from '@/helpers/constants'
  import {handleHidingGlobalLoader, postRequest, getSnackbar} from '@/helpers/helpers'
  import {AppMutations} from '@/stores/AppStore'

  export default {
    name: 'SiteUnderMaintenance',
    data () {
      return {
        snackbar: {},
      }
    },
    methods: {

    }
  }
</script>
