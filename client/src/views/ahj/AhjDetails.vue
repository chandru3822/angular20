<template>
  <v-row>
    <v-col cols="12">
      <v-row justify="space-between">
        <v-col class="text-left" cols="12">
          <v-btn id="back-btn" text class="pl-0 pr-2" :to="'/ahj'">
            <v-icon>arrow_left</v-icon><span id="back-btn-text">Back to menu</span>
          </v-btn>

          <v-row justify="space-between" align="center" no-gutters>
            <div class="page-title">AHJ</div>
            <div class="page-info">
              <div>{{ ahj.name }}</div>
              <div>{{ ahj.metroArea }}</div>
              <div>{{ ahj.state }}</div>
            </div>
          </v-row>

          <v-divider></v-divider>

          <v-tabs id="fixed-tabs-bar" background-color="rgba(0,0,0,0)">
            <v-tab v-for="(tab, index) in ahjDetailTabs" :key="index" :to="tab.path" class="text-capitalize ma-0">
              {{ tab.label }}
            </v-tab>
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
    name: 'ahjDetails',
    data: () => ({
      ahj: {}
    }),
    computed: {
      ahjDetailTabs () {
        return [
          {
            label: 'Permitting',
            path: '/ahj/' + this.ahjId + '/permit',
          },
          {
            label: 'Inspection',
            path: '/ahj/' + this.ahjId + '/inspection'
          },
          {
            label: 'Design',
            path: '/ahj/' + this.ahjId + '/design'
          }
        ]
      }
    },
    async created () {
      this.ahjId = parseInt(this.$route.params.ahjId)
      const {data} = await getRequest(`/ahj/${this.ahjId}`, 'blueraven')
      this.ahj = cloneDeep(data)
    }
  }
</script>

<style scoped lang="scss">
  #back-btn {
    text-transform: unset;
    letter-spacing: unset;
    &:before {
      background-color: initial;
    }
    #back-btn-text:hover {
      text-decoration: underline;
    }
  }
  .page-title {
    font-size: 32px;
    font-weight: 200;
  }
  .page-info {
    font-family: 'Roboto Condensed', sans-serif;
    font-size: 20px;
    text-align: right;
  }
  #fixed-tabs-bar {
    position: sticky;
    top: -12px;
    z-index: 2;
    background-color: var(--v-secondary-base) !important;
  }
  .v-tab--active {
    color: var(--v-primaryCustom-base) !important;
  }
</style>
