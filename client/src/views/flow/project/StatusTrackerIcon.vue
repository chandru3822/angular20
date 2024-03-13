<template>
  <AlbatrossButton
      height="28px"
      width="28px"
      :activation-handler="on"
      :class="{'not-clickable': !clickable }"
      :html-style="`background-color: ${currentStatusId === milestone.id ? 'var(--v-primary-lighten5)' : milestone.btnColor}`"
      :variant="currentStatusId !== milestone.id && milestone.btnColor === '#F5F5F5' ? 'outlined' : 'plain'"
      :elevation="0"
      :color="milestone.iconColor"
      size="small"
      icon
  >
    <template #default>
      <v-icon size="16" :color="currentStatusId  === milestone.id ? 'white' : milestone.iconColor">
        {{milestone.iconTag || 'blank'}}
      </v-icon>
    </template>
  </AlbatrossButton>
</template>

<script setup>
//NOTE: In the albatross btn, the only thing the :color="milestone.iconColor"
// is used for is making the outline color correct when needed

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
