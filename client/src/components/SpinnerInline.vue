<template>
  <v-col class="spinner-container" :class="{'transparent': transparent, 'centered': centered}">
    {{text}}
    <v-progress-circular
        indeterminate
        :size="size"
        :color="spinnerColor"
    ></v-progress-circular>
  </v-col>
</template>

<script setup>
import { toRefs, computed } from 'vue'

const props = defineProps({
  spinnerColor: String,
  size: Number,
  text: String,
  transparent: Boolean,
  centered: Boolean
})
const { spinnerColor, size, text, transparent, centered } = toRefs(props)

</script>

<style scoped lang="scss">
.spinner-container {
  z-index: 1;
  opacity: .5;
}

.transparent {
  background-color: transparent;
}

.centered {
  text-align: center;
}
</style>
