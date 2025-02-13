<script setup>
/*
*@name ProjectTabBillOfMaterials
*@author jess
*@date 2/11/25
*
*@description
*
*/

import {computed, getCurrentInstance, onMounted, ref} from "vue";
import {useRoute} from "vue-router/composables";
import { useUserStore } from '@/stores/UserStore.js'
import { useAppStore } from '@/stores/AppStore.js'
import {getRequest, logError} from "@/helpers/helpers.js";
import SpinnerInline from '@/components/SpinnerInline'



const route = useRoute()
const userStore = useUserStore()
const appStore = useAppStore()
const vueInstance = getCurrentInstance().proxy
const vuetify = vueInstance.$vuetify

const bomLoading = ref(false)
const bomParts = ref([])
const headers = ref([
  { text: 'Description', value: 'description', show: true },
  { text: 'Part Number', value: 'partNumber', show: true },
  { text: 'Manufacturer', value: 'brand', show:true },
  { text: 'Quantity', value: 'quantity', show: true },
  { text: 'Supplier', value: 'supplierName', show: true},
  { text: 'Confirmed', value: 'supplierConfirmed', show: true }
])

const projectId = computed(() => {
  return parseInt(route.params.projectId)
})
const isMobile = computed(() => {
  return vuetify.breakpoint.smAndDown
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('PROJECTS', 'EDIT')
})


onMounted(async() =>{
  await getParts()
})

const getParts = async () => {
  bomLoading.value = true
  try {
    const { data } = await getRequest(`/bom/${projectId.value}`, 'blueraven', [])
    bomParts.value = data
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error loading BOM')
  }
  bomLoading.value = false
}

</script>

<template>
  <div id="project-bom-container" class="pa-0 mx-6">

    <div class="pa-0 height-one-hunned">
      <div class="project-header">
        <v-toolbar
            color="transparent"
            class="elevation-0 bom-toolbar"
        >
          <v-toolbar-title class="title-large">
            <span>BOM</span>
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <div>
            <a-btn prepend-icon="mdi-list-box-outline" text="Create PO" :disabled="true"></a-btn>
          </div>
        </v-toolbar>
      </div>

    </div>
    <v-row
        no-gutters
        class="py-0 relative overflow-y-auto"
    >
      <v-toolbar
          color="transparent"
          class="elevation-0 bom-toolbar"
      >
        <v-toolbar-title class="headline-small">
          <span >Bill of Materials</span>
        </v-toolbar-title>
        <v-spacer></v-spacer>
        <div>
          <a-btn variant="outlined" prepend-icon="mdi-pencil" text="Edit" :disabled="true"></a-btn>
        </div>
      </v-toolbar>
    </v-row>
    <v-col v-if="bomLoading" class="d-flex justify-center">
      <SpinnerInline :size="20" color="primary" />
    </v-col>
    <div v-else-if="bomParts?.length === 0" class="grey--text body-medium">
      No BOM Available
    </div>
    <div v-else>
      <v-data-table
          id="bom-parts-table"
          :items="bomParts"
          :headers="headers"
          disable-sort
          class="table-striped"
      >
        <template #item.supplierConfirmed="{ item }">
          <v-simple-checkbox
              dense
              hide-details
              v-model="item.supplierConfirmed"
              :disabled="true"
          ></v-simple-checkbox>
        </template>

      </v-data-table>
    </div>
  </div>
</template>

<style scoped lang="scss">

</style>

<style lang="scss">
.bom-toolbar .v-toolbar__content {
  padding-left: 0px !important;
}
</style>
