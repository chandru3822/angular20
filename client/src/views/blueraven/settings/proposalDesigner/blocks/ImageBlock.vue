<template>
  <div class="proposal-img" :style="styles">
    <img-proxy v-if="blockValue.uuid" :uuid="blockValue.uuid" alt="an image block" />
    <img v-else :src="blockValue.url" alt="an image block" loading="lazy" />
  </div>
</template>


<script setup>
import { mapState } from 'vuex'
import ImgProxy from '@/components/ImgProxy'
import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'

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

//@kaleb not sure if these map state things are right
const { theme } = mapState({
  theme: (state) => state.proposal.theme,
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
