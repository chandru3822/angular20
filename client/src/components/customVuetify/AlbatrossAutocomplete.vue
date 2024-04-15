<template>
  <v-autocomplete
      :id="id"
      :placeholder="placeholder"
      :value="value"
      :items="items"
      :chips="chips"
      :type="type"
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
      :height="height"
      :hint="hint"
      :single-line="singleLine"
      :search-input.sync="syncSearchInput"
      :rules="combinedRules"
      :readonly="readonly"
      :disabled="disabled"
      :cache-items="cacheItems"
      :hide-details="hideDetails"
      :dense="density === 'compact'"
      :color="color"
      :no-data-text="noDataText"
      :item-disabled="itemDisabled"
      :error="error"
      :errorMessages="errorMessages"
      :clear-icon="clearIcon"
      :filter="filter"
      :filled="variant === 'filled'"
      :outlined="variant === 'outlined'"
      :solo="variant === 'solo'"
      :flat="variant === 'flat'"
      :autofocus="autofocus"
      :full-width="fullWidth"
      :persistent-hint="persistentHint"
      :class="[customClasses]"
      autocomplete="autocomplete"
      :label="label">

<!--  do not change :slot to use v-slot here until we are in vue3..this is so dumb  -->
    <template v-for="(_, slot) in $slots" :slot="slot">
        <slot :name="slot"></slot>
    </template>

    <template v-for="(_, slot) in $scopedSlots" v-slot:[slot]="data">
        <slot :name="slot" v-bind="data"></slot>
    </template>

  </v-autocomplete>
</template>

<script setup>
import {defineProps, ref, computed} from 'vue'
import constants from '@/helpers/constants'

// reminder that v-model is sugar syntax for :value="value" @input="v => $emit('input', v)"
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
  height: [String, Number],
  itemValue: String,
  noDataText: String,
  bgColor: String, //vuetify3 = bg-color, vuetify2 = background-color
  multiple: Boolean,
  returnObject: Boolean,
  autofocus: Boolean,
  fullWidth: Boolean,
  loading: Boolean,
  placeholder: String, //fields without a defined default will default to null
  label: String,
  variant: String,
  hint: String,
  menuProps: [String, Object],
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
  cacheItems: Boolean,
  itemDisabled: String,
  hideNoData: Boolean,
  error: Boolean,
  errorMessages: String,
  searchInput: String,
  filter: Function,
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

//i think this makes it work and not complain about changing values in the child..
const syncSearchInput = ref(props.searchInput)

</script>

<style lang="scss" scoped>

</style>
