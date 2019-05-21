<template #items="props">
  <v-layout column fill-height>
    <v-flex xs12 shrink>
      <v-layout align-center row fill-height style="width: 100%">
        <v-flex xs12 text-xs-left fill-height>
          <v-btn color="info" :to="'/ahj'">
            <v-icon>arrow_left</v-icon>Back to menu
          </v-btn>

          <v-layout row nowrap align-center style="width: 100%">
            <p style="font-size: 32px; font-weight: 200;">AHJ</p>
            <p style="font-family: 'Roboto Condensed', sans-serif; font-size: 20px; text-align: right;">
              {{ testAhj.name }}<br>
              {{ testAhj.metroArea }}<br>
              {{ testAhj.state }}
            </p>
          </v-layout>

          <v-divider></v-divider>

          <v-tabs color="transparent">
            <v-tab v-for="(tab, index) in ahjDetailTabs" :key="index" :to="tab.path" class="text-capitalize">
              {{ tab.label }}
            </v-tab>
          </v-tabs>

          <v-divider></v-divider>

          <router-view></router-view>
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
        name: 'Conejo County',
        metroArea: 'Colorado Springs',
        state: 'Denver'
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