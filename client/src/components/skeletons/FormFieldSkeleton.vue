<template>
  <v-skeleton-loader
    :type="type"
    :width="width"
    :height="height"
    :class="customClass"
  ></v-skeleton-loader>
</template>

<script setup>
defineProps({
  type: {
    type: String,
    default: 'text',
    validator: value => [
      'text', 
      'button', 
      'list-item', 
      'list-item-two-line', 
      'list-item-three-line',
      'card',
      'chip',
      'divider'
    ].includes(value)
  },
  width: {
    type: [String, Number],
    default: undefined
  },
  height: {
    type: [String, Number],
    default: undefined
  },
  customClass: {
    type: String,
    default: ''
  }
})
</script>