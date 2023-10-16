<template>
  <v-list :dense="$vuetify.breakpoint.smAndUp" :color="$vuetify.breakpoint.smAndDown ? 'grey lighten-4' : 'transparent'" :class="{'left-menu' : $vuetify.breakpoint.smAndDown}">
    <template v-for="(item, index) in filterBy(menuList, true, 'show')">
      <h3 class="label-large" v-if="item.header">{{item.header}}</h3>
      <v-list-item
          v-else
          :key="item.title"
          @click="selectMenuItem(item.title)"
          :to="item.path"
          class="dense-setting-row"
          :class="{'shaded-row': item.pathMatch && item.pathMatchExclude ? $route.path.includes(`${item.pathMatch}`) && !$route.path.includes(item.pathMatchExclude)
                                          : item.pathMatch ? $route.path.includes(`${item.pathMatch}`) : $route.path === item.path}"
      >
        <v-list-item-content>
          <v-list-item-title class="body-medium">{{item.title}}</v-list-item-title>
        </v-list-item-content>
      </v-list-item>
    </template>
    <v-list-item :dense="$vuetify.breakpoint.smAndDown" v-for="o in filterBy(companyObjectItems, (cot) => { return [1,3,4,5].includes(cot.flowTypeId) })" :key="o.id"
                 :to="{ path: o.flowTypeId === 3 ? `/settings/project/customFieldGroups?companyObjectTypeId=${o.id}` :
                                      o.flowTypeId === 4 ? `/settings/events` :
                                      o.flowTypeId === 5 ? `/settings/attachments` : `/settings/objectType/${o.id}/customFieldGroups?objectType=${o.objectType}`}"
                 @click="selectMenuItem(o.objectType)"
                 class="dense-setting-row"
                 :class="{'shaded-row': $route.path === `/settings/objectType/${o.id}/customFieldGroups?objectType=${o.objectType}` || ($route.query && $route.query.companyObjectTypeId && parseInt($route.query.companyObjectTypeId) === o.id)}">
      <v-list-item-content>
        <v-list-item-title class="body-medium">{{o.objectType}}</v-list-item-title>
      </v-list-item-content>
    </v-list-item>
  </v-list>

</template>

<script>
import {AppMutations} from '@/stores/AppStore'

import Vue2Filters from 'vue2-filters'
import { handleHidingGlobalLoader, getRequest, getSnackbar } from '@/helpers/helpers'
import constants from '@/helpers/constants'
export default {
  name: "SettingsMenu",
  props: {
    title: String,
    menuList: Array,
    companyObjectItems: Array
  },
  data(){
    return {
      constants,
      hasSettingsAccess: this.$store.getters.userHasFeature('SETTINGS'),
      companyObjectTypes: [],
    }
  },
  mixins: [Vue2Filters.mixin],
  computed: {
  },
  methods: {
    setTitle (title) {
      this.$emit('updateTitle', title)
    },
    selectMenuItem(title){
      this.setTitle(title)
      this.$emit('closeMenu')
    }
  }
}
</script>

<style lang="scss" scoped>
@media (min-width: 960px) {
  .dense-setting-row {
    height: 30px !important;
    min-height: 30px !important;
  }
}
</style>
