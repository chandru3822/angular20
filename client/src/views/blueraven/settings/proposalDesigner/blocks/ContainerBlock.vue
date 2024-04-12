<template>
  <div class="proposal-container" :style="styles">
    <slot>Missing Children</slot>
  </div>
</template>
<script setup>
import { computed } from 'vue'
import useProposalStore from '../store.js'
import { storeToRefs } from 'pinia'

const store = useProposalStore()
const { theme } = storeToRefs(store)

const props = defineProps({
  themeKey: {
    type: String
  },
  blockStyle: {
    type: Object
  }
})

const styles = computed(() => {
  return { ...(theme.value[props.themeKey] ?? {}), ...props.blockStyle }
})
</script>
