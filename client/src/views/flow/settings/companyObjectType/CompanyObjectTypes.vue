<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <div v-if="!apiPath">
          No data available.
        </div>
        <v-data-table
          v-else
          :headers="headers"
          :items="companyObjectTypes"
          disable-sort
          :fixed-header="true"
          :items-per-page="-1"
          class="elevation-1 table-striped">

          <template #no-data>
            <span class="default-text-color">No available object types</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available object types</span>
          </template>

          <template #item.objectTye="{ item }">
              <span class="text-left">{{ item.objectType }}</span>
          </template>
              <template #item.icons="{item}">
                <div style="display: flex; justify-content: flex-end">
                  <a-btn size="small" variant="text"
                                   :large="vuetify.breakpoint.smAndDown"
                                   icon color="primary" @click="goToDetails(item)"
                                   prepend-icon="edit"
                  />
                </div>
              </template>
        </v-data-table>
      </v-col>

    </v-row>
  </v-container>
</template>

<script setup>
import {getRequest, logError} from '@/helpers/helpers'

import {getCurrentInstance, onMounted, ref} from 'vue'
import { useUserStore } from '@/stores/UserStorePinia.js'
import {useRouter} from "vue-router/composables"
import { useAppStore } from '@/stores/AppStorePinia.js'
const appStore = useAppStore()
const vueInstance = getCurrentInstance().proxy
const snackbar = vueInstance.$snackbar
const vuetify = vueInstance.$vuetify
const store = vueInstance.$store
const userStore = useUserStore()
const router = useRouter()

const companyObjectTypes = ref([])
const apiPath = ref(userStore.details.apiPath)
const headers = ref([
  {text: 'Object Type', value: 'objectType'},
  {text: '', value: 'icons', show: true},
])

onMounted(() => {
  if(null != apiPath.value) {
    getCompanyObjectTypes()
  }
})
const getCompanyObjectTypes = async () => {
  try {
    const {data} = await getRequest(`/objectType/getCompanyObjectTypes`, 'blueraven')
    companyObjectTypes.value = data
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error fetching object types')
  }
}
const goToDetails = (item) => {
  router.push({name: 'companyObjectTypes', params: {id: item.id}})
}
</script>
