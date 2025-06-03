<script setup>
import { ref, toRefs, computed, watch } from "vue";

const props = defineProps({
maxCapacity: Number,
booked: Number
})

const emit = defineEmits(['input'])

// Create a local ref for the input value
const localMaxCapacity = ref(props.maxCapacity || 0)

// Watch for prop changes
const { maxCapacity } = toRefs(props)
watch(maxCapacity, (newVal) => {
localMaxCapacity.value = newVal || 0
})

// Validation rules with error messages
const capacityRule = (value) => {
return value >= props.booked || `Capacity must be at least ${props.booked} (current bookings)`
}

const nonNegativeRule = (value) => {
// This prevents negative numbers
return value >= 0
}

// Handle input changes - only emit valid non-negative values
const handleInput = (value) => {
// Handle string, number, or empty input
if (value === '' || value === null || value === undefined) {
localMaxCapacity.value = 0
emit('input', 0)
return
}

const numValue = typeof value === 'string' ? parseInt(value, 10) : value

// Only emit if it's a valid non-negative number
if (!isNaN(numValue) && numValue >= 0) {
localMaxCapacity.value = numValue
emit('input', numValue)
} else if (numValue < 0) {
// Reset to 0 if negative
localMaxCapacity.value = 0
emit('input', 0)
}
}

// Computed property to check if capacity is exceeded
const isCapacityExceeded = computed(() => {
return localMaxCapacity.value < props.booked
})

</script>

<template>
  <div class="capacity-booked-grid">
    <div
      class="capacity-col edit-mode label-medium grey--text text--darken-2 d-flex justify-center align-center"
      :class="{'capacity-exceeded': isCapacityExceeded}"
    >
      <a-text-field
        v-model.number="localMaxCapacity"
        type="number"
        placeholder="0"
        min="0"
        @input="handleInput"
        @blur="handleInput(localMaxCapacity)"
        :rules="[nonNegativeRule, capacityRule]"
      />
    </div>
    <div class="booked-col edit-mode label-medium grey--text text--darken-2 d-flex justify-center align-center">
      {{ booked }}
    </div>
  </div>
</template>

<style scoped lang="scss">
.capacity-exceeded {
  .a-text-field {
    color: var(--error-color, #f44336);
  }
}
</style>
