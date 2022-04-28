<template>
  <div class="proposal-container" :style="styles">
    <slot>Missing Children</slot>
  </div>
</template>
<script>
import { mapState } from 'vuex'

export default {
  name: 'Container',
  props: ['blockStyle', 'themeKey'],
  computed: {
    styles() {
      return { ...(this.theme[this.themeKey] ?? {}), ...this.blockStyle }
    },
    ...mapState({
      theme: (state) => state.proposal.theme,
    })
  },
}
</script>
