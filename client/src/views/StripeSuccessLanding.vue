<template>
  <v-main>
    <v-container class="fill-height">
      <v-row>
        <v-col cols="12" class="flex-display justify-center">
          <v-card color="secondaryMaster" class="elevation-12">
            <v-toolbar dark color="primary">
              <v-toolbar-title >Payment Successful</v-toolbar-title>
            </v-toolbar>
            <v-card-text>
              <div class="py-4 font-size-16 text-center">
                Deposit Received. <br/>

                <v-btn v-if="isMobile"
                       class="mt-5"
                       color="primary" @click="doAppLaunch()">Return to Albatross</v-btn>
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
  import {getRequest, getSnackbar, handleHidingGlobalLoader, postRequestWithRequestParams} from '@/helpers/helpers'
  import {AppMutations} from '@/stores/AppStore'

  export default {
    name: 'StripeSuccessLanding',
    data () {
      return {
        snackbar: {},
        isMobile: false,
        userAgent: ''
      }
    },
    created () {
      this.userAgent = window.navigator.userAgent
      this.isMobile = this.userAgent && this.userAgent && ['Android', 'iPhone', 'iPad'].some(v => this.userAgent.includes(v))

      //success check is just a dumb little thing to prevent them from refresh the success screen a bunch and making us re-GET the session from stripe each time
      if(null != this.$route.query.sessionId && this.$route.query.success !== 'true') {
        console.log('do stuff')
        this.setStripePaymentId()
      }
    },
    methods: {
      doAppLaunch() {
        let isAndroid = this.userAgent?.includes('Android');
        const appUrl = isAndroid ? "intent://blueraven.com/#Intent;scheme=albatrossapp;package=com.myblueraven.albatross;end"
            : "albatrossapp://";

        window.location.replace(appUrl);
      },
      async setStripePaymentId() {
        try {
          let params = {
            stripeSessionId: this.$route.query.sessionId,
            projectId: parseInt(this.$route.query.projectId),
          }

          const {data, status} = await postRequestWithRequestParams('/stripe/setPaymentId', [], params, 'blueraven')
          //success check is just a dumb little thing to prevent them from refresh the success screen a bunch and making us re-GET the session from stripe each time
          this.$router.replace(this.$route.fullPath + `&success=true`)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error saving payment ID to process step')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.roundRobinRanksLoading = false
        }
      }
    }
  }
</script>


<style scoped lang="scss">
.maintenance-content {

}

</style>
