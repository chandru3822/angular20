<template>
<fragment>
<div>add field here</div>
<div v-for="f in fields">{{ f.name }}</div>
</fragment>
</template>

<script setup>
import { Fragment } from 'vue-frag'

const props = defineProps({
  fields: {
    type: Array,
    required: true
  },
  availableFields: {
    type: Array,
    required: true
  }
})
</script>

<style scoped lang="scss">

</style>