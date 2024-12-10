<script setup>
/*
*@name EditCapacityItem
*@author jess
*@date 12/3/24
*
*@description
*
*/
import {toRefs} from "vue";
const props = defineProps({
  maxCapacity: Number,
  booked: Number
})
const { maxCapacity } = toRefs(props)


const capacityRule = (value) => {
  return value >= props.booked
}
const positiveCapacity = (value) => {
  return value > 0
}

</script>

<template>
  <div class="capacity-booked-grid">
  <div class="capacity-col edit-mode label-medium grey--text text--darken-2 d-flex justify-center align-center" :class="{'capacity-exceeded': !capacityRule(maxCapacity)}">
    <a-text-field :value="maxCapacity"
                  type="number" placeholder="0"
                  @input="v => $emit('input', v)"
                  :rules="[capacityRule, positiveCapacity]"/>
  </div>
  <div class="booked-col edit-mode label-medium grey--text text--darken-2 d-flex justify-center align-center">
    {{ booked }}
  </div>
  </div>
</template>

<style scoped lang="scss">

</style>
