<template>
  <div class="viewport">
    <div
      class="screen"
      :style="{
        transform: `translateX(0vw) scale(${zoom / 100})`,
      }"
    >
      <slot />
      <div class="spacer" />
    </div>
    <div class="zoom-wrap" v-if="isZoomable">
      <zoom-control v-model="zoom" />
    </div>
  </div>
</template>
<script>
import ZoomControl from './Zoom.vue'
import { ProposalMutations } from '../store'

const findParent = (node, className) => {
  let nodeClassNames = node?.className?.split(' ') ?? []
  if (nodeClassNames.includes(className)) {
    return node
  }
  if (node.parentElement) {
    return findParent(node.parentElement, className)
  }
  return null
}

export default {
  name: 'Viewport',
  components: { ZoomControl },
  mounted() {
    document
      .getElementsByClassName('viewport')[0]
      .addEventListener('mousedown', this.handleClick, false)
  },
  beforeDestroy() {
    // document
    //   .getElementsByClassName('viewport')[0]
    //   .removeEventListener('mousedown', this.handleClick, false)
  },
  data() {
    return {
      isZoomable: false,
      zoom: 75
    }
  },
  methods: {
    handleClick({ target }) {
      const closest = findParent(target, 'block-ui')
      const type = closest?.getAttribute('data-type')
      if (type) {
        const id = parseInt(closest.getAttribute('data-id'), 10)
        this.$store.commit(ProposalMutations.SET_SELECTED, id)
      } else {
        this.$store.commit(ProposalMutations.SET_SELECTED, null)
      }
    }
  }
}
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
