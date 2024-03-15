<template>
  <div class="proposal-container" :style="styles">
    <slot>Missing Children</slot>
  </div>
</template>
<script setup>
import { mapState } from 'vuex'
import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'

//@kaleb??
const props = defineProps({
  themeKey: {
    type: String
  },
  blockStyle: {
    type: Object
  },
})
//@kaleb not sure if these map state things are right
const { theme } = mapState({
  theme: (state) => state.proposal.theme,
})

const styles = computed(() => {
  return { ...(theme.value[props.themeKey] ?? {}), ...props.blockStyle }
})


</script>
