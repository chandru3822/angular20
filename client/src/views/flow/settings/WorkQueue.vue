<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar mb-3">
          <v-toolbar-title v-if="!vuetify.breakpoint.smAndDown" class="app-title">Work Queue</v-toolbar-title>
          <v-spacer />
          <v-toolbar-items :slot="vuetify.breakpoint.smAndDown ? 'extension' : 'default'">
            <v-tabs>
              <v-tab :to="`/settings/workQueue/types`">
                Types
              </v-tab>
              <v-tab v-if="userCanAccessCategories" :to="`/settings/workQueue/categories`">
                Categories
              </v-tab>
            </v-tabs>
          </v-toolbar-items>
        </v-toolbar>
        <router-view />
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>

import { getCurrentInstance, ref } from 'vue'
import { useUserStore } from '@/stores/UserStore.js'
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const vuetify = vueInstance.$vuetify
const userStore = useUserStore()
const userCanAccessCategories = ref(userStore.userHasFeature('SETTINGS'))

</script>
