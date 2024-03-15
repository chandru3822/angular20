<template>
  <fragment>
    <component
      class="block-ui"
      :is="blockType"
      :key="child.id"
      :class="{
        'debug' : debug ,
        'editable' : editable,
        'selected': selectedId === child.id
      }"
      :style="{ zIndex: 100 + depth }"
      :data-type="blockType"
      :data-id="child.id"
      :data-parent="parentId"
      :data-depth="depth"
      :data-order="blockOrder"
      :editable="editable"
      v-bind="{ ...child }"
      v-for="{ blockType, blockOrder, parentId, ...child } in sortedChildren"
    >
      <block
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
import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'

const store = vueInstance.$store

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
    default: function() {
      return []
    }
  }
})
const { debug, editable, depth, children } = toRefs(props)


    const sortedChildren = computed(() => {
      return children.value?.slice().sort(((a, b) => {
        if (a.blockOrder > b.blockOrder) {
          return 1
        }
        if (a.blockOrder < b.blockOrder) {
          return -1
        }
        return 0
      }))
    })
    const selectedId = computed(() => {
      return editable.value ? store.state.proposal.selectedId : -1
    })

    const filterByParentId = (parent) => {
      return store.getters.filterByParentId(parent)
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
