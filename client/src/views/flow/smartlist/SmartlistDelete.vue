<template>
<a-btn
  @click.native.stop="showDialog = true"
  :icon="!showText"
  :variant="showText ? 'text' : ''"
  class="pa-5"
  :disabled="!smartlistId || disabled"
>
  <template #default>
    <v-icon>mdi-delete</v-icon>
    <span v-if="showText">Delete</span>

    <ConfirmationDialog
      v-if="showDialog"
      :parent-close="true"
      :open-dialog="showDialog"
      @confirm="deleteSmartlist"
      @close-dialog="showDialog = false"
    >
      Do you want to delete this smartlist?
    </ConfirmationDialog>
  </template>
</a-btn>
</template>

<script setup>
import { deleteRequest, logError } from '@/helpers/helpers'
import { getCurrentInstance, ref } from 'vue'
import ConfirmationDialog from '@/components/ConfirmationDialog.vue'
import { useAppStore } from '@/stores/AppStore.js'

const props = defineProps({
  smartlistId: {
    required: true,
    validator(value) {
      //'undefined' might be passed in from the editor (due to it being a route param) and we want to allow this

      if (value === null) {
        return false
      }

      if (typeof value === 'undefined') {
        return true
      }

      return Number.isInteger(value)
    }
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

const emit = defineEmits(['deleted'])
let showDialog = ref(false)
const appStore = useAppStore()

let deleteSmartlist = async () => {

  try {
    appStore.loading = true
    await deleteRequest(`/smartlist/${props.smartlistId}`)
	appStore.showSnack('SUCCESS', 'Smartlist Deleted')
    emit('deleted')
  } catch (e) {
    logError(e)
	appStore.showSnack('ERROR', 'Unable to delete smartlist')
  } finally {
    appStore.loading = false
    showDialog.value = false
  }
}
</script>

<style scoped lang="scss">
button {
  color: var(--v-primary-base) !important;
}
</style>