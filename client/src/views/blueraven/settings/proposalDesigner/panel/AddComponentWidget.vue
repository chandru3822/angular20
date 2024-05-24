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

        </v-card>
      </div>
      <div v-if="newComponent === PAGE_BLOCK" class="pb-4">
      <v-card flat class="text-left px-3" color="transparent">
        <v-card-title class="px-0 pt-0">Location</v-card-title>
        <InsertLocationWidget attr="pageLocation" :existing-blocks="existingBlocks"/>
      </v-card>
        <v-card flat color="transparent" v-if="location === 1 || location === 2">
          Select an existing block
          <a-select
              density="compact"
              v-model="relativeBlock"
              :items="existingBlocks"
              :item-title="(i) => `${i.id} - ${i.blockType}`"
              item-value="id"
              return-object
              single-line
          />
        </v-card>
      </div>
<!--      <div v-if-->
      <div class="d-flex justify-end">
        <v-col cols="2">
        <a-btn text="Cancel" variant="outlined" @click="emit('cancel')"/>
        </v-col>
        <v-col cols="10">
      <a-btn
          class="one-hunned"
        color="primary"
        :disabled="newComponentReadyToAdd"
        @click="add(newComponent)"
        text="Add"
      ></a-btn>
        </v-col>
      </div>
    </div>
  </v-card>
</template>
<script setup>
import { computed, ref } from 'vue'
import useProposalStore from '../store.js'
import {typeOf} from "uri-js/dist/esnext/util.js";
import InsertLocationWidget from "@/views/blueraven/settings/proposalDesigner/panel/InsertLocationWidget.vue";

const store = useProposalStore()
const props = defineProps({
  existingBlocks:Array,
})

const selected = computed(() => store.selectedBlock)

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
const location = ref(null)
const newComponent = ref(null)

const emit = defineEmits(['cancel'])

const availableBlocks = computed(() => {
  return BLOCK_TYPES
})
const newComponentReadyToAdd = computed(() => {
  if(!newComponent){
    return false
  }
  if(newComponent.value === PAGE_BLOCK){
    return location !== null
  }
  return true
})
const add = ({ id, typeId, value }) => {
  emit('input', { blockType: id, blockTypeId: typeId, blockValue: value })
  newComponent.value = null
}
</script>
<style lang="scss"></style>
