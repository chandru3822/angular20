<template>
  <v-col class="spinner-container" :class="{'transparent': transparent, 'centered': centered}">
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
    transparent: Boolean,
    centered: Boolean
  }
}
</script>

<style scoped lang="scss">
.spinner-container {
  z-index: 1;
  background-color: var(--v-secondary-base);
  opacity: .5;
}

.transparent {
  background-color: transparent;
}

.centered {
  text-align: center;
}
</style>
