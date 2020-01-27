<template>
  <v-row>
    <v-col cols="12">
      <v-row justify="space-between">
        <v-col class="text-left" cols="12">
          <v-btn id="back-btn" color="primaryButton" class="white--text my-2" :to="'/ahjUtility'">
            <v-icon dark>arrow_left</v-icon>
            Back to menu
          </v-btn>

          <v-row justify="space-between" align="center" no-gutters>
            <div class="page-title">Utility</div>
            <div class="page-info">
              <div>{{ ahjUtility.name }}</div>
              <div>{{ ahjUtility.metroArea }}, {{ ahjUtility.state }}</div>
            </div>
          </v-row>

          <v-divider></v-divider>

          <v-tabs background-color="rgba(0,0,0,0)">
            <v-tab style="cursor: default" :ripple="false" class="text-capitalize ma-0">Details</v-tab>
          </v-tabs>

          <v-divider></v-divider>

          <router-view />
        </v-col>
      </v-row>
    </v-col>
  </v-row>
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
      const {data} = await getRequest(`/ahjUtility/${this.ahjUtilityId}`, 'blueraven')
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
