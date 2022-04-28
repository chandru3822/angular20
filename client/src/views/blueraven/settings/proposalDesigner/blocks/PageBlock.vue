<template>
  <div class="proposal-page" :style="styles">
    <slot>Page data goes here</slot>
  </div>
</template>

<script>
import { mapState } from 'vuex'

export default {
  name: 'PageBlock',
  props: ['blockStyle', 'themeKey'],
  computed: {
    styles() {
      return { ...(this.theme[this.themeKey] ?? {}), ...this.blockStyle }
    },
    ...mapState({
      theme: (state) => state.proposal.theme,
    }),
  },
}
</script>
<style lang="scss" scoped>
.proposal-page {
  //padding and height are set in the print css
  padding: 20px;
  min-height: 600px;
  overflow: hidden;
  background-color: white;
  box-shadow: 0 0 5px 0 darkgrey;

  &:not(:last-child) {
    //border-bottom: 1px solid red;
    margin-bottom: 10px;
  }
}
</style>
