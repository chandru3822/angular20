<template>
  <div class="proposal-page" v-proposal-style="styles">
    <slot>Page data goes here</slot>
  </div>
</template>

<script setup>
import { mapState } from 'vuex'
import constants from '@/helpers/constants'
import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'

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

const props = defineProps({
  themeKey: {
    type: String
  },
  blockStyle: {
    type: Object
  },
})

// @kaleb - not sure how to put this directive in
  // directives: {
  //   'proposal-style': {
  //     bind: styleUpdatedFn,
  //     update: styleUpdatedFn
  //   }
  // }

//@kaleb not sure if these map state things are right
  const { theme } = mapState({
    theme: (state) => state.proposal.theme,
  })

  const styles = computed(() => {
    return { ...(theme.value[props.themeKey] ?? {}), ...props.blockStyle }
  })
</script>
<style lang="scss" scoped>
.proposal-page {
  width: 1125px;
  min-height: 794px;
  overflow: hidden;
  background-color: white;
  box-shadow: 0 0 5px 0 darkgrey;
  box-sizing: border-box;
  position:relative;

  &:not(:last-child) {
    margin-bottom: 10px;
  }
}
</style>
