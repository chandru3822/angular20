<template>
  <a-btn
    :class="stateClass"
    :disabled="currentState === 'DISABLED'"
    v-bind="$attrs"
    :activation-handler="$listeners"
  >
    <template #default>
      <v-progress-circular indeterminate :size="20" v-if="loading" />
      <v-icon v-if="currentState === 'SUCCESS'"
        >mdi-check-circle-outline</v-icon
      >
      <slot v-bind:currentState="currentState"></slot>
    </template>
  </a-btn>
</template>
<script setup>
import { toRefs, computed } from 'vue'

const props = defineProps({
  loading: {
    type: Boolean,
    default: false
  },
  disabled: {
    type: Boolean
  },
  error: {
    type: Boolean
  },
  successful: {
    type: Boolean
  }
})
const { loading, disabled, error, successful } = toRefs(props)

const STATE_CLASS = {
  DISABLED: 'state-default',
  ERROR: 'state-error',
  SUCCESS: 'state-success',
  DEFAULT: 'state-default'
}

const currentState = computed(() => {
  if (disabled.value !== undefined && disabled.value === true) {
    return 'DISABLED'
  }
  if (error.value !== undefined && error.value === true) {
    return 'ERROR'
  }
  if (successful.value !== undefined && successful.value === true) {
    return 'SUCCESS'
  }
  return 'DEFAULT'
})
const stateClass = computed(() => {
  return STATE_CLASS[currentState.value]
})
</script>
<style scoped lang="scss">
.state-default {
  background-color: var(--v-primary-base) !important;
  border-color: var(--v-primary-base) !important;
}

.state-success {
  background-color: var(--v-success-lighten1) !important;
  border-color: var(--v-success-lighten1) !important;
}

.state-error {
  background-color: var(--v-error-base) !important;
  border-color: var(--v-error-base) !important;
}
</style>
