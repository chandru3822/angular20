<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar" id="project-settings-toolbar">
          <h3>Projects</h3>
          <v-spacer></v-spacer>
          <v-toolbar-items :slot="$vuetify.breakpoint.smAndDown ? 'extension' : 'default'">
            <v-tabs class="tabs-bar" id="projects-settings-tabs">
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
import {getCurrentInstance, computed, ref, onMounted} from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute} from "vue-router/composables"
import { useAppStore } from '@/stores/AppStorePinia.js'
const appStore = useAppStore()

const route = useRoute()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const processStepId = computed(() => {
  return route.params.id
})
const companyObjectTypeId = computed(() => {
  return route.query.companyObjectTypeId
})

const tabs = ref([
  {
    id: 1,
    label: 'Custom Field Groups',
    path: `/settings/project/customFieldGroups?companyObjectTypeId=${companyObjectTypeId.value}`,
  },
  {
    id: 2,
    label: 'Tabs',
    path: `/settings/project/tabs?companyObjectTypeId=${companyObjectTypeId.value}`,
  },
  {
    id: 3,
    label: 'Attachment Types',
    path: `/settings/project/attachmentTypes?companyObjectTypeId=${companyObjectTypeId.value}`,
  },
  {
    id: 4,
    label: 'System',
    path: `/settings/project/system?companyObjectTypeId=${companyObjectTypeId.value}`,
  }
])

const companyId = computed(() => {
  return userStore.details.companyId
})


</script>

<style scoped lang="scss">
.name-container {
  background-color: var(--v-primary-lighten9) !important;
  border-radius: 5px;
}
</style>
<style lang="scss">
@media (max-width: 959px) {
  #projects-settings-tabs > div > div.v-slide-group__wrapper > div {
    justify-content: center;
  }
  #projects-settings-tabs > div > div.v-slide-group__prev.v-slide-group__prev--disabled {
    display: none;
  }
  #project-settings-toolbar > div.v-toolbar__extension {
    padding-bottom: 0.75rem;
  }
}
</style>
