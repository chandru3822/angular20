<template>
  <v-text-field
                :placeholder="placeholder"
                :value="value"
                :type="type"
                :id="id"
                ref="albatrossTextField"
                :prepend-icon="prependIcon"
                :prepend-inner-icon="prependInnerIcon"
                :append-icon="appendInnerIcon"
                :append-outer-icon="appendIcon"
                :clearable="clearable"
                v-on="$listeners"
                :hint="hint"
                :single-line="singleLine"
                :rules="combinedRules"
                :readonly="readonly"
                :disabled="disabled"
                :hide-details="hideDetails"
                :counter="counter"
                :dense="density === 'compact'"
                :color="color"
                :filled="variant === 'filled'"
                :clear-icon="clearIcon"
                :outlined="variant === 'outlined'"
                :solo="variant === 'solo'"
                :maxlength="maxlength"
                :autofocus="autofocus"
                :autocomplete="autocomplete"
                :persistent-hint="persistentHint"
                :class="[customClasses]"
                :label="label"
                v-maska="maskaOptions">

    <template v-for="(index, name) in $scopedSlots" v-slot:[name]="data">
      <slot :name="name" v-bind="data"></slot>
    </template>

    <!--  do not change :slot to use v-slot here until we are in vue3..this is so dumb  -->
    <template v-for="(_, slot) in $slots" :slot="slot">
      <slot :name="slot"></slot>
    </template>

  </v-text-field>
</template>

<script setup>
import {ref, computed} from 'vue'
import constants from '@/helpers/constants'
import { vMaska } from 'maska/vue'
import {objType} from "html2pdf.js/src/utils.js";

// reminder that v-model is sugar syntax for :value="value" @input="v => $emit('input', v)"
const basicRequiredRule = ref(constants.BASIC_REQUIRED_RULE)

const props = defineProps({
  value: [String, Number],
  placeholder: String, //fields without a defined default will default to null
  id: String,
  label: String,
  variant: String,
  hint: String,
  color: String,
  clearIcon: String,
  prependIcon: String,
  prependInnerIcon: String,
  //vue2's appendIconOuter = appendIcon in vue3
  //vue2's appendIcon = appendInnerIcon in vue3
  appendIcon: String,
  appendInnerIcon: String,
  type: {
    type: String,
    default: "text"
  },
  rules: {
    type: Array,
    default: () => ([])
  },
  customClasses: {
    type: String,
    default: ''
  },
  autofocus: Boolean,
  autocomplete: String,
  required: Boolean,
  readonly: Boolean,
  disabled: Boolean,
  clearable: Boolean,
  hideDetails: Boolean,
  singleLine: Boolean,
  persistentHint: Boolean,
  density: String,
  step: Number,
  counter: Boolean,  //this counter and maxlength is not how vuetify defines the props but it is the only combo that actually stops the user from typing when they hit the limit
  maxlength: Number,
  maskaOptions: {
    type: Object,
    default: {mask: null},
  },
})

const albatrossTextField = ref(null)

const combinedRules = computed(() => {
  let tempRules = []
  //set the rules to any rules that were passed in
  tempRules = props.rules
  // if the field is marked as "required" also add the basic required rule
  if(props.required) {
    tempRules = tempRules.concat(basicRequiredRule.value)
  }
  return tempRules
})

const newFocus = () => {
  albatrossTextField.value.focus()
}

defineExpose({
  focus: newFocus
})


</script>

<style lang="scss" scoped>

</style>
