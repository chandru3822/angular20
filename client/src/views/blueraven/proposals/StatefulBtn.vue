<template>
  <v-btn
    :color="stateClass"
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
  DISABLED: 'primary',
  ERROR: 'red',
  SUCCESS: 'green',
  DEFAULT: 'primary',
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
