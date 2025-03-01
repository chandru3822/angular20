<script setup>
/*
*@name ProjectTabBillOfMaterials
*@author jess
*@date 2/11/25
*
*@description
*
*/

import {computed, getCurrentInstance, onMounted, ref, watch} from "vue";
import {useRoute} from "vue-router/composables";
import { useUserStore } from '@/stores/UserStore.js'
import { useAppStore } from '@/stores/AppStore.js'
import {getRequest, getRequestWithParams, postRequest, logError} from "@/helpers/helpers.js";
import SpinnerInline from '@/components/SpinnerInline'
import cloneDeep from "lodash.clonedeep";
import ConfirmationDialog from "@/components/ConfirmationDialog.vue";



const route = useRoute()
const userStore = useUserStore()
const appStore = useAppStore()
const vueInstance = getCurrentInstance().proxy
const vuetify = vueInstance.$vuetify

const bomLoading = ref(false)
const partsMasterLoading = ref(false)
const bomParts = ref([])
const editParts = ref([])
const partsToDisplay = ref([])
const partsTypes = ref([])
const suppliers = ref([])
const partsMasterParts = ref([])
const editMode = ref(false)
const addPart = ref(false)
const duplicatedPart = ref(false)
const bomPartsForm = ref(null)

const newPart = ref(null)
const newPartQuantity = ref(null)
const newPartSupplier = ref(null)


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
    partsToDisplay.value = data
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

const getPartsMasterParts = async () => {
  if(partsMasterParts.value?.length === 0) {
    partsMasterLoading.value = true
    try {
      const {data} = await getRequest('/partsMaster/versions/allParts', 'blueraven')
      partsMasterParts.value = data
    } catch (e) {
      logError(e)
      appStore.showSnack('ERROR', 'Error loading parts master list')
    }
    partsMasterLoading.value = false
  }
}

const newPartSearch = (item, queryText, itemText) => {
  const description = item.description?.toLowerCase()
  const partNumber = item.partNumber?.toLowerCase()
  const searchText = queryText?.toLowerCase()
  return description?.indexOf(searchText) > -1 || partNumber?.indexOf(searchText) > -1
}

const setNewPart = (input) => {
  newPart.value = input
}


const addNewPartToList = () => {
  debugger
  let partForUpdate = {
    partsMasterId: newPart.value.id,
    quantity: newPartQuantity.value,
    supplierId: newPartSupplier.value?.id,
    supplierConfirmed: null
  }
  //if the part already exists in the BOM we will temporarily add a new row, but that row might get combined on save depending on other factors
  const existingPart = findBestMatchDuplicatePart()

  if(existingPart && (existingPart.supplierId === newPartSupplier || (!existingPart.supplierId && !newPartSupplier)) && !existingPart.supplierConfirmed) {
    //if the existing part's supplier and the new part's supplier match (or if both are null) AND the existing part's supplier is NOT confirmed,
    // the new row quantity will be added to the existing row (ie, update the existing value) on save, so we need to add the id
    partForUpdate.id = existingPart.id
    //and combine the existing quantity with the new quantity to get the updated quantity value
    partForUpdate.quantity = Number(newPartQuantity.value) + Number(existingPart.quantity)


  }
  //but we need to display a temporary row with the values entered into the add field,
  // so we'll add the entered quantity and supplier id to the "newPart" object and then add that to the newParts list
  newPart.value.quantity = newPartQuantity.value
  newPart.value.supplierId = newPartSupplier.value?.id
  newPart.value.supplierName = newPartSupplier.value?.supplierName
  //we will also set the duplicated part equal to this value to display the confirmation dialog; then we are free to clear out the new Part
  partsToDisplay.value.push(newPart.value)



  //now that our value is formatted correctly, we need to add it to the list that will be saved
  editParts.value.push(partForUpdate)

  //clear out the new part so another may be added
  newPartQuantity.value = null
  newPartSupplier.value = null
  newPart.value = null
  //close the add card
  addPart.value = false
}

