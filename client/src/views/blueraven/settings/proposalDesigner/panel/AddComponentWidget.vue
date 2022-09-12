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
      <v-btn color="primary" :disabled="!newComponent" @click="add(newComponent)">Add</v-btn>
    </div>
  </v-card>
</template>
<script>
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
const IMAGE_BLOCK = { id: 'ImageBlock', label: 'Image Block', typeId: 4, value: { url: 'https://picsum.photos/200' } }
const CONTAINER_BLOCK = { id: 'ContainerBlock', label: 'Container Block', typeId: 2, value: {} }
const PLACEHOLDER_BLOCK = { id: 'PlaceholderBlock', label: 'Placeholder Block', typeId: 5, value: {} }

const AVAILABLE = {
  'PageBlock': [TEXT_BLOCK, IMAGE_BLOCK, CONTAINER_BLOCK, PLACEHOLDER_BLOCK],
  'ContainerBlock': [TEXT_BLOCK, IMAGE_BLOCK, CONTAINER_BLOCK, PLACEHOLDER_BLOCK]
}
export default {
  data() {
    return {
      newComponent: null
    }
  },
  computed: {
    availableBlocks() {
      const selected = this.$store.getters.selectedBlock
      if (!selected) {
        return []
      }
      return AVAILABLE[selected.blockType] ?? []
    }
  },
  methods: {
    add({ id, typeId, value }) {
      this.$emit('input', { blockType: id, blockTypeId: typeId, blockValue: value })
      this.newComponent = null
    }
  }
}
</script>
<style lang="scss"></style>
