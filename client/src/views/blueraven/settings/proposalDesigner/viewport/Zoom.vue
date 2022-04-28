<template>
  <div class="zoom-control">
    <v-slider
      dense
      max="100"
      min="50"
      thumb-label
      :label="value.toString()"
      :value="value"
      @change="handleChange"
    />
  </div>
</template>
<script>
export default {
  name: 'ZoomControl',
  props: ['value'],
  methods: {
    handleChange(e) {
      this.$emit('input', e)
    },
  },
}
</script>
<style lang="scss" scoped>
.zoom-control{
  user-select: none;
}
</style>
