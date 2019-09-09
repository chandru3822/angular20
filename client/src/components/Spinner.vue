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
  z-index: 1;
  background-color: var(--v-secondary-base);
  opacity: .5;
}
</style>
