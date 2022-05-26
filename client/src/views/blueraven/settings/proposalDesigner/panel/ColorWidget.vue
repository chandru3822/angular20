<template>
  <div>
    <v-subheader class="pl-0 d-flex">
      <slot name="title" class="flex-grow-1">Color</slot>
      <span v-if="editing">
        <v-btn v-if="editing" text @click="editing = false">Cancel</v-btn>
        <v-btn v-if="editing" text @click="onDone">Done</v-btn>
      </span>

      <div v-else class="color-brick" @click="editing = true" :style="{'background-color' : color }" >
        <span v-if="color === undefined">NA</span>
      </div>
    </v-subheader>
    <v-color-picker v-if="editing" v-model="color" />
  </div>
</template>
<script>
export default {
  props: {
    value: {
      type: String
    },
    attr: {
      type: String,
      default: 'color'
    }
  },
  data() {
    return {
      editing: false,
      color: undefined
    }
  },
  watch: {
    value: {
      handler: function(newVal) {
        this.color = newVal
      }
    }
  },
  methods: {
    onDone() {
      this.editing = false
      const color = (typeof this.color === 'object') ? this.color?.hexa : this.color
      this.$emit('input', { [this.attr]: color })
    }
  }
}
</script>

<style lang="scss" scoped>
.color-brick {
  height: 25px;
  width: 50px;
  border: 1px solid #ccc;
  cursor: pointer;
  display: flex;
  justify-content: center;
}
</style>
