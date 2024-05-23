<template>
  <draggable
    class="node-container"
    :class="{ 'is-dragging': dragging }"
    :list="sortedChildren"
    :move="checkMove"
    :disabled="true"
    @start="dragging = true"
    @end="dragging = false"
  >
    <div class="node-group" :key="child.id" v-for="child in children">
      <div
        class="node"
        :class="{ selected: selected && selected.id === child.id }"
        @click="handleClick(child)"
      >
<!--        #{{ child.id }} - {{ child.blockType }}-->
        {{ child.displayName }}
        <span v-if="child.modified">*</span>
      </div>
      <nested-tree
        class="node-sub"
        v-on="$listeners"
        :children="filterByParentId(child.id)"
      />
    </div>
  </draggable>
</template>
<script setup>
import debounce from 'lodash.debounce'
import draggable from 'vuedraggable'
import { toRefs, computed, ref } from 'vue'
import useProposalStore from '../store.js'

const store = useProposalStore()

const props = defineProps({
  children: {
    type: Array,
    default: function () {
      return []
    }
  }
})
const { children } = toRefs(props)

const blockOrderSorter = (a, b) => {
  if (a.blockOrder > b.blockOrder) {
    return 1
  }
  if (a.blockOrder < b.blockOrder) {
    return -1
  }
  return 0
}

const emit = defineEmits(['select'])
const dragging = ref(false)

const selected = computed(() => {
  return store.selectedBlock
})
const sortedChildren = computed(() => {
  return children.value?.slice().sort(blockOrderSorter)
})

const filterByParentId = (parent) => {
  return store.filterByParentId(parent)
}
const handleClick = (node) => {
  store.setSelected(node.id)
  emit('select', node.id)
}
//todo; this should register in the undo history
const checkMove = debounce((evt) => {
  const { draggedContext: active, relatedContext: target } = evt ?? {}

  if (!active || !active.element) {
    return false
  }

  const isSameParent = active?.element?.parentId === target?.element?.parentId
  if (!isSameParent) {
    return false
  }

  const prev = target.list[target.index - 1]

  const pos = prev
    ? (prev?.blockOrder - target?.element?.blockOrder) / 2 +
      target?.element?.blockOrder
    : target?.element?.blockOrder + 1

  // console.log({active, target, pos})

  //
  // const draggedItem = draggedContext?.element
  // const targetItem = relatedContext?.element
  //
  // if (!targetItem) {
  //   return
  // }
  //
  // const isPage = draggedItem?.blockType === 'PageBlock'
  // if (!isPage && targetItem?.parentId === undefined || isPage && targetItem?.parentId !== undefined) {
  //   return false
  // }
  //
  // const canDrop = false
  //
  // const isTextBlock = draggedItem?.blockType === 'TextBlock' && targetItem?.blockType === 'TextBlock'
  //
  // const isRoot = targetItem?.parentId === undefined
  //
  // const isSameParent = draggedItem?.parentId === targetItem?.parentId
  //
  // const targetChildren = this.$store.getters.filterByParentId(targetItem?.parentId)
  //   .slice()
  //   .sort(blockOrderSorter)
  //
  // const indexOf = targetChildren.indexOf(targetItem)
  // const next =  targetChildren[indexOf + 1]
  //
  //
  // console.log({ indexOf, targetItem, next })
  //
  // let newOrder = targetChildren?.blockOrder + 1
  // if (next){
  //   newOrder = Math.abs(((targetItem?.blockOrder - next?.blockOrder) / 2)) + next?.blockOrder
  // }
  //
  // // console.log({ draggedItem, targetItem })
  store.updatePosition({
    blockId: active?.element.id,
    pos,
    parentId: target?.element?.parentId
  })
}, 250)
</script>
<style lang="scss" scoped>
.node-container {
  &.is-dragging {
    cursor: grabbing;
  }
}

.node {
  cursor: pointer;
  display: block;
  padding: 0.2rem 0.4rem;
  //background-color: white;

  &:hover {
    background-color: #e0e0e069;
  }

  &.selected {
    background-color: var(--v-primary-base);
    color: white;

    ~ .node-container {
      background-color: #e0e0e0;

      &:hover .node:hover {
        background-color: #c1bfbf;
      }
    }

    //&:hover{
    //  ~ .node-container {
    //    background-color:red;
    //  }
    //}
  }
}

.node-sub {
  padding: 0 0 0 1rem;
}
</style>
