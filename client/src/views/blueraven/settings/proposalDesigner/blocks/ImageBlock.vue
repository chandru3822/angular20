<template>
  <div class="proposal-img" :style="styles">
    <img-proxy v-if="blockValue.uuid" :uuid="blockValue.uuid" alt="an image block" />
    <img v-else :src="blockValue.url" alt="an image block" loading="lazy" />
  </div>
</template>


<script>
import { mapState } from 'vuex'
import ImgProxy from '@/components/ImgProxy'

export default {
  name: 'ImageBlock',
  components: { ImgProxy },
  props: {
    themeKey: {
      type: String
    },
    blockStyle: {
      type: Object
    },
    blockValue: {
      type: Object,
      required: true
    }
  },
  computed: {
    styles() {
      return { ...this.theme[this.themeKey] ?? {}, ...this.blockStyle }
    },
    ...mapState({
      theme: (state) => state.proposal.theme
    })
  }
}
</script>
<style lang="scss" scoped>
.proposal-img img {
  max-width: 100%;
  object-fit: contain;
}
</style>
