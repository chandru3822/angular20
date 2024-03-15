<template>
  <v-btn :text="props.variant === 'text'"
         :outlined="props.variant === 'outlined'"
         :loading="props.loading"
         :disabled="props.disabled"
         :color="props.color"
         :elevation="props.elevation"
         :icon="props.icon"
         v-on="activationHandler"
         :style="props.htmlStyle"
         :target="props.target"
         :href="props.href"
         :large="props.size === 'large'"
         :small="props.size === 'small'"
         :x-small="size === 'x-small'"
         :class="['text-none',
                  props.customClasses]"
         :to="props.to"
         :type="props.btnType"
         @click="$emit('click')">
    <slot name="default">
      <template>
          <v-icon v-if="props.prependIcon" class="mr-1">{{ props.prependIcon }}</v-icon>
          <span :class="{'hide-sm': props.hideTextOnMobile}">{{ props.text }}</span>
          <v-icon v-if="props.appendIcon" class="ml-3">{{ props.appendIcon }}</v-icon>
      </template>
    </slot>
  </v-btn>
</template>

<script setup>
import {defineProps} from 'vue'

//note in vue3 using the prepend icon you can't change its size. so for now if the size of the icon is custom, then a default template must be sent in to override
//note the text-none class means that you dont have to specify casing, just pass the text in the way you want it to appear
const props = defineProps({
  to: String, //fields without a defined default will default to null
  variant: String, //using `variant` to prep for vue3, if there is not a variant set it will default to null which is why the text color is set to white if there is no variant
  elevation: Number,
  href: String,
  target: String, //pretty sure this prop is gone in v3
  htmlStyle: String, //style was a reserved word...only seen this used to set a max width so far. in v3 there is an option for that so style should go away
  htmlStyleObject: String, //style was a reserved word...only seen this used to set a max width so far. in v3 there is an option for that so style should go away
  activationHandler: Object,
  text: {
    type: String,
    default: ''
  },
  color: {
    type: String,
    default: 'primary'
  },
  loading: {
    type: Boolean,
    default: false
  },
  disabled: {
    type: Boolean,
    default: false
  },
  icon: {
    type: Boolean,
    default: false
  },
  prependIcon: {  //using `prependIcon` to prep for vue3
    type: String,
    default: ''
  },
  appendIcon: { //using `appendIcon` to prep for vue3
    type: String,
    default: ''
  },
  size: {
    type: String,
    default: 'default'
  },
  hideTextOnMobile: {
    type: Boolean,
    default: false
  },
  customClasses: {
    type: String,
    default: ''
  },
  btnType: {
    type: String,
    default: 'button'
  }
})

</script>

<style lang="scss" scoped>

</style>
