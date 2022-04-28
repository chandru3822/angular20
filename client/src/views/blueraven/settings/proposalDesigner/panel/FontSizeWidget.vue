<template>
  <div>
    <v-subheader class="pl-0">
      Font Size
    </v-subheader>
    <div class="d-flex flex-row align-end">
      <v-slider
        class="flex-grow-1 flex-shrink-0"
        dense
        thumb-label
        v-model="size"
        @change="onChange"
        max="50"
        min="10"
      />
    </div>
  </div>
</template>
<script>
export default {
  props: {
    value: {
      type: String,
      default: '10px'
    }
  },
  watch: {
    value: {
      immediate: true,
      handler: function(newVal) {
        const args = newVal
          ?.split(/(\d+)/)
          ?.filter(x => x !== '')

        if (args.length === 2) {
          this.size = args[0]
          this.unit = args[1]
        }
      }
    }
  },
  data() {
    return {
      unit: 'px',
      size: 10,
      units: ['px']
    }
  },
  methods: {
    onChange() {
      this.$emit('input', { fontSize: `${this.size}${this.unit}` })
    }
  }
}
</script>
