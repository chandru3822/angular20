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
import {getRequest, getRequestWithParams, postRequest, logError} from "@/helpers/helpers.js";
import SpinnerInline from '@/components/SpinnerInline'
import cloneDeep from "lodash.clonedeep";



const route = useRoute()
const userStore = useUserStore()
const appStore = useAppStore()
const vueInstance = getCurrentInstance().proxy
const vuetify = vueInstance.$vuetify

const bomLoading = ref(false)
const bomParts = ref([])
const editParts = ref([])
const partsTypes = ref([])
const editMode = ref(false)
const suppliers = ref([])


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
  //todo: change to new BOM edit permission
  return userStore.userHasFeatureAccessLevel('PROJECTS', 'EDIT')
})


onMounted(async() =>{
  bomLoading.value = true
  await getParts()
  await getPartsTypes()
  await getSuppliers()
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

const getSuppliers = async () => {
  try {
    const {data, status} = await getRequest('/featDb/supplier/list/all', 'blueraven')
    suppliers.value = cloneDeep(data)
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error loading suppliers')
  }
}

const populateDirtyRows = (event, item, column) => {
  let alreadyEdited = false
  editParts.value.map(ep => {
    if(ep.id === item.id)
      ep[column] = event
    alreadyEdited = true
  })
  if(!alreadyEdited){
    const editedItem = {
      id:item.id
    }
    editedItem[column] = event
    editParts.value.push(editedItem)
  }
}

const cancel = () => {
  editParts.value = [] //clear the editParts list
  editMode.value = false //turn off edit mode
}

const save = async () => {
  bomLoading.value = true
  try {
    const {data} = await postRequest(
        `/bom/${projectId.value}/parts`,
        editParts.value,
        'blueraven')
    bomParts.value = data //update the saved bom
    editParts.value = [] //clear the editParts list
    editMode.value = false //turn off edit mode
    appStore.showSnack('SUCCESS', 'BOM Saved')
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error saving BOM')
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
        <v-toolbar-title class="headline-small d-flex align-center">
          <span >Bill of Materials</span>
          <a-btn v-if="editMode" @click="" size="small" variant="text" prepend-icon="mdi-plus" text="Add"/>
        </v-toolbar-title>
        <v-spacer></v-spacer>
        <div>
          <a-btn v-if="userCanEdit && !editMode" @click="editMode = true" variant="outlined" prepend-icon="mdi-pencil" text="Edit"></a-btn>
          <a-btn v-if="editMode" @click="cancel" variant="text" text="Cancel"></a-btn>
          <a-btn v-if="editMode" :disabled="editParts?.length === 0" @click="save" variant="outlined" prepend-icon="save" text="Save"></a-btn>
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
      <v-form ref="bomPartsForm">
      <v-data-table
          id="bom-parts-table"
          :items="bomParts"
          :headers="headers"
          group-by="objectType"
          :items-per-page="-1"
          disable-sort
          fixed-header
          hide-default-footer
          class="table-striped elevation-1"
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

        <template #item.quantity="{ item }">
          <td class="text-end">
            <a-text-field
                v-if="editMode"
                type="number"
                :value="item.quantity"
                @input="populateDirtyRows($event, item, 'quantity')"
            />
            <span v-else>{{item.quantity}}</span>
          </td>
        </template>
        <template #item.supplierName="{ item }">
          <td class="supplier-col">
          <a-autocomplete
              v-if="editMode"
              :value="item.supplierId"
              :items="suppliers"
              item-title="name"
              item-value="id"
              placeholder="Unspecified"
              clearable
              @input="populateDirtyRows($event, item, 'supplierId')"
          />
          <span v-else-if="!item.supplierName" class="grey--text body-large">Unspecified</span>
          <span v-else>{{item.supplierName}}</span>
          </td>
        </template>
        <template #item.supplierConfirmed="{ item }">
          <td class="text-end">
            <v-simple-checkbox
              dense
              hide-details
              :value="item.supplierConfirmed"
              @input="populateDirtyRows($event, item, 'supplierConfirmed')"
              :disabled="!editMode || !item.supplierId"
          ></v-simple-checkbox>
          </td>
        </template>

      </v-data-table>
      </v-form>
    </div>
  </div>
</template>

<style scoped lang="scss">
::v-deep {
  .v-data-table__wrapper {
    max-height: calc(100vh - 300px);
    //min-height: 300px;
  }
  .supplier-col {
    min-width: 135px;
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
