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
                Albatross is under maintenance. <br/><br/>
                The site will be available again on Monday, Feb 14th.<br/><br/>

                If you’re a mobile user please watch your training video below:<br/><br/>
                Setters: <a target="_blank" href="https://www.screencast.com/t/ciilzrVome">https://www.screencast.com/t/ciilzrVome</a><br/><br/>
                Closers: <a target="_blank" href="https://www .screencast.com/t/wZqOQ3oSj">https://www .screencast.com/t/wZqOQ3oSj</a><br/><br/>
                Installers: <a target="_blank" href="https://www.screencast.com/t/rSuSwmqOUD">https://www.screencast.com/t/rSuSwmqOUD</a><br/><br/>
                Site Surveyors: <a target="_blank" href="https://www.screencast.com/t/ab3SnJTpxqw">https://www.screencast.com/t/ab3SnJTpxqw</a><br/><br/>
                AHJ Inspections: <a target="_blank" href="https://www.screencast.com/t/HrhoSk7Hs5">https://www.screencast.com/t/HrhoSk7Hs5</a><br/><br/>
                Work Orders: <a target="_blank" href="https://www.screencast.com/t/yvYxZ4fOT">https://www.screencast.com/t/yvYxZ4fOT</a>
              </div>
<!--              <div class="text-center one-hunned">-->
<!--                <video-->
<!--                  v-for="a in attachments"-->
<!--                  class="maintenance-c"-->
<!--                  :key="a.presignedUrl"-->
<!--                  width="450"-->
<!--                  height="400"-->
<!--                  controls-->
<!--                >-->
<!--                  <source-->
<!--                    :src="a.presignedUrl"-->
<!--                    type="video/mp4"-->
<!--                  >-->
<!--                </video>-->
<!--              </div>-->
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
      //they decided they wanted to show links
      // this.getMaintenanceAttachments()
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
