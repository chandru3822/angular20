<template>
  <img v-if="uuid !== undefined" loading="lazy" :src="srcUrl" />
</template>
<script setup>
import constants from '@/helpers/constants'
import { toRefs, computed } from 'vue'

const props = defineProps({
  uuid: String,
  width: {
    type: Number,
    default: 1080
  },
  height: Number,
  quality: Number
})
const { uuid, width, height, quality } = toRefs(props)


    const srcUrl = computed(() => {
      const queryParams = []
      if (quality.value) {
        queryParams.push('q=' + quality.value)
      }

      if (height.value) {
        queryParams.push('h=' + height.value)
      }

      if (width.value) {
        queryParams.push('w=' + width.value)
      }
      return `${constants.VUE_APP_BASE_API}/public/image/${uuid.value}?${queryParams.join('&')}`
    })
</script>
