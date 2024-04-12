<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="title-large">Configurations</v-toolbar-title>
        </v-toolbar>

        <div class="ma-3">
          WARNING: These values can represent many data types so there is no data validation or error handling done. Please use caution when making changes.
        </div>

        <v-data-table
            id="defaults-config-table"
          :headers="headers"
          :items="configurationValues"
          :items-per-page="-1"
          hide-default-footer
          class="elevation-1 square-card table-striped"
        >
          <template #no-data>
            <span class="default-text-color">No Configuration Values</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No Configuration Values</span>
          </template>

          <template #item.value="{ item, index }">
                <a-text-field
                              style="overflow-wrap: anywhere"
                              type="text"
                              v-if="index === editIndex"
                              label="Value"
                              v-model="item.value">
                </a-text-field>
                <div v-else style="overflow-wrap: anywhere">
                  {{ item.value }}
                </div>
          </template>
              <template #item.icons = "{item, index}">
                <a-btn size="small" variant="text" :large="vuetify.breakpoint.smAndDown" icon color="primary" @click="editIndex = index" v-if="index !== editIndex" prepend-icon="edit"/>
                <a-btn size="small" variant="text" :large="vuetify.breakpoint.smAndDown" icon color="primary" @click="saveConfigurationValue(item)" v-if="index === editIndex" prepend-icon="save"/>
                <a-btn size="small" variant="text" :large="vuetify.breakpoint.smAndDown" icon color="primary" @click="editIndex = null" v-if="index === editIndex && vuetify.breakpoint.smAndDown" prepend-icon="close"/>
                <a-btn size="small" variant="text" color="primary" @click="editIndex = null" v-else-if="index === editIndex" text="CANCEL"/>              </template>
        </v-data-table>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>

import {handleHidingGlobalLoader, getRequest, putRequest, getSnackbar} from '@/helpers/helpers'
import constants from '@/helpers/constants'

import {getCurrentInstance, onMounted, ref, computed, watch} from "vue";
import {useUserStore} from "@/stores/UserStore.js"
import { useAppStore } from '@/stores/AppStore.js'
const appStore = useAppStore()

const vueInstance = getCurrentInstance().proxy

const vuetify = vueInstance.$vuetify
const store = vueInstance.$store
const userStore = useUserStore()


const editIndex = ref(null)
const configurationValues = ref([])
const companyId = ref(userStore.details.companyId)

const headers = ref([
  {text: 'Name', value: 'name', show: true},
  {text: 'Value', value: 'value', show: true},
  {text: null, value: 'icons', show: true, sortable: false}
])

onMounted(async () => {
  await getConfigurationValues()
})

    const getConfigurationValues = async () => {
      appStore.loading = true
      try {
        const {data, status} = await getRequest(`/companies/${companyId.value}/configuration`)
        configurationValues.value = data
        handleHidingGlobalLoader(status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        appStore.showSnack('ERROR', 'Error Retrieving Data')
        appStore.loading = false
      }
    }
    const saveConfigurationValue = async (item) => {
      appStore.loading = true
      try {
        const {status} = await putRequest(`/companies/${companyId.value}/configuration`, item)
        editIndex.value = null
        handleHidingGlobalLoader(status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        appStore.showSnack('ERROR', 'Error Saving Configuration Value')
        appStore.loading = false
      }
    }
</script>
<style lang="scss">
//keeps the arrow icon on the sort chip (mobile dropdown) from having a light blue background
#defaults-config-table > div > table > thead > tr > th > div > div > div > div > div.v-select__slot > div.v-select__selections > span > span > div {
  background-color: inherit !important;
}
</style>
