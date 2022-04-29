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
<script>
import { Fragment } from 'vue-frag'
import Blocks from './blocks'

export default {
  name: 'block',
  components: {
    Fragment,
    ...Blocks
  },
  props: {
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
  },
  computed: {
    sortedChildren() {
      return this.children.slice().sort(((a, b) => {
        if (a.blockOrder > b.blockOrder) {
          return 1
        }
        if (a.blockOrder < b.blockOrder) {
          return -1
        }
        return 0
      }))
    },
    selectedId() {
      return this.editable ? this.$store.state.proposal.selectedId : -1
    }
  },
  methods: {
    filterByParentId(parent) {
      return this.$store.getters.filterByParentId(parent)
    }
  }
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
