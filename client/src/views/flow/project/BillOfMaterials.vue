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
import {getRequest, getRequestWithParams, logError} from "@/helpers/helpers.js";
import SpinnerInline from '@/components/SpinnerInline'



const route = useRoute()
const userStore = useUserStore()
const appStore = useAppStore()
const vueInstance = getCurrentInstance().proxy
const vuetify = vueInstance.$vuetify

const bomLoading = ref(false)
const bomParts = ref([])
const partsTypes = ref([])
const headers = ref([
  { text: 'Description', value: 'description', show: true },
  { text: 'Part Number', value: 'partNumber', show: true, width: 160 },
  { text: 'Manufacturer', value: 'brand', show: true},
  { text: 'Quantity', value: 'quantity', show: true, width: 80},
  { text: 'Supplier', value: 'supplierName', show: true},
  { text: 'Confirmed', value: 'supplierConfirmed', show: true, width: 80 },
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
  bomLoading.value = true
  await getParts()
  await getPartsTypes()
  bomLoading.value = false
})

const getParts = async () => {
  try {
    const { data } = await getRequest(`/bom/${projectId.value}`, 'blueraven', [])
    bomParts.value = data
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error loading BOM')
  }
}

const getPartsTypes = async () => {
  try {
    const {data} = await getRequestWithParams(
        '/partsMaster/versions/types',
        {},
        'blueraven'
    )
    partsTypes.value = [...data]
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error loading part types')
  }
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
      <SpinnerInline :size="20" color="primary" class="d-flex justify-center"/>
    </v-col>
    <div v-else-if="bomParts?.length === 0" class="grey--text body-medium">
      No BOM Available
    </div>
    <div v-else class="bom-parts-table-container">
      <v-data-table
          id="bom-parts-table"
          :items="bomParts"
          :headers="headers"
          group-by="objectType"
          :items-per-page="-1"
          disable-sort
          fixed-header
          hide-default-footer
          class="table-striped"
      >
        <template v-slot:group.header="{ groupBy, group, headers, isOpen=true, toggle, remove }">
          <td :colspan="headers.length" class="grey lighten-5 group-header clickable" @click="toggle">
            <div class="one-hunned d-flex grey--text text--darken-1">
              <v-icon color="grey darken-1" v-if="isOpen">mdi-chevron-up</v-icon>
              <v-icon v-else color="grey darken-1">mdi-chevron-down</v-icon>
            {{ group }}
            </div>
          </td>
        </template>

        <template #item.supplierConfirmed="{ item }">
          <td class="text-end">
          <v-simple-checkbox
              dense
              hide-details
              v-model="item.supplierConfirmed"
              :disabled="true"
          ></v-simple-checkbox>
          </td>
        </template>
        <template #item.quantity="{ item }">
          <td class="text-end">
            {{item.quantity}}
          </td>
        </template>

      </v-data-table>
    </div>
  </div>
</template>

<style scoped lang="scss">
::v-deep {
  .v-data-table__wrapper {
    height: calc(100vh - 300px);
    min-height: 300px;
  }
}
</style>

<style lang="scss">
.bom-toolbar .v-toolbar__content {
  padding-left: 0px !important;
}
#bom-parts-table > div.v-data-table__wrapper > table > tbody > tr > td.group-header {
  border-top: 1px solid var(--v-grey-lighten1) !important;
}
</style>
