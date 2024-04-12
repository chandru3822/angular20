<template>
  <v-main>
    <v-container class="fill-height">
      <v-row>
        <v-col cols="12" class="flex-display justify-center">
          <v-card color="secondaryMaster" class="elevation-12">
            <v-toolbar dark color="primary">
              <v-toolbar-title>Payment Successful</v-toolbar-title>
            </v-toolbar>
            <v-card-text>
              <div class="py-4 font-size-16 text-center">
                Deposit Received. <br/>

                <a-btn v-if="isMobile"
                       class="mt-5" text="Return to Albatross"
                       @click="doAppLaunch()" />
              </div>

            </v-card-text>
          </v-card>
        </v-col>
      </v-row>

    </v-container>
  </v-main>
</template>

<script setup>
import {handleHidingGlobalLoader, postRequestWithRequestParams} from '@/helpers/helpers'
import {getCurrentInstance, onMounted, ref} from "vue";

import {useRouter, useRoute} from "vue-router/composables"

const vueInstance = getCurrentInstance().proxy
const route = useRoute()
const router = useRouter()
const snackbar = vueInstance.$snackbar

const isMobile = ref(false)
const userAgent = ref('')

onMounted(() => {
  userAgent.value = window.navigator.userAgent
  isMobile.value = userAgent.value && userAgent.value && ['Android', 'iPhone', 'iPad'].some(v => userAgent.value.includes(v))

  //success check is just a dumb little thing to prevent them from refresh the success screen a bunch and making us re-GET the session from stripe each time
  if (null != route.query.sessionId && route.query.success !== 'true') {
    setStripePaymentId()
  }
})

const doAppLaunch = () => {
  let isAndroid = userAgent.value?.includes('Android');
  const appUrl = isAndroid ? "intent://blueraven.com/#Intent;scheme=albatrossapp;package=com.myblueraven.albatross;end"
      : "albatrossapp://";

  window.location.replace(appUrl);
}

const setStripePaymentId = async() => {
  try {
    let params = {
      stripeSessionId: route.query.sessionId,
      projectId: parseInt(route.query.projectId),
    }

    const {data, status} = await postRequestWithRequestParams('/stripe/setPaymentId', [], params, 'blueraven')
    //success check is just a dumb little thing to prevent them from refresh the success screen a bunch and making us re-GET the session from stripe each time
    router.replace(route.fullPath + `&success=true`)
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error saving payment ID to process step')
  }
}
</script>


<style scoped lang="scss">
.maintenance-content {

}

</style>
