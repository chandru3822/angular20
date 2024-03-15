<template>
  <v-card flat v-if="availableBlocks.length > 0">
    <v-card-title>Add Component</v-card-title>
    <div class="d-flex">
      <v-select
          outlined
          dense
          v-model="newComponent"
          :items="availableBlocks"
          item-text="label"
          item-value="id"
          return-object
          single-line
      />
      <a-btn
          color="primary"
          :disabled="!newComponent"
          @click="add(newComponent)"
          text="Add"
      ></a-btn>
    </div>
  </v-card>
</template>
<script setup>
import {getCurrentInstance, toRefs, computed, ref, onMounted, watch} from 'vue'

const store = vueInstance.$store

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
const IMAGE_BLOCK = {id: 'ImageBlock', label: 'Image Block', typeId: 4, value: {url: 'https://picsum.photos/200'}}
const CONTAINER_BLOCK = {id: 'ContainerBlock', label: 'Container Block', typeId: 2, value: {}}
const PLACEHOLDER_BLOCK = {id: 'PlaceholderBlock', label: 'Placeholder Block', typeId: 5, value: {}}

const AVAILABLE = {
  'PageBlock': [TEXT_BLOCK, IMAGE_BLOCK, CONTAINER_BLOCK, PLACEHOLDER_BLOCK],
  'ContainerBlock': [TEXT_BLOCK, IMAGE_BLOCK, CONTAINER_BLOCK, PLACEHOLDER_BLOCK]
}
const newComponent = ref(null)

const emit = defineEmits(['input'])

const availableBlocks = computed(() => {
  const selected = store.getters.selectedBlock
  if (!selected) {
    return []
  }
  return AVAILABLE[selected.blockType] ?? []
})
const add = ({id, typeId, value}) => {
  emit('input', {blockType: id, blockTypeId: typeId, blockValue: value})
  newComponent.value = null
}
</script>
<style lang="scss"></style>
