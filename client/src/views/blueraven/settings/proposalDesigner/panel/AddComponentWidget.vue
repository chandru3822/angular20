<template>
  <v-card flat>
    <v-card-title>Add Component</v-card-title>
    <div class="d-flex flex-column px-4">
      <a-select
          density="compact"
          v-model="newComponent"
          :items="availableBlocks"
          item-title="label"
          item-value="id"
          return-object
          single-line
      />
      <div v-if="newComponent === PAGE_BLOCK" class="pb-4">
      <v-card flat class="text-left px-3" color="transparent">
        Location:
        <v-btn-toggle
            v-model="location"
            group
        >
        <a-btn
            size="small"
            class="mx-0 mt-1 primary--text"
            color="unset"
            text="FIRST PAGE"
            value="firstPage"
        ></a-btn>
          <a-btn
            size="small"
            class="mx-0 mt-1 primary--text"
            color="unset"
            text="BEFORE BLOCK"
            value="before"
        ></a-btn>
          <a-btn
            size="small"
            class="mx-0 mt-1 primary--text"
            color="unset"
            text="AFTER BLOCK"
            value="after"
        ></a-btn>
        <a-btn
            size="small"
            class="mx-0 mt-1 primary--text"
            color="unset"
            text="LAST PAGE"
            value="lastPage"
        ></a-btn>
        </v-btn-toggle>
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
      <div class="d-flex justify-end">
        <v-col cols="2">
        <a-btn text="Cancel" variant="outlined"/>
        </v-col>
        <v-col cols="10">
      <a-btn
          class="one-hunned"
        color="primary"
        :disabled="!newComponent"
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

const store = useProposalStore()
const props = defineProps({
  existingBlocks:Array,
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
const location = ref(null)
const newComponent = ref(null)
const relativeBlock = ref(null)

const emit = defineEmits(['input'])

const availableBlocks = computed(() => {
  return BLOCK_TYPES
})
const add = ({ id, typeId, value }) => {
  emit('input', { blockType: id, blockTypeId: typeId, blockValue: value })
  newComponent.value = null
}
</script>
<style lang="scss"></style>
