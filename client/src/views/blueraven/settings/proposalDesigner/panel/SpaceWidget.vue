<template>
  <div>
    <v-btn-toggle v-model="toggle">
      <v-btn text small value="all">All</v-btn>
      <v-btn text small value="hv">H/V</v-btn>
      <v-btn text small value="custom">Custom</v-btn>
    </v-btn-toggle>

    <div v-if="toggle === 'all'">
      <size-widget label="All" attr="all" :value="all" :min="min" :max="max" @input="onChange" />
    </div>
    <div v-if="toggle === 'hv'">
      <size-widget label="Vertical" attr="vertical" :value="vertical" :min="min" :max="max" @input="onChange" />
      <size-widget label="Horizontal" attr="horizontal" :value="horizontal" :min="min" :max="max" @input="onChange" />
    </div>
    <div v-if="toggle === 'custom'">
      <size-widget label="Top" attr="top" :value="top" :min="min" :max="max" @input="onChange" />
      <size-widget label="Right" attr="right" :value="right" :min="min" :max="max" @input="onChange" />
      <size-widget label="Bottom" attr="bottom" :value="bottom" :min="min" :max="max" @input="onChange" />
      <size-widget label="Left" attr="left" :value="left" :min="min" :max="max" @input="onChange" />
    </div>
  </div>

</template>
<script>
import SizeWidget from './SizeWidget.vue'

export default {
  components: { SizeWidget },
  props: {
    value: {
      type: String
    },
    attr: {
      type: String,
      required: true
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
        this.top = null
        this.right = null
        this.bottom = null
        this.left = null
        this.horizontal = null
        this.vertical = null
        this.all = null

        const args = newVal?.split(' ') ?? []
        if (args.length === 0) {
          return
        }

        if (args?.length === 4) {
          this.toggle = 'custom'

          this.top = args[0]
          this.right = args[1]
          this.bottom = args[2]
          this.left = args[3]
        } else if (args?.length === 2) {
          this.toggle = 'hv'

          this.vertical = args[0]
          this.horizontal = args[1]
        } else {
          this.toggle = 'all'

          this.all = args[0]
        }
      }
    }
  },
  data() {
    return {
      all: null,
      horizontal: null,
      vertical: null,
      top: null,
      right: null,
      bottom: null,
      left: null,
      toggle: null
    }
  },
  methods: {
    onChange(updated) {
      Object.keys(updated).forEach(key => {
        this[key] = updated[key]
      })

      let val = ''
      if (this.toggle === 'all') {
        val = this.all
      } else if (this.toggle === 'hv') {
        val = [this.vertical, this.horizontal].map(x => x?.trim()?.length > 1 ? x : '0').join(' ')
      } else if (this.toggle === 'custom') {
        val = [this.top, this.right, this.bottom, this.left].map(x => x?.trim()?.length > 1 ? x : '0').join(' ')
      } else {
        throw new Error('Unknown type')
      }
      this.$emit('input', { [this.attr]: val })
    }
  }
}
</script>
