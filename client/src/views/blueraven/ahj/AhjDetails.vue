<template>
  <v-container id="ahj-details-container">
    <v-row>
      <v-col cols="12" class="pt-0">
        <v-row justify="space-between">
          <v-col class="text-left pa-0" cols="12">
            <v-btn id="back-btn" text class="pl-1 pr-2" :to="'/ahj'">
              <v-icon>arrow_left</v-icon><span id="back-btn-text">Back to menu</span>
            </v-btn>

            <div class="flex-display justify-space-between align-center px-3 mb-4" style="width: 100%">
              <div class="page-title">AHJ</div>
              <div class="page-info">
                <div>{{ ahj.name }}</div>
                <div>{{ ahj.metroArea }}</div>
                <div>{{ ahj.state }}</div>
              </div>
            </div>

            <v-tabs id="fixed-tabs-bar" class="" background-color="var(--v-secondary-base)">
              <v-tab v-for="(tab, index) in ahjDetailTabs" :key="index" :to="tab.path"
                     class="text-capitalize ma-0"
                     :style="{'margin-left': index === 0 ? '12px !important' : '0'}">
                {{ tab.label }}
              </v-tab>
            </v-tabs>

            <router-view class="px-3" />
          </v-col>
        </v-row>
      </v-col>
    </v-row>
  </v-container>
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
            label: 'Design Requirements',
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
    opacity: 0.95;
    border-top: 1px solid #E6E6E6;
    border-bottom: 1px solid #E6E6E6;
    .v-tab:hover {
      color: var(--v-primaryCustom-base);
    }
  }
  .v-tab--active {
    color: var(--v-primaryCustom-base) !important;
  }
</style>
