<template>
<fragment>
<div>add field here</div>
<div v-for="r in requirements">{{ r.name }}</div>
</fragment>
</template>

<script setup>
import { Fragment } from 'vue-frag'

const props = defineProps({
  requirements: {
    type: Array,
    required: true
  }
})
</script>

<style scoped lang="scss">

</style>