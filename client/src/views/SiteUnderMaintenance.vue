<template>
  <v-main>
    <v-container class="fill-height">
      <v-row>
        <v-col cols="12">
          <v-card color="secondaryMaster" class="elevation-12">
            <v-toolbar dark color="primaryCustom">
              <v-toolbar-title>Site is Under Maintenance</v-toolbar-title>
            </v-toolbar>
            <v-card-text>
              <router-link :to="`/login`">Back to Login</router-link>
              <div class="py-4 font-size-16">
                Albatross is under maintenance. <br/>
                If you are a mobile user, please watch the training video below. <br/>
                The site will be available again on Monday, Feb 14th.
              </div>
              <div class="text-center one-hunned">
                <video
                  v-for="a in attachments"
                  class="maintenance-c"
                  :key="a.presignedUrl"
                  width="450"
                  height="400"
                  controls
                >
                  <source
                    :src="a.presignedUrl"
                    type="video/mp4"
                  >
                </video>
              </div>
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>

    </v-container>
  </v-main>
</template>

<script>
  import constants from '@/helpers/constants'
  import {handleHidingGlobalLoader, postRequest, getSnackbar, getRequest} from '@/helpers/helpers'
  import {AppMutations} from '@/stores/AppStore'
  import axios from 'axios'

  export default {
    name: 'SiteUnderMaintenance',
    data () {
      return {
        snackbar: {},
        attachments: []
      }
    },
    created () {
      this.getMaintenanceAttachments()
    },
    methods: {
      async getMaintenanceAttachments () {
        try {
          const {data} = await axios.get(`${constants.VUE_APP_BASE_API}/public/maintenanceAttachments`)
          this.attachments = data
        } catch(e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Files')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    }
  }
</script>


<style scoped lang="scss">
.maintenance-content {

}

</style>
