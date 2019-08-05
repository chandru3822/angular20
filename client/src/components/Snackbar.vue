<template>
  <v-snackbar
      v-model="snackbar.enabled"
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
    <v-btn text
           @click="snackbar.enabled = false">
      <v-icon color="secondary">clear</v-icon>
    </v-btn>
  </v-snackbar>
</template>

<script>
  export default {
    name: 'Snackbar',
    props: {
      snackbar: Object
    }
  }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">

</style>
