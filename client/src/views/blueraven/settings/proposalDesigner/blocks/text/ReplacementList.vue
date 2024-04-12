<template>
  <div class="items">
    <template v-if="items.length">
      <button
        class="item"
        :class="{ 'is-selected': index === selectedIndex }"
        :key="index"
        v-for="(item, index) in items"
        @click.stop.prevent="selectItem(index)"
      >
        {{ item }}
      </button>
    </template>
    <div class="item" v-else>No result</div>
  </div>
</template>

<script setup>
import { toRefs, ref, watch } from 'vue'

const props = defineProps({
  items: {
    type: Array,
    required: true
  },

  command: {
    type: Function,
    required: true
  }
})
const { items } = toRefs(props)

const selectedIndex = ref(0)
watch(items, async () => {
  selectedIndex.value = 0
})

const onKeyDown = ({ event }) => {
  if (event.key === 'ArrowUp') {
    upHandler()
    return true
  }

  if (event.key === 'ArrowDown') {
    downHandler()
    return true
  }

  if (event.key === 'Enter') {
    enterHandler()
    return true
  }

  return false
}
const upHandler = () => {
  selectedIndex.value =
    (selectedIndex.value + items.value?.length - 1) % items.value?.length
}
const downHandler = () => {
  selectedIndex.value = (selectedIndex.value + 1) % items.value?.length
}
const enterHandler = () => {
  selectItem(selectedIndex.value)
}
const selectItem = (index) => {
  const item = items.value[index]
  if (item) {
    props.command({ id: item })
  }
}

defineExpose({
  onKeyDown
})
</script>

<style lang="scss">
.items {
  padding: 0.2rem;
  position: relative;
  border-radius: 0.5rem;
  background: #fff;
  color: rgba(0, 0, 0, 0.8);
  overflow: hidden;
  font-size: 0.9rem;
  box-shadow: 0 0 0 1px rgba(0, 0, 0, 0.05), 0 10px 20px rgba(0, 0, 0, 0.1);
}

.item {
  display: block;
  margin: 0;
  width: 100%;
  text-align: left;
  background: transparent;
  border-radius: 0.4rem;
  border: 1px solid transparent;
  padding: 0.2rem 0.4rem;

  &.is-selected {
    border-color: #000;
  }
}
</style>
