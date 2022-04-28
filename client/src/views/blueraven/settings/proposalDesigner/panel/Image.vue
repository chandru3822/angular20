<template>
  <div>
    <image-selector-widget ref="imageSelector" />
    <v-btn @click="openSelectImage('backgroundImage')">Open Image</v-btn>
  </div>
</template>
<script>
import ImageSelectorWidget from './ImageSelectorWidget'

export default {
  components: { ImageSelectorWidget },
  methods: {
    async openSelectImage(){
      const result = await this.$refs.imageSelector.open()
      if (result && result.url !== undefined){
        this.$emit('input', result)
      }
    }
  }
}
</script>
