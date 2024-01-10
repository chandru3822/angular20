<script setup>
/*
*@name TournamentsContainer
*@author jess
*@date 1/8/24
*
*@description
*
*/
import SettingContainerLayout from '@/views/flow/settings/SettingContainerLayout.vue';
import {getCurrentInstance, ref} from "vue";

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const tabs = ref([
  {
    label: 'Tournaments',
    path: `/settings/tournaments/tournaments`,
    display: store.getters.userHasFeature('SETTINGS')
  },
  {
    label: 'Appearance',
    path: `/settings/tournaments/appearance`,
    display: store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADMIN')
  },
])
</script>

<template>
<v-container>
  <SettingContainerLayout :tabs="tabs">
    <router-view/>
  </SettingContainerLayout>
</v-container>
</template>

<style scoped lang="scss">

</style>
