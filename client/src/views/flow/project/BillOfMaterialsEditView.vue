<script setup>
/*
*@name BillOfMaterialsEditView
*@author jess
*@date 3/3/25
*
*@description
*
*/
import {computed, onMounted, ref, toRefs, watch} from "vue";
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
  selectedPermitPack: Object,
  partsMasterParts: Array,
  partsMasterLoading: Boolean
})

const emit = defineEmits(['save', 'hideAddPart', 'cancel', 'openAddForm'])

const newPart = ref(null)
const newPartQuantity = ref(null)
const newPartSupplier = ref(null)
const localBomParts = ref([])
const editParts = ref([])
const addCustom = ref(false)
const customPartDescription = ref(null)
const customPartNumber = ref(null)
const showPartsMasterDuplicateDialog = ref(false)
const partsMasterDupes = ref([])
const selectedPartDupe = ref(null)

const bomSaving = ref(false)
const unsavedModal = ref(false);
const nextRoute = ref(null);
const override = ref(false);

onMounted(() => {
  localBomParts.value = [...props.bomParts]
})

onBeforeRouteLeave(async (to, from, next) => {
 await routeGuard(to, from, next)
})

const routeGuard = async (to, from, next) => {
  if (!override.value && Object.keys(editParts.value || {}).length > 0 && !bomSaving.value) {
    unsavedModal.value = true
    nextRoute.value = next
  } else {
    next()
  }
}

/*
customPartPlaceholder: object to display in dropdown when 'Add New Part' is selected; prop values should not change
 */
const customPartPlaceholder = ref({
  description: "Add Custom Part",
  id: null,
  objectCode: "PARTS_CUSTOM",
  objectType: "Parts Custom",
  partNumber:"",
})
/*
Add customPartPlaceholder to the list of parts for the dropdown so it can display correctly on 'Add New Part'
 */
const partsList = computed(() => {
  return [...props.partsMasterParts, customPartPlaceholder.value]
})

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
      id:item.id,
      partsMasterId: item.partsMasterId,
      customPartId: item.customPartId
    }
    editedItem[column] = event
    editParts.value.push(editedItem)
  }
}

const closeDupeDialog = () => {
  showPartsMasterDuplicateDialog.value = false
  selectedPartDupe.value = null
  partsMasterDupes.value = null
}

const closeAddPart = () => {
  //clear out the new part so another may be added
  newPart.value = null
  newPartQuantity.value = null
  newPartSupplier.value = null
  customPartDescription.value = null
  customPartNumber.value = null
  addCustom.value = false
  selectedPartDupe.value = null
  //close the add card
  emit('hideAddPart')
}

const cancel = () => {
  editParts.value = [] //clear the editParts list
  newPart.value = null //clear the new part values
  newPartQuantity.value = null
  addCustom.value = false
  emit('cancel')
}

/*
Save all part list changes to database and emit result to parent(BillOfMaterials.vue) to refresh the part list
 */
const save = async () => {
  bomSaving.value = true
  try {
    const {data} = await postRequest(
        `/bom/${props.projectId}/${props.selectedPermitPack.id}/parts`,
        editParts.value,
        'blueraven')
    editParts.value = [] //make sure we clear the edit parts before we save the data to avoid the route guard triggering the unsaved changes dialog
    emit('save', data)//update the saved bom
    appStore.showSnack('SUCCESS', 'BOM Saved')
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error saving BOM')
  }
  bomSaving.value = false
}

/*
Search the description and part number on Add Part autocomplete
 */
const newPartSearch = (item, queryText, itemText) => {
  const description = item.description?.toLowerCase()
  const partNumber = item.partNumber?.toLowerCase()
  const searchText = queryText?.toLowerCase()
  return description?.indexOf(searchText) > -1 || partNumber?.indexOf(searchText) > -1
}

/*
* Called when a part is selected from the Add Part dropdown or when 'Add Custom Part' is clicked
* input is the selected part or customPartPlaceholder if called from 'Add Custom Part'
* newPart is the v-model object for the dropdown
*/
const selectNewPart = (input) => {
  if(input.objectCode === "PARTS_CUSTOM"){
    input = customPartPlaceholder.value
    addCustom.value = true
  }
  newPart.value = input
}

const checkForPartsMasterDupe = () => {
  partsMasterDupes.value = props.bomParts.filter(pmp => pmp.description === customPartDescription.value || pmp.partNumber === customPartNumber.value)
}

