<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-app-bar dense tabs color="white" class="elevation-1">
          <v-toolbar-title>Blue Power + Payments Queue</v-toolbar-title>
          <v-tabs :optional="false" color="primary"
                  slot="extension"
                  background-color="white" v-model="model" slider-color="primary">
            <v-tab v-for="(tab, index) in displayedTabs" :key="index" :to="tab.path">
              {{tab.label}}
            </v-tab>
          </v-tabs>
        </v-app-bar>
        <router-view></router-view>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const model = ref('')

const tabs = computed(() => {
  return [ {
    label: 'View Payments',
    path: '/finances/rebate/viewPayments',
    display: userStore.userHasFeature('REBATES')
  }, {
    label: 'Batches',
    path: '/finances/rebate/batches',
    display: userStore.userHasFeature('REBATES')
  }]
})
const displayedTabs = computed(() => {
  return tabs.value.filter(tab => tab.display)
})

</script>
