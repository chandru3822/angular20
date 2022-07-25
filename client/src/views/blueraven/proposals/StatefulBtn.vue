<template>
  <v-btn
    :color="successful ? 'green' : 'primary'"
    class="text-capitalize"
    :dark="!$attrs.disabled"
    v-bind="$attrs"
    v-on="$listeners"
  >
    <v-icon v-if="successful">mdi-check-circle-outline</v-icon>
    <slot></slot>
  </v-btn>
</template>
<script>

export default {
  props: {
    successful: {
      type: Boolean
    }
  }
}
</script>