const confirmPartsMasterDupe = () => {
  newPart.value = selectedPartDupe.value
  addCustom.value = false
  showPartsMasterDuplicateDialog.value = false
  addNewPartToList()
}

const addNewCustomPartToList = () => {
  checkForPartsMasterDupe()
  if(partsMasterDupes.value?.length > 0){
    showPartsMasterDuplicateDialog.value = true
  } else {
    addNewPartToList()
  }
}


const addNewPartToList = () => {
  let partForUpdate = {
    partsMasterId: newPart.value.id,
    customPartId: newPart.value.customPartId,
    quantity: newPartQuantity.value,
    supplierId: newPartSupplier.value?.id,
    supplierConfirmed: null
  }
  if(addCustom.value){
    partForUpdate.partNumber = customPartNumber.value
    partForUpdate.description = customPartDescription.value
  }

  //first check the list of edited parts to see if we're adding a part that matches a previously added or edited part
  const prevEditedPart = findBestEditedMatchDuplicatePart()
  if(prevEditedPart){
    //if it does, update that quantity and don't add a new part to editParts list
    prevEditedPart.quantity = Number(prevEditedPart.quantity) + Number(newPartQuantity.value)
  } else {

    //if the part already exists in the BOM we will temporarily add a new row, but that row might get combined on save depending on other factors
    const existingPart = findBestMatchDuplicatePart()
    if (existingPart && (existingPart.supplierId === newPartSupplier.value?.id || (!existingPart.supplierId && !newPartSupplier.value?.id)) && !existingPart.supplierConfirmed) {
      //if the existing part's supplier and the new part's supplier match (or if both are null) AND the existing part's supplier is NOT confirmed,
      // the new row quantity will be added to the existing row (ie, update the existing value) on save, so we need to add the id
      partForUpdate.id = existingPart.id
      //and combine the existing quantity with the new quantity to get the updated quantity value
      partForUpdate.quantity = Number(newPartQuantity.value) + Number(existingPart.quantity)

    }

    //now that our value is formatted correctly, we need to add it to the list that will be saved
    editParts.value.push(partForUpdate)
  }

  //either way we need to display a temporary row with the values entered into the add field,
  // so we'll make a copy of the new part (so we don't mess up the dropdown part we got it from)
  // add the entered quantity and supplier id to the "newPart" object and then add that to the localBomParts list
  // and update the partsMasterId value to the id value, then nullify the id
  let localNewPart = {...newPart.value, partsMasterId: newPart.value.id}
  localNewPart.id = null
  localNewPart.quantity = newPartQuantity.value
  localNewPart.supplierId = newPartSupplier.value?.id
  localNewPart.supplierName = newPartSupplier.value?.supplierName
  if(addCustom.value){
    localNewPart.description = customPartDescription.value
    localNewPart.partNumber = customPartNumber.value
  }
  localBomParts.value.push(localNewPart)
 closeAddPart()
}

const findBestEditedMatchDuplicatePart = () => {
  let possibleEditedMatches = editParts.value.filter(bp =>
      addCustom.value ?
          (bp.description === customPartDescription.value && bp.partNumber === customPartNumber.value) :
          (bp.partsMasterId === newPart.value.id))
  if(possibleEditedMatches?.length === 0) {
    return null
  }
  if(newPartSupplier?.value){
    //if new part has supplier, match must have same supplier and must not be confirmed
    return possibleEditedMatches.find(pm => (pm.supplierId && pm.supplierId === newPartSupplier.value.id && !pm.supplierConfirmed))
  }
  return possibleEditedMatches.find(pm => (!pm.supplierId))
}

