<template>
  <v-card flat>
    <ImageSelectorWidget ref="imageSelector" />
    <a-btn
        @click="openSelectImage('backgroundImage')"
        color="unset"
        text="Open Image"
    ></a-btn>
  </v-card>
</template>
<script setup>
import ImageSelectorWidget from './ImageSelectorWidget'
import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'


const imageSelector = ref(null)
const emit = defineEmits(['input'])

const openSelectImage = async() => {
  const result = await imageSelector.value.open()
  if (result && result.uuid !== undefined){
    emit('input', result)
  }
}
</script>
