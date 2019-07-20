<template #items="props">
  <v-layout column fill-height>
    <v-flex xs12 shrink>
      <v-layout space-between row fill-height full-width>
        <v-flex xs12 text-xs-left fill-height>
          <v-btn id="back-btn" color="primaryButton" class="white--text my-2" :to="'/ahjUtility'">
            <v-icon dark>arrow_left</v-icon>
            Back to menu
          </v-btn>

          <v-layout row nowrap justify-space-between align-center style="width: 100%">
            <div class="page-title">Utility</div>
            <div class="page-info">
              <div>{{ ahjUtility.name }}</div>
              <div>{{ ahjUtility.metroArea }}, {{ ahjUtility.state }}</div>
            </div>
          </v-layout>

          <v-divider></v-divider>

          <v-tabs>
            <v-tab class="text-capitalize" style="cursor: default" :ripple="false">Details</v-tab>
          </v-tabs>

          <v-divider></v-divider>

          <router-view />
        </v-flex>
      </v-layout>
    </v-flex>
  </v-layout>
</template>

<script>
  import cloneDeep from 'lodash.clonedeep'
  import { getRequest } from '@/helpers/helpers'

  export default {
    name: 'ahjUtilityDetails',
    data: () => ({
      ahjUtility: {}
    }),
    async created () {
      this.ahjUtilityId = parseInt(this.$route.params.ahjUtilityId)
      const {data} = await getRequest(`/api/v1/company/blueraven/ahjUtility/${this.ahjUtilityId}`)
      this.ahjUtility = cloneDeep(data)
      console.log("AHJ Utility:", this.ahjUtility)
    }
  }
</script>

<style scoped lang="scss">
  .page-title {
    font-size: 32px;
    font-weight: 200;
  }
  .page-info {
    font-family: 'Roboto Condensed', sans-serif;
    font-size: 20px;
    text-align: right;
  }
</style>