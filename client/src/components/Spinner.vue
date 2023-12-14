<template>
  <v-col cols="12" class="spinner-container">

<!--    <img v-if="spinnerUrl" :src="require(spinnerUrl)" width="300" height="300"/>-->
    <v-img v-if="spinnerUrl" name="spinnerImg"
           class="custom-spinner-icon"
           alt="spinner-image" :src="spinnerUrl"></v-img>
    <v-progress-circular
        v-else
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
  },
  computed: {
    spinnerUrl() {
      return this.$store.state.app.spinnerUrl || null
    }
  },
  data() {
    return {
    }
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

.custom-spinner-icon {
  max-height: 300px;
  max-width: 300px;
}
</style>
