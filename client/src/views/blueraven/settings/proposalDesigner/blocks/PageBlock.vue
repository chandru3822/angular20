<template>
  <div class="proposal-page" v-proposal-style="styles">
    <slot>Page data goes here</slot>
  </div>
</template>

<script>
import { mapState } from 'vuex'
import constants from '@/helpers/constants'

const styleUpdatedFn = function(el, binding) {
  const replacer = {
    'backgroundImage': (value) => {
      return `url(${constants.VUE_APP_BASE_API}/public/image/${value}?q=80&w=1080)`
    }
  }
  Object.entries(binding?.value).forEach(([key, value]) => {
    let newVal = value
    let newKey = key

    if (newKey.startsWith('@')) {
      newKey = newKey.split('@')[1]
      const replacerElement = replacer[newKey]
      if (value !== undefined && replacerElement) {
        newVal = replacerElement(value)
      }
    }
    el.style[newKey] = (newVal !== undefined) ? newVal : ''
  })
}

export default {
  name: 'PageBlock',
  props: ['blockStyle', 'themeKey'],
  directives: {
    'proposal-style': {
      bind: styleUpdatedFn,
      update: styleUpdatedFn
    }
  },
  computed: {
    styles() {
      return { ...(this.theme[this.themeKey] ?? {}), ...this.blockStyle }
    },
    ...mapState({
      theme: (state) => state.proposal.theme
    })
  }
}
</script>
<style lang="scss" scoped>
.proposal-page {
  width: 1125px;
  min-height: 794px;
  overflow: hidden;
  background-color: white;
  box-shadow: 0 0 5px 0 darkgrey;
  box-sizing: border-box;

  &:not(:last-child) {
    margin-bottom: 10px;
  }
}
</style>