const findBestMatchDuplicatePart = () => {
  //if it hasn't been previously added/edited, check the list of parts already in the bom
  let possibleMatches = localBomParts.value.filter(bp =>
      addCustom.value ?
          (bp.description === customPartDescription.value && bp.partNumber === customPartNumber.value) :
          (bp.partsMasterGroupUuid === newPart.value.partsMasterGroupUuid))
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
  <v-container id="bom-edit-view">
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
          <span class="body-medium grey--text text--darken-1 pl-2">#{{ selectedPermitPack?.permitPackLogNbr }}</span>
          <a-btn @click="emit('openAddForm')" size="small" variant="text" prepend-icon="mdi-plus" text="Add Part"/>
        </v-toolbar-title>
        <v-spacer></v-spacer>
        <div>
          <a-btn @click="cancel" variant="text" text="Cancel"></a-btn>
          <a-btn :disabled="editParts?.length === 0" @click="save" variant="outlined" prepend-icon="save" text="Save"></a-btn>
        </div>
      </v-toolbar>
    </v-row>
    <v-card v-if="showAddPart" class="mb-3">
      <v-card-title class="label-medium">Add Part</v-card-title>
      <v-card-text class="d-flex flex-wrap pr-0">
        <a-autocomplete
            :items="partsList"
            :value="newPart"
            :filter="newPartSearch"
            :loading = partsMasterLoading
            @input="selectNewPart"
            label="Part (Find in Parts Master by Description, Part Number)"
            clearable
            menu-props="closeOnContentClick"
            class="one-hunned new-part-autocomplete pr-4"
        >
          <template v-slot:no-data>
            <div class="d-flex align-baseline">
            <span class="px-2">No data available,</span>
            <span class="primary--text underline clickable" @click="[addCustom=true, selectNewPart(customPartPlaceholder)]">Add Custom Part</span>
            </div>
          </template>
          <template v-slot:item="{item}">
            {{item.description}} <span v-if="item.partNumber?.length > 0">({{item.partNumber}})</span>
          </template>
          <template v-slot:selection="{item}">
            {{item.description}} <span v-if="item.partNumber?.length > 0">({{item.partNumber}})</span>
          </template>
        </a-autocomplete>

        <div v-if="addCustom" class="d-flex one-hunned">
        <a-text-field
            type="text"
            v-model="customPartDescription"
            label="Description"
            customClasses="new-custom-part-field pr-4"
        />
          <a-text-field
            type="text"
            v-model="customPartNumber"
            label="Part Number"
            customClasses="new-custom-part-field pr-4"
        />
        </div>
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
            label="Supplier"
            clearable
            class="pr-4"
        />
      </v-card-text>
      <v-card-actions class="px-4 pt-0 pb-4">
        <v-spacer/>
        <a-btn variant="text" @click="closeAddPart" text="Cancel"></a-btn>
        <a-btn :disabled="!newPart || !newPartQuantity" @click="addCustom ? addNewCustomPartToList() : addNewPartToList()" text="Add"></a-btn>
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
      item-key="index"
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
    <ConfirmationDialog :open-dialog="showPartsMasterDuplicateDialog"
                        @confirm="confirmPartsMasterDupe"
                        @cancel="[addNewPartToList(), showPartsMasterDuplicateDialog = false]"
                        @close-dialog="closeDupeDialog"
                        :disable-confirm="!selectedPartDupe"
    >
      <template v-slot:title>
        <div class="d-flex justify-space-between one-hunned">
          <span>Did you mean one of these parts?</span>
          <a-btn variant="text" icon prepend-icon="close" @click="closeDupeDialog"></a-btn>
        </div>
      </template>
        <div class="pb-4">
          <v-radio-group v-model="selectedPartDupe">
            <template v-slot:label><span class="label-large">Existing Parts</span></template>
            <v-radio v-for="part in partsMasterDupes" :value="part">
              <template v-slot:label>
                <div>
                <div class="label-medium">Description: {{part.description}}</div>
                <div><span class="label-medium">Part Number:</span> {{part.partNumber}}</div>
                <div><span class="label-medium">Type: </span>{{part.objectType}}</div>
                <div><span class="label-medium">Manufacturer: </span>{{part.brand}}</div>
                </div>
              </template>
            </v-radio>
          </v-radio-group>
        </div>
      <v-divider/>
        <div class="pt-4">
          <div class="label-large">Your Custom Part</div>
          <div class="label-medium pt-2">Description: {{customPartDescription}}</div>
          <div><span class="label-medium">Part Number:</span> {{customPartNumber}}</div>
          <div><span class="label-medium">Type: </span>Parts Custom</div>
        </div>
      <template v-slot:yes>Yes, use existing part</template>
      <template v-slot:no>No, add my custom part</template>
    </ConfirmationDialog>
  </v-container>
</template>

<style scoped lang="scss">
#bom-edit-view .fix-toggle-opacity:before {
  background-color: unset !important;
}
.new-custom-part-field {
}
.new-part-quantity {
  max-width: 100px;
}


</style>
