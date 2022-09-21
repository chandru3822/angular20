<template>
  <div>
    <v-subheader class="pl-0">{{label}} - {{size}}</v-subheader>
    <div class="d-flex flex-row align-end">
      <v-slider
        class="flex-grow-1 flex-shrink-0"
        dense
        thumb-label
        v-model="size"
        @change="onChange"
        :max="max"
        :min="min"
      />
    </div>
  </div>
</template>
<script>
export default {
  props: {
    label: {
      type: String,
      required: true
    },
    attr: {
      type: String,
      required: true
    },
    value: {
      type: String,
      default: '0px'
    },
    min: {
      type: Number,
      default: 0
    },
    max: {
      type: Number,
      default: 50
    }
  },
  watch: {
    value: {
      immediate: true,
      handler: function(newVal) {
        const args = newVal
          ?.split(/(\d+)/)
          ?.filter(x => x !== '')

        if (args?.length === 2) {
          this.size = args[0]
          this.unit = args[1]
        }
      }
    }
  },
  data() {
    return {
      unit: 'px',
      size: 0,
      units: ['px']
    }
  },
  methods: {
    onChange() {
      this.$emit('input', { [this.attr]: `${this.size}${this.unit}` })
    }
  }
}
</script>
