<template>
  <v-container>
    <v-row  class="pt-0">
      <v-col cols="12"  class="pt-0">
        <v-tabs class="tabs-bar" id="default-settings-tabs">
          <v-tab v-for="(tab, index) in displayedTabs" :key="index" :to="tab.path"
                 class="text-capitalize ma-0 label-medium"
                 :style="{'margin-left': (index === 0 && vuetify.breakpoint.smAndDown) ? '12px !important' : '0'}">
            {{ tab.label }}
          </v-tab>
        </v-tabs>
        <router-view></router-view>
      </v-col>
    </v-row>

  </v-container>
</template>

<script setup>
import constants from '@/helpers/constants'
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";
import {getCurrentInstance, ref, computed} from "vue";
import {useUserStore} from "@/stores/UserStorePinia.js";

const vueInstance = getCurrentInstance().proxy
const vuetify = vueInstance.$vuetify
const store = vueInstance.$store
const userStore = useUserStore()
const tabs = ref([
  {
    label: 'Settings',
    path: `/settings/company/settings`,
    display: userStore.userHasFeature('SETTINGS')
  },
  {
    label: 'Configurations',
    path: `/settings/company/configurations`,
    display: userStore.userHasFeatureAccessLevel('SETTINGS', 'ADMIN')
  },
  {
    label: 'Email',
    path: `/settings/company/email`,
    display: userStore.userHasFeatureAccessLevel('SETTINGS', 'ADMIN')
  },
  {
    label: 'Message Types',
    path: `/settings/company/messageTypes`,
    display: userStore.userHasFeatureAccessLevel('SETTINGS', 'ADMIN')
  },
  {
    label: 'Closer Dashboard',
    path:`/settings/company/closerDashboard`,
    display: userStore.userHasFeatureAccessLevel('SETTINGS','ADMIN')
  }
])

const displayedTabs = computed(() => {
  return tabs.value.filter(tab => tab.display)
})
</script>
<style lang="scss">
@media (max-width: 959px) {
  #default-settings-tabs > div > div.v-slide-group__wrapper > div {
    justify-content: center;
  }
  #default-settings-tabs > div > div.v-slide-group__prev.v-slide-group__prev--disabled {
    display: none;
  }
}
</style>
