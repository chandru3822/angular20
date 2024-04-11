<template>
  <v-textarea
                :placeholder="placeholder"
                :value="value"
                :type="type"
                :prepend-icon="prependIcon"
                :prepend-inner-icon="prependInnerIcon"
                :append-icon="appendInnerIcon"
                :append-outer-icon="appendIcon"
                :clearable="clearable"
                @change="v => $emit('change', v)"
                v-on="$listeners"
                :hint="hint"
                :auto-grow="autoGrow"
                :autofocus="autofocus"
                :no-resize="noResize"
                :rows="rows"
                :single-line="singleLine"
                :rules="combinedRules"
                :readonly="readonly"
                :disabled="disabled"
                :background-color="bgColor"
                :hide-details="hideDetails"
                :counter="counter"
                :dense="density === 'compact'"
                :color="color"
                :filled="variant === 'filled'"
                :clear-icon="clearIcon"
                :outlined="variant === 'outlined'"
                :solo="variant === 'solo'"
                :maxlength="maxlength"
                :persistent-hint="persistentHint"
                :class="[customClasses]"
                :label="label">
  </v-textarea>
</template>

<script setup>
import {getCurrentInstance, onMounted, defineProps, ref, computed} from 'vue'
import constants from '@/helpers/constants'

// reminder that v-model is sugar syntax for :value="value" @input="v => $emit('input', v)"

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const router = vueInstance.$router
const snackbar = vueInstance.$snackbar

const basicRequiredRule = ref(constants.BASIC_REQUIRED_RULE)

const props = defineProps({
  value: [String, Number],
  placeholder: String, //fields without a defined default will default to null
  label: String,
  variant: String,
  hint: String,
  rows: [ Number, String ],
  color: String,
  clearIcon: String,
  bgColor: String, //vuetify3 = bgColor
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
  autoGrow: Boolean,
  autofocus: Boolean,
  noResize: Boolean,
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
  maxlength: Number
})

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


</script>

<style lang="scss" scoped>

</style>
