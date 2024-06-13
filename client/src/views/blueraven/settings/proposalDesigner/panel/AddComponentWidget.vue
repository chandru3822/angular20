<template>
  <v-card flat>
    <v-card-title>Add Component Block</v-card-title>
    <div class="d-flex flex-column px-4">
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
      <div v-if="newComponent && newComponent !== PAGE_BLOCK">
        <v-card flat class="text-left px-3" color="transparent">
          <v-card-title class="px-0 pt-0">Parent</v-card-title>
          <v-card-text>
           <a-text-field :value="parentBlock.displayName" hint="Please select parent block from pdf or tree tab." :rules="parentRules()">
           </a-text-field>
          </v-card-text>
        </v-card>
      </div>
      <div v-if="newComponent === PAGE_BLOCK || (!!parentBlock.id && parentBlock.blockTypeId !== TEXT_BLOCK.typeId)" class="pb-4">
      <v-card flat class="text-left px-3" color="transparent">
        <v-card-title class="px-0 pt-0">Location</v-card-title>
        <LocationSelectorWidget attr="pageLocation" :existing-blocks="existingBlocks" @input="setLocation($event)"/>
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

const store = useProposalStore()
const props = defineProps({
  existingBlocks:Array,
})

const selected = computed(() => store.selectedBlock)
const { selectedId } = storeToRefs(store)

const parentBlock = ref({})
const parentRules = () => [
    () =>  (parentBlock) || `Parent is required for block type ${newComponent.value.blockType}`,
    () =>  (parentBlock?.value?.blockTypeId !== TEXT_BLOCK.typeId) || `Parent Block cannot be a ${TEXT_BLOCK.label}`
  ]


watch(selectedId, async () => {
  parentBlock.value = selected.value
})


const PAGE_BLOCK = {
  id:'PageBlock',
  typeId:1,
  label: 'New Page',
  value: {}
}

const TEXT_BLOCK = {
  id: 'TextBlock',
  typeId: 3,
  label: 'Text Block',
  value: {
    type: 'doc',
    content: [
      {
        type: 'paragraph',
        content: [
          {
            type: 'text',
            text: 'Add text here'
          }
        ]
      }
    ]
  }
}
const IMAGE_BLOCK = {
  id: 'ImageBlock',
  label: 'Image Block',
  typeId: 4,
  value: { url: 'https://picsum.photos/200' }
}
const CONTAINER_BLOCK = {
  id: 'ContainerBlock',
  label: 'Container Block',
  typeId: 2,
  value: {}
}
const PLACEHOLDER_BLOCK = {
  id: 'PlaceholderBlock',
  label: 'Placeholder Block',
  typeId: 5,
  value: {}
}

const AVAILABLE = {
  PageBlock: [TEXT_BLOCK, IMAGE_BLOCK, CONTAINER_BLOCK, PLACEHOLDER_BLOCK],
  ContainerBlock: [TEXT_BLOCK, IMAGE_BLOCK, CONTAINER_BLOCK, PLACEHOLDER_BLOCK]
}
const BLOCK_TYPES = [PAGE_BLOCK,TEXT_BLOCK, IMAGE_BLOCK, CONTAINER_BLOCK, PLACEHOLDER_BLOCK]
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

const setLocation = (locationInfo) => {
  parentId.value = locationInfo.parentId
  const siblings = store.filterByParentId(locationInfo.parentId)
  switch (locationInfo.location){
    case 'first':
    case 'before':
    case 'after':
    case 'last':
    default:
      let lastBlockOrderValue = 0
      for(let s of siblings){
        if(s.blockOrder > lastBlockOrderValue){
          lastBlockOrderValue = s.blockOrder
        }
      }
      blockOrder.value = lastBlockOrderValue + 1
  }
}

const emit = defineEmits(['cancel', 'input'])

const availableBlocks = computed(() => {
  return BLOCK_TYPES
})
const newComponentReadyToAdd = computed(() => {
  if(!newComponent || blockOrder.value === null){
    return false
  }
  if(newComponent.value === PAGE_BLOCK){
    return true
  }
  return true
})
const add = ({ id, typeId, value }) => {
  debugger
  emit('input', { blockType: id, blockTypeId: typeId, ...value, blockOrder: blockOrder.value, parentId: parentId.value })
  newComponent.value = null
}
</script>
<style lang="scss"></style>
