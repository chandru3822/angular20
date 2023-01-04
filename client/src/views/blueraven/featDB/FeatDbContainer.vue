<template>
  <v-container id="feat-db-container">
    <v-row>
      <v-col cols="12" class="pb-0">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">
            <v-btn v-for="tab in tabs" text :to="tab.path" color="primary"
            :class="{'v-btn--active': isActiveBtn(tab)}" v-if="hasAccess(tab)">
              {{tab.label}}
            </v-btn>
          </v-toolbar-title>
          <v-spacer></v-spacer>
        </v-toolbar>
      </v-col>
    </v-row>
    <router-view></router-view>
  </v-container>
</template>

<script>
  import constants from '@/helpers/constants'
  import {FEAT_DB_TABS} from "@/views/blueraven/featDB/FeatDbConstants";

  export default {
    name: 'featDbContainer',
    data: () => ({
      constants,
      tabs: FEAT_DB_TABS,
    }),
    methods: {
      isActiveBtn(btn) {
        return btn.pathMatches.some(pm => {
          return this.$route.path.includes(pm)
        })
      },

      hasAccess(tab){
        return this.$store.getters.userHasFeatureAccessLevel(tab.label.toUpperCase(), 'VIEW')
      }
    }
  }
</script>

<style lang="scss" scoped>

</style>
