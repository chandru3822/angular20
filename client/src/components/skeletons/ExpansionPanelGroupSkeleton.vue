<template>
  <v-expansion-panels multiple :class="groupClass">
    <ExpansionPanelSkeleton
      v-for="(panel, index) in panels"
      :key="`panel-${index}`"
      v-bind="panel"
    />
  </v-expansion-panels>
</template>

<script setup>
import ExpansionPanelSkeleton from './ExpansionPanelSkeleton.vue'

defineProps({
  panels: {
    type: Array,
    required: true,
    // Expected format: Array of ExpansionPanelSkeleton props
  },
  groupClass: {
    type: String,
    default: ''
  }
})
</script>