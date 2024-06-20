<template>
  <div>
    <v-subheader class="pl-0 d-flex">
      <slot name="title" class="flex-grow-1">Color</slot>
      <span v-if="editing">
        <a-btn
          v-if="editing"
          variant="text"
          @click="editing = false"
          color="unset"
          text="Cancel"
        ></a-btn>
        <a-btn
          v-if="editing"
          variant="text"
          @click="onDone"
          color="unset"
          text="Done"
          >Done</a-btn
        >
      </span>

      <div
        v-else
        class="color-brick"
        @click="editing = true"
        :style="{ 'background-color': color }"
      >
        <span v-if="color === undefined">NA</span>
      </div>
    </v-subheader>
    <v-color-picker v-if="editing" v-model="color" />
  </div>
</template>
<script setup>
import { toRefs, ref, watch } from 'vue'

const emit = defineEmits(['input'])
const props = defineProps({
  value: {
    type: String
  },
  attr: {
    type: String,
    default: 'color'
  }
})

const { value, attr } = toRefs(props)
const editing = ref(false)
const color = ref(undefined)

watch(value, (newValue, oldValue) => {
  color.value = newValue
})

const onDone = () => {
  editing.value = false
  const localColor =
    typeof color.value === 'object' ? color.value?.hexa : color.value
  emit('input', { [attr.value]: localColor })
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
