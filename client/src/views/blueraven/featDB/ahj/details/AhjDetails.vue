<template>
  <v-container id="ahj-details-container">
    <v-row>
      <v-col cols="12" class="pt-0 py-0">
        <v-row justify="space-between">
          <v-col class="text-left pa-0" cols="12">
            <v-card class="ahj-details-card square-card">
              <v-toolbar flat>
                <v-toolbar-title class="app-title"  v-if="ahj && ahj.name">
                  {{ ahj.name }}, {{ ahj.metroArea }}, {{ ahj.state }}
                </v-toolbar-title>
              </v-toolbar>

              <v-tabs id="fixed-tabs-bar" class="pl-0">
                <v-tab v-for="(tab, index) in ahjDetailTabs" :key="index" :to="tab.path"
                       class="text-capitalize ma-0"
                       :style="{'margin-left': index === 0 ? '0' : '0'}">
                  {{ tab.label }}
                </v-tab>
              </v-tabs>
            </v-card>
            <router-view class="px-2"/>
          </v-col>
        </v-row>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import {getRequest} from '@/helpers/helpers'
import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
 const ahj = ref({})

const ahjId = computed(() => {
  return route.params.ahjId
})

    const ahjDetailTabs = computed(() => {
      return [
        {
          label: 'Permitting',
          path: '/database/ahj/' + ahjId.value + '/permit',
        },
        {
          label: 'Inspection',
          path: '/database/ahj/' + ahjId.value + '/inspection'
        },
        {
          label: 'Design',
          path: '/database/ahj/' + ahjId.value + '/design'
        }
      ]
    })

onMounted(async() => {
    const {data} = await getRequest(`/featDb/ahj/${ahjId.value}`, 'blueraven')
    ahj.value = data
})

    const goToPath = async(path) => {
      await router.push({ path })
    }
</script>

<style scoped lang="scss">
#ahj-details-container {
  padding-right: 0;
  padding-left: 0;
  padding-top: 10px;
}

.ahj-details-card {
  margin-left: 12px;
  margin-right: 12px;
}

#back-btn {
  text-transform: unset;
  letter-spacing: unset;

  &:before {
    background-color: initial;
  }

  #back-btn-text:hover {
    text-decoration: underline;
  }
}

.page-title {
  font-size: 32px;
  font-weight: 200;
}

.page-info {
  font-family: 'Roboto Condensed', sans-serif;
  font-size: 20px;
  text-align: right;
}

#fixed-tabs-bar {
  position: sticky;
  top: -12px;
  z-index: 2;
  opacity: 0.95;
  border-bottom: 1px solid #E6E6E6;

  .v-tab:hover {
    color: var(--v-primary-base);
  }
}

.v-tab--active {
  color: var(--v-primary-base) !important;
}
</style>
