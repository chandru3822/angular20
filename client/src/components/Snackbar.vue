<template>
  <v-snackbar
      id="app-snackbar"
      v-model="show"
      :bottom="snackbar.y === 'bottom'"
      :left="snackbar.x === 'left'"
      :multi-line="snackbar.mode === 'multi-line'"
      :right="snackbar.x === 'right'"
      :timeout="snackbar.timeout"
      :top="snackbar.y === 'top'"
      :color="snackbar.color"
      :class="snackbar.fontClass"
      :vertical="snackbar.mode === 'vertical'"
  >
    {{ snackbar.text }}
    <template v-slot:action="{ attrs }">
      <v-btn text v-bind="attrs"
             @click="show = false">
        <v-icon color="secondary">clear</v-icon>
      </v-btn>
    </template>
  </v-snackbar>
</template>

<script>
  export default {
    name: 'Snackbar',
    props: {},
    data() {
      return {
        snackbar: {},
        show: false
      }
    },
    created() {
      this.$store.subscribe((mutation, state) => {
        if (mutation.type === "SHOW_SNACK") {
          this.snackbar = state.app.snack
          this.show = true
        }
      });
    },
  }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
#app-snackbar {
  z-index: 1002 !important;
}
</style>
