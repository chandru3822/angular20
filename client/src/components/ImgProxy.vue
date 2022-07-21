<template>
  <img v-if="uuid !== undefined" loading="lazy" :src="srcUrl" />
</template>
<script>
import constants from '@/helpers/constants'

export default {
  name: 'img-proxy',
  props: {
    uuid: String,
    width: {
      type: Number,
      default: 1080
    },
    height: Number,
    quality: Number
  },
  computed: {
    srcUrl() {
      const queryParams = []
      if (this.quality) {
        queryParams.push('q=' + this.quality)
      }

      if (this.height) {
        queryParams.push('h=' + this.height)
      }

      if (this.width) {
        queryParams.push('w=' + this.width)
      }
      return `${constants.VUE_APP_BASE_API}/public/image/${this.uuid}?${queryParams.join('&')}`
    }
  }
}
</script>
