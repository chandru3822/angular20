<template>
  <v-text-field
                :placeholder="placeholder"
                :value="value"
                :type="type"
                :clearable="clearable"
                @input="v => $emit('input', v)"
                :rules="combinedRules"
                :readonly="readonly"
                :disabled="disabled"
                :class="[customClasses]"
                :label="label">
  </v-text-field>
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
  required: {
    type: Boolean,
    default: false
  },
  readonly: {
    type: Boolean,
    default: false
  },
  disabled: {
    type: Boolean,
    default: false
  },
  clearable: {
    type: Boolean,
    default: false
  },
  step: Number
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