const findBestMatchDuplicatePart = () => {
  let possibleMatches = bomParts.value.filter(bp => (bp.partsMasterGroupUuid === newPart.value.partsMasterGroupUuid))
  if(possibleMatches?.length === 0){
    return null
  }
  if(newPartSupplier?.value){
    //if new part has supplier, match must have same supplier and must not be confirmed
    return possibleMatches.find(pm => (pm.supplierId && pm.supplierId === newPartSupplier.value.id && !pm.supplierConfirmed))
  }
  return possibleMatches.find(pm => (!pm.supplierId))
}

const confirmDuplicate = () => {
  duplicatedPart.value = null

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

const openAddForm = () => {
  addPart.value = true
  editMode.value = true
  getPartsMasterParts()
}

const cancel = () => {
  editParts.value = [] //clear the editParts list
  partsToDisplay.value = bomParts.value //clear the added parts list
  addPart.value = false //turn off add parts
  newPart.value = null //clear the new part values
  newPartQuantity.value = null
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
    cancel()
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
          <a-btn @click="openAddForm" size="small" variant="text" prepend-icon="mdi-plus" text="Add Material"/>
        </v-toolbar-title>
        <v-spacer></v-spacer>
        <div>
          <a-btn v-if="userCanEdit && !editMode" @click="editMode = true" variant="outlined" prepend-icon="mdi-pencil" text="Edit"></a-btn>
          <a-btn v-if="editMode" @click="cancel" variant="text" text="Cancel"></a-btn>
          <a-btn v-if="editMode" :disabled="editParts?.length === 0" @click="save" variant="outlined" prepend-icon="save" text="Save"></a-btn>
        </div>
      </v-toolbar>
    </v-row>
    <v-card v-if="addPart" class="mb-3">
      <v-card-title class="label-medium">Add Material</v-card-title>
      <v-card-text class="d-flex flex-wrap pr-0">
        <a-autocomplete
            :items="partsMasterParts"
            :value="newPart"
            :filter="newPartSearch"
            :loading = partsMasterLoading
            @input="setNewPart"
            label="Material(Find in Parts Master by Description, Part Number)"
            clearable
            class="one-hunned new-part-autocomplete pr-4"
        >
          <template v-slot:item="{item}">
            {{item.description}} ({{item.partNumber}})
          </template>
          <template v-slot:selection="{item}">
            {{item.description}} ({{item.partNumber}})
          </template>
        </a-autocomplete>
        <a-text-field
            type="number"
            v-model="newPartQuantity"
            label="Quantity"
            customClasses="new-part-quantity pr-4"
        />
        <a-autocomplete
            v-model="newPartSupplier"
            :items="suppliers"
            item-title="name"
            return-object
            placeholder="Unspecified"
            clearable
            class="pr-4"
        />
      </v-card-text>
      <v-card-actions class="px-4 pt-0 pb-4">
        <v-spacer/>
        <a-btn variant="text" @click="[addPart = false, newPart = null, newPartQuantity = null, newPartSupplier = null]" text="Cancel"></a-btn>
        <a-btn :disabled="!newPart || !newPartQuantity" @click="addNewPartToList" text="Add"></a-btn>
      </v-card-actions>
    </v-card>
    <v-form ref="bomPartsForm">

    <v-col v-if="bomLoading" class="d-flex justify-center">
      <SpinnerInline :size="20" color="primary" class="d-flex justify-center"/>
    </v-col>
    <div v-else-if="bomParts?.length === 0" class="grey--text body-medium">
      No BOM Available
    </div>
    <div v-else class="bom-parts-table-container">
      <v-data-table
          id="bom-parts-table"
          :items="partsToDisplay"
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
    </div>
    </v-form>
    <ConfirmationDialog :open-dialog="!!duplicatedPart"
                        hideCancel
                        @confirm="[duplicatedPart = null]"
                        @close-dialog="confirmDuplicate"
    >
      <template v-slot:title>Duplicate Material</template>
      <template v-slot>
        This material already exists in the BOM.  The quantity will be updated from {{duplicatedPart?.quantity}} to {{duplicatedPart?.updatedQuantity}}.
      </template>
      <template v-slot:yes>Okay</template>
    </ConfirmationDialog>
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
.new-part-autocomplete {
  max-width: 800px;
}
.new-part-quantity {
  max-width: 6rem;
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
