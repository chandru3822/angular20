<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar" id="object-settings-toolbar">
          <h3>{{ objectType }}</h3>
          <v-spacer></v-spacer>
          <v-toolbar-items :slot="isMobile ? 'extension' : 'default'">
            <v-tabs class="tabs-bar" v-model="activeTab" id="object-settings-tabs">
              <v-tab v-for="(tab, index) in tabs" :key="index" :to="tab.path"
                     class="text-capitalize ma-0"
                     :style="{'margin-left': (index === 0 && $vuetify.breakpoint.smAndDown) ? '12px !important' : '0'}">
                {{ tab.label }}
              </v-tab>
            </v-tabs>
          </v-toolbar-items>
        </v-toolbar>
        <router-view/>
      </v-col>

    </v-row>
  </v-container>
</template>

<script setup>
import constants from '@/helpers/constants'
import { useUserStore } from '@/stores/UserStore.js'


import {ref, onMounted, getCurrentInstance, computed, defineProps, watch} from "vue";
import {useRouter, useRoute} from "vue-router/composables"
import { useAppStore } from '@/stores/AppStore.js'
const appStore = useAppStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const route = useRoute()
const router = useRouter()
const vuetify = vueInstance.$vuetify
const userStore = useUserStore()

const props = defineProps({
  isProject: Boolean
})
const activeTab = computed({
  get() {
    return route?.path?.includes('/objectType') ?       `/settings/objectType/${companyObjectTypeId}/attachmentTypes?objectType=${objectType}` : null
  },
  set(val) {
    return val
  }
})
const tabs = computed(() => {
 return [
    {
      id: 1,
      label: 'Custom Field Groups',
      path: `/settings/objectType/${companyObjectTypeId.value}/customFieldGroups?objectType=${objectType.value}`,
    },
    {
      id: 2,
      label: 'Attachment Types',
      path: `/settings/objectType/${companyObjectTypeId.value}/attachmentTypes?objectType=${objectType.value}`,
    }
  ]
})

const isMobile = computed(() => {
  return vuetify.breakpoint.smAndDown
})

const companyObjectTypeId = computed(() => {
  return route.params.id
})

const objectType = computed(() => {
  return route.query.objectType
})


watch(() => companyObjectTypeId.value, () => {
  // whenever objectTypeId changes, this function will run
    // reset the selected group when the object type changes
    objectType.value = route.query.objectType
})
</script>

<style lang="scss">
@media (max-width: 959px) {
  #object-settings-tabs > div > div.v-slide-group__wrapper > div {
    justify-content: center;
  }
  #object-settings-tabs > div > div.v-slide-group__prev.v-slide-group__prev--disabled {
    display: none;
  }
  #object-settings-toolbar > div.v-toolbar__extension {
    padding-bottom: 0.75rem;
  }
}
</style>
