<template>
  <v-card flat class="height-one-hunned">
    <v-card-title class="pb-0">Add Component Block</v-card-title>
    <div class="d-flex flex-column px-4">
      <v-card flat class="px-3 mb-4">
      <a-text-field type="string"
                    color="primary"
                    v-model="blockName"
                    dense
                    label="Block Name"
                    class="pb-2"
      ></a-text-field>
      <a-select
          density="compact"
          variant="outlined"
          v-model="newComponent"
          :items="availableBlocks"
          item-title="label"
          item-value="id"
          return-object
          label="Block Type"
      />
      </v-card>
      <div v-if="newComponent && newComponent !== PAGE_BLOCK">
        <v-card flat class="text-left px-3" color="transparent">
          <v-card-title class="px-0 py-0">Parent</v-card-title>
          <v-card-text>
           <a-text-field :value="parentBlock?.displayName" hint="Please select parent block from pdf or tree tab." :rules="parentRules()">
           </a-text-field>
          </v-card-text>
        </v-card>
      </div>
      <div v-if="newComponent === PAGE_BLOCK || (!!parentBlock.id && parentBlock.blockTypeId !== TEXT_BLOCK.typeId)" class="pb-4">
      <v-card flat class="text-left px-3" color="transparent">
        <v-card-title class="px-0 pt-0">Location</v-card-title>
        <v-card-text>
        <LocationSelectorWidget attr="pageLocation" :existing-blocks="siblings" @input="setLocation($event)"/>
        </v-card-text>
      </v-card>
      </div>
<!--      <div v-if-->
      <div class="d-flex justify-end mx-0">
        <a-btn text="Cancel" style="width: 25%" variant="outlined" class="mr-2" @click="emit('cancel')"/>
      <a-btn
          style="width: 70%"
        color="primary"
        :disabled="!newComponentReadyToAdd"
        @click="add(newComponent)"
        text="Add"
      ></a-btn>
      </div>
    </div>
  </v-card>
</template>
<script setup>
import {computed, ref, watch} from 'vue'
import useProposalStore from '../store.js'
import LocationSelectorWidget from "@/views/blueraven/settings/proposalDesigner/panel/LocationSelectorWidget.vue";
import {storeToRefs} from "pinia";
import {BLOCK_TYPES, PAGE_BLOCK, TEXT_BLOCK, IMAGE_BLOCK, CONTAINER_BLOCK, PLACEHOLDER_BLOCK} from "@/views/blueraven/settings/proposalDesigner/blocks/PropsDesignerConstants.js";

const store = useProposalStore()
const props = defineProps({
  existingBlocks:Array,
})
const emit = defineEmits(['cancel', 'input'])

const selected = computed(() => store.selectedBlock)
const { selectedId } = storeToRefs(store)

const parentBlock = ref({})
const parentRules = () => [
    () =>  (parentBlock) || `Parent is required for block type ${newComponent.value.blockType}`,
    () =>  (parentBlock?.value?.blockTypeId !== TEXT_BLOCK.typeId) || `Parent Block cannot be a ${TEXT_BLOCK.label}`
  ]


watch(selectedId, async () => {
  if(newComponent.value.typeId !== PAGE_BLOCK.typeId) {
    parentBlock.value = selected.value
  }
})

const siblings = computed(() => props.existingBlocks.filter(b => {
  if(!newComponent.value?.typeId){
    return false
  } else if(newComponent.value.typeId === PAGE_BLOCK.typeId){
    return b.parentId === undefined
  }
  return b.parentId === parentBlock?.value?.id
}))


const newComponent = ref({
  blockStyle:{
    backgroundPosition:"center center",
    backgroundSize:"cover",
    color:"#ffffff",
    display:"flex"
  },
  id:-1,
  version:14
})
const blockOrder = ref(null)
const parentId = ref(null)
const blockLocation = ref(null)
const blockName = ref(null)

const setLocation = (locationInfo) => {
  parentId.value = locationInfo.parentId
  blockLocation.value = locationInfo
}


const availableBlocks = computed(() => {
  return BLOCK_TYPES
})
const newComponentReadyToAdd = computed(() => {
  if(!newComponent || blockLocation.value === null){
    return false
  }
  if(newComponent.value === PAGE_BLOCK){
    return true
  }
  return true
})
const add = ({ id, typeId, value }) => {
  emit('input', {
    newBlock: {
      blockType: id,
      blockTypeId: typeId,
      blockValue: value,
      blockName: blockName.value,
      blockOrder: blockOrder.value,
      parentId: parentBlock.value.id,
      modified: true
    },
    blockLocation: {
      blockLocation: blockLocation.value.location,
      relativeBlock: blockLocation.value.relativeBlock
    }
  })
  newComponent.value = null
}
</script>
<style lang="scss"></style>
