<template>
  <v-btn
    :class="stateClass"
    :disabled="currentState === 'DISABLED'"
    :dark="!disabled"
    v-bind="$attrs"
    v-on="$listeners"
  >
    <v-progress-circular indeterminate :size="20" v-if="loading" />
    <v-icon v-if="currentState === 'SUCCESS'">mdi-check-circle-outline</v-icon>
    <slot v-bind:currentState="currentState"></slot>
  </v-btn>
</template>
<script>

const STATE_CLASS = {
  DISABLED: 'state-default',
  ERROR: 'state-error',
  SUCCESS: 'state-success',
  DEFAULT: 'state-default',
}

export default {
  props: {
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
  },
  computed: {
    currentState() {
      if (this.disabled !== undefined && this.disabled === true) {
        return 'DISABLED'
      }
      if (this.error !== undefined && this.error === true) {
        return 'ERROR'
      }
      if (this.successful !== undefined && this.successful === true) {
        return 'SUCCESS'
      }
      return 'DEFAULT'
    },
    stateClass(){
      return STATE_CLASS[this.currentState]
    }
  }
}
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
