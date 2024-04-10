<template>
  <v-card flat>
    <ImageSelectorWidget ref="imageSelector" />
    <a-btn @click="openSelectImage()" color="unset" text="Open Image"></a-btn>
  </v-card>
</template>
<script setup>
import ImageSelectorWidget from './ImageSelectorWidget'
import { ref } from 'vue'

const imageSelector = ref(null)
const emit = defineEmits(['input'])

const openSelectImage = async () => {
  try {
    const result = await imageSelector.value.open()
    if (result && result.uuid !== undefined) {
      emit('input', result)
    }
  } catch (e) {
    //ignore this
  }
}
</script>
