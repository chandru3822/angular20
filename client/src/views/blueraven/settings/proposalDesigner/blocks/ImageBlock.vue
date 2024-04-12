<template>
  <div class="proposal-img" :style="styles">
    <img-proxy
      v-if="blockValue.uuid"
      :uuid="blockValue.uuid"
      alt="an image block"
    />
    <img v-else :src="blockValue.url" alt="an image block" loading="lazy" />
  </div>
</template>

<script setup>
import ImgProxy from '@/components/ImgProxy'
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
  },
  blockValue: {
    type: Object,
    required: true
  }
})

const styles = computed(() => {
  return { ...(theme.value[props.themeKey] ?? {}), ...props.blockStyle }
})
</script>
<style lang="scss" scoped>
.proposal-img img {
  max-width: 100%;
  object-fit: contain;
}
</style>
