<template>
  <v-layout row wrap>
    <v-flex xs-12>
      <h2>Custom Fields</h2>
        <v-tabs
            background-color="#fff"
            color="primaryText"
            slider-color="#1F3C73"
        >
          <v-tab v-for="(tab, index) in customFieldTabs" :key="index" :to="tab.path">
            {{tab.label}}
          </v-tab>
        </v-tabs>
      <router-view class="router-view"/>
    </v-flex>
  </v-layout>
</template>

<script>
import {mapState} from 'vuex'
import {AppMutations} from '@/stores/AppStore'

export default {
  name: 'CustomFields',
  data () {
    return {
      model: '',
      tabs: [{
        label: 'Project',
        path: '/settings/customFields/project',
        display: true
      }, {
        label: 'Customer',
        path: '/settings/customFields/customer',
        display: true
      }, {
        label: 'Process Steps',
        path: '/settings/customFields/processSteps',
        display: true
      }, {
        label: 'User',
        path: '/settings/customFields/user',
        display: true
      }]
    }
  },
  computed: {
  },
  methods: {

  },
  async created () {

  },
  computed: {
    customFieldTabs () {
      return this.tabs.filter(tab => tab.display)
    }
  },
}
</script>

<style scoped lang="scss">

</style>
