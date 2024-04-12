<template>
  <div class="viewport">
    <div
      class="screen"
      :style="{
        transform: `translateX(0vw) scale(${zoom / 100})`
      }"
    >
      <slot></slot>
      <div class="spacer" />
    </div>
    <div class="zoom-wrap" v-if="isZoomable">
      <zoom-control v-model="zoom" />
    </div>
  </div>
</template>

<script setup>
import ZoomControl from './Zoom.vue'
import { ref, onMounted } from 'vue'
import useProposalStore from '../store.js'

const store = useProposalStore()

const findParent = (node, className) => {
  const nodeClassNames = node?.className?.split(' ') ?? []
  if (nodeClassNames.includes(className)) {
    return node
  }
  if (node.parentElement) {
    return findParent(node.parentElement, className)
  }
  return null
}

const isZoomable = ref(false)
const zoom = ref(75)

const handleClick = ({ target }) => {
  const closest = findParent(target, 'block-ui')
  const type = closest?.getAttribute('data-type')
  if (type) {
    const id = parseInt(closest.getAttribute('data-id'), 10)
    store.setSelected(id)
  } else {
    store.setSelected(null)
  }
}

onMounted(() => {
  document
    .getElementsByClassName('viewport')[0]
    .addEventListener('mousedown', handleClick, false)
})
// TODO: handle unmount
</script>
<style lang="scss" scoped>
.viewport {
  user-select: none;
  display: flex;
  flex: 1;
  justify-content: flex-start;
  align-content: center;
  height: calc(100vh - 115px);
  overflow: auto;
  border: 1px solid #f5f5f5;
  background-image: linear-gradient(
      45deg,
      #f5f5f5 25%,
      transparent 0,
      transparent 75%,
      #f5f5f5 0
    ),
    linear-gradient(
      45deg,
      #f5f5f5 25%,
      transparent 0,
      transparent 75%,
      #f5f5f5 0
    );
  background-position: 0 0, 13px 13px;
  background-size: 26px 26px;
  background-repeat: repeat;
}

.screen {
  //scroll-snap-type: y mandatory;
  //overflow: auto;
  margin: 25px auto;
  transform-origin: center top;

  & .spacer {
    height: 100px;
  }
}

.zoom-wrap {
  position: absolute;
  width: 25vw;
  bottom: 0;
  margin: 0 25vw;
  z-index: 1000;
  background: white;
  outline: 1px solid #ccc;
  padding: 0 10px;
  transition: opacity 0.3s;
  opacity: 0;
}

.viewport:hover .zoom-wrap {
  opacity: 1;
}
</style>
