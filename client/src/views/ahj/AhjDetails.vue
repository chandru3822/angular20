<template #items="props">
  <v-layout column fill-height>
    <v-flex xs12 shrink>
      <v-layout space-between row fill-height full-width>
        <v-flex xs12 text-xs-left fill-height>
          <v-btn id="back-btn" dark color="info" :to="'/ahj'">
            <v-icon dark>arrow_left</v-icon>
            Back to menu
          </v-btn>

          <v-layout row nowrap justify-space-between align-center style="width: 100%">
            <div class="page-title">AHJ</div>
            <div class="page-info">
              <div>{{ testAhj.name }}</div>
              <div>{{ testAhj.metroArea }}</div>
              <div>{{ testAhj.state }}</div>
            </div>
          </v-layout>

          <v-divider></v-divider>

          <v-tabs color="transparent">
            <v-tab v-for="(tab, index) in ahjDetailTabs" :key="index" :to="tab.path" class="text-capitalize">
              {{ tab.label }}
            </v-tab>
          </v-tabs>

          <v-divider></v-divider>

          <router-view />
        </v-flex>
      </v-layout>
    </v-flex>
  </v-layout>
</template>

<script>
  export default {
    name: 'ahjDetails',
    data: () => ({
      testAhj: {
        name: 'Conejos County',
        metroArea: 'Colorado Springs',
        state: 'Colorado'
      }
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
    created () {
      this.ahjId = this.$route.params.ahjId
    }
  }
</script>

<style scoped lang="scss">
  #back-btn {
    margin: 5px 0 0 0;
  }
  @media (min-width: 769px) {
    #back-btn {
      margin: 20px 0 0 0;
    }
  }
  @media (min-width: 960px) {
    #back-btn {
      margin: 12px 0 0 0;
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
</style>