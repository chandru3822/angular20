<template>
  <v-container>
    <v-row>
      <v-col cols="12" md="3" class="text-left">
        <v-menu data-app left
                v-if="constants.IS_MOBILE"
                offset-y
                v-model="menuOpen"
                max-height="350"
                class="account-menu"
                :close-on-content-click="false">
          <template v-slot:activator="{ on }">
            <v-toolbar
                   color="white"
                   v-on="on"
            >
              {{ title }}
              <v-spacer></v-spacer>
              <v-btn text>
                <v-icon>expand_more</v-icon>
              </v-btn>
            </v-toolbar>
          </template>
          <v-list dense class="pa-3">
            <template v-for="item in filterBy(items, true, 'show')">
              <h3 v-if="item.header" :key="item.title">{{item.header}}</h3>

              <v-list-item
                  v-else
                  :key="item.title"
                  :to="item.path"
                  :class="{'shaded-row': item.pathMatch ? $route.path.includes(`${item.pathMatch}`) : $route.path === item.path}"
                  @click="menuOpen = false; setTitle(item.title)"
              >
                <v-list-item-content>
                  <v-list-item-title>{{item.title}}</v-list-item-title>
                </v-list-item-content>
              </v-list-item>
            </template>
          </v-list>
        </v-menu>
        <v-card class="px-5 py-2" v-else>
          <v-list dense>
            <template v-for="item in filterBy(items, true, 'show')">
              <h3 v-if="item.header" :key="item.title">{{item.header}}</h3>

              <v-list-item
                  v-else
                  :key="item.title"
                  @click="title = item.title"
                  :to="item.path"
                  :class="{'shaded-row': item.pathMatch ? $route.path.includes(`${item.pathMatch}`) : $route.path === item.path}"
              >
                <v-list-item-content>
                  <v-list-item-title>{{item.title}}</v-list-item-title>
                </v-list-item-content>
              </v-list-item>
            </template>
          </v-list>
        </v-card>
      </v-col>
      <v-col cols="12" md="9" class="pa-4">
        <v-sheet color="#fff" class="elevation-2 text-left">
          <router-view/>
        </v-sheet>
      </v-col>
    </v-row>

  </v-container>
</template>

<script>

import Vue2Filters from 'vue2-filters'
import constants from '@/helpers/constants'

export default {
  name: 'Menu',
  mixins: [Vue2Filters.mixin],

  data () {
    return {
      snackbar: {},
      menuOpen: false,
      constants,
      companyId: this.$store.state.user.details.companyId,
      parentId: this.$store.state.user.details.parentCompanyId,

    }
  },
  computed: {
    items() { return [
      {
        header: 'Proposal Tool',
        show: true
      }, {
        path: '/proposal/create',
        title: 'Create New Proposal',
        show: this.$store.getters.userHasFeatureAccessLevel('PROPOSALS', 'ADD')
      }, {
        path: '/proposal/search',
        title: 'Search Proposals',
        show: this.$store.getters.userHasFeatureAccessLevel('PROPOSALS', 'VIEW')
      }, {
        path: '/proposal/export',
        title: 'Export Proposal Log',
        show: this.$store.getters.userHasFeatureAccessLevel('PROPOSALS', 'VIEW')
      }, {
        path: '/proposal/recreate',
        title: 'Recreate Proposal',
        show: this.$store.getters.userHasFeatureAccessLevel('PROPOSALS', 'ADD')
      }
    ]
  }
  },
  methods: {

  },
  created () {

  }
}
</script>

<style scoped lang="scss">

a {
  text-decoration: none;
}
</style>
