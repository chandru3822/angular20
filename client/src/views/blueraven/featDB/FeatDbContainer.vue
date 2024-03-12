<template>
  <v-container id="feat-db-container">
    <v-row>
      <v-col cols="12" class="pb-0">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">
            <AlbatrossButton
                v-for="tab in tabs"
                variant="text"
                :to="tab.path"
                color="primary"
                :class="{'AlbatrossButton--active': isActiveBtn(tab)}"
                v-if="hasAccess(tab)"
                :text="tab.label"
            ></AlbatrossButton>
          </v-toolbar-title>
          <v-spacer></v-spacer>
        </v-toolbar>
      </v-col>
    </v-row>
    <router-view></router-view>
  </v-container>
</template>

<script setup>
  import constants from '@/helpers/constants'
  import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue"
  import {FEAT_DB_TABS} from "@/views/blueraven/featDB/FeatDbConstants";
  import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
  import {useUserStore} from '@/stores/UserStorePinia.js'
  import {useRoute, useRouter} from "vue-router/composables";
  import { useAppStore } from '@/stores/AppStorePinia.js'

  const appStore = useAppStore()
  const route = useRoute()
  const router = useRouter()
  const userStore = useUserStore()
  const vueInstance = getCurrentInstance().proxy
  const store = vueInstance.$store
  const snackbar = vueInstance.$snackbar

  const tabs = ref(FEAT_DB_TABS)


      const isActiveBtn = (btn)  => {
        return btn.pathMatches.some(pm => {
          return route.path.includes(pm)
        })
      }
      const hasAccess = (tab) => {
        return userStore.userHasFeatureAccessLevel(tab.featureCode, 'VIEW')
      }
</script>

<style lang="scss" scoped>

</style>
