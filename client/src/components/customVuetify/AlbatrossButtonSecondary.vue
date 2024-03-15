<script setup>
/*
*@name AlbatrossButtonSecondary
*@author jess
*@date 3/15/24
*
*@description
* A pre-made secondary button,
*  so we don't have to style the Albatross button every time we want a cancel button
* Sets the variant to text
* Defaults the text to 'Cancel' (can be overwritten)
* Passes through a limited selection of Albatross Button props:
*   - text
*   - color
*   - disabled
*   - icon
*   - prependIcon
*   - appendIcon
*   - size
*   - hideTextOnMobile
*
*/
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";
import {defineProps} from "vue";

const props = defineProps({
  text: {
    type: String,
    default: 'Cancel'
  },
  color: {
    type: String,
    default: 'primary'
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
  }
})
</script>

<template>
<AlbatrossButton variant="text"
                 :text="text"
                 :disabled="disabled"
                 :icon="icon"
                 :prepend-icon="prependIcon"
                 :append-icon="appendIcon"
                 :size="size"
                 :hide-text-on-mobile="hideTextOnMobile"
                 @click="$emit('click')">
<slot/>
</AlbatrossButton>
</template>

<style scoped lang="scss">

</style>
