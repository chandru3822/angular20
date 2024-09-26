<template>
  <div>
    <div
      class="node-group transparent"
      :key="child.id"
      v-for="child in sortedChildren"
    >
      <div
        class="node d-flex justify-space-between body-large align-center"
        :class="{ selected: selected && selected.id === child.id }"
        @click="handleClick(child)"
      >
        <div>
          {{ child.displayName }}
          <span v-if="child.modified">*</span>
        </div>
        <a-btn
          v-if="hasChildren(child.id)"
          :variant="selected && selected.id === child.id ? '' : 'text'"
          :prepend-icon="child.expanded ? 'mdi-chevron-up' : 'mdi-chevron-down'"
          :custom-classes="
            selected && selected.id === child.id ? 'white--text' : ''
          "
          @click.native.stop="expandCollapseNode(child)"
        />
      </div>
      <v-expand-transition>
        <div v-show="isExpanded(child)" class="pa-0 node-container">
          <nested-tree
            class="node-sub"
            v-on="$listeners"
            :children="filterByParentId(child.id)"
            :sort-by-id="sortById"
          />
        </div>
      </v-expand-transition>
    </div>
  </div>
</template>
<script setup>
import { toRefs, computed, ref, watch, onMounted } from 'vue'
import useProposalStore from '../store.js'
import { storeToRefs } from 'pinia'

const store = useProposalStore()
const { selectedId } = storeToRefs(store)

const props = defineProps({
  children: {
    type: Array,
    default: function () {
      return []
    }
  },
  sortById: {
    type: Boolean,
    default: true
  },
  expandAll: {
    type: Boolean,
    default: true
  }
})
const { children, sortById, expandAll } = toRefs(props)
const expanded = ref([])

const blockOrderSorter = (a, b) => {
  if (a.blockOrder > b.blockOrder) {
    return 1
  }
  if (a.blockOrder < b.blockOrder) {
    return -1
  }
  return 0
}

onMounted(() => {
  for (let i = 0; i < sortedChildren.value.length; i++) {
    expanded.value.push(i)
    sortedChildren.value[i].expanded = true
  }
})

const emit = defineEmits(['select'])
const dragging = ref(false)

const selected = computed(() => {
  return store.selectedBlock
})
watch(selectedId, async () => {})
const sortedChildren = computed(() => {
  if (props.sortById) {
    return children.value
  } else {
    return children.value?.slice().sort(blockOrderSorter)
  }
})

const filterByParentId = (parent) => {
  return store.filterByParentId(parent)
}
const hasChildren = (parent) => {
  const children = filterByParentId(parent)
  return children.length > 0
}
const handleClick = (node) => {
  store.setSelected(node.id)
  emit('select', node.id)
}

const isExpanded = (node) => {
  const itemIndex = sortedChildren.value.indexOf(node) //index of the item in the children prop
  const index = expanded.value.indexOf(itemIndex) //index of the itemIndex in the expanded ref which determines which elements in the list are expanded/collapsed
  return index >= 0
}

const expandCollapseNode = (node) => {
  const itemIndex = sortedChildren.value.indexOf(node) //index of the item in the children prop
  const index = expanded.value.indexOf(itemIndex) //index of the itemIndex in the expanded ref which determines which elements in the list are expanded/collapsed
  if (node?.expanded) {
    // if it's expanded, we want to collapse it by removing it from the expanded array
    expanded.value.splice(index, 1)
    node.expanded = false
  } else {
    // if it's not expanded, we want to expand it by adding it to the expanded array
    expanded.value.push(itemIndex)
    node.expanded = true
  }
}

const collapseExpandAllNodes = (expand) => {
  expanded.value = []
  for (let i = 0; i < sortedChildren.value.length; i++) {
    const node = sortedChildren.value[i]
    node.expanded = expand
    if (expand === true) {
      expanded.value.push(i)
    }
  }
}

watch(expandAll, () => {
  collapseExpandAllNodes(expandAll.value)
})
</script>
<style lang="scss" scoped>
.node-container {
  &.is-dragging {
    cursor: grabbing;
  }
}

.node {
  cursor: pointer;
  padding: 0.2rem 0.4rem;
  //background-color: white;
  min-height: 24px;

  &:hover {
    background-color: #e0e0e069;
  }

  &.selected {
    background-color: var(--v-primary-base) !important;
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

.transparent {
  background-color: transparent;
}
</style>
<style lang="scss">
#props-designer-tree .v-expansion-panel-content__wrap {
  padding: 0;
}
#props-designer-tree .v-expansion-panel--active:not(:first-child),
.v-expansion-panel--active + .v-expansion-panel {
  margin-top: 0;
}
</style>
