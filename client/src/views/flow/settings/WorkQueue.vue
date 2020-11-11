<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Work Queue</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items :slot="constants.IS_MOBILE ? 'extension' : 'default'">
            <v-tabs>
              <v-tab :to="`/settings/workQueue/types`">
                Types
              </v-tab>
              <v-tab :to="`/settings/workQueue/categories`">
                Categories
              </v-tab>
            </v-tabs>
          </v-toolbar-items>
        </v-toolbar>
        <router-view/>
      </v-col>
    </v-row>

  </v-container>
</template>


<script>
  import Vue2Filters from 'vue2-filters'

  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'

  export default {
    name: 'WorkQueueAdmin',
    mixins: [Vue2Filters.mixin],

    data() {
      return {
        snackbar: {},
        constants,
      }
    },
    computed: {},
    methods: {
    },
    async created() {
    }
  }
</script>

<style scoped lang="scss">

</style>
