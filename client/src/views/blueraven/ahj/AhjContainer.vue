<template>
  <v-container id="ahj-container">
    <v-row>
      <v-col cols="12" class="pb-0">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">
            <v-btn v-for="tab in tabs" text :to="tab.path" color="primary"
            :class="{'v-btn--active': isActiveBtn(tab)}">
              {{tab.label}}
            </v-btn>
          </v-toolbar-title>
          <v-spacer></v-spacer>
<!--          <v-toolbar-items>-->
<!--            <v-btn text @click="addItem" color="primary" v-if="$store.getters.userHasFeatureAccessLevel('AHJ_DATABASE', 'ADD')">-->
<!--              <v-icon>add</v-icon>-->
<!--              <span v-if="!constants.IS_MOBILE">Add New</span>-->
<!--            </v-btn>-->
<!--          </v-toolbar-items>-->
        </v-toolbar>
      </v-col>
    </v-row>
    <router-view></router-view>
  </v-container>
</template>

<script>
  import constants from '@/helpers/constants'
  import {AHJ_TABS} from "@/views/blueraven/ahj/AhjConstants";

  export default {
    name: 'ahjContainer',
    data: () => ({
      constants,
      tabs: AHJ_TABS,
    }),
    methods: {
      isActiveBtn(btn) {
        return btn.pathMatches.some(pm => {
          return this.$route.path.includes(pm)
        })
        // if(this.$route.path.includes())
        // return false
      }
    }
  }
</script>

<style lang="scss" scoped>

</style>
