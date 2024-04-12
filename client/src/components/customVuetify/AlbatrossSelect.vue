<template>
  <v-select
      :id="id"
      :placeholder="placeholder"
      :value="value"
      :items="items"
      :chips="chips"
      :loading="loading"
      :item-text="itemTitle"
      :item-value="itemValue"
      :return-object="returnObject"
      :multiple="multiple"
      :prepend-icon="prependIcon"
      :prepend-inner-icon="prependInnerIcon"
      :append-icon="appendInnerIcon"
      :append-outer-icon="appendIcon"
      :clearable="clearable"
      :menu-props="menuProps"
      v-on="$listeners"
      :hint="hint"
      :single-line="singleLine"
      :rules="combinedRules"
      :readonly="readonly"
      :disabled="disabled"
      :hide-details="hideDetails"
      :dense="density === 'compact'"
      :color="color"
      :no-data-text="noDataText"
      :clear-icon="clearIcon"
      :filled="variant === 'filled'"
      :outlined="variant === 'outlined'"
      :solo="variant === 'solo'"
      :persistent-hint="persistentHint"
      :class="[customClasses]"
      autocomplete="autocomplete"
      prepend-item
      :label="label">


    <template v-for="(index, name) in $scopedSlots" v-slot:[name]="data">
      <slot :name="name" v-bind="data"></slot>
    </template>

  </v-select>
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
  id: String,
  value: [String, Number, Object, Array], //object for when return-object, array for when multiple
  items: {
    type: Array,
    default: () => ([])
  },
  // itemTitle: String, //vuetify3 = item-title, vuetify2 = item-text
  itemTitle: [String, Function], //vuetify3 = item-title, vuetify2 = item-text
  itemValue: String,
  noDataText: String,
  bgColor: String, //vuetify3 = bg-color, vuetify2 = background-color
  multiple: Boolean,
  returnObject: Boolean,
  loading: Boolean,
  placeholder: String, //fields without a defined default will default to null
  label: String,
  variant: String,
  hint: String,
  menuProps: String,
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
  required: Boolean,
  readonly: Boolean,
  disabled: Boolean,
  clearable: Boolean,
  chips: Boolean,
  hideDetails: Boolean,
  singleLine: Boolean,
  persistentHint: Boolean,
  density: String,
  autocomplete: String,
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
