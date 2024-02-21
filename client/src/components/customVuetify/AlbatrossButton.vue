<template>
  <v-btn :id="props.id"
         :text="props.variant === 'text'"
         :outlined="props.variant === 'outlined'"
         :loading="props.loading"
         :color="props.color"
         :large="props.size === 'large'"
         :small="props.size === 'small'"
         :class="[{'white--text': !props.variant,
                   'text-capitalize': props.capitalize,
                   'text-lowercase': props.lowerCase},
                  props.customClasses]"
         :to="props.to"
         :type="props.btnType"
         @click="$emit('click')">
    <slot name="default">
      <template>
        <div>
          <v-icon v-if="props.icon && !props.showAlternate" class="mr-1">{{ props.icon }}</v-icon>
          <v-icon v-else-if="props.alternateIcon && props.showAlternate" class="mr-1">{{ props.alternateIcon }}</v-icon>
          <span v-if="!props.hideTextOnMobile">{{ props.showAlternate ? props.alternateText : props.text }}</span>
        </div>
      </template>
    </slot>
  </v-btn>
</template>

<script setup>
import {getCurrentInstance, computed, defineProps, ref} from 'vue'

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const router = vueInstance.$router
const snackbar = vueInstance.$snackbar

const props = defineProps({
  id: String, //fields without a defined default will default to null
  to: String,
  variant: String, //using `variant` to prep for vue3, //i THINK that if there is NOT a variant we need to set it to have white text...but i could be wrong
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
  icon: {
    type: String,
    default: ''
  },
  showAlternate: {
    type: Boolean,
    default: false
  },
  alternateIcon: {
    type: String,
    default: ''
  },
  alternateText: {
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
  capitalize: {
    type: Boolean, //by default a btn's text will be all caps
    default: false
  },
  lowerCase: {
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
