<template>
  <fragment>
    <v-icon @click.stop="showDialog = true">mdi-share-variant</v-icon>

    <ShareDialog
      v-if="showDialog"
      :smartlist="smartlist"
      :open-dialog="showDialog"
      @closed-dialog="showDialog = false"
    />
  </fragment>
</template>

<script setup>
import { Fragment } from 'vue-frag'
import ShareDialog from '@/views/flow/smartlist/ShareDialog.vue'
import { ref } from 'vue'

const showDialog = ref(false)

const props = defineProps({
  smartlist: {
    type: Object,
    required: true
  }
})
</script>

<style scoped lang="scss">
button {
  color: var(--v-primary-base) !important;
}
</style>