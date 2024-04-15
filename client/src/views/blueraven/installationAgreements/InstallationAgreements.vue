<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-app-bar dense tabs color="white" class="elevation-1">
          <v-toolbar-title>Installation Agreements</v-toolbar-title>
          <v-tabs :optional="false" color="primary"
                  slot="extension"
                  background-color="white" v-model="model" slider-color="primary">
            <v-tab v-for="(tab, index) in displayedTabs" :key="index" :to="tab.path">
              {{ tab.label }}
            </v-tab>
          </v-tabs>
        </v-app-bar>
        <router-view></router-view>
      </v-col>
    </v-row>

  </v-container>
</template>

<script setup>
import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'

const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

    const tabs = computed(() => {
      return [{
        label: 'Installation Agreement Request',
        path: '/installation-agreements/request',
        display: userStore.userHasFeature('INSTALLATION_AGREEMENT')
      }]
    })
    const displayedTabs = computed(() => {
      return tabs.value?.filter(tab => tab.display)
    })
    const model = ref('')
</script>
