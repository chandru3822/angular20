<template>
  <a-btn
      @click.native.stop="showDialog = true"
      :icon="!showText"
      :variant="showText ? 'text' : ''"
      class="pa-5"
      :disabled="disabled"
      color="unset"
  >
  <template #default>
    <v-icon>mdi-share-variant</v-icon>
    <span v-if="showText">Share</span>

    <ShareDialog
        v-if="showDialog"
        :smartlist="smartlist"
        :open-dialog="showDialog"
        @dialog-closed="showDialog = false"
        @updated-public="(isPublic) => emit('updated-public', isPublic)"
        @updated-owner="(newOwner) => emit('updated-owner', newOwner)"
    />
  </template>

  </a-btn>
</template>

<script setup>
import ShareDialog from '@/views/flow/smartlist/ShareDialog.vue'
import { ref } from 'vue'

const showDialog = ref(false)

const props = defineProps({
  smartlist: {
    type: Object,
    required: true
  },
  showText: {
    type: Boolean,
    required: false,
    default: false
  },
  disabled: {
    type: Boolean,
    required: false,
    default: false
  }
})

const emit = defineEmits(['updated-public', 'updated-owner'])
</script>

<style scoped lang="scss">
button {
  color: var(--v-primary-base) !important;
}
</style>