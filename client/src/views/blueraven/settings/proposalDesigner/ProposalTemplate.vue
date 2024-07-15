<template>
  <fragment>
    <component
      class="block-ui"
      :is="blocks[child.blockType]"
      :key="child.id"
      :class="{
        debug: debug,
        editable: editable,
        selected: selectedId === child.id
      }"
      :style="{ zIndex: 100 + depth }"
      :data-type="child.blockType"
      :data-id="child.id"
      :data-parent="child.parentId"
      :data-depth="depth"
      :data-order="child.blockOrder"
      :editable="editable"
      v-bind="{ ...child }"
      v-for="child in sortedChildren"
    >
      <proposal-template
        :children="filterByParentId(child.id)"
        :debug="debug"
        :depth="depth + 1"
        :editable="editable"
      />
    </component>
  </fragment>
</template>
<script setup>
import { Fragment } from 'vue-frag'
import Blocks from './blocks'
import { toRefs, computed } from 'vue'
import useProposalStore from './store.js'

const store = useProposalStore()
const blocks = { ...Blocks }
const props = defineProps({
  debug: {
    type: Boolean,
    default: false
  },
  editable: {
    type: Boolean,
    default: false
  },
  depth: {
    type: Number,
    default: 0
  },
  children: {
    type: Array,
    default: function () {
      return []
    }
  }
})

const { debug, editable, depth, children } = toRefs(props)

const sortedChildren = computed(() => {
  return children.value?.slice().sort((a, b) => {
    if (a.blockOrder > b.blockOrder) {
      return 1
    }
    if (a.blockOrder < b.blockOrder) {
      return -1
    }
    return 0
  })
})
const selectedId = computed(() => {
  return editable.value ? store.selectedId : -1
})

const filterByParentId = (parent) => {
  return store.filterByParentId(parent)
}
</script>
<style lang="scss">
.block-ui {
  user-select: none;
  &.editable {
    user-select: auto;
  }

  &.selected {
    outline: 1px solid #2196f3 !important;
  }

  &:hover {
    outline: 2px dashed white !important;
  }

  &.debug {
    position: relative;

    &:hover {
      outline: 1px dashed rgb(0 0 0 / 30%);
    }

    &:hover:after {
      text-transform: none;
      content: attr(data-type);
      position: absolute;
      top: 0;
      right: 0;
      padding: 0 5px;
      color: white;
      background-color: #2196f3;
      border-radius: 0 0 0 4px;
      font-size: 12px;
      opacity: 0.9;
      width: 75px;
      overflow: hidden;
      text-overflow: ellipsis;
    }
  }
}
</style>
