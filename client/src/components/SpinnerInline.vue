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

<script>
export default {
  name: 'Spinner',
  props: {
    spinnerColor: String,
    size: Number,
    text: String,
    transparent: Boolean,
    centered: Boolean
  }
}
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
