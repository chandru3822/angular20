<template>
  <v-col cols="12" class="spinner-container">
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
    size: Number
  }
}
</script>

<style scoped lang="scss">
.spinner-container {
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  position: absolute;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  margin: auto;
  background-color: var(--v-secondary-base);
  opacity: .5;
}
</style>
