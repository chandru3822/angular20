<template>
  <AlbatrossButton
      icon
      height="28px"
      width="28px"
      :activation-handler="on"
      :class="{'not-clickable': !clickable }"
      html-style="background-color: #F5F5F5"
      :outlined="currentStatusId !== milestone.id && milestone.btnColor === 'grey'"
      :color="currentStatusId === milestone.id ? 'primary lighten-5' : milestone.btnColor"
      :elevation="0"
      :prepend-icon="milestone.iconTag || 'blank'"
  ></AlbatrossButton>
</template>

<script setup>

import {getRequest,  handleHidingGlobalLoader, logError} from '@/helpers/helpers'
import constants from "@/helpers/constants";
import SpinnerInline from '@/components/SpinnerInline'
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue"
import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const props = defineProps({
  currentStatusId: Number,
  milestone: Object,
  clickable: Boolean,
  on: Object
})
const { currentStatusId, milestone, clickable, on } = toRefs(props)

</script>

<style lang="scss" scoped>

</style>

<style lang="scss">

</style>
