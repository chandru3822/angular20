<script setup>
/*
*@name Location
*@author jess
*@date 5/31/24
*
*@description
*
*/
import InsertLocationWidget from "@/views/blueraven/settings/proposalDesigner/panel/LocationSelectorWidget.vue";
import {ref} from "vue";

const props = defineProps({
  existingBlocks:Array,
})
const location = ref(null)
const relativeBlock = ref(null)

const emit = defineEmits(['selectLocation', 'selectRelativeBlock'])
const LocationEnum = Object.freeze({
  FIRST:{
    index: 0,
    id: 'first',
    name: 'First'
  },
  BEFORE:{
    index: 0,
    id: 'before-block',
    name: 'Before Block'
  },

})
const selectLocation = (location) => {
  emit('selectLocation', location)
}

</script>

<template>
  <v-card flat class="text-left px-3" color="transparent">
    <v-card-title class="px-0 pt-0">Location</v-card-title>
    <InsertLocationWidget attr="pageLocation" :existing-blocks="existingBlocks" @input="selectLocation"/>
  <v-card flat color="transparent" v-if="location === 1 || location === 2">

  </v-card>
  </v-card>
</template>

<style scoped lang="scss">

</style>
