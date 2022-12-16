<template>
  <v-icon @click.stop="">mdi-share-variant</v-icon>
</template>

<script setup>

const props = defineProps({
  smartlist: {
    type: Object,
    required: true
  }
})
</script>

<style scoped lang="scss">
button {
  color: var(--v-primary-base) !important;
}
</style>