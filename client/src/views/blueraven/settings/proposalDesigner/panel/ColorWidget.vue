<template>
  <div>
    <v-subheader class="pl-0">
      <slot name="title">Color</slot>
    </v-subheader>
    <!--    TODO: don't automatically set color -->
    <v-color-picker v-model="color" @update:color="onChange" />
  </div>
</template>
<script>
import debounce from 'lodash.debounce'

export default {
  props: {
    value: {
      type: String,
      default: '#000000'
    },
    attr: {
      type: String,
      default: 'color'
    }
  },
  data() {
    return {
      color: ''
    }
  },
  watch: {
    value: {
      immediate: false,
      handler: function(newVal, oldVal) {
        this.color = newVal
      }
    }
  },
  methods: {
    _emitter: debounce(function(val) {
      if (val) {
        const color = (typeof val === 'object') ? val?.hexa : val
        this.$emit('input', { [this.attr]: color })
      }
    }, 250),
    onChange(val) {
      this._emitter(val)
    }
  }
}
</script>
