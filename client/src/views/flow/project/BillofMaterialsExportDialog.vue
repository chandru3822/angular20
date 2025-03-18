<script setup>
/*
*@name BillofMaterialsExportDialog
*@author jess
*@date 3/18/25
*
*@description
*
*/
import ConfirmationDialog from "@/components/ConfirmationDialog.vue";
import VueClamp from "vue-clamp";
import {computed, ref, watch} from "vue";

const props = defineProps({
  openDialog: Boolean,
  bomParts: Array,
  headers: Array,
})

const emit = defineEmits(['download', 'close'])

const showConfirmed = ref(false)
const selected = ref([])
const selectedParts = ref([])

const filteredParts = computed(() => {
  if(showConfirmed.value){
    return props.bomParts
  }
  return props.bomParts.filter(p => !p.supplierConfirmed)
})

watch(selected, (newValue, oldValue) => {
  selectedParts.value = newValue
})

const downloadSelected = () => {
  emit('download', selectedParts.value)
}

</script>

<template>
  <ConfirmationDialog :openDialog="openDialog" full-size :disable-confirm="selected.length <= 0" @confirm="downloadSelected" @close="emit('close')" @cancel="emit('close')">
    <template v-slot:title>
  <span class="d-flex align-baseline pb-3">
  Export Material List
  <span class="body-medium pl-4 pr-2 grey--text text--darken-2">Show confirmed materials</span><v-switch v-model="showConfirmed" dense hide-details class=""/>
    </span>
      <v-spacer/>
      <a-btn icon prepend-icon="mdi-close" @click="emit('close')"/>
    </template>

    <template v-slot:default>
      <v-data-table
          id="bom-parts-table"
          :items="filteredParts"
          :headers="headers"
          v-model="selected"
          show-select
          group-by="objectType"
          :items-per-page="-1"
          disable-sort
          fixed-header
          hide-default-footer
          height="70vh"
          class="table-striped elevation-1"
      >
        <template v-slot:header.selection></template>
        <template v-slot:group.header="{ groupBy, group, headers, isOpen=true, toggle, remove }">
          <td :colspan="headers.length" class="grey lighten-5 group-header clickable" @click="toggle">
            <div class="one-hunned d-flex grey--text text--darken-1">
              <v-icon color="grey darken-1" v-if="isOpen">mdi-chevron-up</v-icon>
              <v-icon v-else color="grey darken-1">mdi-chevron-down</v-icon>
              {{ group }}
            </div>
          </td>
        </template>
        <template #item.description="{ item }">
          <v-tooltip top max-width="240">
            <template v-slot:activator="{ on, attrs }">
              <span v-bind="attrs" v-on="on">
          <vue-clamp autoresize :max-lines="3">
            {{item.description}}
          </vue-clamp>
              </span>
            </template>
            <!--tooltip text-->
            {{item.description}}
          </v-tooltip>
        </template>

        <template #item.supplierName="{ item }">
          <td class="supplier-col">
            <span v-if="!item.supplierName" class="grey--text body-medium">Unspecified</span>
            <span v-else class="body-medium">{{item.supplierName}}</span>
          </td>
        </template>
        <template #item.quantity="{ item }">
          <td class="text-end">
            <span >{{item.quantity}}</span>
          </td></template>
        <template #item.supplierConfirmed="{ item }">
          <td class="text-end">
            {{item.supplierConfirmed ? 'Confirmed' : ''}}
          </td>
        </template>
      </v-data-table>

    </template>

    <template v-slot:yes><v-icon size="20" class="align-self-center pr-1 pt-1">mdi-tray-arrow-down</v-icon>Download</template>
  </ConfirmationDialog>
</template>

<style scoped lang="scss">

</style>
