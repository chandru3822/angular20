<template>
  <v-list :dense="vuetify.breakpoint.smAndUp" :color="vuetify.breakpoint.smAndDown ? 'grey lighten-4' : 'transparent'" :class="{'left-menu' : vuetify.breakpoint.smAndDown}">
    <template v-for="(item, index) in filteredMenu">
      <h3 class="label-large" v-if="item.header">{{item.header}}</h3>
      <v-list-item
          v-else
          :key="item.title"
          @click="selectMenuItem(item.title)"
          :to="item.path"
          class="dense-setting-row"
          :class="{'shaded-row': item.pathMatch && item.pathMatchExclude ? route.path.includes(`${item.pathMatch}`) && !route.path.includes(item.pathMatchExclude)
                                          : item.pathMatch ? route.path.includes(`${item.pathMatch}`) : route.path === item.path}"
      >
        <v-list-item-content>
          <v-list-item-title class="body-medium">{{item.title}}</v-list-item-title>
        </v-list-item-content>
      </v-list-item>
    </template>
    <v-list-item :dense="vuetify.breakpoint.smAndDown" v-for="o in filteredCompanyObjects" :key="o.id"
                 :to="{ path: o.flowTypeId === 3 ? `/settings/project/customFieldGroups?companyObjectTypeId=${o.id}` :
                                      o.flowTypeId === 4 ? `/settings/events` :
                                      o.flowTypeId === 5 ? `/settings/attachments` : `/settings/objectType/${o.id}/customFieldGroups?objectType=${o.objectType}`}"
                 @click="selectMenuItem(o.objectType)"
                 class="dense-setting-row"
                 :class="{'shaded-row': route.path === `/settings/objectType/${o.id}/customFieldGroups?objectType=${o.objectType}` || (route.query && route.query.companyObjectTypeId && parseInt(route.query.companyObjectTypeId) === o.id)}">
      <v-list-item-content>
        <v-list-item-title class="body-medium">{{o.objectType}}</v-list-item-title>
      </v-list-item-content>
    </v-list-item>
  </v-list>

</template>

<script setup>
import {getCurrentInstance, ref, computed, defineProps, defineEmits} from 'vue'
import { useUserStore } from '@/stores/UserStorePinia.js'
import {useRoute} from "vue-router/composables"

const vueInstance = getCurrentInstance().proxy
const snackbar = vueInstance.$snackbar
const vuetify = vueInstance.$vuetify
const store = vueInstance.$store
const userStore = useUserStore()
const route = useRoute()

const props = defineProps({
  title: String,
  menuList: Array,
  companyObjectItems: Array
})

const emit = defineEmits(['updateTitle', 'closeMenu'])
const hasSettingsAccess = ref(userStore.userHasFeature('SETTINGS'))
const companyObjectTypes = ref([])
const setTitle = (title) => {
  emit('updateTitle', title)
}
const selectMenuItem = (title) => {
  setTitle(title)
  emit('closeMenu')
}

const filteredMenu = computed(() => {
  return props.menuList.filter((m) => m.show === true)
})

const filteredCompanyObjects = computed(() => {
  return props.companyObjectItems.filter((c) => [1,3,4,5].includes(c.flowTypeId))
})

</script>

<style lang="scss" scoped>
@media (min-width: 960px) {
  .dense-setting-row {
    height: 30px !important;
    min-height: 30px !important;
  }
}
</style>
