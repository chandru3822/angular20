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
            <template v-for="(item, index) in filteredItems">
              <h3 v-if="item.header">{{item.header}}</h3>

              <v-list-item
                  v-else
                  :key="item.title"
                  :to="item.path"
                  :class="{'shaded-row': item.pathMatch ? vueInstance.$route.path.includes(`${item.pathMatch}`) : $route.path === item.path}"
                  @click="menuOpen = false"
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
            <template v-for="(item, index) in filteredItems">
              <h3 v-if="item.header">{{item.header}}</h3>

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

<script setup>
import constants from '@/helpers/constants'
import {getCurrentInstance, computed, onMounted, ref} from 'vue'

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const menuOpen = ref(false)
const companyId = ref(store.state.user.details.companyId)
const parentId = ref(store.state.user.details.parentCompanyId)

const items = computed(() => {
  return [
    {
      header: 'Admin',
      show: true
    }, {
      path: '/admin/features',
      title: 'Features',
      show: true
    }, {
      path: '/admin/functions',
      title: 'Functions',
      show: store.getters.isCompanyRoot(companyId.value)
    }, {
      path: '/admin/certs',
      title: 'Certs',
      show: store.getters.isCompanyRoot(companyId.value)
    }, {
      path: '/admin/orgFilters',
      title: 'Org Filters',
      show: !store.getters.isCompanyRoot(companyId.value)
    }, {
      path: '/admin/orgLevels',
      title: 'Org Levels',
      show: !store.getters.isCompanyRoot(companyId.value)
    }, {
      path: '/admin/statusTypes',
      title: 'Status Types',
      //todo: make this page work like features. so that if at root you add a status type to flow.user_status_type instead of flow.company_user_status_type
      show: !store.getters.isCompanyRoot(companyId.value)
    },  {
      path: '/admin/uploads',
      title: 'File Upload',
      show: !store.getters.isCompanyRoot(companyId.value)
    }
  ]
})

const filteredItems = computed(() => {
  return items.value.filter(i => i.show)
})

</script>

<style scoped lang="scss">
a {
  text-decoration: none;
}
</style>
