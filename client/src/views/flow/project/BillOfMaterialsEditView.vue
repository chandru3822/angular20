<script setup>
/*
*@name BillOfMaterialsEditView
*@author jess
*@date 3/3/25
*
*@description
*
*/
import {onMounted, ref, toRefs, watch} from "vue";
import {postRequest, logError} from "@/helpers/helpers.js";
import { useAppStore } from '@/stores/AppStore.js'
import {onBeforeRouteLeave, onBeforeRouteUpdate} from "vue-router/composables";
import ConfirmationDialog from "@/components/ConfirmationDialog.vue";

const appStore = useAppStore()

const props = defineProps({
  projectId: Number,
  bomParts: Array,
  headers: Array,
  showAddPart: Boolean,
  suppliers: Array,
  partsMasterParts: Array,
  partsMasterLoading: Boolean
})

const emit = defineEmits(['save', 'hideAddPart', 'cancel', 'openAddForm'])

const newPart = ref(null)
const newPartQuantity = ref(null)
const newPartSupplier = ref(null)
const localBomParts = ref([])
const editParts = ref([])

const bomSaving = ref(false)
const unsavedModal = ref(false);
const nextRoute = ref(null);
const override = ref(false);

onMounted(() => {
  localBomParts.value = [...props.bomParts]
})

onBeforeRouteUpdate(async (to, from, next) => {
  await routeGuard(to, from, next)
})

onBeforeRouteLeave(async (to, from, next) => {
 await routeGuard(to, from, next)
})

const routeGuard = async (to, from, next) => {
  if (!override.value && Object.keys(editParts.value || {}).length > 0) {
    unsavedModal.value = true
    nextRoute.value = next
  } else {
    next()
  }
}

watch(props.bomParts, () => {
  localBomParts.value = [...props.bomParts]
})

const populateDirtyRows = (event, item, column) => {
  let alreadyEdited = false
  editParts.value.map(ep => {
    if(ep.id === item.id || (!item.id && !ep.id && ep.partsMasterId === item.partsMasterId))
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

const closeAddPart = () => {
  newPart.value = null
  newPartQuantity.value = null
  newPartSupplier.value = null
  emit('hideAddPart')
}

const cancel = () => {
  editParts.value = [] //clear the editParts list
  newPart.value = null //clear the new part values
  newPartQuantity.value = null
  emit('cancel')
}

const save = async () => {
  bomSaving.value = true
  try {
    const {data} = await postRequest(
        `/bom/${props.projectId}/parts`,
        editParts.value,
        'blueraven')
     emit('save', data)//update the saved bom
    editParts.value = []
    appStore.showSnack('SUCCESS', 'BOM Saved')
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error saving BOM')
  }
  bomSaving.value = false
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
  let partForUpdate = {
    partsMasterId: newPart.value.id,
    quantity: newPartQuantity.value,
    supplierId: newPartSupplier.value?.id,
    supplierConfirmed: null
  }
  //if the part already exists in the BOM we will temporarily add a new row, but that row might get combined on save depending on other factors
  const existingPart = findBestMatchDuplicatePart()

  if(existingPart && (existingPart.supplierId === newPartSupplier.value?.id || (!existingPart.supplierId && !newPartSupplier.value?.id)) && !existingPart.supplierConfirmed) {
    //if the existing part's supplier and the new part's supplier match (or if both are null) AND the existing part's supplier is NOT confirmed,
    // the new row quantity will be added to the existing row (ie, update the existing value) on save, so we need to add the id
    partForUpdate.id = existingPart.id
    //and combine the existing quantity with the new quantity to get the updated quantity value
    partForUpdate.quantity = Number(newPartQuantity.value) + Number(existingPart.quantity)


  }
  //either way we need to display a temporary row with the values entered into the add field,
  // so we'll add the entered quantity and supplier id to the "newPart" object and then add that to the newParts list
  newPart.value.partsMasterId = newPart.value.id
  newPart.value.id = null
  newPart.value.quantity = newPartQuantity.value
  newPart.value.supplierId = newPartSupplier.value?.id
  newPart.value.supplierName = newPartSupplier.value?.supplierName
  localBomParts.value.push(newPart.value)


  //now that our value is formatted correctly, we need to add it to the list that will be saved
  editParts.value.push(partForUpdate)
  //clear out the new part so another may be added
  newPartQuantity.value = null
  newPartSupplier.value = null
  newPart.value = null
  //close the add card
  emit('hideAddPart')
}

const findBestMatchDuplicatePart = () => {
  let possibleMatches = localBomParts.value.filter(bp => (bp.partsMasterGroupUuid === newPart.value.partsMasterGroupUuid))
  if(possibleMatches?.length === 0){
    return null
  }
  if(newPartSupplier?.value){
    //if new part has supplier, match must have same supplier and must not be confirmed
    return possibleMatches.find(pm => (pm.supplierId && pm.supplierId === newPartSupplier.value.id && !pm.supplierConfirmed))
  }
  return possibleMatches.find(pm => (!pm.supplierId))
}

</script>

<template>
  <v-container>
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
          <a-btn @click="emit('openAddForm')" size="small" variant="text" prepend-icon="mdi-plus" text="Add Material"/>
        </v-toolbar-title>
        <v-spacer></v-spacer>
        <div>
          <a-btn @click="cancel" variant="text" text="Cancel"></a-btn>
          <a-btn :disabled="editParts?.length === 0" @click="save" variant="outlined" prepend-icon="save" text="Save"></a-btn>
        </div>
      </v-toolbar>
    </v-row>
    <v-card v-if="showAddPart" class="mb-3">
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
        <a-btn variant="text" @click="closeAddPart" text="Cancel"></a-btn>
        <a-btn :disabled="!newPart || !newPartQuantity" @click="addNewPartToList" text="Add"></a-btn>
      </v-card-actions>
    </v-card>
    <div v-if="bomParts?.length === 0" class="grey--text body-medium">
      No BOM Available
    </div>
    <v-data-table
      id="bom-parts-table"
      :items="localBomParts"
      :headers="headers"
      group-by="objectType"
      :items-per-page="-1"
      disable-sort
      fixed-header
      hide-default-footer
      :loading="bomSaving"
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
            type="number"
            :value="item.quantity"
            @input="populateDirtyRows($event, item, 'quantity')"
        />
      </td>
    </template>
    <template #item.supplierName="{ item }">
      <td class="supplier-col">
        <a-autocomplete
            :value="item.supplierId"
            :items="suppliers"
            item-title="name"
            item-value="id"
            placeholder="Unspecified"
            clearable
            @input="populateDirtyRows($event, item, 'supplierId')"
        />
      </td>
    </template>
    <template #item.supplierConfirmed="{ item }">
      <td class="text-end">
        <v-simple-checkbox
            dense
            hide-details
            v-model="item.supplierConfirmed"
            @input="populateDirtyRows($event, item, 'supplierConfirmed')"
            :disabled="!item.supplierId"
        ></v-simple-checkbox>
      </td>
    </template>

  </v-data-table>
    <ConfirmationDialog :open-dialog="unsavedModal" @confirm="nextRoute()"
                        @close-dialog="[unsavedModal = false, nextRoute = null]">
      <template v-slot:title>Unsaved Changes</template>
      <template>You have unsaved changes.  Are you sure you want to leave this page without saving?</template>
      <template v-slot:yes>Leave Without Saving</template>
      <template v-slot:no>Stay and Keep Editing</template>
    </ConfirmationDialog>
  </v-container>
</template>

<style scoped lang="scss">

</style>
