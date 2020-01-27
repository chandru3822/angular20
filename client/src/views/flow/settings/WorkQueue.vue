<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!IS_MOBILE" class="app-title">Work Queue</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items :slot="IS_MOBILE ? 'extension' : 'default'">
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
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>


<script>
  import Vue2Filters from 'vue2-filters'
  import Snackbar from '@/components/Snackbar.vue'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar, IS_MOBILE} from '@/helpers/helpers'

  export default {
    name: 'Works',
    mixins: [Vue2Filters.mixin],
    components: {
      Snackbar
    },
    data() {
      return {
        snackbar: {},
        IS_MOBILE,
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
